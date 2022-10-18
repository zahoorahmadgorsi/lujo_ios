import UIKit
import JGProgressHUD

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
    private var phonePrefix = PhoneCountryCode(id: 238,
                                               alpha2Code: "US",
                                               phonePrefix: "+1",
                                               nationality: "American",
                                               country: "United States of America",
                                               flag: "https://bit.ly/2Vrjgrk")

    fileprivate func updatePrefixLabels() {
        countryCode.text = phonePrefix.alpha2Code
        phonePrefixValue.text = phonePrefix.phonePrefix
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
        presenter?.requestOTPLogin(prefix: nil,number: nil)
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

        if isChanging {
            if let prefix = LujoSetup().getCurrentUser()?.prefix, let oldNumber = LujoSetup().getCurrentUser()?.phone {
                presenter?.updateUserPhone(oldPrefix: prefix, oldNumber: oldNumber, newPrefix: phonePrefix.phonePrefix, newNumber: number)
            } else {
                showFeedback("Can't change phone number because old number is not available.")
            }
        } else {
            presenter?.requestOTPLogin(prefix: phonePrefix, number: number)
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
        phonePrefix = country
        updatePrefixLabels()
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "DoOPTConfirmation" {
            guard let confirmationVC = segue.destination as? ConfirmationView else { return }
            confirmationVC.presenter = presenter
            confirmationVC.prefix = phonePrefix
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
