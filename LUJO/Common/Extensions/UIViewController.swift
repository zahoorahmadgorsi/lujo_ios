import IQKeyboardManagerSwift
import SwiftEntryKit
import UIKit
import SwiftMessages
import Intercom

extension UIViewController {
    func canPerformSegue(withIdentifier identifier: String) -> Bool {
        guard let identifiers = value(forKey: "storyboardSegueTemplates") as? [NSObject] else { return false }

        let canPerform = identifiers.contains { (object) -> Bool in
            guard let id = object.value(forKey: "_identifier") as? String else { return false }
            return id == identifier
        }

        return canPerform
    }

    func showErrorPopup(withTitle title: String, error: Error) {
        showCardAlertWith(title: title, body: error.localizedDescription)
    }

    func showInformationPopup(withTitle title: String, message: String) {
        showCardAlertWith(title: title, body: message)
    }
    
    func activateKeyboardManager() {
        IQKeyboardManager.shared.enable = true
    }
    
    func startChatWithInitialMessage(_ message: String? = nil) {
        Intercom.presentMessageComposer(message)
    }
    
    var isModal: Bool {
        let presentingIsModal = presentingViewController != nil
        let presentingIsNavigation = navigationController?.presentingViewController?.presentedViewController == navigationController
        let presentingIsTabBar = tabBarController?.presentingViewController is UITabBarController
        return presentingIsModal || presentingIsNavigation || presentingIsTabBar
    }
}

extension UIApplication
{
    //UIApplication.shared.windows.filter {$0.isKeyWindow}.first
    //class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController?
    class func topViewController(_ base: UIViewController? = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController) -> UIViewController?
    {
        if let nav = base as? UINavigationController
        {
            let top = topViewController(nav.visibleViewController)
            return top
        }

        if let tab = base as? UITabBarController
        {
            if let selected = tab.selectedViewController
            {
                let top = topViewController(selected)
                return top
            }
        }

        if let presented = base?.presentedViewController
        {
            let top = topViewController(presented)
            return top
        }
        return base
    }

}

