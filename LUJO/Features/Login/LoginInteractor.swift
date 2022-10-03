import Foundation

class LoginInteractor: LoginInteractuable {

    
    private var dataLayer: GoLujoAPIManager
    private var setup: LoginDataStorable

    init(_ dataLayer: GoLujoAPIManager, setup: LoginDataStorable!) {
        self.dataLayer = dataLayer
        self.setup = setup
    }

//    func doLogin(username: String, password: String, completion: @escaping LoginInteractorCallback) {
//        dataLayer.login(username: username, password: password) { token, error in
//            guard error == nil else {
//                guard let loginError = error as? LoginError else {
//                    completion(error!.localizedDescription, .errorLogin(description: error!.localizedDescription))
//                    return
//                }
//                completion("", loginError)
//                return
//            }
//
//            if let setup = self.setup as? AppDefaults, var currentUser = self.setup.getCurrentUser() {
//                setup.updateDefaults {
//                    guard self.getUserStatus() != .noUser else {
//                        completion("", .accountError)
//                        return
//                    }
//
//                    self.dataLayer.approved(user: currentUser, completion: { approved, error in
//                        guard error == nil else {
//                            guard let loginError = error as? LoginError else {
//                                completion(error!.localizedDescription,
//                                           .errorLogin(description: error!.localizedDescription))
//                                return
//                            }
//                            completion(token, loginError)
//                            return
//                        }
//
//                        guard approved else {
//                            completion(token, LoginError.userNotApproved)
//                            return
//                        }
//                        currentUser.approved = true
//                        self.setup.store(currentUser: currentUser)
//
//                        completion(token, nil)
//                    })
//                }
//            }
//        }
//    }

    func doLoginWithOTP(prefix: String, _ number: String, code: String, completion: @escaping LoginInteractorCallback) {
        dataLayer.loginWithOTP(prefix: prefix, number, code: code) { token, error in
            guard error == nil else {
                guard let loginError = error as? LoginError else {
                    completion(error!.localizedDescription, .errorLogin(description: error!.localizedDescription))
                    return
                }
                completion("", loginError)
                return
            }

            if let setup = self.setup as? AppDefaults, var currentUser = self.setup.getCurrentUser() {
                setup.updateDefaults {
                    guard self.getUserStatus() != .noUser else {
                        completion("", .accountError)
                        return
                    }

                    self.dataLayer.approved(user: currentUser, completion: { approved, error in
                        guard error == nil else {
                            guard let loginError = error as? LoginError else {
                                completion(error!.localizedDescription,
                                           .errorLogin(description: error!.localizedDescription))
                                return
                            }
                            completion(token, loginError)
                            return
                        }

                        guard approved else {
                            completion(token, LoginError.userNotApproved)
                            return
                        }
                        currentUser.approved = true
                        self.setup.store(currentUser: currentUser)

                        completion(token, nil)
                    })
                }
            }
        }
    }

    func createAccount(_ user: LujoUser,captchaToken:String, completion: @escaping LoginInteractorCallback) {
        dataLayer.create(user: user, captchaToken: captchaToken) { result, error in
            guard error == nil else {
                guard let createError = error as? LoginError else {
                    completion(error!.localizedDescription, .errorLogin(description: error!.localizedDescription))
                    return
                }

                completion("", createError)
                return
            }
            let currentUser = LoginUser(prefix: user.phoneNumber.countryCode, phone: user.phoneNumber.number, token: nil, approved: false)
            self.setup.store(currentUser: currentUser)
            self.setup.store(userInfo: user)

            completion(result, nil)
        }
    }

    func requestVerificationCode(captchaToken:String, completion: @escaping LoginInteractorCallback) {
        guard let currentUser = self.setup.getCurrentUser() else {
            completion("", LoginError.errorLogin(description: "User not logged in"))
            return
        }
        dataLayer.requestOTP(for: currentUser, captchaToken: captchaToken) { result, error in
            guard error == nil else {
                guard let verificationError = error as? LoginError else {
                    completion(error!.localizedDescription, .errorLogin(description: error!.localizedDescription))
                    return
                }
                completion("", verificationError)
                return
            }
            completion(result, nil)
        }
    }

    func requestLoginVerificationCode(prefix: PhoneCountryCode, _ number: String, _ captchaToken: String, completion: @escaping LoginInteractorCallback) {
        dataLayer.requestLoginOTP(prefix: prefix, number, captchaToken) { result, error in
            guard error == nil else {
                guard let verificationError = error as? LoginError else {
                    completion(error!.localizedDescription, .errorLogin(description: error!.localizedDescription))
                    return
                }
                completion("", verificationError)
                return
            }
            completion(result, nil)
        }
    }

    func verify(with code: String, completion: @escaping LoginInteractorCallback) {
        guard var currentUser = self.setup.getCurrentUser() else {
            completion("", .errorLogin(description: "There is no user in the app"))
            return
        }
        dataLayer.requestVerification(for: currentUser, withCode: code) { result, error in
            guard error == nil else {
                guard let verificationError = error as? LoginError else {
                    completion(error!.localizedDescription, .errorLogin(description: error!.localizedDescription))
                    return
                }
                completion("", verificationError)
                return
            }

            completion(result, nil)
        }
    }

    func getUserStatus() -> UserStatus {
        guard let currentUser = self.setup.getCurrentUser() else {
            return .noUser
        }

        guard currentUser.token != nil else {
            return .unverified
        }

        guard currentUser.approved else {
            return .verified
        }

        guard setup.getCurrentUser() != nil else {
            return .other
        }

        return .approved
    }

    func updateUserPhone(oldPrefix: String, oldNumber: String, newPrefix: String, newNumber: String,captchaToken:String, completion: @escaping LoginInteractorCallback) {
        guard let currentUser = self.setup.getCurrentUser() else {
            completion("", LoginError.errorLogin(description: "User not logged in"))
            return
        }

        dataLayer.update(oldPrefix: oldPrefix, oldNumber: oldNumber, newPrefix: newPrefix, newNumber: newNumber,captchaToken:captchaToken) { _, error in
            if error == nil {
                completion("", nil)
                return
            }

            if let loginError = error as? LoginError {
                completion("", loginError)
                return
            }

            completion("", LoginError.errorLogin(description: error!.localizedDescription))
        }
    }

    func forgotPassword(for user: String, completion: @escaping LoginInteractorCallback) {
        dataLayer.forgot(user: user) { _, error in
            if error == nil {
                completion("", nil)
                return
            }

            if let loginError = error as? LoginError {
                completion("", loginError)
                return
            }

            completion("", LoginError.errorLogin(description: error!.localizedDescription))
        }
    }

    func getUserApproval(completion: @escaping (Bool, Error?) -> Void) {
        guard let currentUser = self.setup.getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            completion(false, LoginError.errorLogin(description: "User does not exist or is not verified"))
            return
        }

        dataLayer.approved(user: currentUser, completion: { approved, error in
            guard error == nil else {
                guard let loginError = error as? LoginError else {
                    completion(false, LoginError.errorLogin(description: error!.localizedDescription))
                    return
                }
                completion(false, loginError)
                return
            }

            completion(approved, nil)
        })
    }

    func logoutUser() {
        setup.deleteCurrentUser()
    }
}
