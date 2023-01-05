import UIKit

struct CardInputData {
    let encryptedCard: String?
    let holderName: String
    let storeDetails: Bool
    let cardNumber: String
    let expiryDate: String
    let ccv2: Int
}

protocol AddCreditCardDelegate: class {
    func add(card data: CardInputData)
}

class AddCreditCardView: UIViewController {
    @IBOutlet var cardHolderName: LujoTextField!
    @IBOutlet var cardNumber: LujoTextField!
    @IBOutlet var expiryMonth: LujoTextField!
    @IBOutlet var expiryYear: LujoTextField!
    @IBOutlet var cvcCode: LujoTextField!

    @IBOutlet var addCreditCardButton: UIButton!

    weak var delegate: AddCreditCardDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareControlDelegatesAndTargets()
        #if DEBUG
            cardHolderName.text = "ZAHOOR AHMAD GORSI"
            cardNumber.text = "4111 1111 1111 1111"
            expiryMonth.text = "12"
            expiryYear.text = "28"
            cvcCode.text = "135"
        #endif
    }

    @IBAction func addCreditCard(_ sender: Any) {
        guard
            let displayName = cardHolderName.text,
            let number = cardNumber.text,
            let month = expiryMonth.text,
            let year = expiryYear.text,
            let cvcCode = cvcCode.text,
            let cvc2Code = Int(cvcCode)
        else {
            return
        }

        let clearNumber = number.replacingOccurrences(of: " ", with: "")
        let cardData = CardInputData(encryptedCard: nil,
                                     holderName: displayName,
                                     storeDetails: true,
                                     cardNumber: clearNumber,
                                     expiryDate: month + year,
                                     ccv2: cvc2Code)

        if delegate != nil {
            dismiss(animated: true) {
                self.delegate?.add(card: cardData)
            }
        }
    }

    @IBAction func cancelAddCreditCard(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension AddCreditCardView: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)

            switch textField {
            case cardNumber:
                let clearString = updatedText.replacingOccurrences(of: " ", with: "")
                return clearString.count <= 16
            case expiryMonth:
                return updatedText.count <= 2
            case expiryYear:
                return updatedText.count <= 2
            case cvcCode:
                return updatedText.count <= 4
            default:
                return true
            }
        }
        return true
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField == cardNumber {
            cardNumber.attributedText = cardNumber.text?.formatAsCreditCard()
        }
        validateFields()
    }

    func validateFields() {
        guard let textName = cardHolderName.text, textName.count >= 5 else {
            addCreditCardButton.isEnabled = false
            return
        }

        guard let textMonth = expiryMonth.text, let month = Int(textMonth), (1 ... 12).contains(month) else {
            addCreditCardButton.isEnabled = false
            return
        }

        guard let textYear = expiryYear.text, var year = Int(textYear) else {
            addCreditCardButton.isEnabled = false
            return
        }

        if year < 999 { year += 2000 }

        guard year >= Calendar.current.component(.year, from: Date()) else {
            addCreditCardButton.isEnabled = false
            return
        }

        guard let textCVC = cvcCode.text, (3 ... 4) ~= textCVC.count else {
            addCreditCardButton.isEnabled = false
            return
        }

        guard let textCardNumber = cardNumber.text, textCardNumber.isValidCreditCardNumber() else {
            addCreditCardButton.isEnabled = false
            return
        }

        addCreditCardButton.isEnabled = true
    }

    fileprivate func prepareControlDelegatesAndTargets() {
        cardNumber.delegate = self
        cardHolderName.delegate = self
        expiryYear.delegate = self
        expiryMonth.delegate = self
        cvcCode.delegate = self
        cardNumber.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        cardHolderName.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        expiryYear.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        expiryMonth.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        cvcCode.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
}
