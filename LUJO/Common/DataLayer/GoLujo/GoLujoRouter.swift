import Alamofire
import FirebaseCrashlytics
import Foundation
import UIKit

enum GoLujoRouterCategory {
    case creation, update, setup, delete
}

enum GoLujoRouter: URLRequestConvertible {
    // Obtain backend URL from configuration
    static let baseURLString: String = {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "BACKEND_URL") as? String else {
            return ""
        }
        return urlString
    }()

    static let apiVersion: String = {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "BACKEND_API_VERSION") as? String else {
            return ""
        }
        return "/" + urlString
    }()

    static let scheme: String = {
        guard let scheme = Bundle.main.object(forInfoDictionaryKey: "BACKEND_SCHEME") as? String else {
            return "https"
        }
        return scheme
    }()

    case refreshToken(String)
    case login(String, String)
    case loginWithOTP(String, String, String)
    case requestLoginOTP(PhoneCountryCode, String)
    case createUser(LujoUser)
    case verify(LoginUser, String)
    case requestOTP(LoginUser)
    case updatePhoneNumber(String, String, String, String)
    case updateDefaults
    case countryCodes
    case forgotPassword(String)
    case userProfile(String)
    case updateProfile(LujoUser)
    case updateUserImage(LujoUser, UIImage)
    case approved(String)
    case registerForPush(String, String)
    case unregisterForPush(String)

    private func getCategory() -> GoLujoRouterCategory {
        switch self {
        case .createUser, .verify, .requestOTP, .requestLoginOTP, .approved:
            return .creation
        case .refreshToken, .updatePhoneNumber, .updateProfile, .updateUserImage, .forgotPassword:
            return .update
        case .login, .loginWithOTP, .updateDefaults, .userProfile, .countryCodes, .registerForPush:
            return .setup
        case .unregisterForPush:
            return .delete
        }
    }

    func asURLRequest() throws -> URLRequest {
        
        var method: HTTPMethod {
            return getHTTPMethod()
        }

        let requestUrl: URL = {
            getRequestURL()
        }()

        let body: Data? = {
            getBodyData()
        }()

        var urlRequest = URLRequest(url: requestUrl)
        urlRequest.httpMethod = method.rawValue
        urlRequest.httpBody = body
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        if let token = LujoSetup().getCurrentUser()?.token{
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        switch self {
        case .registerForPush: fallthrough
        case .unregisterForPush:
            urlRequest.setValue(getAuthTokenForPush(isStaging: false), forHTTPHeaderField: "x-api-key")
        default:
            break
        }

        return urlRequest
    }

    func getHTTPMethod() -> HTTPMethod {
        switch getCategory() {
        case .creation:
            return getHTTPMethodCreation()
        case .update:
            return getHTTPMethodUpdate()
        case .setup:
            return getHTTPMethodSetup()
        case .delete:
            return getHTTPMethodDelete()
        }
    }

    fileprivate func getHTTPMethodCreation() -> HTTPMethod {
        switch self {
        case .createUser:
            return .post
        case .verify:
            return .post
        case .requestOTP:
            return .post
        case .requestLoginOTP:
            return .post
        case .approved:
            return .get
        default:
            fatalError("Wrong method category called")
        }
    }

    fileprivate func getHTTPMethodUpdate() -> HTTPMethod {
        switch self {
        case .updatePhoneNumber:
            return .post
        case .forgotPassword:
            return .post
        case .updateProfile:
            return .post
        case .updateUserImage:
            return .post
        case .refreshToken:
            return .post
        default:
            fatalError("Wrong method category called")
        }
    }

    fileprivate func getHTTPMethodSetup() -> HTTPMethod {
        switch self {
        case .login:
            return .post
        case .loginWithOTP:
            return .post
        case .updateDefaults:
            return .get
        case .userProfile:
            return .get
        case .countryCodes:
            return .get
        case .registerForPush:
            return .post
        default:
            fatalError("Wrong method category called")
        }
    }
    
    fileprivate func getHTTPMethodDelete() -> HTTPMethod {
        switch self {
        case .unregisterForPush:
            return .delete
        default:
            fatalError("Wrong method category called")
        }
    }


    fileprivate func getRequestURL() -> URL {
        var newURLComponents = URLComponents()
        newURLComponents.scheme = GoLujoRouter.scheme
        newURLComponents.host = GoLujoRouter.baseURLString
        newURLComponents.path = GoLujoRouter.apiVersion
        
        let urlData = getUrlDataForPushService(isStaging: false)

        switch self {
        case .refreshToken:
            newURLComponents.path.append("/users/new-token")
        case .login:
            newURLComponents.path.append("/users/login")
        case .loginWithOTP:
            newURLComponents.path.append("/users/login")
        case .requestLoginOTP:
            newURLComponents.path.append("/users/login-otp/")
        case .createUser:
            newURLComponents.path.append("/users")
        case .verify:
            newURLComponents.path.append("/users/verify")
        case .requestOTP:
            newURLComponents.path.append("/users/verify-otp/")
        case .updatePhoneNumber:
            newURLComponents.path.append("/users/change-phone")
        case .updateDefaults:
            newURLComponents.path.append("/setup")
            newURLComponents.queryItems = [
                URLQueryItem(name: "type", value: "all"),
            ]
        case .countryCodes:
            newURLComponents.path.append("/phone-prefix")
            newURLComponents.queryItems = [
                URLQueryItem(name: "id", value: "all"),
            ]
        case .forgotPassword:
            newURLComponents.path.append("/users/forgot")
        case let .userProfile(token):
            newURLComponents.path.append("/users/profile")
            newURLComponents.queryItems = [
                URLQueryItem(name: "token", value: token),
            ]
        case .updateProfile:
            newURLComponents.path.append("/users/update")
        case .updateUserImage:
            newURLComponents.path.append("/users/avatar")
        case let .approved(token):
            newURLComponents.path.append("/users/approved")
            newURLComponents.queryItems = [
                URLQueryItem(name: "token", value: token),
            ]
        case .registerForPush:
            newURLComponents = URLComponents()
            newURLComponents.scheme = "https"
            newURLComponents.host = urlData.url
            newURLComponents.path = urlData.scheme
            newURLComponents.path.append("/device-token")
        case let .unregisterForPush(userId):
            newURLComponents = URLComponents()
            newURLComponents.scheme = "https"
            newURLComponents.host = urlData.url
            newURLComponents.path = urlData.scheme
            newURLComponents.path.append("/device-token/\(userId)")
        }

        do {
            let callURL = try newURLComponents.asURL()
            return callURL
        } catch {
            Crashlytics.crashlytics().record(error: error)
        }

        return URL(string: "http://\(GoLujoRouter.baseURLString)")!
    }

    fileprivate func getBodyData() -> Data? {
        switch self {
        case let .refreshToken(token):
            return getUserTokenAsJSONData(token)
        case let .login(username, password):
            return getCredentialsAsJSONData(username, password)
        case let .loginWithOTP(prefix, number, code):
            return getOTPCredentialsAsJSONData(prefix, number, code)
        case let .requestLoginOTP(prefix, number):
            return getPhoneNumberAsJSONData(prefix, number)
        case let .createUser(user):
            return getUserAsJSONData(user)
        case let .verify(user, code):
            return getVerificationAsJSONData(user, code)
        case let .requestOTP(user):
            return getUserAsJSONData(user)
        case let .updatePhoneNumber(oldPrefix, oldNumber, newPrefix, newNumber):
            return getUserNameAndPhoneAsJSONData(oldPrefix, oldNumber, newPrefix, newNumber)
        case .updateDefaults:
            return nil
        case .countryCodes:
            return nil
        case .forgotPassword:
            return nil
        case .userProfile:
            return nil
        case let .updateProfile(profile):
            return getProfileAsJSONData(profile)
        case let .updateUserImage(user, image):
            return getUserImageAsJSONData(user, image)
        case .approved:
            return nil // getUserTokenAsJSONData(token)
        case let .registerForPush(userId, deviceToken):
            return getDeviceTokenAsJSONData(userId, deviceToken)
        case .unregisterForPush:
            return nil
        }
    }

    fileprivate func getUserTokenAsJSONData(_ token: String) -> Data? {
        let verificationData: [String: String] = [
            "token": token,
        ]
        return try? JSONSerialization.data(withJSONObject: verificationData, options: [])
    }

    fileprivate func getUserImageAsJSONData(_ user: LujoUser, _ image: UIImage) -> Data? {
        guard let imageData = image.convertImageTobase64(format: .jpegFormat(0.4)) else { return nil }
        let userImageData: [String: String?] = [
            "avatar": imageData,
            "token": user.token,
        ]
        return try? JSONSerialization.data(withJSONObject: userImageData, options: [])
    }

    fileprivate func getCredentialsAsJSONData(_ username: String, _ password: String) -> Data? {
        let credentials: [String: AnyObject] = [
            "username": username as AnyObject,
            "password": password as AnyObject,
        ]
        return try? JSONSerialization.data(withJSONObject: credentials, options: [])
    }

    fileprivate func getOTPCredentialsAsJSONData(_ prefix: String, _ number: String, _ code: String) -> Data? {
        let credentials: [String: String] = [
            "phone_prefix": prefix,
            "phone": number,
            "code": code,
        ]
        return try? JSONSerialization.data(withJSONObject: credentials, options: [])
    }

    fileprivate func getPhoneNumberAsJSONData(_ prefix: PhoneCountryCode, _ number: String) -> Data? {
        let credentials: [String: String] = [
            "phone_prefix": prefix.phonePrefix,
            "phone": number,
        ]
        return try? JSONSerialization.data(withJSONObject: credentials, options: [])
    }
    
    fileprivate func getDeviceTokenAsJSONData(_ userId: String, _ deviceToken: String) -> Data? {
        let verificationData: [String: String] = [
            "userId": userId,
            "deviceToken": deviceToken
        ]
        return try? JSONSerialization.data(withJSONObject: verificationData, options: [])
    }

    // TODO: Added plus sign before phone prefix until it's taken from list
    fileprivate func getUserAsJSONData(_ user: LujoUser) -> Data? {
        let profileData: [String: String] = [
//            "title": user.title.rawValue,
            "firstname": user.firstName,
            "lastname": user.lastName,
            "email": user.email,
            "phone_prefix": String(user.phoneNumber.countryCode),
            "phone": user.phoneNumber.number,
        ]
        return try? JSONSerialization.data(withJSONObject: profileData, options: [])
    }

    fileprivate func getVerificationAsJSONData(_ user: LoginUser, _ code: String) -> Data? {
        let verificationData: [String: String] = [
            "phone_prefix": user.prefix,
            "phone": user.phone,
            "code": code,
        ]
        return try? JSONSerialization.data(withJSONObject: verificationData, options: [])
    }

    fileprivate func getUserAsJSONData(_ user: LoginUser) -> Data? {
        let verificationData: [String: String] = [
            "phone_prefix": user.prefix,
            "phone": user.phone,
        ]
        return try? JSONSerialization.data(withJSONObject: verificationData, options: [])
    }

    fileprivate func getUserNameAndPhoneAsJSONData(_ oldPrefix: String, _ oldNumber: String, _ newPrefix: String, _ newNumber: String) -> Data? {
        let verificationData: [String: String] = [
            "old_phone_prefix": oldPrefix,
            "old_phone": oldNumber,
            "phone_prefix": newPrefix,
            "phone": newNumber,
        ]
        return try? JSONSerialization.data(withJSONObject: verificationData, options: [])
    }

    fileprivate func getProfileAsJSONData(_ profile: LujoUser) -> Data? {
        let profileData: [String: String] = [
//            "title": profile.title.rawValue,
            "firstname": profile.firstName,
            "lastname": profile.lastName,
            "email": profile.email,
            "phone_prefix": String(profile.phoneNumber.countryCode),
            "phone": profile.phoneNumber.number,
            "token": profile.token,
        ]
        return try? JSONSerialization.data(withJSONObject: profileData, options: [])
    }
    
    fileprivate func getUrlDataForPushService(isStaging: Bool) -> (url: String, scheme: String) {
        if isStaging {
            return ("swm5jezyb0.execute-api.us-east-1.amazonaws.com", "/dev")
        }
        
        return ("4h2sxlp6y7.execute-api.us-east-1.amazonaws.com", "/prod")
    }
    
    fileprivate func getAuthTokenForPush(isStaging: Bool) -> String {
        if isStaging {
            return "pvzLFJ3Mhr9grNQsumAh86oEYaXUkZzv49Fjf61q"
        }
        
        return "81INxZA3bV43JEJersZaj9b3t5hFrGNm452JgsOL"
    }
}
