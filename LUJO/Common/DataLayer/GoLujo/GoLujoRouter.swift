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
    case getCities(Taxonomy)
    case getCountries
    case addressDelete(Address)
    case addressUpdate(Address)
    case addressAdd(Address)
    case getAddresses
    case cardDelete(Card)
    case cardUpdate(Card)
    case cardAdd(Card)
    case getCards
    case getReferralTypes
    case getReferralCodeAgainstType(String)
    case refreshToken(String)
    case login(String, String)
    case loginWithOTP(String, String, String)
    case requestLoginOTP(PhoneCountryCode, String, String)
    case createUser(LujoUser,String, String)
    case verify(LoginUser, String)
    case requestOTP(LoginUser, String)
    case updatePhoneNumber(String, String, String, String, String)
    case updateDefaults
    case countryCodes
    case forgotPassword(String)
    case userProfile
    case updateProfile(LujoUser)
    case updateUserImage(LujoUser, UIImage)
    case approved(String)
    case registerForPush(String, String)
    case unregisterForPush(String)
    case getTwilioParticipants(String)
    case deleteAccount
    
    private func getCategory() -> GoLujoRouterCategory {
        switch self {
        case .createUser, .verify, .requestOTP, .requestLoginOTP, .approved, .cardAdd, .addressAdd:
            return .creation
        case .refreshToken, .updatePhoneNumber, .updateProfile, .updateUserImage, .forgotPassword, .cardUpdate, .addressUpdate:
            return .update
        case .login, .loginWithOTP, .updateDefaults, .userProfile, .countryCodes, .registerForPush, .getTwilioParticipants, .getReferralTypes, .getReferralCodeAgainstType, .getCards, .getAddresses, .getCountries, .getCities:
            return .setup
        case .unregisterForPush, .deleteAccount,.cardDelete,.addressDelete:
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
        print("urlRequest:\(String(describing: urlRequest.url))")
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
        case .createUser:       fallthrough
        case .verify:           fallthrough
        case .requestOTP:       fallthrough
        case .requestLoginOTP:  fallthrough
        case .cardAdd:          fallthrough
        case .addressAdd:
            return .post
        case .approved: fallthrough
        case .getReferralTypes: fallthrough
        case .getReferralCodeAgainstType: fallthrough
        case .getCards: fallthrough
        case .getAddresses: fallthrough
        case .getCountries: fallthrough
        case .getCities:
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
        case .cardUpdate: fallthrough
        case .addressUpdate:
            return .put
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
        case .getReferralTypes: fallthrough
        case .getReferralCodeAgainstType: fallthrough
        case .getTwilioParticipants: fallthrough
        case .getCards: fallthrough
        case .getAddresses: fallthrough
        case .getCountries: fallthrough
        case .getCities:
            return .get
        default:
            fatalError("Wrong method category called")
        }
    }
    
    fileprivate func getHTTPMethodDelete() -> HTTPMethod {
        switch self {
        case .unregisterForPush: fallthrough
        case .deleteAccount:  fallthrough
        case .cardDelete:   fallthrough
        case .addressDelete:
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
        case let .getCities(country):
            newURLComponents.path.append("/restaurants/city/search")
            newURLComponents.queryItems = [
                URLQueryItem(name: "country", value: country.termId)
            ]
        case .getCountries:         newURLComponents.path.append("/restaurants/country/search")
        case let .addressDelete(address): newURLComponents.path.append("/users/user-address/delete/" + address.id)
        case let .addressUpdate(address): newURLComponents.path.append("/users/user-address/update/" + address.id)
        case .addressAdd:              newURLComponents.path.append("/users/user-address")
        case .getAddresses:         newURLComponents.path.append("/users/user-address")
        case let .cardDelete(card): newURLComponents.path.append("/users/user-card/delete/" + card.id)
        case let .cardUpdate(card): newURLComponents.path.append("/users/user-card/update/" + card.id)
        case .cardAdd:              newURLComponents.path.append("/users/user-card")
        case .getCards:             newURLComponents.path.append("/users/user-card")
        case let .getReferralCodeAgainstType(discountPercentageEnum):
            newURLComponents.path.append("/users/get-referral-code")
            newURLComponents.queryItems = [
                URLQueryItem(name: "discount_percentage", value: discountPercentageEnum)
            ]
        case .getReferralTypes:     newURLComponents.path.append("/list-referral")
        case .refreshToken:         newURLComponents.path.append("/users/new-token")
        case .login:                newURLComponents.path.append("/users/login")
        case .loginWithOTP:         newURLComponents.path.append("/users/login")
        case .requestLoginOTP:      newURLComponents.path.append("/users/login-otp/")
        case .createUser:           newURLComponents.path.append("/users")
        case .verify:               newURLComponents.path.append("/users/verify")
        case .requestOTP:           newURLComponents.path.append("/users/generate-otp/")
        case .updatePhoneNumber:    newURLComponents.path.append("/users/change-phone")
        case .updateDefaults:       newURLComponents.path.append("/setup")
            newURLComponents.queryItems = [
                URLQueryItem(name: "type", value: "all"),
            ]
        case .countryCodes:         newURLComponents.path.append("/phone-prefix")
            newURLComponents.queryItems = [
                URLQueryItem(name: "id", value: "all"),
            ]
        case .forgotPassword:       newURLComponents.path.append("/users/forgot")
        case .userProfile:          newURLComponents.path.append("/users/profile")
        case .updateProfile:        newURLComponents.path.append("/users/update")
        case .updateUserImage:      newURLComponents.path.append("/users/avatar")
        case let .approved(token):  newURLComponents.path.append("/users/approved")
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
        case let .getTwilioParticipants(type):
            newURLComponents.path.append("/users/twilio")
            newURLComponents.queryItems = [
                URLQueryItem(name: "type", value: type)
            ]
        case .deleteAccount:
            newURLComponents.path.append("/users/delete")
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
        case .getCities: fallthrough
        case .getCountries: fallthrough
        case .getAddresses: fallthrough
        case .getCards: fallthrough
        case .getReferralCodeAgainstType: fallthrough
        case .getReferralTypes: fallthrough
        case .cardDelete:   fallthrough
        case .addressDelete:
            return nil
            
        case let .addressUpdate(address):
            return getAddressAsJSONData(address)
        case let .addressAdd(address):
            return getAddressAsJSONData(address)
        case let .cardUpdate(card):
            return getCardUpdateAsJSONData(card)
        case let .cardAdd(card):
            return getCardAddAsJSONData(card)
        case let .refreshToken(token):
            return getUserTokenAsJSONData(token)
        case let .login(username, password):
            return getCredentialsAsJSONData(username, password)
        case let .loginWithOTP(prefix, number, code):
            return getOTPCredentialsAsJSONData(prefix, number, code)
        case let .requestLoginOTP(prefix, number, captchaToken):
            return getPhoneNumberAsJSONData(prefix, number,captchaToken)
        case let .createUser(user, token, countryName):
            return getCreateUserAsJSONData(user, token, countryName)
        case let .verify(user, code):
            return getVerificationAsJSONData(user, code)
        case let .requestOTP(user, captchaToken):
            return getOTPAsJSONData(user, captchaToken)
        case let .updatePhoneNumber(oldPrefix, oldNumber, newPrefix, newNumber, captchaToken):
            return getUserNameAndPhoneAsJSONData(oldPrefix, oldNumber, newPrefix, newNumber, captchaToken)
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
        case .unregisterForPush:        fallthrough
        case .getTwilioParticipants:    fallthrough
        case .deleteAccount:
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
            "file": imageData
//            ,"token": user.token,
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

    fileprivate func getPhoneNumberAsJSONData(_ prefix: PhoneCountryCode, _ number: String, _ captchaToken:String) -> Data? {
        let credentials: [String: String] = [
            "phone_prefix": prefix.phonePrefix,
            "phone": number,
            "captcha_token" : captchaToken
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
    fileprivate func getCreateUserAsJSONData(_ user: LujoUser,_ token:String,_ countryName:String) -> Data? {
        let profileData: [String: String] = [
            "firstname": user.firstName,
            "lastname": user.lastName,
            "email": user.email.lowercased(),
            "phone_prefix": String(user.phoneNumber.countryCode),
            "phone": user.phoneNumber.number,
            "captcha_token": token,
            "country": countryName,
            "role": "customer"  //{"allowedValues":["admin","agent","customer","owner","super_customer"]}
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

    fileprivate func getOTPAsJSONData(_ user: LoginUser, _ captchaToken: String) -> Data? {
        let verificationData: [String: String] = [
            "phone_prefix": user.prefix,
            "phone": user.phone,
            "captcha_token" : captchaToken
        ]
        return try? JSONSerialization.data(withJSONObject: verificationData, options: [])
    }

    fileprivate func getUserNameAndPhoneAsJSONData(_ oldPrefix: String, _ oldNumber: String, _ newPrefix: String, _ newNumber: String, _ captchaToken: String) -> Data? {
        let verificationData: [String: String] = [
            "old_phone_prefix": oldPrefix,
            "old_phone": oldNumber,
            "phone_prefix": newPrefix,
            "phone": newNumber,
            "captcha_token": captchaToken
        ]
        return try? JSONSerialization.data(withJSONObject: verificationData, options: [])
    }

    fileprivate func getProfileAsJSONData(_ profile: LujoUser) -> Data? {
        let profileData: [String: String] = [
            "firstname": profile.firstName,
            "lastname": profile.lastName,
            "email": profile.email.lowercased(),
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

    fileprivate func getCardUpdateAsJSONData (_ card: Card) -> Data? {
        let profileData: [String: String] = [
            "default_card": card.default_card == true ? "true" : "false"
        ]
        return try? JSONSerialization.data(withJSONObject: profileData, options: [])
    }
    
    fileprivate func getCardAddAsJSONData(_ card: Card) -> Data? {
        var data: [String: Any] = [
            "card_number" : card.masked_card_number,
            "card_holder_name": card.card_holder_name,
            "card_expiry": [
                "month": card.card_expiry.month,
                "year": card.card_expiry.year
            ],
            "default_card": card.default_card
        ]
        if let cvv =  card.cvv{
            data["card_cvv"] = cvv
        }
        return try? JSONSerialization.data(withJSONObject: data, options: [])
    }
    //this method is used for both add and update
    fileprivate func getAddressAsJSONData(_ address: Address) -> Data? {
        var data: [String: Any] = [
            "address" : address.address,
            "apartment": address.apartment,
            "zip_code": address.zip_code,
            "address_type": address.address_type,
            "city": address.city.termId,
            "country": address.country.termId,
            "default_address": address.default_address
        ]
        
        return try? JSONSerialization.data(withJSONObject: data, options: [])
    }
}
