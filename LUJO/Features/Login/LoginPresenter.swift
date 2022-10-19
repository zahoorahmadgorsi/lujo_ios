import UIKit

enum LoginError: Error, Equatable {
    case missingUsername
    case missingPassword
    case missingData
    case passwordMistmatch
    case missingTermsOfUse
    case userNotApproved
    case accountError
    case errorLogin(description: String)
    case phoneLessThen6Digits
    case missingCorrectPhoneNumber

    var errorCode: Int {
        switch self {
        case .missingUsername:
            return 1
        case .missingPassword:
            return 2
        case .missingData:
            return 3
        case .passwordMistmatch:
            return 4
        case .missingTermsOfUse:
            return 5
        case .userNotApproved:
            return 6
        case .accountError:
            return 7
        case .errorLogin:
            return 8
        case .phoneLessThen6Digits:
            return 9
        case .missingCorrectPhoneNumber:
            return 10
        }
    }
}

extension LoginError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .missingUsername:
            return NSLocalizedString("Username is missing.", comment: "")
        case .missingPassword:
            return NSLocalizedString("Password is missing.", comment: "")
        case .missingData:
            return NSLocalizedString("Please provide all needed data.", comment: "")
        case .passwordMistmatch:
            return NSLocalizedString("Username or password are wrong.", comment: "")
        case .missingTermsOfUse:
            return NSLocalizedString("Terms of use not accepted.", comment: "")
        case .userNotApproved:
            return NSLocalizedString("User is not approved", comment: "")
        case .accountError:
            return NSLocalizedString("User account returner an error", comment: "")
        case let .errorLogin(description):
            return NSLocalizedString(description, comment: "")
        case .phoneLessThen6Digits:
            return NSLocalizedString("Phone number must have at least 6 digits.", comment: "")
        case .missingCorrectPhoneNumber:
            return NSLocalizedString("Phone number is invalid. Please check it and try again.", comment: "")
        }
    }
}

class LoginPresenter: Presentable, LoginViewResponder {
    

    
    var view: Viewable {
        return presenterView
    }

    var route: String = ""

    private(set) var presenterView: LoginViewProtocol
    private var presenterInteractor: LoginInteractuable!

    private var currentUser: LujoUser?

    weak var router: WireFrame?

    private lazy var initialUserCheckout: Void = {
        LujoSetup().updateDefaults({
            let currentUserStatus = self.presenterInteractor.getUserStatus()

            guard currentUserStatus != .noUser else {
                self.presenterView.hideSplashView()
                return
            }

            guard currentUserStatus != .unverified else {//                self.requestOTP() //commenting this because now captcha verificatino is required for this API to work
                self.presenterView.hideSplashView()
                LujoSetup().updateDefaults {}
                return
            }

            if currentUserStatus == .verified {
                self.presenterView.showView("JumpUnapproved", data: nil)
                return
            }

            UserDefaults.standard.set(true, forKey: "showWelcome")
            self.router?.navigate(from: self.route, data: ["result": "Home" as AnyObject])
        })
    }()

    required init(view: LoginViewProtocol, interactor: LoginInteractuable) {
        presenterView = view
        presenterInteractor = interactor
        presenterView.presenter = self
    }

    // MARK: Login Responder Methods

    func doLogin(username: String, password: String) throws {
        guard !username.isEmpty else {
            throw LoginError.missingUsername
        }

        guard !password.isEmpty else {
            throw LoginError.missingPassword
        }

        view.showNetworkActivity()

//        presenterInteractor.doLogin(username: username, password: password) { [weak self] _, error in
//            self?.view.hideNetworkActivity()
//
//            guard error == nil else {
//                if error == LoginError.userNotApproved {
//                    self?.presenterView.showView("JumpUnapproved", data: nil)
//                    return
//                }
//                if error == LoginError.accountError {
//                    self?.presenterView.showView("ShowAccountError", data: nil)
//                    return
//                }
//                self?.presenterView.showError(error!)
//                return
//            }
//
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//            appDelegate.registerForPushNotifications()
//
//            guard let origin = self?.route, !origin.isEmpty else {
//                return
//            }
//
//            self?.showHomeScreen()
//        }
    }

    func doLoginWithOTP(prefix: PhoneCountryCode?, _ number: String?, code: String) throws {
        guard let phonePrefix = prefix?.phonePrefix, !phonePrefix.isEmpty else {
            throw LoginError.missingCorrectPhoneNumber
        }

        guard let phoneNumber = number, !phoneNumber.isEmpty else {
            throw LoginError.missingCorrectPhoneNumber
        }

        view.showNetworkActivity()

        presenterInteractor.doLoginWithOTP(prefix: phonePrefix, phoneNumber, code: code) { [weak self] _, error in
            self?.view.hideNetworkActivity()

            guard error == nil else {
                if error == LoginError.userNotApproved {
                    self?.presenterView.showView("JumpUnapproved", data: nil)
                    return
                }
                if error == LoginError.accountError {
                    self?.presenterView.showView("ShowAccountError", data: nil)
                    return
                }
                self?.presenterView.showError(error!)
                return
            }

            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.registerForPushNotifications()

            guard let origin = self?.route, !origin.isEmpty else {
                return
            }

            UserDefaults.standard.set(true, forKey: "showWelcome")
            self?.showHomeScreen()
        }
    }

