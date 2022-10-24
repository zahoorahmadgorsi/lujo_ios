import IQKeyboardManagerSwift
import SwiftEntryKit
import UIKit
import SwiftMessages

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
    
    func showInformationPopup(withTitle title: String, message: String, btnTitle: String = "Dismiss" ,  btnTapHandler: (()->Swift.Void)? = nil) {
        showCardAlertWith(title: title, body: message, buttonTitle: btnTitle, cancelButtonTitle: nil, buttonTapHandler:btnTapHandler)
    }
    
    func activateKeyboardManager() {
        IQKeyboardManager.shared.enable = true
    }
    
    func showInformationPopup(){
        showInformationPopup(withTitle: "Information", message: "24/7 agent chat is only available to Lujo members. Please upgrade to enjoy full benefits of Lujo.", btnTitle: "Upgrade" , btnTapHandler: { () in
            if let user = LujoSetup().getLujoUser(), user.id.count > 0 {
                let userFullname = "\(user.firstName) \(user.lastName)"
                let hasMembership = LujoSetup().getLujoUser()?.membershipPlan ?? nil != nil
                var paymentType = MembershipType.none
                
                if let isContain = LujoSetup().getLujoUser()?.membershipPlan?.accessTo.contains(where: {$0.caseInsensitiveCompare("dining") == .orderedSame}), isContain == true{
                    paymentType = .dining
                }else{ //if let isContain = LujoSetup().getLujoUser()?.membershipPlan?.target.contains(where: {$0.caseInsensitiveCompare("dining") == .orderedSame}){
                    paymentType = .all
                }

                let viewController = MembershipViewControllerNEW.instantiate(userFullname: userFullname
                                                                             , screenType: hasMembership ? .viewMembership : .buyMembership
                                                                             , paymentType: paymentType)
                let navController = UINavigationController(rootViewController: viewController)
                self.present(navController, animated: true)
            }
        })
    }
    
    var isModal: Bool {
        let presentingIsModal = presentingViewController != nil
        let presentingIsNavigation = navigationController?.presentingViewController?.presentedViewController == navigationController
        let presentingIsTabBar = tabBarController?.presentingViewController is UITabBarController
        return presentingIsModal || presentingIsNavigation || presentingIsTabBar
    }
    
    func updateTitleView(title: String, subtitle: String?, baseColor: UIColor = .white) {
        
        let titleLength = 35
        let titleLabel = UILabel(frame: CGRect(x: 0, y: -2, width: 0, height: 0))
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = baseColor
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.text = title.count > titleLength ? String(title.prefix(titleLength)) + ".." : title
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.sizeToFit()
        
        let subtitleLabel = UILabel(frame: CGRect(x: 0, y: 18, width: 0, height: 0))
        subtitleLabel.textColor = baseColor.withAlphaComponent(0.95)
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        if let subTitle = subtitle{
            subtitleLabel.text = subTitle.count > titleLength ? String(subTitle.prefix(titleLength)) + ".." : subTitle
    //        subtitleLabel.text = subtitle
        }

        subtitleLabel.textAlignment = .center
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.sizeToFit()
        
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: max(titleLabel.frame.size.width, subtitleLabel.frame.size.width), height: 30))
        titleView.addSubview(titleLabel)
        if subtitle != nil {
            titleView.addSubview(subtitleLabel)
        } else {
            titleLabel.frame = titleView.frame
        }
        let widthDiff = subtitleLabel.frame.size.width - titleLabel.frame.size.width
        if widthDiff < 0 {
            let newX = widthDiff / 2
            subtitleLabel.frame.origin.x = abs(newX)
        } else {
            let newX = widthDiff / 2
            titleLabel.frame.origin.x = newX
        }
        
        navigationItem.titleView = titleView
    }
    
    func showInputDialog(title:String? = nil,
                             subtitle:String? = nil,
                             actionTitle:String? = "Done",
                             cancelTitle:String? = "Cancel",
                             inputText:String? = nil,
                             inputPlaceholder:String? = nil,
                             inputKeyboardType:UIKeyboardType = UIKeyboardType.default,
                             cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
                             actionHandler: ((_ text: String?) -> Void)? = nil) {
            
            let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
            alert.addTextField { (textField:UITextField) in
                textField.placeholder = inputPlaceholder
                textField.keyboardType = inputKeyboardType
                textField.text = inputText
            }
            alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (action:UIAlertAction) in
                guard let textField =  alert.textFields?.first else {
                    actionHandler?(nil)
                    return
                }
                actionHandler?(textField.text)
            }))
            alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler))
            
            self.present(alert, animated: true, completion: nil)
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

extension UIScrollView {
    func scrollToTop() {
        let desiredOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(desiredOffset, animated: true)
   }
}
