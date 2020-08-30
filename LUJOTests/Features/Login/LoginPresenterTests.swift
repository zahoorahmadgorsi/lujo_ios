@testable import LUJO
import UIKit
import XCTest

private let TEST_TOKEN = "1234567890abcdefghijklmnopqrstuvwxyz"
private let TEST_VERIFICATION_CODE = "1234"
private let TEST_PHONE_NUMBER = "0040 1223 332 23"

class SpyLoginInteractor: LoginInteractuable {
    func logoutUser() {}

    func requestLoginVerificationCode(prefix: PhoneCountryCode, _ number: String, completion: @escaping LoginInteractorCallback) {}
    
    func updateUserPhone(oldPrefix: String, oldNumber: String, newPrefix: String, newNumber: String, completion: @escaping LoginInteractorCallback) {}

    func doLoginWithOTP(prefix: String, _ number: String, code: String, completion: @escaping LoginInteractorCallback) {}

    func getUserApproval(completion: @escaping (Bool, Error?) -> Void) {}

    var invokedDoLogin = false
    var invokedDoLoginCount = 0
    var invokedDoLoginParameters: (username: String, password: String)?
    var invokedDoLoginParametersList = [(username: String, password: String)]()
    var stubbedDoLoginCompletionResult: (String, LoginError?)?

    var invokedCreateAccount = false
    var invokedCreateAccountCount = 0
    var invokedCreateAccountParameter: LujoUser?
    var invokedCreateAccountParametersList = [LujoUser]()
    var stubbedCreateAccountCompletionResult: (String, LoginError?)?

    var invokedRequestVerification = false
    var invokedRequestVerificationCount = 0
    var stubbedRequestVerification: (String, LoginError?)?

    var invokedUpdatePhoneNumber = false
    var invokedUpdatePhoneNumberParameters: String?
    var stubbedUpdatePhoneCompletionResult: (String, LoginError?)?

    func doLogin(username: String, password: String, completion: @escaping LoginInteractorCallback) {
        invokedDoLogin = true
        invokedDoLoginCount += 1
        invokedDoLoginParameters = (username, password)
        invokedDoLoginParametersList.append((username, password))
        if let result = stubbedDoLoginCompletionResult {
            completion(result.0, result.1)
        }
    }

    func createAccount(_ user: LujoUser, completion: @escaping LoginInteractorCallback) {
        invokedCreateAccount = true
        invokedCreateAccountCount += 1
        invokedCreateAccountParameter = user
        invokedCreateAccountParametersList.append(user)

        if let result = stubbedCreateAccountCompletionResult {
            completion(result.0, result.1)
        }
    }

    func requestVerificationCode(completion: @escaping LoginInteractorCallback) {
        invokedRequestVerification = true
        invokedRequestVerificationCount += 1

        if let result = stubbedRequestVerification {
            completion(result.0, result.1)
        }
    }

    func verify(with code: String, completion: @escaping LoginInteractorCallback) {
        // TODO:
    }

    func getUserStatus() -> UserStatus {
        return .noUser
    }

    func updateUserPhone(prefix: PhoneCountryCode, _ number: String, completion: @escaping LoginInteractorCallback) {
        invokedUpdatePhoneNumber = true
        invokedUpdatePhoneNumberParameters = number

        if let result = stubbedUpdatePhoneCompletionResult {
            completion(result.0, result.1)
        }
    }

    func forgotPassword(for user: String, completion: @escaping LoginInteractorCallback) {
        //
    }
}

class SpyLoginViewPresenter: UIViewController, LoginViewProtocol {
    var presenter: LoginViewResponder?
    var interactor: SpyLoginInteractor?

    var invokedShowError = false
    var invokedShowErrorCount = 0
    var invokedShowErrorParameters: Error?
    var invokedShowErrorParametersList = [Error]()

    func showError(_ error: Error) {
        invokedShowError = true
        invokedShowErrorCount += 1
        invokedShowErrorParameters = error
        invokedShowErrorParametersList.append(error)
    }

    var invokedShowView = false
    var invokedShowViewCount = 0
    var invokedShowViewParameter: (String, [String: Any]?)?
    var invokedShowViewParametersList = [(String, [String: Any]?)]()

    func showView(_ id: String, data: [String: Any]?) {
        invokedShowView = true
        invokedShowViewCount += 1
        invokedShowViewParameter = (id, data)
        invokedShowViewParametersList.append((id, data))
    }

