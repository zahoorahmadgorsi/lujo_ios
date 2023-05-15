import ActiveLabel
import FirebaseCrashlytics
import JGProgressHUD
import M13Checkbox
import MessageUI
import UIKit
import HCaptcha
import WebKit

class RegisterView: UIViewController, LoginViewProtocol, CountrySelectionDelegate {
    var presenter: LoginViewResponder?
    private let naHUD = JGProgressHUD(style: .dark)

    @IBOutlet var stackView: UIStackView!
    @IBOutlet var textFieldHeight: NSLayoutConstraint!

    @IBOutlet var phoneNumberContainer: UIView!
    @IBOutlet var phoneCodeContainer: UIView!
    @IBOutlet var termsCheckboxContainer: UIView!

    @IBOutlet var firstName: LujoTextField!
    @IBOutlet var lastName: LujoTextField!
    @IBOutlet var email: LujoTextField!
    @IBOutlet var phoneCode: UILabel!
    @IBOutlet var phonePrefixValue: UILabel!
    @IBOutlet var phoneNumber: UITextField!

    @IBOutlet var termsLabel: ActiveLabel!

    var phoneCountryCode = Utility.getCountryCode()

    var termsAgreement: M13Checkbox = {
        let checkbox = M13Checkbox(frame: CGRect.zero)
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        checkbox.markType = .checkmark
        checkbox.boxType = .square
        checkbox.tintColor = UIColor(named: "White Text")
        return checkbox
    }()

    let hcaptcha = try? HCaptcha(
        apiKey: Constants.hCaptchaKey,
        baseURL: URL(string: Constants.hCaptchaURL)!
    )
    var captchaWebView: WKWebView?
    
