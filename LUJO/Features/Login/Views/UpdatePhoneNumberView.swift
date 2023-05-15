import UIKit
import JGProgressHUD
import HCaptcha
import WebKit

class UpdatePhoneNumberView: UIViewController, LoginViewProtocol, CountrySelectionDelegate {
    var presenter: LoginViewResponder?

    func showError(_ error: Error) {
        switch error.localizedDescription {
        case "The account was not found":   //it will never execute as server isnt sending this error any more
            errorLabel.isHidden = false
            phoneNumberContainer.layer.borderColor = UIColor.error.cgColor
            
        default:
            showErrorPopup(withTitle: "Error", error: error)
        }
    }
    
    private let naHUD = JGProgressHUD(style: .dark)

    @IBOutlet var stackView: UIStackView!
    @IBOutlet var newPhoneNumber: UITextField!
    @IBOutlet var countryCode: UILabel!
    @IBOutlet var phonePrefixValue: UILabel!
    @IBOutlet var phoneCodeContainer: UIView!
    @IBOutlet var phoneNumberContainer: UIView!
    @IBOutlet var confirmButton: ActionButton!

    @IBOutlet var supportTextView: UITextView!
    @IBOutlet var descriptionLabel: UILabel!

    /// Error label is used to display login error messages to user.
    /// For example: "We can't associate the phone number with an existing account"
    /// Hidden on view load.
    @IBOutlet weak var errorLabel: UILabel!
    
    var isChanging: Bool = true
    var phoneCountryCode = Utility.getCountryCode()
//    private var phoneCountryCode = PhoneCountryCode(id: 238,
//                                               alpha2Code: "US",
//                                               phonePrefix: "+1",
//                                               nationality: "American",
//                                                    country: TaxonomyCountry( _id : "238" , name: "United States of America"),
//                                               flag: "https://bit.ly/2Vrjgrk")

    let hcaptcha = try? HCaptcha(
        apiKey: Constants.hCaptchaKey,
        baseURL: URL(string: Constants.hCaptchaURL)!
    )
    var captchaWebView: WKWebView?
    
    fileprivate func updatePrefixLabels() {
        countryCode.text = phoneCountryCode.alpha2Code
        phonePrefixValue.text = phoneCountryCode.phonePrefix
    }

    fileprivate func updateUI() {
        supportTextView.isHidden = isChanging
        descriptionLabel.text = isChanging ? "Change the phone number" : "Dear LUJO Member, please enter your phone number so we can send you a verification code."
        confirmButton.setTitle(isChanging ? "CONFIRM & RESEND CODE" : "SEND VERIFICATION CODE", for: .normal)
        confirmButton.setDisabled()
        title = isChanging ? "Change phone number" : "Member login"
        newPhoneNumber.placeholder = isChanging ? "New number" : "Phone number"

        if UIDevice.isiPhone4 || UIDevice.isiPhone5 || UIDevice.isIphone6Zoomed {
            stackView.spacing = 35
        }
    }

