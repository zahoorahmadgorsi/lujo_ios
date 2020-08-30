@testable import LUJO
import XCTest

private let LOGIN_USERNAME = "username"
private let LOGIN_PASSWORD = "password"
private let TEST_TOKEN = "1234567890abcdefghijklmnopqrstuvwxyz"
private let GRAVATAR_URL = "http://www.google.com"
private let TEST_USER = LujoUser(id: 0,
                                 firstName: "name",
                                 lastName: "lastname",
                                 email: "user@example.com",
                                 phoneNumber: "0011223344",
                                 password: "password",
                                 avatar: "",
                                 token: "")

private let TEST_LOGIN_USER = LoginUser(userName: "username@example.com",
                                        password: "password",
                                        token: "1234567890")
private let TEST_PHONE_NUMBER = "0040 1234 56 78"

class LoginInteractorShould: XCTestCase {
    var dataLayer: SpyLoginDataLayer!
    var defaults: SpyLuJoSetup!
    var interactor: LoginInteractor!

    override func setUp() {
        super.setUp()
        dataLayer = SpyLoginDataLayer()
        defaults = SpyLuJoSetup()
        interactor = LoginInteractor(dataLayer, setup: defaults)
    }

    override func tearDown() {
        interactor = nil
        dataLayer = nil
        super.tearDown()
    }

    func test_call_data_layer_with_provided_username_and_password_when_doLogin_is_called() {
        interactor.doLogin(username: LOGIN_USERNAME, password: LOGIN_PASSWORD) { _, _ in }

        XCTAssertTrue(dataLayer.invokedLogin)
        XCTAssertEqual(LOGIN_USERNAME, dataLayer.invokedLoginParameters?.username)
        XCTAssertEqual(LOGIN_PASSWORD, dataLayer.invokedLoginParameters?.password)
    }

    func test_call_completion_with_generic_error_when_connection_fails() {
        dataLayer.stubbedLoginCompletionHandlerResult = ("", NSError(domain: NSURLErrorDomain,
                                                                     code: NSURLErrorCannotFindHost,
                                                                     userInfo: [NSLocalizedDescriptionKey: "Could not connect to the server",
                                                                                "_kCFStreamErrorDomainKey": 1,
                                                                                NSURLErrorFailingURLStringErrorKey: "http://localhost:8081/v1/user/login"]))

        let failLoginExpectation = XCTestExpectation(description: "Fail Login")

        interactor.doLogin(username: LOGIN_USERNAME, password: LOGIN_PASSWORD) { _, error in
            if case let .errorLogin(description)? = error {
                XCTAssertEqual("Could not connect to the server", description)
            } else {
                XCTFail()
            }
            failLoginExpectation.fulfill()
        }

        wait(for: [failLoginExpectation], timeout: 1.0)
    }

    func test_call_completion_with_error_when_login_fails() {
        dataLayer.stubbedLoginCompletionHandlerResult = ("", LoginError.errorLogin(description: "Either username or password doesn't match"))

        let failLoginExpectation = XCTestExpectation(description: "Fail Login")

        interactor.doLogin(username: LOGIN_USERNAME, password: LOGIN_PASSWORD) { _, error in
            XCTAssertEqual(LoginError.errorLogin(description: "Either username or password doesn't match"), error)
            failLoginExpectation.fulfill()
        }

        wait(for: [failLoginExpectation], timeout: 1.0)
    }

    func test_call_completion_with_no_error_when_login_succeeds() {
        let succeedLoginExpectation = XCTestExpectation(description: "Succeed Login")

        interactor.doLogin(username: LOGIN_USERNAME, password: LOGIN_PASSWORD) { _, error in
            XCTAssertNil(error)
            succeedLoginExpectation.fulfill()
        }

        wait(for: [succeedLoginExpectation], timeout: 1.0)
    }

    func test_store_current_username_when_login_succeeds() {
        let storeUserExpectation = XCTestExpectation(description: "Store user data on successfull login")
        let expectedtUser = LoginUser(userName: LOGIN_USERNAME, password: LOGIN_PASSWORD, token: TEST_TOKEN)

        interactor.doLogin(username: LOGIN_USERNAME, password: LOGIN_PASSWORD) { _, _ in
            XCTAssertTrue(self.defaults.invokedStoreCurrentUser)
            XCTAssertEqual(expectedtUser, self.defaults.invokedStoreCurrentUserParameters?.currentUser)
            storeUserExpectation.fulfill()
        }

        wait(for: [storeUserExpectation], timeout: 1.0)
    }