    fileprivate func navigationBarSetup() {
//        title = "Create new account"
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

    fileprivate func setupActiveLabels() {
        let termsOfUseType = ActiveType.custom(pattern: "\\sTerms of Use\\b")
        termsLabel.enabledTypes = [termsOfUseType]

        termsLabel.customize { label in
            label.text = "I agree with Terms of Use"
            label.font = UIFont.systemFont(ofSize: 17, weight: .light)
            label.textColor = UIColor.paragraphWhite
            label.customColor[termsOfUseType] = UIColor.rgMid
            label.handleCustomTap(for: termsOfUseType) { string in
                guard let urlString = Bundle.main.object(forInfoDictionaryKey: "TERMS_OF_USE_URL") as? String else {
                    return
                }
                guard let urlURL = URL(string: urlString) else {
                    return
                }

                UIApplication.shared.open(urlURL, options: [:]) { _ in
                    // TODO: Implement
                }
            }
        }
    }

    fileprivate func controlsSetup() {
        phoneCodeContainer.layer.borderColor = UIColor(named: "TVBorder")?.cgColor
        phoneNumberContainer.layer.borderColor = UIColor(named: "TVBorder")?.cgColor

        view.addSubview(termsAgreement)
        view.addConstraint(NSLayoutConstraint(item: termsAgreement, attribute: .width, relatedBy: .equal,
                                              toItem: termsCheckboxContainer, attribute: .width,
                                              multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: termsAgreement, attribute: .height, relatedBy: .equal,
                                              toItem: termsCheckboxContainer, attribute: .height,
                                              multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: termsAgreement, attribute: .centerX, relatedBy: .equal,
                                              toItem: termsCheckboxContainer, attribute: .centerX,
                                              multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: termsAgreement, attribute: .centerY, relatedBy: .equal,
                                              toItem: termsCheckboxContainer, attribute: .centerY,
                                              multiplier: 1, constant: 0))

        setupActiveLabels()
    }

    fileprivate func updatePrefixLabels() {
        phoneCode.text = phoneCountryCode.alpha2Code
        phonePrefixValue.text = phoneCountryCode.phonePrefix
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter?.logoutUser()

        navigationBarSetup()
        controlsSetup()

//        naHUD.textLabel.text = "Creating account ..."

        if UIDevice.isiPhone5 || UIDevice.isIphone6Zoomed {
            stackView.spacing = 8
            textFieldHeight.constant = 36
        }

        // init toolbar
        let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 30))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let separator = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonPressed))
        let previousButton = UIBarButtonItem(title: "Prev", style: .done, target: self, action: #selector(nextField))
        let nextButton = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(previousField))

        toolbar.setItems([previousButton, separator, nextButton, flexSpace, doneButton], animated: false)
        toolbar.sizeToFit()

        updatePrefixLabels()

        firstName.inputAccessoryView = toolbar
        lastName.inputAccessoryView = toolbar
        email.inputAccessoryView = toolbar
        phoneNumber.inputAccessoryView = toolbar

        phoneNumber.attributedPlaceholder = NSAttributedString(
            string: phoneNumber.placeholder!,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.placeholderText]
        )
        
        //configuring webview for captcha
        hcaptcha?.configureWebView { [weak self] webview in
            webview.frame = self?.view.bounds ?? CGRect.zero
            
            // could use this option if using an enterprise passive sitekey:
            // webview.isHidden = true
            // seems to prevent flickering on latest iOS 15.2
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
        
//        LujoSetup().getCountryCodes()   zahoor
    }

    //this function validates the captcha and if validated sends call for registration
    func validateCaptchaThenSignup() {
        showNetworkActivity()
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
        
        hcaptcha?.validate(on: view) { [weak self] (result: HCaptchaResult) in
//            print(try? result.dematerialize() as Any)
            self?.captchaWebView?.removeFromSuperview()
            //After successful validation signup the user
            if let firstname = self?.firstName.text
                , let lastName = self?.lastName.text
                ,let email = self?.email.text
                ,let phonePrefix = self?.phoneCountryCode.phonePrefix
                ,let phoneNumber = self?.phoneNumber.text
                ,let captchaToken = try? result.dematerialize()
                ,let countryAlpha2Code = self?.phoneCountryCode.alpha2Code
            {
            do {
                try self?.presenter?.createAccount(title: .mr,
                                             firstName: firstname,
                                             lastName: lastName,
                                             email: email,
                                             phoneNumber: PhoneNumber(countryCode: phonePrefix,
                                                                      number: phoneNumber)
                                            ,captchaToken:captchaToken
                                            ,countryAlpha2Code: countryAlpha2Code)
            } catch {
                // swiftlint:disable force_cast
                self?.showError(error as! LoginError)
            }
            }
        }
    }
    
    @IBAction func countryCodeButton_onClick(_ sender: Any) {
        showCountryCodes()
    }
    
    @IBAction func createAccount(_: UIButton) {
        let allFields = [firstName, lastName, email, phoneNumber]

        guard termsAgreement.checkState == .checked else {
            showError(LoginError.missingTermsOfUse)
            return
        }

        for textField in allFields {
            guard !(textField!.text!.isEmpty) else {
                showError(LoginError.missingData)
                return
            }
        }
        validateCaptchaThenSignup()
    }

    override func viewWillAppear(_: Bool) {
        navigationController?.navigationBar.isHidden = false
        presenter?.update(view: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func showNetworkActivity() {
        naHUD.show(in: view)
    }

    func hideNetworkActivity() {
        naHUD.dismiss()
    }

    func showError(_ error: Error) {
        let loginError = LoginError.errorLogin(description: error.localizedDescription)
        showError(loginError)
    }

    func showError(_ error: LoginError) {
        view.endEditing(true)

        showErrorPopup(withTitle: "Create Account Error", error: error)
    }

    func showView(_ id: String, data _: [String: Any]?) {
        if canPerformSegue(withIdentifier: id) {
            performSegue(withIdentifier: "ShowConfirmationView", sender: self)
        }
        return
    }

    func showFeedback(_ message: String) {
        showInformationPopup(withTitle: "Information", message: message)
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "ShowConfirmationView" {
            guard let confirmationVC = segue.destination as? ConfirmationView else { return }
            confirmationVC.presenter = presenter
            return
        }
    }

    @objc private func doneButtonPressed() {
        view.endEditing(true)
    }

    @objc private func nextField() {
        guard let currentResponder: UIView = self.view.currentFirstResponder() as? UIView else {
            return
        }

        let currentTag = currentResponder.tag
        let nextTag = currentTag > 1000 ? currentTag - 1 : 1005

        view.viewWithTag(nextTag)?.becomeFirstResponder()
    }

    @objc private func previousField() {
        guard let currentResponder: UIView = self.view.currentFirstResponder() as? UIView else {
            return
        }

        let currentTag = currentResponder.tag
        let nextTag = currentTag < 1005 ? currentTag + 1 : 1000

        view.viewWithTag(nextTag)?.becomeFirstResponder()
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
}

extension RegisterView: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if error != nil {
            Crashlytics.crashlytics().record(error: error!)
        }

        controller.dismiss(animated: true, completion: nil)
    }
}