    func createAccount(title: UserTitle,
                       firstName: String,
                       lastName: String,
                       email: String,
                       phoneNumber: PhoneNumber
                       ,captchaToken:String
                       ,countryName:String) throws {
        guard !firstName.isEmpty else { throw LoginError.missingData }
        guard !lastName.isEmpty else { throw LoginError.missingData }
        guard !email.isEmpty else { throw LoginError.missingData }
        guard !phoneNumber.isEmpty else { throw LoginError.missingData }
        guard phoneNumber.number.count > 5 else { throw LoginError.phoneLessThen6Digits }

        guard isValid(email: email) else { throw LoginError.errorLogin(description: "Email is not valid") }

        currentUser = LujoUser(id: "0asdf1qwer2",
                               title: title,
                               firstName: firstName,
                               lastName: lastName,
                               email: email,
                               phoneNumber: phoneNumber,
                               password: "",
                               avatar: "",
                               token: "",
                               approved: false,
                               referralCode: [],
                               points: 0,
                               membershipPlan: nil,
                               sfid: "")

        view.showNetworkActivity()

        presenterInteractor.createAccount(currentUser!, captchaToken: captchaToken,countryName: countryName) { [weak self] _, error in
            self?.view.hideNetworkActivity()

            guard error == nil else {
                self?.presenterView.showError(error!)
                return
            }

            self?.presenterView.showView("ShowConfirmationView", data: nil)
        }
    }

    func verifyCode(_ code: String) {
        view.showNetworkActivity()

        presenterInteractor.verify(with: code) { _, error in
            self.view.hideNetworkActivity()

            guard error == nil else {
                self.presenterView.showError(error!)
                return
            }

            guard !self.route.isEmpty else {
                return
            }
            
            LujoSetup().updateDefaults {}

            // uncomment to jump to verify and remove navigate(from:...) if manual verification is approved again
            self.presenterView.showView("ShowWelcomeScreen", data: nil)
        }
    }

    func showHomeScreen() {
        router?.navigate(from: route, data: ["result": "Home" as AnyObject])
    }

    func requestOTP(captchaToken:String) {
        presenterView.showView("JumpConfirmation", data: nil)

        presenterInteractor.requestVerificationCode(captchaToken:captchaToken) { _, error in
            guard error == nil else {
                self.presenterView.showError(error!)
                return
            }
        }
    }

    func requestOTPLogin(phoneCountryCode: PhoneCountryCode?, number: String?, captchaToken:String?) {
        if let countryCode = phoneCountryCode, let phoneNumber = number, let captchaToken = captchaToken{
            
            self.presenterView.showNetworkActivity()
            presenterInteractor.requestLoginVerificationCode(prefix: countryCode, phoneNumber,captchaToken) { [weak self] _, error in
                self?.presenterView.hideNetworkActivity()
                guard error == nil else {
                    self?.presenterView.showError(error!)
                    return
                }
                self?.presenterView.showView("DoOPTConfirmation", data: nil)
            }
        }else{ //if user already have the verification code
            self.presenterView.showView("DoOPTConfirmation", data: nil)
        }
    }
    

    func requestResendCode(captchaToken:String) {
        presenterInteractor.requestVerificationCode(captchaToken:captchaToken) { _, error in
            guard error == nil else {
                self.presenterView.showError(error!)
                return
            }
        }
    }

    func updateUserPhone(oldPrefix: String, oldNumber: String, newPrefix: String, newNumber: String, captchaToken:String) {
        presenterView.showNetworkActivity()
        presenterInteractor.updateUserPhone(oldPrefix: oldPrefix, oldNumber: oldNumber, newPrefix: newPrefix, newNumber: newNumber,captchaToken:captchaToken) { _, error in
            self.presenterView.hideNetworkActivity()

            guard error == nil else {
                self.presenterView.showError(error!)
                return
            }
            
            let upadtedUser = LoginUser(prefix: newPrefix, phone: newNumber, token: LujoSetup().getCurrentUser()?.token, approved: LujoSetup().getCurrentUser()!.approved)
            
            LujoSetup().store(currentUser: upadtedUser)
            self.presenterView.showView("unwindToOTPConfirmation", data: nil)
            self.presenterView.showFeedback("You successfully changed your phone number.")
        }
    }

    func update(view: Viewable) {
        guard let newView = view as? LoginViewProtocol else { return }
        presenterView = newView
        _ = initialUserCheckout
    }

    func forgotPassword(for user: String) {
        presenterInteractor.forgotPassword(for: user) { _, error in

            guard error == nil else {
                self.presenterView.showError(error!)
                return
            }
            self.presenterView.showFeedback("Reset password requested")
        }
    }

    func logoutUser() {
//        presenterView.showNetworkActivity()
        presenterInteractor.logoutUser()
    }

    // MARK: Helper functions

    func isValid(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
}
