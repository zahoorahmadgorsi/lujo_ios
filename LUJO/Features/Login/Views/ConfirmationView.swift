import ActiveLabel
import JGProgressHUD
import UIKit
import HCaptcha
import WebKit

class ConfirmationView: UIViewController, LoginViewProtocol, UITextFieldDelegate {
    var presenter: LoginViewResponder?
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var digit1: UITextField!
    @IBOutlet var digit2: UITextField!
    @IBOutlet var digit3: UITextField!
    @IBOutlet var digit4: UITextField!
    @IBOutlet var sentToLabel: UILabel!

    @IBOutlet weak var actionButton: ActionButton!
    
    @IBOutlet var spacingViewHeight: NSLayoutConstraint!

    var prefix: PhoneCountryCode?
    var phoneNumber: String?
    var isLogin: Bool = false

    private let naHUD = JGProgressHUD(style: .dark)
    private var firstTime: Bool = true

    let hcaptcha = try? HCaptcha(
        apiKey: Constants.hCaptchaKey,
        baseURL: URL(string: Constants.hCaptchaURL)!
    )
    var captchaWebView: WKWebView?
    
    func showError(_ error: LoginError) {
        showErrorPopup(withTitle: "Confirmation Error", error: error)
    }

    @IBAction func resendButton_onClick(_ sender: Any) {
        validateCaptchaThenOTPRequest()
    }

    //this function validates captcha and if validated it sends call for user login
    func validateCaptchaThenOTPRequest() {
        showNetworkActivity()
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
        
        hcaptcha?.validate(on: view) { [weak self] (result: HCaptchaResult) in
//            print(try? result.dematerialize() as Any)
            if let captchaToken = try? result.dematerialize(){
                self?.captchaWebView?.removeFromSuperview()
                //After successful validation login the user
                if ((self?.isLogin) != nil), let prefix = self?.prefix, let number = self?.phoneNumber {
                    self?.presenter?.requestOTPLogin(phoneCountryCode: prefix, number: number, captchaToken: captchaToken)
                }else{
                    self?.showFeedback("New Code Requested")
                    self?.presenter?.requestResendCode(captchaToken: captchaToken)
                }
            }
        }
    }
    
    @IBAction func updateNumberButton_onClick(_ sender: Any) {
        showView("ShowUpdatePhoneNumber", data: nil)    //update phone number is basically change phone number
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        presenter?.update(view: self)
        updateUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if firstTime {
            digit1.becomeFirstResponder()
            firstTime = false
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if isLogin {
            presenter?.logoutUser()
        }

        updateUI()

        [digit1, digit2, digit3, digit4].forEach { styleDigitContainer($0) }

        // init toolbar
        let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 30))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonPressed))

        toolbar.setItems([flexSpace, doneButton], animated: false)
        toolbar.sizeToFit()

        digit1.inputAccessoryView = toolbar
        digit2.inputAccessoryView = toolbar
        digit3.inputAccessoryView = toolbar
        digit4.inputAccessoryView = toolbar
        
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

    func textFieldDidBeginEditing(_ textField: UITextField) {
        styleDigitContainer(textField, isEditing: true)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        styleDigitContainer(textField)
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let finalString: String? = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
       
        
        //---------------------------------------------------------------------------------------------------
        // Check for curent combination so we can enable disable button if needed.
        var combination: String = ""
        switch textField {
        case digit1: combination = "\(string)\(digit2.text!)\(digit3.text!)\(digit4.text!)"
        case digit2: combination = "\(digit1.text!)\(string)\(digit3.text!)\(digit4.text!)"
        case digit3: combination = "\(digit1.text!)\(digit2.text!)\(string)\(digit4.text!)"
        case digit4: combination = "\(digit1.text!)\(digit2.text!)\(digit3.text!)\(string)"
        default:
            break
        }
        combination.count == 4 ? actionButton.setEnabled() : actionButton.setDisabled()
        //---------------------------------------------------------------------------------------------------
        
        if string.isEmpty, range.length > 0 {
            textField.text = string
            let nextResponderTag = textField.tag == 1000 ? -1 : textField.tag - 1
            let nextResponder: UIResponder? = textField.superview?.viewWithTag(nextResponderTag)
            if nextResponder != nil {
                nextResponder?.becomeFirstResponder()
            }
            return false
        } else if (finalString?.count)! > 0 {
            textField.text = string
            let nextResponderTag = textField.tag == 1003 ? -1 : textField.tag + 1
            let nextResponder: UIResponder? = textField.superview?.viewWithTag(nextResponderTag)
            if nextResponder != nil {
                nextResponder?.becomeFirstResponder()
            }
            return false
        }
        return true
    }

    @IBAction func submitCode(_: Any) {
        guard let firstDigit = digit1.text,
            let secondDigit = digit2.text,
            let thirdDigit = digit3.text,
            let fourthDigit = digit4.text
        else {
            let error = LoginError.errorLogin(description: "The confirmation code should be 4 digits")
            showErrorPopup(withTitle: "Error in confirmation", error: error)
            return
        }

        let combination = "\(firstDigit)\(secondDigit)\(thirdDigit)\(fourthDigit)"

        if isLogin {
            do {
                try presenter?.doLoginWithOTP(prefix: prefix, phoneNumber, code: combination)
            } catch {
                // swiftlint:disable force_cast
                showError(error as! LoginError)
            }
        } else {
            presenter?.verifyCode(combination)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    fileprivate func updateUI() {
//        if UIDevice.isiPhone5 || UIDevice.isIphone6Zoomed {
//            spacingViewHeight.constant = 30
//        }
        actionButton.setDisabled()
        sentToLabel.text = "Code sent to \(prefix?.phonePrefix ?? LujoSetup().getCurrentUser()?.prefix ?? "-") \(phoneNumber ?? LujoSetup().getCurrentUser()?.phone ?? "")"
        title = isLogin ? "Verify request" : "Verify phone number"
        descriptionLabel.text = isLogin ? "In order to verify your request, please enter a 4 digit code sent to you via SMS." : "In order to verify your account, please enter a 4 digit code sent to you via SMS."
    }

    fileprivate func styleDigitContainer(_ digit: UITextField, isEditing: Bool = false) {
        digit.backgroundColor = .clear
        digit.layer.borderWidth = 1
        digit.layer.borderColor = isEditing ? UIColor.rgMid.cgColor : UIColor(named: "TVBorder")?.cgColor

        digit.delegate = self
    }

    @objc private func doneButtonPressed() {
        view.endEditing(true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "ShowUpdatePhoneNumber" {
            guard let updateNumber = segue.destination as? UpdatePhoneNumberView else { return }
            updateNumber.presenter = presenter
            return
        }

        if segue.identifier == "ShowWelcomeScreen" {
            guard let welcomeView = segue.destination as? WelcomeView else { return }
            welcomeView.presenter = presenter
            return
        }
    }

    func showView(_ id: String, data _: [String: Any]?) {
        if canPerformSegue(withIdentifier: id) {
            performSegue(withIdentifier: id, sender: self)
        }
        return
    }

    func showError(_ error: Error) {
        showErrorPopup(withTitle: "Verification Error", error: error)
    }

    func showNetworkActivity() {
        naHUD.show(in: view)
    }

    func hideNetworkActivity() {
        naHUD.dismiss()
    }

    @IBAction func unwindToConfirmationView(segue: UIStoryboardSegue) {
        // Placeholder for unwind segue
    }

    func showFeedback(_ message: String) {
        showInformationPopup(withTitle: "Information", message: message)
    }
}
