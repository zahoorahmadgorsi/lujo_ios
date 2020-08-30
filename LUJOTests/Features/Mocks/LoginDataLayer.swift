@testable import LUJO

class SpyLoginDataLayer: LoginDataLayerProtocol {
    var invokedLogin = false
    var invokedLoginCount = 0
    var invokedLoginParameters: (username: String, password: String)?
    var invokedLoginParametersList = [(username: String, password: String)]()
    var stubbedLoginCompletionHandlerResult: (String, Error?)?
    func login(username: String, password: String, completionHandler: @escaping DataLayerCallback) {
        invokedLogin = true
        invokedLoginCount += 1
        invokedLoginParameters = (username, password)
        invokedLoginParametersList.append((username, password))
        if let result = stubbedLoginCompletionHandlerResult {
            completionHandler(result.0, result.1)
        }
    }

    var invokedCreate = false
    var invokedCreateCount = 0
    var invokedCreateParameters: (user: LujoUser, Void)?
    var invokedCreateParametersList = [(user: LujoUser, Void)]()
    var stubbedCreateCompletionHandlerResult: (String, Error?)?
    func create(user: LujoUser, completionHandler: @escaping DataLayerCallback) {
        invokedCreate = true
        invokedCreateCount += 1
        invokedCreateParameters = (user, ())
        invokedCreateParametersList.append((user, ()))
        if let result = stubbedCreateCompletionHandlerResult {
            completionHandler(result.0, result.1)
        }
    }

    var invokedRequestVerification = false
    var invokedRequestVerificationCount = 0
    var invokedRequestVerificationParameters: (user: LoginUser, code: String)?
    var invokedRequestVerificationParametersList = [(user: LoginUser, code: String)]()
    var stubbedRequestVerificationCompletionHandlerResult: (String, Error?)?
    func requestVerification(for user: LoginUser, withCode code: String, completionHandler: @escaping DataLayerCallback) {
        invokedRequestVerification = true
        invokedRequestVerificationCount += 1
        invokedRequestVerificationParameters = (user, code)
        invokedRequestVerificationParametersList.append((user, code))
        if let result = stubbedRequestVerificationCompletionHandlerResult {
            completionHandler(result.0, result.1)
        }
    }

    var invokedRequestOTP = false
    var invokedRequestOTPCount = 0
    var invokedRequestOTPParameters: (user: LoginUser, Void)?
    var invokedRequestOTPParametersList = [(user: LoginUser, Void)]()
    var stubbedRequestOTPCompletionHandlerResult: (String, Error?)?
    func requestOTP(for user: LoginUser, completionHandler: @escaping DataLayerCallback) {
        invokedRequestOTP = true
        invokedRequestOTPCount += 1
        invokedRequestOTPParameters = (user, ())
        invokedRequestOTPParametersList.append((user, ()))
        if let result = stubbedRequestOTPCompletionHandlerResult {
            completionHandler(result.0, result.1)
        }
    }

    var invokedUpdateUser = false
    var invokedUpdateUserCount = 0
    var invokedUpdateUserParameters: (user: LoginUser, number: String)?
    var invokedUpdateUserParametersList = [(user: LoginUser, number: String)]()
    var stubbedUpdateUserCompletionResult: (String, Error?)?
    func update(user: LoginUser, phone number: String, completion: @escaping DataLayerCallback) {
        invokedUpdateUser = true
        invokedUpdateUserCount += 1
        invokedUpdateUserParameters = (user, number)
        invokedUpdateUserParametersList.append((user, number))
        if let result = stubbedUpdateUserCompletionResult {
            completion(result.0, result.1)
        }
    }

    var invokedForgot = false
    var invokedForgotCount = 0
    var invokedForgotParameters: (password: String, Void)?
    var invokedForgotParametersList = [(password: String, Void)]()
    var stubbedForgotCompletionResult: (String, Error?)?
    func forgot(user password: String, completion: @escaping DataLayerCallback) {
        invokedForgot = true
        invokedForgotCount += 1
        invokedForgotParameters = (password, ())
        invokedForgotParametersList.append((password, ()))
        if let result = stubbedForgotCompletionResult {
            completion(result.0, result.1)
        }
    }

    var invokedUserProfile = false
    var invokedUserProfileCount = 0
    var invokedUserProfileParameters: (token: String, Void)?
    var invokedUserProfileParametersList = [(token: String, Void)]()
    var stubbedUserProfileCompletionResult: (LujoUser?, Error?)?
    func userProfile(for token: String, completion: @escaping (LujoUser?, Error?) -> Void) {
        invokedUserProfile = true
        invokedUserProfileCount += 1
        invokedUserProfileParameters = (token, ())
        invokedUserProfileParametersList.append((token, ()))
        if let result = stubbedUserProfileCompletionResult {
            completion(result.0, result.1)
        }
    }

    var invokedUpdate = false
    var invokedUpdateCount = 0
    var invokedUpdateParameters: (profile: LujoUser, Void)?
    var invokedUpdateParametersList = [(profile: LujoUser, Void)]()
    var stubbedUpdateCompletionResult: (Error?, Void)?
    func update(user profile: LujoUser, completion: @escaping (Error?) -> Void) {
        invokedUpdate = true
        invokedUpdateCount += 1
        invokedUpdateParameters = (profile, ())
        invokedUpdateParametersList.append((profile, ()))
        if let result = stubbedUpdateCompletionResult {
            completion(result.0)
        }
    }

    func loginWithOTP(prefix: String, _ number: String, code: String, completionHandler: @escaping DataLayerCallback) {}

    func loginWithOTP(prefix: PhoneCountryCode, _ number: String, completionHandler: @escaping DataLayerCallback) {}

    func update(user: LoginUser, prefix: Int, phone number: String, completion: @escaping DataLayerCallback) {}

    func approved(user: LoginUser, completion: @escaping (Bool, Error?) -> Void) {}

    func requestLoginOTP(prefix: PhoneCountryCode, _ number: String, completionHandler: @escaping DataLayerCallback) {}
}
