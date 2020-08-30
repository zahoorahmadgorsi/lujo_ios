import DefaultsKit
@testable import LUJO
import XCTest

let SAMPLE_MARGINS: [String: Int] = [
    "members": 5,
    "non-members": 15,
]

let MEMBER_MARGIN: Double = 0.05

private class SpyDataLayer: AppDefaultsDataLayer {
    func getCountryCodes(completion: @escaping ([PhoneCountryCode], Error?) -> Void) {}

    func userProfile(for token: String, completion: @escaping (LujoUser?, Error?) -> Void) {}

    func update(user: LujoUser, image: UIImage, completion: @escaping (Error?) -> Void) {}

    var invokedGetDefaults = false
    var invokedGetDefaultsCount = 0
    var stubbedGetDefaultsCompletionResult: ([String: Any], Error?)?
    func getDefaults(completion: (_ data: [String: Any], Error?) -> Void) {
        invokedGetDefaults = true
        invokedGetDefaultsCount += 1
        if let result = stubbedGetDefaultsCompletionResult {
            completion(result.0, result.1)
        }
    }
}

class LujoSetupShould: XCTestCase {
    var setup: LujoSetup!
    var testDefaults: Defaults!
    fileprivate var dataLayer: SpyDataLayer!

    let VALID_USERNAME = "frontend@golujo.com"
    let VALID_PASSWORD = "1234567890"
    let VALID_TOKEN = "1234567890abcdefghijklmnopqrstuvwxyz"

    override func setUp() {
        dataLayer = SpyDataLayer()
        testDefaults = Defaults(userDefaults: UserDefaults())
        setup = LujoSetup(testDefaults, data: dataLayer)
    }

    override func tearDown() {
        dataLayer = nil
        testDefaults = nil
        setup = nil
    }

    func test_not_have_current_user_when_first_time_created() {
        let currentUser = setup.getCurrentUser()

        XCTAssertNil(currentUser)
    }

    func test_create_a_new_current_user_record_when_store_is_called() {
        let expectedUser = LoginUser(prefix: "", phone: "", token: VALID_TOKEN, approved: true)

        setup.store(currentUser: expectedUser)

        let currentUser = setup.getCurrentUser()

        XCTAssertEqual(expectedUser, currentUser)
    }

    func test_recover_last_verification_code_stored() {
        let expectedCode = "1234"

        setup.storeVerificationCode("4321")
        setup.storeVerificationCode(expectedCode)

        XCTAssertEqual(expectedCode, setup.getVerificationCode())
    }

    func test_have_no_user_after_delete_current_user() {
        let expectedUser = LoginUser(prefix: "", phone: "", token: VALID_TOKEN, approved: true)

        setup.store(currentUser: expectedUser)

        setup.deleteCurrentUser()

        XCTAssertNil(setup.getCurrentUser())
    }

    func test_load_defaults_from_network_when_update_is_requested() {
        setup.updateDefaults({})

        XCTAssert(dataLayer.invokedGetDefaults)
    }

    func test_store_member_margin_margin_from_network() {
        dataLayer.stubbedGetDefaultsCompletionResult = (["margins": SAMPLE_MARGINS], nil)
        setup.updateDefaults({})

        XCTAssertEqual(0.05, setup.getMembersMargin())
    }

    func test_store_non_member_margin_margin_from_network() {
        dataLayer.stubbedGetDefaultsCompletionResult = (["margins": SAMPLE_MARGINS], nil)
        setup.updateDefaults({})

        XCTAssertEqual(0.15, setup.getNonMembersMargin())
    }
}
