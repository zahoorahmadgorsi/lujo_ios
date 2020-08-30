//@testable import LUJO
import UIKit
import XCTest

class RouterShould: XCTestCase {
    func UNtest_present_login_when_main_view_is_ready() {
        let mainVC = UIWindow()
        _ = Router(mainVC: mainVC)

        guard let navigationController = mainVC.rootViewController as? UINavigationController else {
            XCTFail()
            return
        }

        XCTAssertTrue(navigationController.viewControllers[0] is LoginView)
    }

    // TODO: Restore navigation when aviation is finished
    func _test_present_main_screen_when_login_feature_returns_with_success() {
        let mainVC = UIWindow()
        let router = Router(mainVC: mainVC)

        router.navigate(from: "/login", data: ["result": "Success" as AnyObject])

        guard let navigationController = mainVC.rootViewController as? UINavigationController else {
            XCTFail()
            return
        }

        XCTAssertTrue(navigationController.viewControllers[0] is MainScreenView)
    }
}
