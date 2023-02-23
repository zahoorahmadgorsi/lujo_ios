import Alamofire
import FirebaseCrashlytics
import UIKit

struct LUJOLoginResponse: Codable {
    let token: String
    let error: String
}

struct LUJOTokenReponse: Codable {
    let token: String
    let expiration: TimeInterval
}

struct LUJOAvatarResponse: Codable {
    let code: Int
    let type: String
    let content: String
}

class GoLujoAPIManager {
    
}

extension GoLujoAPIManager {
    
    func refreashToken(completionHandler: @escaping (Bool) -> Void) {
        guard let token = LujoSetup().getCurrentUser()?.token else {
            print("ERROR: there is no token")
            completionHandler(false)
            return
        }
        
        Alamofire.request(GoLujoRouter.refreshToken(token))
            .responseJSON { response in
                guard let result = try? JSONDecoder().decode(LujoServerResponse<LUJOTokenReponse>.self, from: response.data!), result.code == 200, var currentUser = LujoSetup().getCurrentUser() else {
                    print ("Error: \(response.error?.localizedDescription ?? "can't get new token :(")")
                    completionHandler(false)
                    
                    DispatchQueue.main.async {
                        guard let userId = LujoSetup().getLujoUser()?.id else {
                            print("NO USER ID ERROR!!!")
                            return
                        }
                        
                        LujoSetup().deleteCurrentUser()
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.removePushToken(userId: userId)
                        
                          // Present login view controller using VIPER.
                        appDelegate.windowRouter.navigate(from: "/", data: [:])
                    }
                    return
                }
                
                currentUser.token = result.content.token
                currentUser.tokenExpiration = result.content.expiration
                LujoSetup().store(currentUser: currentUser)
                                   
                completionHandler(true)
            }
    }
    
    func loginWithOTP(prefix: String, _ number: String, code: String, completionHandler: @escaping DataLayerCallback) {
        Alamofire.request(GoLujoRouter.loginWithOTP(prefix, number, code))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completionHandler("", LoginError.errorLogin(description: response.result.error!.localizedDescription))
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completionHandler("", LoginError.errorLogin(description: "Unhandled response from server"))
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    self.reportError(statusCode, response)
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<LUJOTokenReponse>.self, from: response.data!)
                    else {
                        let errorDescription = "Unable to login user, plase try again"
                        completionHandler("", LoginError.errorLogin(description: errorDescription))
                        return
                    }
                
                    let currentUser = LoginUser(prefix: prefix, phone: number, token: result.content.token, tokenExpiration: result.content.expiration, approved: false)
                    LujoSetup().store(currentUser: currentUser)
                    
                    completionHandler(result.content.token, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    self.reportError(statusCode, response)
                case 400 ... 499: // Client Error
                    self.handleError(response, statusCode, completion: completionHandler)
                default: // 500 or bigger, Server Error
                    self.handleError(response, statusCode, completion: completionHandler)
                }
            }
    }

    static let shared = GoLujoAPIManager()

    func login(username: String, password: String, completionHandler: @escaping DataLayerCallback) {
        Alamofire.request(GoLujoRouter.login(username, password))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completionHandler("", LoginError.errorLogin(description: response.result.error!.localizedDescription))
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completionHandler("", LoginError.errorLogin(description: "Unhandled response from server"))
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    self.reportError(statusCode, response)
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<LUJOTokenReponse>.self, from: response.data!)
                    else {
                        let errorDescription = "Unable to login user, plase try again"
                        completionHandler("", LoginError.errorLogin(description: errorDescription))
                        return
                    }
                    
                    let currentUser = LoginUser(prefix: "", phone: "", token: result.content.token, tokenExpiration: result.content.expiration, approved: false)
                    LujoSetup().store(currentUser: currentUser)
                    
                    completionHandler(result.content.token, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    self.reportError(statusCode, response)
                case 400 ... 499: // Client Error
                    self.handleError(response, statusCode, completion: completionHandler)
                default: // 500 or bigger, Server Error
                    self.handleError(response, statusCode, completion: completionHandler)
                }
            }
    }

    func requestLoginOTP(prefix: PhoneCountryCode, _ number: String,_ captchaToken:String, completionHandler: @escaping DataLayerCallback) {
        Alamofire.request(GoLujoRouter.requestLoginOTP(prefix, number,captchaToken))
            .responseJSON { response in
                switch response.result {
                case .success:
                    guard let statusCode = response.response?.statusCode else {
                        completionHandler("", LoginError.errorLogin(description: "Unhandled response from server"))
                        return
                    }
                    guard (200 ... 299).contains(statusCode) else {
                        let result = try? JSONDecoder().decode(LujoServerResponse<String>.self, from: response.data!)
                        completionHandler("", LoginError.errorLogin(description: result?.content ?? "Some error happend, please try again later."))
                        return
                    }
                    completionHandler("", nil)
                case let .failure(error):
                    if error._code == NSURLErrorTimedOut {
                        completionHandler("", nil)
                        return
                    }
                    completionHandler("", LoginError.errorLogin(description: response.result.error!.localizedDescription))
                }
            }
    }
    

    func create(user: LujoUser,captchaToken:String, countryName:String ,completionHandler: @escaping DataLayerCallback) {
        Alamofire.request(GoLujoRouter.createUser(user, captchaToken, countryName)).responseJSON { response in
            guard response.result.error == nil else {
                completionHandler("", LoginError.errorLogin(description: response.result.error!.localizedDescription))
                return
            }

            guard let statusCode = response.response?.statusCode else {
                completionHandler("", LoginError.errorLogin(description: "Unhandled response from server"))
                return
            }

            switch statusCode {
            case 1 ... 199: // Transfer protoco-level information: Unexpected
                self.reportError(statusCode, response)
            case 200 ... 299: // Success
                completionHandler("", nil)
                return
            case 300 ... 399: // Redirection: Unexpected
                self.reportError(statusCode, response)
            case 400 ... 499: // Client Error
                self.handleError(response, statusCode, completion: completionHandler)
            default: // 500 or bigger, Server Error
                self.handleError(response, statusCode, completion: completionHandler)
            }
        }
    }

    func requestVerification(for user: LoginUser, withCode code: String, completionHandler: @escaping DataLayerCallback) {
        Alamofire.request(GoLujoRouter.verify(user, code))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completionHandler("", LoginError.errorLogin(description: response.result.error!.localizedDescription))
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completionHandler("", LoginError.errorLogin(description: "Unhandled response from server"))
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    self.reportError(statusCode, response)
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<LUJOTokenReponse>.self, from: response.data!), var currentUser = LujoSetup().getCurrentUser()
                    else {
                        //User verification response format is invalid
                        let errorDescription = "User verification failed, plase contact at support@golujo.com"
                        completionHandler("", LoginError.errorLogin(description: errorDescription))
                        return
                    }
                    
