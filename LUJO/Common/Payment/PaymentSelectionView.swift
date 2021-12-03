import ActiveLabel
import FirebaseCrashlytics
import JGProgressHUD
import UIKit

enum PaymentSteps: Int {
    case selectType = 1
    case selectPayment = 2
    case sendPayment = 3
    case paymentResult = 4

    static let allSteps = [selectType, selectPayment, sendPayment, paymentResult]
}

protocol PaymentSelectionDelegate: class {
    func paymentFished(with result: PaymentResult, at session: PaymentSession?, completion: @escaping (Error?) -> Void)
    func paymentCompleted(with result: String)
}

class PaymentSelectionView: UIViewController, UITableViewDelegate {
    @IBOutlet var paymentMethodName: UILabel!
    @IBOutlet var authorizationAmount: UILabel!

    @IBOutlet var optionsTableView: UITableView!

    @IBOutlet var addCreditCardLabel: ActiveLabel!

    private var tableDatasource: UITableViewDataSource!

    @IBOutlet var nextStepButton: UIButton!

    @IBOutlet var pseudoNavBarHeight: NSLayoutConstraint!

    private let naHUD = JGProgressHUD(style: .dark)

    var paymentType: PaymentType? = .creditCard
    var paymentData: PaymentData?

    private var paymentController: PaymentController!
    private var paymentMethodSelection: Completion<PaymentMethod<CreditCardInfo>>?
    private var paymentMethod: Any?

    weak var paymentDelegate: PaymentSelectionDelegate?

    private let apiManager = CCAPIManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupAddCreditCard()

        optionsTableView.delegate = self
        optionsTableView.rowHeight = 91

//        naHUD.textLabel.text = "Loading Payment Info"

        prepareStep()

        paymentController = PaymentController(delegate: self)

        // Hide fake navigation bar when real navigation bar is present
        guard navigationController == nil else {
            pseudoNavBarHeight.constant = 0
            return
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        if let paymentData = paymentData, paymentController.paymentSession == nil {
            showNetworkActivity()
            paymentController.startSession(with: paymentData)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let source = tableDatasource as? CreditCardsDataSource {
            paymentMethod = source.element(at: indexPath) as Any

            guard let methodSelection = self.paymentMethodSelection else {
                return
            }

            guard let method = paymentMethod as? PaymentMethod<CreditCardInfo> else {
                fatalError("Selected unexisting credit card")
            }

            methodSelection(method)

        } else if let source = tableDatasource as? PaymentTypeDataSource {
            print(source)
        }
    }

    func prepareStep() {
        // Step 1: Obtain payment type
        guard let selectedPaymentType = paymentType else {
            tableDatasource = PaymentTypeDataSource()
            optionsTableView.dataSource = tableDatasource
            nextStepButton.setTitle("NEXT STEP", for: .normal)
            addCreditCardLabel.isHidden = true
            return
        }

        nextStepButton.setTitle("AUTHORIZE", for: .normal)
        /// Step 2: Obtain payment Details
        guard paymentMethod != nil else {
            switch selectedPaymentType {
            case .creditCard:
                guard !(tableDatasource is CreditCardsDataSource) else { return }
                tableDatasource = CreditCardsDataSource()
                optionsTableView.dataSource = tableDatasource
                addCreditCardLabel.isHidden = false
            default:
//                print("Pending other payment methods")
                addCreditCardLabel.isHidden = true
            }
            return
        }
    }

    @IBAction func paymentNextStep(_ sender: Any) {
        prepareStep()

        guard let paymentMethod = paymentMethod else {
            optionsTableView.reloadData()
            return
        }
        guard let paymentSession = paymentController.paymentSession else {
            NSError.logLUJOError(for: "Payment", description: "Requested next step with no session")
            showInformationPopup(withTitle: "Payment", message: "Something went wrong, plesase restart the app")
            return
        }

        if let method = paymentMethod as? PaymentMethod<CreditCardInfo> {
            performPayment(with: method, using: paymentSession)
        }
    }

    @IBAction func cancelPayment(_ sender: Any) {
        dismiss(animated: true)
    }
}

extension PaymentSelectionView: PaymentControllerDelegate {
    func added(payment method: PaymentMethod<CreditCardInfo>, to session: PaymentSession?) {
        hideNetworkActivity()
        performPayment(with: method, using: session)
    }

    // swiftlint:disable line_length
    func requestPaymentSession(withToken token: String, for paymentController: PaymentController, responseHandler: @escaping Completion<String>) {
        // Nothing to do here I guess
    }

    func startNewPaymentSession(selectionHandler: @escaping Completion<PaymentMethod<CreditCardInfo>>) {
        hideNetworkActivity()
        addNewCreditCard()
    }

