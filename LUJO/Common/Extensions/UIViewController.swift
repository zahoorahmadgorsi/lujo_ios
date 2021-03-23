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
//        let userAttributes = ICMUserAttributes()
//        userAttributes.customAttributes = ["sales_force_yacht_request_id": 1234]
//        Intercom.updateUser(userAttributes)
        //https://developers.intercom.com/installing-intercom/docs/ios-configuration
        if let user = LujoSetup().getLujoUser(), user.id > 0 {
            Intercom.logEvent(withName: "custom_request", metaData:[
                        "sales_force_yacht_intent_id": 123456
                        ,"user_id":user.id])
        }
        Intercom.presentMessageComposer(message)
    }
}