    func test_call_data_layer_with_user_data_when_createAccoint_is_called() {
        interactor.createAccount(TEST_USER) { _, _ in }

        XCTAssertTrue(dataLayer.invokedCreate)
        XCTAssertEqual(TEST_USER, dataLayer.invokedCreateParameter)
    }

    func test_call_completion_with_connection_error_fails_on_createAccount() {
        dataLayer.failWithError = NSError(domain: NSURLErrorDomain,
                                          code: NSURLErrorCannotFindHost,
                                          userInfo: [NSLocalizedDescriptionKey: "Could not connect to the server",
                                                     "_kCFStreamErrorDomainKey": 1,
                                                     NSURLErrorFailingURLStringErrorKey: "http://localhost:8081/v1/user/login"])

        let failCreateExpectation = XCTestExpectation(description: "Fail Create Account")

        interactor.createAccount(TEST_USER) { _, error in
            if case let .errorLogin(description)? = error {
                XCTAssertEqual("Could not connect to the server", description)
            } else {
                XCTFail()
            }
            failCreateExpectation.fulfill()
        }

        wait(for: [failCreateExpectation], timeout: 1.0)
    }

    func test_store_current_user_when_create_account_call_succeeds() {
        let succeedCreateAccountExpectation = XCTestExpectation(description: "Create Account Succeeded")

        interactor.createAccount(TEST_USER) { _, error in
            XCTAssertNil(error)
            succeedCreateAccountExpectation.fulfill()
        }

        wait(for: [succeedCreateAccountExpectation], timeout: 1.0)
    }

    func test_call_completion_with_no_error_when_create_account_call_succeeds() {
        let succeedCreateAccountExpectation = XCTestExpectation(description: "Create Account Succeeded")

        interactor.createAccount(TEST_USER) { _, error in
            XCTAssertNil(error)
            succeedCreateAccountExpectation.fulfill()
        }

        wait(for: [succeedCreateAccountExpectation], timeout: 1.0)
    }

    func test_call_completion_with_error_when_request_verification_fails() {
        let error = NSError(domain: NSURLErrorDomain,
                            code: NSURLErrorCannotFindHost,
                            userInfo: [NSLocalizedDescriptionKey: "Could not connect to the server",
                                       "_kCFStreamErrorDomainKey": 1,
                                       NSURLErrorFailingURLStringErrorKey: "http://localhost:8081/v1/user/login"])
        dataLayer.stubbedRequestOTPCompletionResult = ("", error)
        defaults.stubGetCurrentUserParameters = TEST_LOGIN_USER

        let failVerifyExpectation = XCTestExpectation(description: "Fail Request Verification Code")

        interactor.requestVerificationCode { _, error in
            if case let .errorLogin(description)? = error {
                XCTAssertEqual("Could not connect to the server", description)
            } else {
                XCTFail()
            }
            failVerifyExpectation.fulfill()
        }

        wait(for: [failVerifyExpectation], timeout: 1.0)
    }

    func test_call_completion_with_no_error_when_request_verification_succeeds() {
        dataLayer.stubbedRequestOTPCompletionResult = ("Success", nil)
        defaults.stubGetCurrentUserParameters = TEST_LOGIN_USER

        let succeedVerifyExpectation = XCTestExpectation(description: "Succeed Request Verification Code")

        interactor.requestVerificationCode { _, error in
            XCTAssertNil(error)
            succeedVerifyExpectation.fulfill()
        }

        wait(for: [succeedVerifyExpectation], timeout: 1.0)
    }

    func test_call_update_user_with_new_user_number() {
        defaults.stubGetCurrentUserParameters = TEST_LOGIN_USER
        interactor.updateUserPhone(TEST_PHONE_NUMBER) { _, _ in }

        XCTAssertTrue(dataLayer.invokedUpdateData)
        XCTAssertEqual(TEST_LOGIN_USER, dataLayer.invokedUpdateDataParameter!.0)
        XCTAssertEqual(TEST_PHONE_NUMBER, dataLayer.invokedUpdateDataParameter!.1)
    }

    func test_call_presenter_after_phone_number_is_updated_with_result() {
        dataLayer.stubbedUpdateDataCompletionResult = ("", nil)
        defaults.stubGetCurrentUserParameters = TEST_LOGIN_USER

        let succeedUpdateExpectation = XCTestExpectation(description: "Succeed Phone Number Update Requested")

        interactor.updateUserPhone(TEST_PHONE_NUMBER) { _, error in
            XCTAssertNil(error)
            succeedUpdateExpectation.fulfill()
        }

        wait(for: [succeedUpdateExpectation], timeout: 1.0)
    }
}