    func selectPaymentMethod(from paymentMethods: [PaymentMethod<CreditCardInfo>],
                             for paymentController: PaymentController,
                             selectionHandler: @escaping Completion<PaymentMethod<CreditCardInfo>>) {
        hideNetworkActivity()
        guard let paymentMethodsDataSource = tableDatasource as? CreditCardsDataSource else { return }
        paymentMethodsDataSource.creditCards = paymentMethods

        optionsTableView.reloadData()
    }

    public func didFinish(with result: ResultPayment<PaymentResult>, for paymentController: PaymentController) {
        hideNetworkActivity()
        switch result {
        case let .success(paymentInfo):
            dismiss(animated: true) {
                self.paymentDelegate?.paymentFished(with: paymentInfo, at: paymentController.paymentSession!) { error in
                    print(error ?? "Nothing to see here")
                }
            }
        case let .failure(error):
            showErrorPopup(withTitle: "Payment Error", error: error)
        }
    }

    func show(_ error: String) {
        let title = "Payment Process"
        stopNewtworkActivityAndShowError(for: title, with: error)
    }
}

extension PaymentSelectionView: AddCreditCardDelegate {
    fileprivate func setupAddCreditCard() {
        let addCreditCardLabelType = ActiveType.custom(pattern: "\\+ Add credit card\\b") // Regex that looks for "with"
        addCreditCardLabel.enabledTypes = [addCreditCardLabelType]
        addCreditCardLabel.attributedText = NSAttributedString(string: "+ Add credit card")

        addCreditCardLabel.configureLinkAttribute = { type, attributes, _ in
            var atts = attributes
            switch type {
            case addCreditCardLabelType:
                atts[NSAttributedString.Key.font] = UIFont(name: "HelveticaNeueLTStd-Roman", size: 14.0)
                atts[NSAttributedString.Key.foregroundColor] = UIColor(named: "Action Button")
            default: ()
            }

            return atts
        }

        addCreditCardLabel.handleCustomTap(for: addCreditCardLabelType) { [weak self] _ in
            self?.addNewCreditCard()
        }
    }

    func add(card data: CardInputData) {
        showNetworkActivity()
        paymentController.encode(data)
    }

    func addNewCreditCard() {
        let stbrd = UIStoryboard(name: "Payment", bundle: nil)
        // swiftlint:disable force_cast
        let addCCVC = stbrd.instantiateViewController(withIdentifier: "AddCreditCardView") as! AddCreditCardView
        addCCVC.delegate = self

        present(addCCVC, animated: true)
    }

    func performPayment(with method: PaymentMethod<CreditCardInfo>, using session: PaymentSession?) {
//        naHUD.textLabel.text = "Processing Payment"
        // If CVC reenter is requested
        // requestCVCNumber(for: method, using: session)
        // else
        showNetworkActivity()
        paymentController.performPayment(with: method)
    }
}

extension PaymentSelectionView {
    fileprivate func stopNewtworkActivityAndShowError(for domain: String,
                                                      with description: String,
                                                      _ error: Error? = nil) {
        hideNetworkActivity()
        if let error = error {
            Crashlytics.crashlytics().record(error: error)
        } else {
            NSError.logLUJOError(for: domain, description: description)
        }
        showInformationPopup(withTitle: domain, message: description)
    }

    func showNetworkActivity() {
        if Thread.isMainThread {
            naHUD.show(in: view)
        } else {
            DispatchQueue.main.async {
                self.naHUD.show(in: self.view)
            }
        }
    }

    func hideNetworkActivity() {
        if Thread.isMainThread {
            naHUD.dismiss()
        } else {
            DispatchQueue.main.async {
                self.naHUD.dismiss()
            }
        }
    }

    // CVC Alert View
    func getCVCAlertView() -> UIAlertController {
        guard let creditCard = paymentMethod as? PaymentMethod<CreditCardInfo> else {
            fatalError("Selected CVC for non credit card payment method")
        }

        let title = "Verify your card"
        let message = "Please enter the CVC code for \(creditCard.displayName)"

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { textField in
            textField.textAlignment = .center
            textField.keyboardType = .numberPad
            textField.placeholder = "123"
            textField.accessibilityLabel = "CVC / CVV"
            //            textField.delegate = self
        })

        let cancelActionTitle = "Cancel"
        let cancelAction = UIAlertAction(title: cancelActionTitle, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        return alertController
    }

    func requestCVCNumber(for method: PaymentMethod<CreditCardInfo>, using session: PaymentSession) {
        let cvcAlert = getCVCAlertView()

        let amount = paymentController.paymentSession?.payment?.amount
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .currency

        guard let formattedAmount = formatter.string(from: NSNumber(value: amount!)) else {
            return
        }

        let actionTitle = formattedAmount
        let action = UIAlertAction(title: actionTitle, style: .default) { [unowned self] _ in
            self.showNetworkActivity()
            guard let textField = cvcAlert.textFields?.first,
                textField.text != nil else {
                return
            }

            self.performPayment(with: method, using: session)
        }

        //        action.isEnabled = false
        cvcAlert.addAction(action)

        present(cvcAlert, animated: true)
    }
}