    var invokedShowNA = false
    var invokedShowNABeforeLogin = false
    var invokedShowNABeforeCreateAccount = false
    var invokedShowNACount = 0

    func showNetworkActivity() {
        invokedShowNA = true
        if let _ = self.interactor {
            invokedShowNABeforeLogin = (interactor?.invokedDoLogin == false)
            invokedShowNABeforeCreateAccount = (interactor?.invokedCreateAccount == false)
        }

        invokedShowNACount += 1
    }

    var invokedHideNA = false
    var invokedHideNACount = 0

    func hideNetworkActivity() {
        invokedHideNA = (invokedShowError == false)
        invokedHideNACount += 1
    }

    var invokedShowFeedback = false
    var invokedShowFeedbackParameters: String?

    func showFeedback(_ message: String) {
        invokedShowFeedback = true
        invokedShowFeedbackParameters = message
    }
}

class RouterStub: WireFrame {
    private(set) var mainVC: UIKit.UIWindow?
    var invokedMainVCGetter = false
    var invokedMainVCGetterCount = 0
    var invokedNavigate = false
    var invokedNavigateCount = 0
    var invokedNavigateParameters: (from: String, data: [String: AnyObject])?
    var invokedNavigateParametersList = [(from: String, data: [String: AnyObject])]()

    func navigate(from: String, data: [String: AnyObject]) {
        invokedNavigate = true
        invokedNavigateCount += 1
        invokedNavigateParameters = (from, data)
        invokedNavigateParametersList.append((from, data))
    }
}

class LoginPresenterShould: XCTestCase {
    let FIRSTNAME = "First"
    let LASTNAME = "Last"
    let USERNAME = "username@example.com"
    let PHONE = "440192019192"
    let PASSWORD = "password"

    var presenter: LoginPresenter!
    var interactor: SpyLoginInteractor!
    var view: SpyLoginViewPresenter!

    override func setUp() {
        super.setUp()
        interactor = SpyLoginInteractor()
        view = SpyLoginViewPresenter()
        presenter = LoginPresenter(view: view, interactor: interactor)
    }

    override func tearDown() {
        presenter = nil
        super.tearDown()
    }

    func test_set_presenter_as_view_presenter() {
        guard let viewDelegate = view.presenter as? LoginPresenter else {
            XCTFail()
            return
        }

        XCTAssertTrue(viewDelegate === presenter)
    }

    func test_fail_when_login_is_called_with_missing_username() {
        XCTAssertThrowsError(try presenter.doLogin(username: "", password: PASSWORD)) { error in
            XCTAssertEqual(error as? LoginError, LoginError.missingUsername)
        }
    }

    func test_fail_when_login_is_called_with_missing_() {
        XCTAssertThrowsError(try presenter.doLogin(username: USERNAME, password: "")) { error in
            XCTAssertEqual(error as? LoginError, LoginError.missingPassword)
        }
    }

    func test_not_call_show_network_activity_when_paramaters_are_missing() {
        XCTAssertThrowsError(try presenter.doLogin(username: "", password: PASSWORD)) { _ in
            XCTAssertFalse(view.invokedShowNA)
        }
        XCTAssertThrowsError(try presenter.doLogin(username: USERNAME, password: "")) { _ in
            XCTAssertFalse(view.invokedShowNA)
        }
    }

    func test_call_show_network_activity_before_interactor_is_called() {
        view.interactor = interactor

        try! presenter.doLogin(username: USERNAME, password: PASSWORD)

        XCTAssertTrue(view.invokedShowNABeforeLogin)
        XCTAssertTrue(interactor.invokedDoLogin)
    }

    func test_call_hide_network_activity_when_interactor_returns_from_login_before_show_error() {
        interactor.stubbedDoLoginCompletionResult = ("", LoginError.errorLogin(description: "Generic error"))

        try! presenter.doLogin(username: USERNAME, password: PASSWORD)

        XCTAssertTrue(view.invokedHideNA)
        XCTAssertTrue(view.invokedShowError)
    }

    func test_interactor_login_is_called_when_login_is_requested_with_username_and_password() {
        try! presenter.doLogin(username: USERNAME, password: PASSWORD)

        XCTAssertTrue(interactor.invokedDoLogin)
        XCTAssertEqual(interactor.invokedDoLoginParameters!.username, USERNAME)
        XCTAssertEqual(interactor.invokedDoLoginParameters!.password, PASSWORD)
    }

