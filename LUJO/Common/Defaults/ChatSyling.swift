//import ZDCChat
import Foundation
import UIKit

class ChatStyling: NSObject {
    private static let whiteTxtColor = UIColor(named: "White Text")
    private static let darkBackColor = UIColor(named: "Navigation Bar")
    
    private static func styleNavigationBar(_ whiteTxtColor: UIColor?, _ darkBackColor: UIColor?) {
        // Navigation Bar
        UINavigationBar.appearance().tintColor = whiteTxtColor
        UINavigationBar.appearance().barTintColor = darkBackColor
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: whiteTxtColor!,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .regular),
        ]
    }

    class func appyStyling() {
        styleNavigationBar(whiteTxtColor, darkBackColor)
    }
}