    fileprivate func navigationBarSetup() {
//        title = "Update Phone Number"
//        navigationController?.navigationBar.barTintColor = UIColor(named: "Grey Button")
//        navigationController?.navigationBar.tintColor = UIColor(named: "White Text")
//        navigationController?.navigationBar.topItem?.title = ""
//
//        if let navFont = UIFont(name: "HelveticaNeueLTStd-Md", size: 17.0) {
//            let navBarAttributesDictionary: [NSAttributedString.Key: Any]? = [
//                NSAttributedString.Key.foregroundColor: UIColor(named: "White Text")!,
//                NSAttributedString.Key.font: navFont,
//            ]
//            navigationController?.navigationBar.titleTextAttributes = navBarAttributesDictionary
//        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBarSetup()
        
        phoneCodeContainer.layer.borderColor = UIColor.tvBorder.cgColor
        phoneNumberContainer.layer.borderColor = UIColor.tvBorder.cgColor

        // init toolbar
        let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 30))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonPressed))

        toolbar.setItems([flexSpace, doneButton], animated: false)
        toolbar.sizeToFit()

        newPhoneNumber.inputAccessoryView = toolbar
        newPhoneNumber.attributedPlaceholder = NSAttributedString(
            string: newPhoneNumber.placeholder!,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.placeholderText]
        )

        updatePrefixLabels()
        updateUI()
        
        //configuring webview for captcha
        hcaptcha?.configureWebView { [weak self] webview in
            webview.frame = self?.view.bounds ?? CGRect.zero
            webview.isOpaque = false
            webview.backgroundColor = UIColor.clear
            webview.scrollView.backgroundColor = UIColor.clear
            self?.captchaWebView = webview
        }
        hcaptcha?.onEvent { (event, data) in
            self.hideNetworkActivity()
            if event == .open {
                print("captcha open")
            }else if event == .close{
                print(" captcha closed")
                self.captchaWebView?.removeFromSuperview()  //if we wont remove then screen will become irresponsive
            }else if event == .error {
                let error = data as? HCaptchaError
                print("captcha onEvent error: \(String(describing: error))")
                self.captchaWebView?.removeFromSuperview()
            }
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        presenter?.update(view: self)
    }

    @objc private func doneButtonPressed() {
        view.endEditing(true)
    }

    @IBAction func countryCodeButton_onClick(_ sender: Any) {
        showCountryCodes()
    }
    
    @IBAction func btnAlreadyHaveTheCodeTapped(_ sender: Any) {
        guard let number = newPhoneNumber.text, !number.isEmpty else {
            showError(LoginError.errorLogin(description: isChanging ? "You need to set a new number" : "Please, enter your phone number"))
            return
        }

        guard number.count > 5 else {
            let error = LoginError.errorLogin(description: "Phone number must have at least 6 digits.")
            showError(error)
            return
        }

//        if isChanging {
//            if let prefix = LujoSetup().getCurrentUser()?.prefix, let oldNumber = LujoSetup().getCurrentUser()?.phone {
//                presenter?.updateUserPhone(oldPrefix: prefix, oldNumber: oldNumber, newPrefix: phonePrefix.phonePrefix, newNumber: number)
//            } else {
//                showFeedback("Can't change phone number because old number is not available.")
//            }
//        } else
//        {
        presenter?.requestOTPLogin(phoneCountryCode: nil,number: nil, captchaToken: nil)
//        }
    }
    
    @IBAction func verifyNewNumber(_ sender: Any) {
        guard let number = newPhoneNumber.text, !number.isEmpty else {
            showError(LoginError.errorLogin(description: isChanging ? "You need to set a new number" : "Please, enter your phone number"))
            return
        }

        guard number.count > 5 else {
            let error = LoginError.errorLogin(description: "Phone number must have at least 6 digits.")
            showError(error)
            return
        }
        validateCaptcha(phonenNumber:number)
//        if isChanging {
//            if let prefix = LujoSetup().getCurrentUser()?.prefix, let oldNumber = LujoSetup().getCurrentUser()?.phone {
//                presenter?.updateUserPhone(oldPrefix: prefix, oldNumber: oldNumber, newPrefix: phonePrefix.phonePrefix, newNumber: number)
//            } else {
//                showFeedback("Can't change phone number because old number is not available.")
//            }
//        } else {
//            validateCaptchaThenLogin(phonenNumber:number)
////            presenter?.requestOTPLogin(prefix: phonePrefix, number: number)
//        }
    }

    //this function validates captcha and if validated it sends call for user login or user phone update
    func validateCaptcha( phonenNumber: String) {
//    func validateCaptchaThenLogin() {
        showNetworkActivity()
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
        
        hcaptcha?.validate(on: view) { [weak self] (result: HCaptchaResult) in
//            print(try? result.dematerialize() as Any)
            if let captchaToken = try? result.dematerialize(){

                self?.captchaWebView?.removeFromSuperview()
                //After successful validation signup the user or change the phone number

                if let isChanging = self?.isChanging, isChanging == true {
                    if let oldPrefix = LujoSetup().getCurrentUser()?.prefix
                        , let oldNumber = LujoSetup().getCurrentUser()?.phone
                        ,let newPrefix = self?.phoneCountryCode.phonePrefix{
                        self?.presenter?.updateUserPhone(oldPrefix: oldPrefix, oldNumber: oldNumber, newPrefix: newPrefix, newNumber: phonenNumber,captchaToken:captchaToken)
                    } else {
                        self?.showFeedback("Can't change phone number because old number is not available.")
                    }
                } else if let phoneCountryCode = self?.phoneCountryCode{
                    //User is coming for login
                    self?.presenter?.requestOTPLogin(phoneCountryCode: phoneCountryCode, number: phonenNumber, captchaToken: captchaToken)
                }
                
//                self?.presenter?.requestOTPLogin(prefix: self?.phonePrefix, number: phonenNumber,captchaToken:captchaToken)
            }
            
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard let number = newPhoneNumber.text, !number.isEmpty else { return false }
        return true
    }

    private func showCountryCodes() {
        let stbrd = UIStoryboard(name: "Login", bundle: nil)
        // swiftlint:disable force_cast
        let codes = stbrd.instantiateViewController(withIdentifier: "CountrySelect") as! CountryCodeSelectionView
        codes.delegate = self
        present(codes, animated: true, completion: nil)
    }

    func didSelect(_ country: PhoneCountryCode, at view: CountryCodeSelectionView) {
        view.dismiss(animated: true, completion: nil)
        phoneCountryCode = country
        updatePrefixLabels()
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "DoOPTConfirmation" {
            guard let confirmationVC = segue.destination as? ConfirmationView else { return }
            confirmationVC.presenter = presenter
            confirmationVC.prefix = phoneCountryCode
            confirmationVC.phoneNumber = newPhoneNumber.text
            confirmationVC.isLogin = true
        }
    }

    func showView(_ id: String, data _: [String: Any]?) {
        if canPerformSegue(withIdentifier: id) {
            performSegue(withIdentifier: id, sender: self)
        }
        return
    }
    
    func showNetworkActivity() {
        naHUD.show(in: view)
    }
    
    func hideNetworkActivity() {
        naHUD.dismiss()
    }
    
    func showError(_ error: LoginError) {
        showErrorPopup(withTitle: "Error", error: error)
    }
    
    func showFeedback(_ message: String) {
        showInformationPopup(withTitle: "Information", message: message)
    }

}

extension UpdatePhoneNumberView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text as NSString? else { return true }
        let newString = text.replacingCharacters(in: range, with: string)
        
        newString.count > 5 ? confirmButton.setEnabled() : confirmButton.setDisabled()
        
        if !errorLabel.isHidden {
            errorLabel.isHidden = true
            phoneNumberContainer.layer.borderColor = UIColor.tvBorder.cgColor
        }
        return true
    }
    
}