//                    DispatchQueue.main.async {    //commenting to make it synch call as we need this token immediately
                        currentUser.token = result.content.token
                        currentUser.tokenExpiration = result.content.expiration
                        LujoSetup().store(currentUser: currentUser)
//                    }
                    
                    completionHandler(result.content.token, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    self.reportError(statusCode, response)
                case 400 ... 499: // Client Error
                    self.handleError(response, statusCode, completion: completionHandler)
                default: // 500 or bigger, Server Error
                    self.handleError(response, statusCode, completion: completionHandler)
                }
            }
    }

    func requestOTP(for user: LoginUser, captchaToken:String, completionHandler: @escaping DataLayerCallback) {
        Alamofire.request(GoLujoRouter.requestOTP(user, captchaToken))
            .responseJSON { response in
                switch response.result {
                case .success:
                    guard let statusCode = response.response?.statusCode else {
                        completionHandler("", LoginError.errorLogin(description: "Unhandled response from server"))
                        return
                    }
                    guard (200 ... 299).contains(statusCode) else {
                        let result = try? JSONDecoder().decode(LujoServerResponse<String>.self, from: response.data!)
                        completionHandler("", LoginError.errorLogin(description: result?.content ?? "Server error \(statusCode)"))
                        return
                    }
                    completionHandler("", nil)
                case let .failure(error):
                    if error._code == NSURLErrorTimedOut {
                        completionHandler("", nil)
                        return
                    }
                    completionHandler("", LoginError.errorLogin(description: response.result.error!.localizedDescription))
                }
            }
    }

    func update(oldPrefix: String, oldNumber: String, newPrefix: String, newNumber: String,captchaToken:String, completion: @escaping DataLayerCallback) {
        Alamofire.request(GoLujoRouter.updatePhoneNumber(oldPrefix, oldNumber, newPrefix, newNumber, captchaToken))
            .responseJSON { response in
                switch response.result {
                case .success:
                    guard let statusCode = response.response?.statusCode,
                        let result = try? JSONDecoder().decode(LujoServerResponse<String>.self, from: response.data!)
                    else {
                        completion("", LoginError.errorLogin(description: "Unhandled response from server"))
                        return
                    }
//                    guard (200 ... 299).contains(statusCode) else {
//                        completion("", LoginError.errorLogin(description: result.content))
//                        return
//                    }
                    guard (200 ... 299).contains(statusCode) else {
                        completion("", LoginError.errorLogin(description: result.content ))
                        return
                    }
                    completion("", nil)
                case let .failure(error):
                    if error._code == NSURLErrorTimedOut {
                        completion("", nil)
                        return
                    }
                    completion("", LoginError.errorLogin(description: response.result.error!.localizedDescription))
                }
            }
    }

    func forgot(user password: String, completion: @escaping DataLayerCallback) {
        Alamofire.request(GoLujoRouter.forgotPassword(password))
            .responseJSON { response in
                switch response.result {
                case .success:
                    guard let statusCode = response.response?.statusCode,
                        let result = try? JSONDecoder().decode(LujoServerResponse<String>.self, from: response.data!)
                    else {
                        completion("", LoginError.errorLogin(description: "Unhandled response from server"))
                        return
                    }
                    guard (200 ... 299).contains(statusCode) else {
                        completion("", LoginError.errorLogin(description: result.content))
                        return
                    }
                    completion("", nil)
                case let .failure(error):
                    if error._code == NSURLErrorTimedOut {
                        completion("", nil)
                        return
                    }
                    completion("", LoginError.errorLogin(description: response.result.error!.localizedDescription))
                }
            }
    }

    func getDefaults(completion: @escaping ([String: Any], Error?) -> Void) {
        Alamofire.request(GoLujoRouter.updateDefaults)
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion([:], LoginError.errorLogin(description: response.result.error!.localizedDescription))
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion([:], LoginError.errorLogin(description: "Unhandled response from server"))
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    self.reportError(statusCode, response)
                case 200 ... 299: // Success
                    guard let fullResult = response.result.value as? [String: AnyObject] else {
                        let errorDescription = "Unable to parse setup"
                        completion([:], LoginError.errorLogin(description: errorDescription))
                        return
                    }

                    guard let content = fullResult["content"] as? [String: Any] else {
                        let errorDescription = "Unable to parse setup"
                        completion([:], LoginError.errorLogin(description: errorDescription))
                        return
                    }
                    completion(content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    self.reportError(statusCode, response)
                case 400 ... 499: // Client Error
                    self.reportError(statusCode, response)
                default: // 500 or bigger, Server Error
                    self.reportError(statusCode, response)
                }
            }
    }

    func getCountryCodes(completion: @escaping ([PhoneCountryCode], Error?) -> Void) {
        Alamofire.request(GoLujoRouter.countryCodes)
            .responseJSON { response in
                switch response.result {
                case .success:
                    guard let statusCode = response.response?.statusCode else {
                        completion([], LoginError.errorLogin(description: "Unhandled response from server"))
                        return
                    }
                    guard (200 ... 299).contains(statusCode) else {
                        completion([], LoginError.errorLogin(description: "Unable to retrieve country codes"))
                        return
                    }

                    guard let response = try? JSONDecoder().decode(LujoServerResponse<[PhoneCountryCode]>.self,
                                                                   from: response.data!)
                    else {
                        completion([], LoginError.errorLogin(description: "Error reading country codes"))
                        return
                    }

                    completion(response.content, nil)
                    return
                case let .failure(error):
                    completion([], error)
                    return
                }
            }
    }

    func userProfile(for token: String, completion: @escaping (LujoUser?, Error?) -> Void) {
        Alamofire.request(GoLujoRouter.userProfile)
            .responseJSON { response in
                print("Request URL: \(String(describing: response.request)) \nRequest Body: \(String(data: response.request?.httpBody ?? Data(), encoding: .utf8)!) \nResponse Body: \(String(data: response.data ?? Data(), encoding: .utf8)!)")

                switch response.result {
                case .success:
                    guard let statusCode = response.response?.statusCode else {
                        completion(nil, LoginError.errorLogin(description: "Unhandled response from server"))
                        return
                    }
                    guard (200 ... 299).contains(statusCode) else {
                        let result = try? JSONDecoder().decode(LujoServerResponse<String>.self, from: response.data!)
                        completion(nil , LoginError.errorLogin(description: result?.content ?? "User profile could not updated"))
                        return
                    }
                    do {
                        let resultResponse = try JSONDecoder().decode(UserProfileResponse.self, from: response.data!)

                        let user = LujoUser(id: resultResponse.content.id,
                                            title: UserTitle(rawValue: resultResponse.content.title ?? "Mr."),
                                            firstName: resultResponse.content.firstname,
                                            lastName: resultResponse.content.lastname,
                                            email: resultResponse.content.email.lowercased(),
                                            phoneNumber: PhoneNumber(countryCode: resultResponse.content.phone_prefix,
                                                                     number: resultResponse.content.phone),
                                            password: "",
                                            avatar: resultResponse.content.avatar ?? "",
                                            token: token,
                                            approved: resultResponse.content.approved,
                                            referralCode: resultResponse.content.referralCode,
                                            points: resultResponse.content.points,
                                            membershipPlan: resultResponse.content.membershipPlan,
                                            sfid: resultResponse.content.sfid
                                            ,membershipPlanExpiration: resultResponse.content.membershipPlanExpiration
                                            ,isEmailVerified: resultResponse.content.isEmailVerified)
                        completion(user, nil)

                    } catch {
                        print(error)
                        completion(nil, error)
                    }
                case let .failure(error):
                    if error._code == NSURLErrorTimedOut {
                        completion(nil, nil)
                        return
                    }
                    completion(nil, LoginError.errorLogin(description: response.result.error!.localizedDescription))
                }
            }
    }
    
    func registerForOurPushService(userId: String, deviceToken: String) {
        Alamofire.request(GoLujoRouter.registerForPush(userId, deviceToken)).responseJSON { response in
            guard let statusCode = response.response?.statusCode else {
                print("DEBUG:: Unhandled response from server")
                return
            }
            guard (200 ... 299).contains(statusCode) else {
                print("DEBUG:: Server error \(statusCode)")
                return
            }
            print("DEBUG:: SUCCESS")
        }
    }
    
    func unregisterForOurPushService(userId: String) {
        Alamofire.request(GoLujoRouter.unregisterForPush(userId)).responseJSON { response in
            guard let statusCode = response.response?.statusCode else {
                print("DEBUG:: Unhandled response from server")
                return
            }
            guard (200 ... 299).contains(statusCode) else {
                print("DEBUG:: Server error \(statusCode)")
                return
            }
            print("DEBUG:: SUCCESS")
        }
    }

    func update(user profile: LujoUser, completion: @escaping (Error?) -> Void) {
        Alamofire.request(GoLujoRouter.updateProfile(profile))
            .responseJSON { response in
                print("Request URL: \(String(describing: response.request)) \tRequest Body: \(String(data: response.request?.httpBody ?? Data(), encoding: .utf8)!) \tResponse Body: \(String(data: response.data ?? Data(), encoding: .utf8)!)")
                
                switch response.result {
                case .success:
                    guard let statusCode = response.response?.statusCode else {
                        completion(LoginError.errorLogin(description: "Unhandled response from server"))
                        return
                    }
                    guard (200 ... 299).contains(statusCode) else {
                        let result = try? JSONDecoder().decode(LujoServerResponse<String>.self, from: response.data!)
                        completion(LoginError.errorLogin(description: result?.content ?? "Some error happend, please try again later."))
                        
                        return
                    }
                    completion(nil)
                case let .failure(error):
                    if error._code == NSURLErrorTimedOut {
                        completion(nil)
                        return
                    }
                    completion(LoginError.errorLogin(description: response.result.error!.localizedDescription))
                }
            }
    }

    func update(user: LujoUser, image: UIImage, completion: @escaping (String?, Error?) -> Void) {
        Alamofire.request(GoLujoRouter.updateUserImage(user, image))
            .responseJSON { response in
                switch response.result {
                case .success:
                    guard let statusCode = response.response?.statusCode else {
                        completion(nil, LoginError.errorLogin(description: "Unhandled response from server"))
                        return
                    }
                    guard (200 ... 299).contains(statusCode) else {
                        let result = try? JSONDecoder().decode(LujoServerResponse<String>.self, from: response.data!)
                        completion(nil, LoginError.errorLogin(description: result?.content ?? "Server error \(statusCode)"))
                        return
                    }
                    guard let data = response.data else {
                        completion(nil, LoginError.errorLogin(description: "There is no data returned from the server"))
                        return
                    }
                    let avatarResponse = try! JSONDecoder().decode(LUJOAvatarResponse.self, from: data)
                    completion(avatarResponse.content, nil)
                    
                case let .failure(error):
                    if error._code == NSURLErrorTimedOut {
                        completion(nil, nil)
                        return
                    }
                    completion(nil, LoginError.errorLogin(description: response.result.error!.localizedDescription))
                }
            }
    }

    func approved(user: LoginUser, completion: @escaping (Bool, Error?) -> Void) {
        guard let token = user.token else {
            completion(false, LoginError.errorLogin(description: "Missing user token"))
            return
        }
        Alamofire.request(GoLujoRouter.approved(token)).responseJSON { response in
            switch response.result {
            case .success:
                guard let statusCode = response.response?.statusCode else {
                    completion(false, LoginError.errorLogin(description: "Unhandled response from server"))
                    return
                }
                guard (200 ... 299).contains(statusCode) else {
                    let result = try? JSONDecoder().decode(LujoServerResponse<String>.self, from: response.data!)
                    completion(false, LoginError.errorLogin(description: result?.content ?? "Server error \(statusCode)"))
                    return
                }

                guard let resultResponse = try? JSONDecoder().decode(LujoServerResponse<Bool>.self,
                                                                     from: response.data!)
                else {
                    completion(false, LoginError.errorLogin(description: "Error parsing server response"))
                    return
                }

                completion(resultResponse.content, nil)
                return
            case let .failure(error):
                completion(false, error)
                return
            }
        }
    }

    func getReferralTypes(completion: @escaping ([ReferralType]?, Error?) -> Void) {
        Alamofire.request(GoLujoRouter.getReferralTypes)
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<[ReferralType]>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func getReferralCodeAgainstType(_ discountPercentageEnum: String, completion: @escaping (ReferralCode?, Error?) -> Void) {
        Alamofire.request(GoLujoRouter.getReferralCodeAgainstType(discountPercentageEnum))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<ReferralCode>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func deleteAccount( completion: @escaping (String?, Error?) -> Void) {
        Alamofire.request(GoLujoRouter.deleteAccount)
            .responseJSON { response in
                switch response.result {
                case .success:
                    guard let statusCode = response.response?.statusCode else {
                        completion(nil, LoginError.errorLogin(description: "Unhandled response from server"))
                        return
                    }
                    guard (200 ... 299).contains(statusCode) else {
                        let result = try? JSONDecoder().decode(LujoServerResponse<String>.self, from: response.data!)
                        completion(nil, LoginError.errorLogin(description: result?.content ?? "Server error \(statusCode)"))
                        return
                    }
                    guard let data = response.data else {
                        completion(nil, LoginError.errorLogin(description: "There is no data returned from the server"))
                        return
                    }
                    let deleteAccountResponse = try! JSONDecoder().decode(LujoServerResponse<String>.self, from: data)
                    completion(deleteAccountResponse.content, nil)
                    
                case let .failure(error):
                    if error._code == NSURLErrorTimedOut {
                        completion(nil, nil)
                        return
                    }
                    completion(nil, LoginError.errorLogin(description: response.result.error!.localizedDescription))
                }
            }
    }
    
    func getCards(completion: @escaping ([Card]?, Error?) -> Void) {
        Alamofire.request(GoLujoRouter.getCards)
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<[Card]>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func cardAdd(_ card: Card, completion: @escaping (CardResponse?, Error?) -> Void) {
        Alamofire.request(GoLujoRouter.cardAdd(card))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<CardResponse>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func cardUpdate(_ card: Card, completion: @escaping (String, Error?) -> Void) {
        Alamofire.request(GoLujoRouter.cardUpdate(card))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion("", response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion("", BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion("", self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion("", BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion("", self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion("", self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion("", self.handleError(response, statusCode))
                }
            }
    }
    
    func cardDelete(_ card: Card, completion: @escaping (String, Error?) -> Void) {
        Alamofire.request(GoLujoRouter.cardDelete(card))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion("", response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion("", BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion("", self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion("", BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion("", self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion("", self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion("", self.handleError(response, statusCode))
                }
            }
    }
    
    func getAddresses(completion: @escaping ([Address]?, Error?) -> Void) {
        Alamofire.request(GoLujoRouter.getAddresses)
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<[Address]>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func addressAdd(_ address: Address, completion: @escaping (CardResponse?, Error?) -> Void) {
        Alamofire.request(GoLujoRouter.addressAdd(address))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<CardResponse>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func addressUpdate(_ address: Address, completion: @escaping (String, Error?) -> Void) {
        Alamofire.request(GoLujoRouter.addressUpdate(address))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion("", response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion("", BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion("", self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion("", BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion("", self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion("", self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion("", self.handleError(response, statusCode))
                }
            }
    }
    
    func addressDelete(_ address: Address, completion: @escaping (String, Error?) -> Void) {
        Alamofire.request(GoLujoRouter.addressDelete(address))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion("", response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion("", BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion("", self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion("", BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion("", self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion("", self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion("", self.handleError(response, statusCode))
                }
            }
    }
    
    func getCounntries( completion: @escaping ([Taxonomy], Error?) -> Void) {
        Alamofire.request(GoLujoRouter.getCountries)
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion([], response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion([], BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion([], self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<[Taxonomy]>.self,
                                                                 from: response.data!)
                    else {
                        completion([], BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion([], self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion([], self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion([], self.handleError(response, statusCode))
                }
            }
    }

    func getCities( _ country:Taxonomy, completion: @escaping ([Taxonomy], Error?) -> Void) {
        Alamofire.request(GoLujoRouter.getCities(country))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion([], response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion([], BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion([], self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<[Taxonomy]>.self,
                                                                 from: response.data!)
                    else {
                        completion([], BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion([], self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion([], self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion([], self.handleError(response, statusCode))
                }
            }
    }
    
    func resendEmailVerificationLink( completion: @escaping (String?, Error?) -> Void) {
        Alamofire.request(GoLujoRouter.resendEmailVerificationLink)
            .responseJSON { response in
                switch response.result {
                case .success:
//                    guard let statusCode = response.response?.statusCode else {
//                        completion(nil, LoginError.errorLogin(description: "Unhandled response from server"))
//                        return
//                    }
//                    guard (200 ... 299).contains(statusCode) else {
//                        let result = try? JSONDecoder().decode(LujoServerResponse<String>.self, from: response.data!)
//                        completion(nil, LoginError.errorLogin(description: result?.content ?? "Server error \(statusCode)"))
//                        return
//                    }
//                    guard let data = response.data else {
//                        completion(nil, LoginError.errorLogin(description: "There is no data returned from the server"))
//                        return
//                    }
//                    let strResponse = try! JSONDecoder().decode(String.self, from: data)
//                    completion(strResponse, nil)
                    
                    guard let statusCode = response.response?.statusCode else {
                        completion(nil, LoginError.errorLogin(description: "Unhandled response from server"))
                        return
                    }
                    guard (200 ... 299).contains(statusCode) else {
                        let result = try? JSONDecoder().decode(LujoServerResponse<String>.self, from: response.data!)
                        completion(nil, LoginError.errorLogin(description: result?.content ?? "Server error \(statusCode)"))
                        return
                    }
                    guard let data = response.data else {
                        completion(nil, LoginError.errorLogin(description: "There is no data returned from the server"))
                        return
                    }
                    let strResponse = try! JSONDecoder().decode(LujoServerResponse<String>.self, from: data)
                    completion(strResponse.content, nil)
                    
                case let .failure(error):
                    if error._code == NSURLErrorTimedOut {
                        completion(nil, nil)
                        return
                    }
                    completion(nil, LoginError.errorLogin(description: response.result.error!.localizedDescription))
                }
            }
    }
    
    // MARK: Helper methods

    fileprivate func handleSuccess(_ json: [String: Any],
                                   keys: [String]?,
                                   completion completionHandler: @escaping DataLayerCallback) {
        guard let requestedKeys = keys else {
            completionHandler("", nil)
            return
        }

        var values = [Any]()

        for aKey in requestedKeys {
            if let newValue = json[aKey] {
                values.append(newValue)
            }
        }

        var result = ""
        if values.count == 1 {
            guard let singleResult = values[0] as? String else {
                completionHandler("", nil)
                return
            }
            result = singleResult
        } else {
            result = values.reduce("") { text, value in "\(text), \(value)" }
        }

        completionHandler(result, nil)
    }

    fileprivate func handleError(_ response: DataResponse<Any>,
                                 _ statusCode: Int,
                                 completion completionHandler: @escaping DataLayerCallback) {
        var serverError: String!
        do {
            let errorResult = try JSONDecoder().decode(LujoServerResponse<String>.self, from: response.data!)
            serverError = errorResult.content
        } catch {
            serverError = "Unknown server error"
        }
        completionHandler(String(statusCode), LoginError.errorLogin(description: serverError))
    }

    fileprivate func handleError(_ response: DataResponse<Any>,
                                 _ statusCode: Int) -> Error {
        var serverError: String!
        do {
            let errorResult = try JSONDecoder().decode(LujoServerResponse<String>.self, from: response.data!)
            serverError = errorResult.content
        } catch {
            serverError = "Unknown server error"
        }
        reportError(statusCode, response)
        return BackendError.unexpectedCode(description: serverError)
    }
    
    fileprivate func reportError(_ statusCode: Int, _ response: DataResponse<Any>) {
        let sourceURL = String(describing: response.request?.url)
        let error = NSError(domain: NSURLErrorDomain,
                            code: NSURLErrorBadServerResponse,
                            userInfo: [
                                NSLocalizedDescriptionKey: "Unexpected \(statusCode) received on \(sourceURL)",
                                NSLocalizedFailureReasonErrorKey: "Expected code 20X, 40X or 50X",
                            ])
        Crashlytics.crashlytics().record(error: error)
    }
    
}
