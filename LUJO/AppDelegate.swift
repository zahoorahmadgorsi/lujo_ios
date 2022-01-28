import FirebaseCrashlytics
import IQKeyboardManagerSwift
import UIKit
import UserNotifications
import Intercom
import Firebase
import Mixpanel
import OneSignal
//import Delighted

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    var windowRouter: Router!
    var navigationController: UINavigationController!
    var isBackground: Bool!

    func application(_: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        isBackground = false

        window = UIWindow(frame: UIScreen.main.bounds)
        windowRouter = Router(mainVC: window!)
        
        UIApplication.shared.registerForRemoteNotifications()
        
        LujoSetup().getSetup()
        
        if LujoSetup().getCurrentUser() == nil || !(LujoSetup().getCurrentUser()?.approved ?? false) {
            UserDefaults.standard.set(true, forKey: "isFirstTimeLoggedOut")
            windowRouter.navigate(from: "/", data: [:])
        } else {
            if UserDefaults.standard.bool(forKey: "isFirstTimeLoggedOut") {
                UserDefaults.standard.set(true, forKey: "showWelcome")
                window?.rootViewController = MainTabBarController.instantiate()
            } else {
                LujoSetup().deleteCurrentUser()
                
                if let userId = LujoSetup().getLujoUser()?.id {
                    removePushToken(userId: userId)
                }
                
                UserDefaults.standard.set(true, forKey: "isFirstTimeLoggedOut")
                
                windowRouter.navigate(from: "/", data: [:])
                
            }
        }
        
        window?.makeKeyAndVisible()
        
        FirebaseApp.configure()
        
        IQKeyboardManager.shared.enable = true

        Intercom.setApiKey("ios_sdk-6458822f5722423dbb6aef0b2dd9b0f44a694fe3", forAppId:"vc290ayr")
        
        ChatStyling.appyStyling()

        Mixpanel.initialize(token: "974677a8bc1707f564ce3ac082c3cb62")
        
        // Remove this method to stop OneSignal Debugging
        OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)

        // OneSignal initialization
        OneSignal.initWithLaunchOptions(launchOptions)
        OneSignal.setAppId("eae6e09f-04c0-439f-ac65-6a000e8f77f6")

        // promptForPushNotifications will show the native iOS notification permission prompt.
        // We recommend removing the following code and instead using an In-App Message to prompt for notification permission (See step 8)
        OneSignal.promptForPushNotifications(userResponse: { accepted in
        print("User accepted notifications: \(accepted)")
        })
        
        return true
    }

    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface. applicationDidBecomeActive will never be called if app is in foreground and you have received a push notification
    func applicationDidBecomeActive(_ application: UIApplication) {
//        Delighted.initializeSDK()
        // handle any deeplink
        Deeplinker.checkDeepLink()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        if
            let tabBarController = window?.rootViewController as? MainTabBarController,
            let navigationController = tabBarController.viewControllers?[0] as? UINavigationController,
            let viewController = navigationController.viewControllers[0] as? HomeViewController
        {
            viewController.checkLocationAuthorizationStatus()
        }
    }

    func applicationDidEnterBackground(_: UIApplication) {
        isBackground = true
    }

    // Silent push notifications.
    // when app is running in the background or closed, and there is tap on push notification then this method is called
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        //if app is already in foreground then just check the deep link
        switch UIApplication.shared.applicationState {
        case .background, .inactive:    // background
            print("app is in background")
            break
        case .active:   // foreground
            Deeplinker.checkDeepLink()
            print("app is in foreground")
            break
        default:
            break
        }
        Deeplinker.handleRemoteNotification(userInfo)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken tokenData: Data) {
        let tokenParts = tokenData.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
//        print("Device Token: \(token)")
        Intercom.setDeviceToken(tokenData)
        registerForOurPushService(deviceToken: token)
    }

    func registerForPushNotifications() {
        if let user = LujoSetup().getLujoUser(), user.id > 0 {
            
            setExternalUserId(externalUserId: user.phoneNumber.readableNumber)  //setting external User id as phone number at oneSignal
            
            Mixpanel.mainInstance().identify(distinctId: "\(user.id)")
            
            Intercom.registerUser(withUserId: "\(user.id)")
            
            let userAttributes = ICMUserAttributes()
            userAttributes.name = "\(user.firstName) \(user.lastName)"
            if LujoSetup().getLujoUser()?.membershipPlan == nil {
                if let name = userAttributes.name{
                    userAttributes.name = name + " (Non Member)" //appending non member with the user name if user is free
                }
            }
            userAttributes.email = user.email
            Intercom.updateUser(userAttributes)
        }
        
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in

//                print("Permission granted: \(granted)")

                guard granted else { return }
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
    }
    
    func setExternalUserId(externalUserId:String){
        // Setting External User Id with Callback Available in SDK Version 3.x.x
        OneSignal.setExternalUserId(externalUserId, withSuccess: { results in
        // The results will contain push and email success statuses
        print("External user id update complete with results: ", results!.description)
        // Push can be expected in almost every situation with a success status, but
        // as a pre-caution its good to verify it exists
        if let pushResults = results!["push"] {
            print("Set external user id push status: ", pushResults)
        }
        if let emailResults = results!["email"] {
            print("Set external user id email status: ", emailResults)
        }
        })
    }


    
    func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navController = base as? UINavigationController {
            return getTopViewController(base: navController.visibleViewController)

        } else if let tabController = base as? UITabBarController, let selected = tabController.selectedViewController {
            return getTopViewController(base: selected)

        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }

    func removePushToken(userId: Int) {
        Intercom.logout()
        GoLujoAPIManager().unregisterForOurPushService(userId: String(userId))
    }
    
    func registerForOurPushService(deviceToken: String) {
        guard let userId = LujoSetup().getLujoUser()?.id else {
            print("NO USER ID ERROR!!!")
           return
        }
        
         GoLujoAPIManager().registerForOurPushService(userId: String(userId), deviceToken: deviceToken)
    }
}
