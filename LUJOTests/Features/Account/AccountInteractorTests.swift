@testable import LUJO
import XCTest

private let SAMPLE_USER_TOKEN = "sjdfkshfoiasufhadklsjhailsufhlwafshadsiufhalsufhadjklshljk"
private let SAMPLE_USER_INFO = LujoUser(id: 0,
                                        firstName: "John",
                                        lastName: "Doe",
                                        email: "johndoe@exapmple.com",
                                        phoneNumber: "00 34 600 200 300",
                                        password: "",
                                        avatar: "https://via.placeholder.com/150",
                                        token: SAMPLE_USER_TOKEN,
                                        approved: "")

private let SAMPLE_USER_PROFILE = LujoUser(id: 1,
                                           firstName: "John",
                                           lastName: "Doe",
                                           email: "johndoe@exapmple.com",
                                           phoneNumber: "00 34 600 200 300",
                                           password: "",
                                           avatar: "https://via.placeholder.com/150",
                                           token: "",
                                           approved: "")

class AccountInteractorTests: XCTestCase {
    var dataLayer: SpyLoginDataLayer!
    var defaults: SpyLuJoSetup!

    var interactor: AccountInteractor!

    override func setUp() {
        dataLayer = SpyLoginDataLayer()
        defaults = SpyLuJoSetup()

        defaults.stubbedGetCurrentUserResult = LoginUser(userName: "johndoe@example.com",
                                                         password: "12345678",
                                                         token: SAMPLE_USER_TOKEN,
                                                         approved: "")

        interactor = AccountInteractor(data: dataLayer, setup: defaults)
    }

    override func tearDown() {
        interactor = nil
    }

    func test_return_error_if_no_user_is_logged_in_when_user_profile_data_is_called() {
        let expectation = XCTestExpectation(description: "Call complete with data")
        defaults.stubbedGetCurrentUserResult = nil
        let expectedError = LoginError.errorLogin(description: "No logged in user")

        interactor.getUserProfile { user, error in
            guard let obtainedError = error as? LoginError else {
                XCTFail("Should return a login error")
                return
            }
            XCTAssertEqual(expectedError, obtainedError)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.25)
    }

    func test_call_data_layer_with_loged_in_user_token_when_user_profile_data_is_called() {
        interactor.getUserProfile { user, error in
            // Ignore
        }

        XCTAssertTrue(dataLayer.invokedUserProfile)
        XCTAssertEqual(SAMPLE_USER_TOKEN, dataLayer.invokedUserProfileParameters?.token)
    }

    func test_return_error_to_presenter_when_call_to_user_profile_failed() {
        let expectedError = LoginError.errorLogin(description: "Generic error")
        dataLayer.stubbedUserProfileCompletionResult = (nil, expectedError)
        let expectation = XCTestExpectation(description: "Call complete with data")

        interactor.getUserProfile { user, error in
            guard let obtainedError = error as? LoginError else {
                XCTFail("Should return a login error")
                return
            }
            XCTAssertEqual(expectedError, obtainedError)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.25)
    }

    func test_returne_user_profile_when_call_to_user_profile_succeeds() {
        dataLayer.stubbedUserProfileCompletionResult = (SAMPLE_USER_INFO, nil)
        let expectation = XCTestExpectation(description: "Call complete with data")

        interactor.getUserProfile { user, error in
            XCTAssertEqual(SAMPLE_USER_INFO, user)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.25)
    }

    func test_call_data_layer_with_profile_date_when_update_is_requested() {
        interactor.update(user: SAMPLE_USER_PROFILE) { error in
            // Ignore
        }

        XCTAssertTrue(dataLayer.invokedUpdate)
        XCTAssertEqual(SAMPLE_USER_INFO, dataLayer.invokedUpdateParameters?.profile)
    }

    func test_return_error_to_presenter_when_call_to_update_profile_failed() {
        let expectedError = LoginError.errorLogin(description: "Generic error")
        dataLayer.stubbedUpdateCompletionResult = (expectedError as Error, ())
        let expectation = XCTestExpectation(description: "Call complete with error")

        interactor.update(user: SAMPLE_USER_PROFILE) { error in
            guard let obtainedError = error as? LoginError else {
                XCTFail("Should return a login error")
                return
            }
            XCTAssertEqual(expectedError, obtainedError)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.25)
    }

    func test_return_no_error_when_call_to_update_profile_succeeds() {
        dataLayer.stubbedUpdateCompletionResult = (nil, ())
        let expectation = XCTestExpectation(description: "Call complete with no error")

        interactor.update(user: SAMPLE_USER_PROFILE) { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.25)
    }
}
