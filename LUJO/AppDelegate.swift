import FirebaseCrashlytics
import AVFAudio
//import Crashlytics
//import Fabric
import IQKeyboardManagerSwift
import UIKit
import UserNotifications
import Firebase
import Mixpanel
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    var windowRouter: Router!
    var navigationController: UINavigationController!
    var isBackground: Bool!

    let oneSignalAppId: String = {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "ONE_SIGNAL_APP_ID") as? String else {
            return "eae6e09f-04c0-439f-ac65-6a000e8f77f6"   //BY DEFAULT PRODUCTION APP
        }
        return urlString
    }()
    
    func application(_: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print(launchOptions as Any)
        isBackground = false

        window = UIWindow(frame: UIScreen.main.bounds)
        windowRouter = Router(mainVC: window!)
        
//        //navigatino bar non trasparent
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().backgroundColor = .black
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().backItem?.title = ""
        UIApplication.shared.statusBarStyle = .lightContent
        
        
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
        
        ChatStyling.appyStyling()

        Mixpanel.initialize(token: "974677a8bc1707f564ce3ac082c3cb62", trackAutomaticEvents: false)
        
        //***********
        // ONE SIGNAL
        //***********
        // Remove this method to stop OneSignal Debugging
        OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)
        // OneSignal initialization
        OneSignal.initWithLaunchOptions(launchOptions)
        OneSignal.setAppId(oneSignalAppId)
        print("oneSignalAppId: \(oneSignalAppId)")
        // promptForPushNotifications will show the native iOS notification permission prompt.
        // We recommend removing the following code and instead using an In-App Message to prompt for notification permission (See step 8)
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })
        
        loginToTwilio()
        
        getUnReadPushNotificationsCount()
        
        setAudioMix()
        
        return true
    }

    //if you will mute your video from the app it wont impact other audio/video players running on iphone i.e. apple music etc
    func setAudioMix(){
        do{
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        }catch{
            print("something went wrong")
        }
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

    //How push notification works in simulator https://medium.com/compass-true-north/how-to-ui-test-push-notifications-and-universal-links-in-the-ios-simulator-81cc43b33f81
    // Silent push notifications.
    // when app is running in the background or closed, and there is tap on push notification then this method is called
//    How push notification works in simulator https://medium.com/compass-true-north/how-to-ui-test-push-notifications-and-universal-links-in-the-ios-simulator-81cc43b33f81
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        getUnReadPushNotificationsCount()
        
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
        registerForOurPushService(deviceToken: token)
    }

    func registerForPushNotifications() {
        if let user = LujoSetup().getLujoUser(), user.id.count > 0 {
            
            setExternalUserId(externalUserId: user.phoneNumber.readableNumber)  //setting external User id as phone number at oneSignal
            
            Mixpanel.mainInstance().identify(distinctId: "\(user.id)")
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

    func removePushToken(userId: String) {
        GoLujoAPIManager().unregisterForOurPushService(userId: String(userId))
        ConversationsManager.sharedConversationsManager.shutdown()
    }
    
    func registerForOurPushService(deviceToken: String) {
        guard let userId = LujoSetup().getLujoUser()?.id else {
            print("NO USER ID ERROR!!!")
           return
        }
        
         GoLujoAPIManager().registerForOurPushService(userId: String(userId), deviceToken: deviceToken)
    }
    
    //MARK:- loginToTwilio
    
    func loginToTwilio(){
        //************
        //Chat Manager
        //************
        ConversationsManager.sharedConversationsManager.login(LujoSetup().getLujoUser()?.email ?? ""){ (success) in
            if success {
                print("Twilio: Logged in as \"\(LujoSetup().getLujoUser()?.email ?? "")\"")
            } else {
                print("Twilio: Unable to login")
            }
        }
    }
    
    //this method loads the unread push notifications from the server and set as badge value
    func getUnReadPushNotificationsCount(){
        guard let tabBarController = window?.rootViewController as? UITabBarController else { return }
        GoLujoAPIManager().getUnReadPushNotificationsCount() { count, error in
            guard error == nil else {
                Crashlytics.crashlytics().record(error: error!)
                let error = BackendError.parsing(reason: "Could not obtain the unread push notifications count")
                return
            }
            if let _count = count, _count > 0{
//                print("Twilio: Total UnRead push notification count:\(_count)")
                tabBarController.tabBar.items?[4].badgeValue = _count > 9 ? "9+" : String(_count)
            }else{
                tabBarController.tabBar.items?[4].badgeValue = nil
            }

        }
    }
    
    //used in universal sceheme (info -> URL types)
//    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
//        var alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
//        let okButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
//        alertController.addAction(okButton)
//        let passed = url.absoluteString.components(separatedBy: "://")
//        if passed.count > 1 {
//            alertController.title = passed[1]
////            if let vc = UIApplication.shared.keyWindow?.rootViewController {
//            if let kw = UIApplication.shared.windows.filter({$0.isKeyWindow}).first , let vc = kw.rootViewController{
//                if vc.presentedViewController != nil {
//                    alertController.dismiss(animated: false, completion: {
//                        vc.present(alertController, animated: true, completion: nil)
//                    })
//                } else {
//                    vc.present(alertController, animated: true, completion: nil)
//                }
//            }
//        }
//        return true
//    }
    
    //used in universal linking
//    public func application(_ application: UIApplication,
//                            continue userActivity: NSUserActivity,
//                            restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
    
    public func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        if let url = userActivity.webpageURL {
            print(url)
            var view = url.lastPathComponent
            print(view)
            var parameters: [String: String] = [:]
            URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach {
                parameters[$0.name] = $0.value
            }
            
            print(parameters)
        }
        return true
    }
}