    func test_raise_the_error_to_view_when_login_interactor_returns_error() {
        interactor.stubbedDoLoginCompletionResult = ("", LoginError.errorLogin(description: "Generic error"))

        try! presenter.doLogin(username: USERNAME, password: PASSWORD)

        XCTAssertTrue(view.invokedShowError)
    }

    func test_inform_the_router_when_a_login_result_is_positive() {
        interactor.stubbedDoLoginCompletionResult = (TEST_TOKEN, nil)

        let router = RouterStub()
        presenter.router = router
        presenter.route = "/login"

        try! presenter.doLogin(username: USERNAME, password: PASSWORD)

        XCTAssertTrue(router.invokedNavigate)

        XCTAssertEqual("/login", router.invokedNavigateParameters?.from)
        XCTAssertEqual("Success", router.invokedNavigateParameters?.data["result"] as? String)
    }

    func test_not_request_navigate_to_router_when_current_route_is_not_set_for_presenter() {
        let router = RouterStub()
        presenter.router = router

        try! presenter.doLogin(username: USERNAME, password: PASSWORD)

        XCTAssertFalse(router.invokedNavigate)
    }

//    // Testing also network activity indicator is not called
//    func test_fail_when_create_account_is_requested_with_missing_parameters() {
//        XCTAssertThrowsError(try presenter.createAccount(firstName: "",
//                                                         lastName: LASTNAME,
//                                                         email: USERNAME,
//                                                         phoneNumber: PHONE,
//                                                         password: PASSWORD)) { _ in
//            XCTAssertFalse(view.invokedShowNA)
//        }
//        XCTAssertThrowsError(try presenter.createAccount(firstName: FIRSTNAME,
//                                                         lastName: "",
//                                                         email: USERNAME,
//                                                         phoneNumber: PHONE,
//                                                         password: PASSWORD)) { _ in
//            XCTAssertFalse(view.invokedShowNA)
//        }
//        XCTAssertThrowsError(try presenter.createAccount(firstName: FIRSTNAME,
//                                                         lastName: LASTNAME,
//                                                         email: "",
//                                                         phoneNumber: PHONE,
//                                                         password: PASSWORD)) { _ in
//            XCTAssertFalse(view.invokedShowNA)
//        }
//        XCTAssertThrowsError(try presenter.createAccount(firstName: FIRSTNAME,
//                                                         lastName: LASTNAME,
//                                                         email: USERNAME,
//                                                         phoneNumber: "",
//                                                         password: PASSWORD)) { _ in
//            XCTAssertFalse(view.invokedShowNA)
//        }
//        XCTAssertThrowsError(try presenter.createAccount(firstName: FIRSTNAME,
//                                                         lastName: LASTNAME,
//                                                         email: USERNAME,
//                                                         phoneNumber: PHONE,
//                                                         password: "")) { _ in
//            XCTAssertFalse(view.invokedShowNA)
//        }
//    }
//
//    func test_fail_when_create_account_is_requested_with_bad_formatted_email() {
//        XCTAssertThrowsError(try presenter.createAccount(firstName: FIRSTNAME,
//                                                         lastName: LASTNAME,
//                                                         email: "wrong_email",
//                                                         phoneNumber: PHONE,
//                                                         password: PASSWORD)) { _ in
//            XCTAssertFalse(view.invokedShowNA)
//        }
//    }
//
//    func test_call_show_network_activity_when_all_params_are_correct_beofre_calling_create_account() {
//        view.interactor = interactor
//        try! presenter.createAccount(firstName: FIRSTNAME,
//                                     lastName: LASTNAME,
//                                     email: USERNAME,
//                                     phoneNumber: PHONE,
//                                     password: PASSWORD)
//
//        XCTAssertTrue(view.invokedShowNABeforeCreateAccount)
//        XCTAssertTrue(interactor.invokedCreateAccount)
//    }
//
//    func test_call_interactor_when_requested_create_account_with_all_parameters_correct() {
//        try! presenter.createAccount(firstName: FIRSTNAME,
//                                     lastName: LASTNAME,
//                                     email: USERNAME,
//                                     phoneNumber: PHONE,
//                                     password: PASSWORD)
//
//        let expectedUser = LujoUser(id: 0,
//                                    firstName: FIRSTNAME,
//                                    lastName: LASTNAME,
//                                    email: USERNAME,
//                                    phoneNumber: PHONE,
//                                    password: PASSWORD,
//                                    avatar: "",
//                                    token: "")
//        XCTAssertTrue(interactor.invokedCreateAccount)
//        XCTAssertEqual(interactor.invokedCreateAccountParameter, expectedUser)
//    }
//
//    func test_call_hide_network_activity_when_interactor_returns_before_show_error() {
//        interactor.stubbedCreateAccountCompletionResult = ("", LoginError.errorLogin(description: "Generic Error"))
//
//        try! presenter.createAccount(firstName: FIRSTNAME,
//                                     lastName: LASTNAME,
//                                     email: USERNAME,
//                                     phoneNumber: PHONE,
//                                     password: PASSWORD)
//
//        XCTAssertTrue(view.invokedHideNA)
//    }
//
//    func test_raise_the_error_to_view_when_create_account_interactor_returns_error() {
//        interactor.stubbedCreateAccountCompletionResult = ("", LoginError.errorLogin(description: "Generic Error"))
//
//        try! presenter.createAccount(firstName: FIRSTNAME,
//                                     lastName: LASTNAME,
//                                     email: USERNAME,
//                                     phoneNumber: PHONE,
//                                     password: PASSWORD)
//
//        XCTAssertTrue(view.invokedShowError)
//    }
//
//    func test_not_request_show_confirmation_view_to_presenter_view_when_request_verification_call_failed() {
//        interactor.stubbedCreateAccountCompletionResult = ("", LoginError.errorLogin(description: "Generic Error"))
//
//        try! presenter.createAccount(firstName: FIRSTNAME,
//                                     lastName: LASTNAME,
//                                     email: USERNAME,
//                                     phoneNumber: PHONE,
//                                     password: PASSWORD)
//
//        XCTAssertFalse(view.invokedShowView)
//        XCTAssertTrue(view.invokedShowError)
//    }
//
//    func test_request_show_confirmation_view_to_presenter_view_when_request_verification_call_suceed() {
//        interactor.stubbedCreateAccountCompletionResult = ("https://www.google.es", nil)
//
//        try! presenter.createAccount(firstName: FIRSTNAME,
//                                     lastName: LASTNAME,
//                                     email: USERNAME,
//                                     phoneNumber: PHONE,
//                                     password: PASSWORD)
//
//        XCTAssertTrue(view.invokedShowView)
//        XCTAssertEqual("ShowConfirmationView", view.invokedShowViewParameter?.0)
//    }
//
//    func test_request_interactor_to_update_user_phone_number() {
//        presenter.updateUserPhone(TEST_PHONE_NUMBER)
//
//        XCTAssertTrue(interactor.invokedUpdatePhoneNumber)
//        XCTAssertEqual(TEST_PHONE_NUMBER, interactor.invokedUpdatePhoneNumberParameters)
//    }
//
//    func test_show_confirmation_view_after_requesting_update_user_phone_number() {
//        interactor.stubbedUpdatePhoneCompletionResult = ("", nil)
//        presenter.updateUserPhone(TEST_PHONE_NUMBER)
//
//        XCTAssertTrue(view.invokedShowView)
//        XCTAssertEqual("ReturnToConfirmationView", view.invokedShowViewParameter?.0)
//    }

    func test_request_verification_resend_to_interactor() {
        presenter.requestResendCode()

        XCTAssertTrue(interactor.invokedRequestVerification)
    }

    func test_provide_feedback_after_requesting_new_OTP() {
        presenter.requestResendCode()

        XCTAssertTrue(view.invokedShowFeedback)
        XCTAssertEqual(view.invokedShowFeedbackParameters, "New Code Requested")
    }

    func test_provide_error_feedback_when_error_is_produced_on_OTP_code_resend() {
        let expectedError = LoginError.errorLogin(description: "Generic Error")
        interactor.stubbedRequestVerification = ("", expectedError)

        presenter.requestResendCode()

        XCTAssertTrue(view.invokedShowError)

        guard let obtainedError = view.invokedShowErrorParameters as? LoginError else {
            XCTFail("Error should be sent")
            return
        }
        XCTAssertEqual(obtainedError, expectedError)
    }
}
