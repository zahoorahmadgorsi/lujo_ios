import UIKit

typealias LoginInteractorCallback = (String, LoginError?) -> Void
typealias DataLayerCallback = (_ result: String, Error?) -> Void

// View -> Presenter
protocol LoginViewResponder: ViewResponder {
    func doLogin(username: String, password: String) throws
    func doLoginWithOTP(prefix: PhoneCountryCode?, _ number: String?, code: String) throws
    func createAccount(title: UserTitle,
                       firstName: String,
                       lastName: String,
                       email: String, phoneNumber: PhoneNumber) throws
    func verifyCode(_ code: String)
    func requestOTP()
    func requestOTPLogin(prefix: PhoneCountryCode, number: String)
    func requestResendCode()
    func updateUserPhone(oldPrefix: String, oldNumber: String, newPrefix: String, newNumber: String)
    func forgotPassword(for user: String)
    func showHomeScreen()
    func logoutUser()
}

// Presenter -> View
protocol LoginViewProtocol: Viewable {
    var presenter: LoginViewResponder? { get set }

    func hideSplashView()
}

extension LoginViewProtocol {
    func showFeedback(_ message: String) {}
    func showView(_: String, data _: [String: Any]?) {}
    func hideSplashView() {}
}

protocol LoginPresentable: Presentable {
    var presenterView: LoginViewProtocol { get }

    init(view: LoginViewProtocol, interactor: LoginInteractuable)
}

// Presenter -> Interactor
protocol LoginInteractuable {
    func doLogin(username: String, password: String, completion: @escaping LoginInteractorCallback)
    func requestLoginVerificationCode(prefix: PhoneCountryCode, _ number: String, completion: @escaping LoginInteractorCallback)
    func doLoginWithOTP(prefix: String, _ number: String, code: String, completion: @escaping LoginInteractorCallback)
    func createAccount(_ user: LujoUser, completion: @escaping LoginInteractorCallback)
    func requestVerificationCode(completion: @escaping LoginInteractorCallback)
    func verify(with code: String, completion: @escaping LoginInteractorCallback)
    func getUserStatus() -> UserStatus
    func updateUserPhone(oldPrefix: String, oldNumber: String, newPrefix: String, newNumber: String, completion: @escaping LoginInteractorCallback)
    func forgotPassword(for user: String, completion: @escaping LoginInteractorCallback)
    func getUserApproval(completion: @escaping (Bool, Error?) -> Void)
    func logoutUser()
}

// Data layer protocol
protocol LoginDataLayerProtocol {
    func login(username: String, password: String, completionHandler: @escaping DataLayerCallback)
    func loginWithOTP(prefix: String, _ number: String, code: String, completionHandler: @escaping DataLayerCallback)
    func create(user: LujoUser, completionHandler: @escaping DataLayerCallback)
    func requestVerification(for user: LoginUser, withCode code: String, completionHandler: @escaping DataLayerCallback)
    func requestOTP(for user: LoginUser, completionHandler: @escaping DataLayerCallback)
    func requestLoginOTP(prefix: PhoneCountryCode, _ number: String, completionHandler: @escaping DataLayerCallback)
    func update(oldPrefix: String, oldNumber: String, newPrefix: String, newNumber: String, completion: @escaping DataLayerCallback)
    func forgot(user password: String, completion: @escaping DataLayerCallback)
    func userProfile(for token: String, completion: @escaping (LujoUser?, Error?) -> Void)
    func update(user profile: LujoUser, completion: @escaping (Error?) -> Void)
    func approved(user: LoginUser, completion: @escaping (Bool, Error?) -> Void)
}

// Setup Protocol
protocol LoginDataStorable {
    func store(currentUser: LoginUser)
    func getCurrentUser() -> LoginUser?
    func store(userInfo: LujoUser)
    func getLujoUser() -> LujoUser?
    func storeVerificationCode(_ code: String)
    func getVerificationCode() -> String?
    func deleteCurrentUser()
}
