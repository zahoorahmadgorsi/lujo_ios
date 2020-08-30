@testable import LUJO
import XCTest

private let SAMPLE_USER_DATA = LujoUser(id: 0,
                                        firstName: "John",
                                        lastName: "Doe",
                                        email: "johndoe@example.com",
                                        phoneNumber: "00 34 600 200 300",
                                        password: "",
                                        avatar: "",
                                        token: "")

class AccountPresenterShould: XCTestCase {
    var presenter: AccountPresenter!
    fileprivate var accountView: MockAccountView!
    fileprivate var accountInteractor: MockAccountInteractor!

    override func setUp() {
        accountView = MockAccountView()
        accountInteractor = MockAccountInteractor()
        presenter = AccountPresenter(accountView, accountInteractor)
    }

    override func tearDown() {
        accountInteractor = nil
        accountView = nil
        presenter = nil
    }

    func test_request_profile_information_to_interactor_when_show_profile_is_requested() {
        presenter.showUserProfile()

        XCTAssertTrue(accountInteractor.invokedGetUserProfile)
    }

    func test_present_user_profile_data_in_account_view() {
        accountInteractor.stubbedGetUserProfileCompletionResult = (SAMPLE_USER_DATA, nil)

        presenter.showUserProfile()

        XCTAssertEqual(SAMPLE_USER_DATA, accountView.invokedShowProfileFormParameters?.user)
    }

    func test_present_error_when_interactor_call_fails() {
        let error = LoginError.errorLogin(description: "Unable to obtain user data")
        accountInteractor.stubbedGetUserProfileCompletionResult = (nil, error)

        presenter.showUserProfile()

        XCTAssertTrue(accountView.invokedShowError)
        guard let obtainedError = accountView.invokedShowErrorParameters?.error as? LoginError else {
            XCTFail("Should call showError with and error")
            return
        }
        XCTAssertEqual(error, obtainedError)
    }

    func test_request_profile_update_to_interactor_when_is_requested() {
        presenter.update(profile: SAMPLE_USER_DATA)

        XCTAssertTrue(accountInteractor.invokedUpdate)
        XCTAssertEqual(SAMPLE_USER_DATA, accountInteractor.invokedUpdateParameters?.profile)
    }

    func test_error_is_presented_when_update_profile_fails() {
        let error = LoginError.errorLogin(description: "Generic Error")
        accountInteractor.stubbedUpdateCompletionResult = error

        presenter.update(profile: SAMPLE_USER_DATA)

        XCTAssertTrue(accountView.invokedShowError)
        guard let obtainedError = accountView.invokedShowErrorParameters?.error as? LoginError else {
            XCTFail("Should call showError with and error")
            return
        }
        XCTAssertEqual(error, obtainedError)
    }

    func test_view_is_informed_when_update_profile_succeeds() {
        presenter.update(profile: SAMPLE_USER_DATA)

        XCTAssertTrue(accountView.invokedProfileUpdated)
    }
}

private class MockAccountView: AccountViewable {
    var invokedPresenterSetter = false
    var invokedPresenterSetterCount = 0
    var invokedPresenter: AccountViewResponder?
    var invokedPresenterList = [AccountViewResponder?]()
    var invokedPresenterGetter = false
    var invokedPresenterGetterCount = 0
    var stubbedPresenter: AccountViewResponder!
    var presenter: AccountViewResponder? {
        set {
            invokedPresenterSetter = true
            invokedPresenterSetterCount += 1
            invokedPresenter = newValue
            invokedPresenterList.append(newValue)
        }
        get {
            invokedPresenterGetter = true
            invokedPresenterGetterCount += 1
            return stubbedPresenter
        }
    }

    var invokedShowProfileForm = false
    var invokedShowProfileFormCount = 0
    var invokedShowProfileFormParameters: (user: LujoUser, Void)?
    var invokedShowProfileFormParametersList = [(user: LujoUser, Void)]()
    func showProfileForm(_ user: LujoUser) {
        invokedShowProfileForm = true
        invokedShowProfileFormCount += 1
        invokedShowProfileFormParameters = (user, ())
        invokedShowProfileFormParametersList.append((user, ()))
    }

    var invokedProfileUpdated = false
    var invokedProfileUpdatedCount = 0
    func profileUpdated() {
        invokedProfileUpdated = true
        invokedProfileUpdatedCount += 1
    }

    var invokedShowNetworkActivity = false
    var invokedShowNetworkActivityCount = 0
    func showNetworkActivity() {
        invokedShowNetworkActivity = true
        invokedShowNetworkActivityCount += 1
    }

    var invokedHideNetworkActivity = false
    var invokedHideNetworkActivityCount = 0
    func hideNetworkActivity() {
        invokedHideNetworkActivity = true
        invokedHideNetworkActivityCount += 1
    }

    var invokedShowError = false
    var invokedShowErrorCount = 0
    var invokedShowErrorParameters: (error: Error, Void)?
    var invokedShowErrorParametersList = [(error: Error, Void)]()
    func showError(_ error: Error) {
        invokedShowError = true
        invokedShowErrorCount += 1
        invokedShowErrorParameters = (error, ())
        invokedShowErrorParametersList.append((error, ()))
    }

    var invokedShowFeedback = false
    var invokedShowFeedbackCount = 0
    var invokedShowFeedbackParameters: (message: String, Void)?
    var invokedShowFeedbackParametersList = [(message: String, Void)]()
    func showFeedback(_ message: String) {
        invokedShowFeedback = true
        invokedShowFeedbackCount += 1
        invokedShowFeedbackParameters = (message, ())
        invokedShowFeedbackParametersList.append((message, ()))
    }

    var invokedShowView = false
    var invokedShowViewCount = 0
    var invokedShowViewParameters: (id: String, data: [String: Any]?)?
    var invokedShowViewParametersList = [(id: String, data: [String: Any]?)]()
    func showView(_ id: String, data: [String: Any]?) {
        invokedShowView = true
        invokedShowViewCount += 1
        invokedShowViewParameters = (id, data)
        invokedShowViewParametersList.append((id, data))
    }
}

private class MockAccountInteractor: AccountInteractuable {
    var invokedGetUserProfile = false
    var invokedGetUserProfileCount = 0
    var stubbedGetUserProfileCompletionResult: (LujoUser?, Error?)?
    func getUserProfile(completion: @escaping (LujoUser?, Error?) -> Void) {
        invokedGetUserProfile = true
        invokedGetUserProfileCount += 1
        if let result = stubbedGetUserProfileCompletionResult {
            completion(result.0, result.1)
        }
    }

    var invokedUpdate = false
    var invokedUpdateCount = 0
    var invokedUpdateParameters: (profile: LujoUser, Void)?
    var invokedUpdateParametersList = [(profile: LujoUser, Void)]()
    var stubbedUpdateCompletionResult: Error?
    func update(user profile: LujoUser, completion: @escaping (Error?) -> Void) {
        invokedUpdate = true
        invokedUpdateCount += 1
        invokedUpdateParameters = (profile, ())
        invokedUpdateParametersList.append((profile, ()))
        if let result = stubbedUpdateCompletionResult {
            completion(result)
        }
    }
}
