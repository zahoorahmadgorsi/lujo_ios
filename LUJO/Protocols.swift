import UIKit

// Basic Wireframe Protocol
protocol WireFrame: class {
    var mainVC: UIWindow? { get }
    func navigate(from: String, data: [String: AnyObject])
}

// Basic Viewable protocol
protocol Viewable {
    func showNetworkActivity()
    func hideNetworkActivity()
    func showError(_ error: Error)
    func showFeedback(_ message: String)
    func showView(_ id: String, data: [String: Any]?)
}

extension Viewable {
    func showNetworkActivity() {}
    func hideNetworkActivity() {}
    func showError(_ error: Error) {}
    func showFeedback(_ message: String) {}
    func showView(_ id: String, data: [String: Any]?) {}
}

// Basic Interactuable protocol
protocol Interactuable {}

// Basic Presentable protocol
protocol Presentable {
    var view: Viewable { get }
    var route: String { get set }
    var router: WireFrame? { get set }
}

protocol ViewResponder {
    // Only needed when presenter manages multiple views
    func update(view: Viewable)
    func navigate(to destination: String)
}

extension ViewResponder {
    func update(view _: Viewable) {}
    func navigate(to destination: String) {}
}

// General App Defaults
protocol AppDefaults {
    func updateDefaults(_ completion: (() -> Void)?)
    func getMembersMargin() -> Double?
    func getNonMembersMargin() -> Double?
    func getCountryCodes() -> [PhoneCountryCode]?
    func getCode(for prefix: String) -> PhoneCountryCode?
}

// General Data Layer
protocol AppDefaultsDataLayer {
    func getDefaults(completion: @escaping ([String: Any], Error?) -> Void)
    func getCountryCodes(completion: @escaping ([PhoneCountryCode], Error?) -> Void)
    func userProfile(for token: String, completion: @escaping (LujoUser?, Error?) -> Void)
    func update(user: LujoUser, image: UIImage, completion: @escaping (Error?) -> Void)
}

// Calendar selection
protocol DateSelectorDelegate: class {
    func selectDates()
}
