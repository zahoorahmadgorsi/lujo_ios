//
//  PurchaseViewController.swift
//  LUJO
//
//  Created by Nemanja Djurisic on 10/25/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import Intercom

protocol PurchasePaymentDelegate: class {
    func paymentFished(with result: PaymentResult, at session: PaymentSession?, completion: @escaping (Error?) -> Void)
    func paymentCompleted()
}

enum PaymentPurchaseType {
    case membership
    case booking
}

class PurchaseViewController: UIViewController {
    
    //MARK: - 🎲 - Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "PurchaseViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate(amount: Double, screenType: PaymentPurchaseType) -> PurchaseViewController {
        let viewController = UIStoryboard.payment.instantiate(identifier) as! PurchaseViewController
        viewController.amount = amount
        viewController.screenType = screenType
        return viewController
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionContainerView: UIView!
    @IBOutlet weak var perYearContainerView: UIView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var typeContainerView: UIView!
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var cardHolderName: LujoTextField!
    @IBOutlet weak var cardNumber: LujoTextField!
    @IBOutlet weak var expiryMonth: LujoTextField!
    @IBOutlet weak var expiryYear: LujoTextField!
    @IBOutlet weak var payNowButton: ActionButton!
    @IBOutlet weak var cvcCode: LujoTextField!
    @IBOutlet weak var networkLayer: UIView!
    
    private var amount: Double = 0
    private var paymentController: PaymentController!
    private var screenType: PaymentPurchaseType = .membership
    
    var paymentDelegate: PurchasePaymentDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareControlDelegatesAndTargets()

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        formatter.usesSignificantDigits = true
        
        priceLabel.text = formatter.string(for: amount)
        titleLabel.text = "Purchase \(screenType == .membership ? "membership" : "booking")"
        
        descriptionContainerView.isHidden = screenType == .booking
        perYearContainerView.isHidden = screenType == .booking
        separatorView.isHidden = screenType == .booking
        typeContainerView.isHidden = screenType == .booking
        
        paymentController = PaymentController(delegate: self)
    }

    @IBAction func cancelButton_onClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func payNowButton_onClick(_ sender: Any) {
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
        
        showNetworkActivity()
        paymentController.encode(cardData)
    }
    
    private func showNetworkActivity() {
        networkLayer.isHidden = false
    }
    
    private func hideNetworkActivity() {
        networkLayer.isHidden = true
    }
}

extension PurchaseViewController: PaymentControllerDelegate {
    func added(payment method: PaymentMethod<CreditCardInfo>, to session: PaymentSession?) {
        showNetworkActivity()
        paymentController.performPayment(with: method, amount: amount)
    }
    
    func didFinish(with result: ResultPayment<PaymentResult>, for paymentController: PaymentController) {
        switch result {
        case let .success(paymentInfo):
            paymentDelegate?.paymentFished(with: paymentInfo, at: self.paymentController.paymentSession) { error in
                guard error == nil else {
                    self.showErrorInforming(with: paymentInfo)
                    return
                }
                self.showSuccessPopup(with: paymentInfo)
                //removing non member from user name
                if let user = LujoSetup().getLujoUser(), user.id > 0 {
                    let userAttributes = ICMUserAttributes()
                    userAttributes.name = "\(user.firstName) \(user.lastName)"
                    Intercom.updateUser(userAttributes)
                }
                
            }
        case let .failure(error as PaymentError):
            showFailurePopup(with: error.localizedDescription)
        case let .failure(error):
            showFailurePopup(with: error.localizedDescription)
        }
    }
    
    func show(_ error: String) {
        print(error)
    }
}

extension PurchaseViewController {
    // swiftlint:disable line_length
    func showSuccessPopup(with info: PaymentResult) {
        hideNetworkActivity()
        
        let bodyString =  screenType == .membership ? "Success! You are now a member of Lujo platform. Welcome!" : "Your payment was successfuly completed. Our team will approve the request shortly."
        
        paymentDelegate?.paymentCompleted()
        showCardAlertWith(title: "\(screenType == .membership ? "Membership" : "Booking") Request Submited", body: bodyString, buttonTitle: "Ok") {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func showFailurePopup(with description: String) {
        hideNetworkActivity()
        
        let bodyString = """
        Unfortunately, the \(screenType == .membership ? "membership" : "booking") request could not be submitted due to \(description).
        
        Please retry by pressing the button below.
        
        If the issue persists contact us directly via telephone or chat widget located in the bottom right corner of the screen.
        """
        
        showCardAlertWith(title: "Request Not Processed", body: bodyString, buttonTitle: "Retry Submission", cancelButtonTitle: "Cancel request procedure") {
            print("Should retry")
        }
    }
    
    func showDeclinedPopup(with description: String) {
        hideNetworkActivity()
        
        let bodyString = """
        Unfortunately, the attempt to authorize payment was declined due to \(description).
        
        Please try using a different card. If the issue persists contact us directly via telephone or chat widget located in the bottom right corner of the screen.
        """
        
        showCardAlertWith(title: "Card Authorization Failed", body: bodyString, buttonTitle: "Authorize a different Card", cancelButtonTitle: "Cancel request procedure") {
            print("Retry")
        }
    }
    
    func showErrorInforming(with info: PaymentResult) {
        hideNetworkActivity()
        
        let bodyString = """
        There was an error while saving your \(screenType == .membership ? "membership" : "booking") request, please contact ours Agents with the following reference:
        
        REF : \(info.reference)
        
        Please keep this reference in a safe place to inform about the payment.
        
        Thank you
        """
        
        showCardAlertWith(title: "\(screenType == .membership ? "Membership" : "Booking") process failed", body: bodyString, buttonTitle: "Ok") {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // swiftlint:enable line_length
}

extension PurchaseViewController: UITextFieldDelegate {
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
            payNowButton.isEnabled = false
            return
        }
        
        guard let textMonth = expiryMonth.text, let month = Int(textMonth), (1 ... 12).contains(month) else {
            payNowButton.isEnabled = false
            return
        }
        
        guard let textYear = expiryYear.text, var year = Int(textYear) else {
            payNowButton.isEnabled = false
            return
        }
        
        if year < 999 { year += 2000 }
        
        guard year >= Calendar.current.component(.year, from: Date()) else {
            payNowButton.isEnabled = false
            return
        }
        
        guard let textCVC = cvcCode.text, (3 ... 4) ~= textCVC.count else {
            payNowButton.isEnabled = false
            return
        }
        
        guard let textCardNumber = cardNumber.text, textCardNumber.isValidCreditCardNumber() else {
            payNowButton.isEnabled = false
            return
        }
        
        payNowButton.isEnabled = true
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
