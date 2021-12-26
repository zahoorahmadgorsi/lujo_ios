import UIKit

class BookingStep3: UIViewController {
    @IBOutlet var networkLayer: UIView!

    private var paymentController: PaymentController!
    var paymentData: PaymentData?
    weak var paymentDelegate: PaymentSelectionDelegate?

    override func viewDidLoad() {
        guard paymentData != nil else {
            fatalError("Booking step called without payment data")
        }

        paymentController = PaymentController(delegate: self)
//        paymentController.startSession(with: paymentData)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activateKeyboardManager()
    }

    @IBAction func cancelStep(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func chatButton_onClick(_ sender: UIButton) {
        if LujoSetup().getLujoUser()?.membershipPlan != nil {
            guard let userFirstName = LujoSetup().getLujoUser()?.firstName else { return }
            let initialMessage = """
            Hi Concierge team,

            I want to authorize card and verify booking request, can you please assist me?

            \(userFirstName)
            """

            let viewController = AdvanceChatViewController()
            viewController.product = Product(id: -1 , type: "aviation" , name: "Authorize card and verify booking request")
            viewController.initialMessage = initialMessage
            let navController = UINavigationController(rootViewController:viewController)
            UIApplication.topViewController()?.present(navController, animated: true, completion: nil)
        } else {
            showInformationPopup()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addCreditCard" {
            guard let addCreditCard = segue.destination as? AddCreditCardView else { return }
            addCreditCard.delegate = self
        }
    }

    private func showNetworkActivity() {
        networkLayer.isHidden = false
    }

    private func hideNetworkActivity() {
        networkLayer.isHidden = true
    }
}

extension BookingStep3: AddCreditCardDelegate {
    func add(card data: CardInputData) {
        showNetworkActivity()
        paymentController.encode(data)
    }
}

extension BookingStep3: PaymentControllerDelegate {
    func added(payment method: PaymentMethod<CreditCardInfo>, to session: PaymentSession?) {
        showNetworkActivity()
        paymentController.performPayment(with: method)
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

extension BookingStep3 {
    // swiftlint:disable line_length
    func showSuccessPopup(with info: PaymentResult) {
        hideNetworkActivity()

        let bodyString = """
        Your chosen card has been successfully authorized and we have forwarded your booking request to a personal aviation agent.

        Your personal aviation agent will swiftly be in touch, while we are waiting to connect, we invite you to further peruse our fleet or perhaps book a flight for your next adventure.
        """

        showCardAlertWith(title: "Booking Request Submited", body: bodyString, buttonTitle: "View Booking Requests") {
            self.paymentDelegate?.paymentCompleted(with: "Home")
        }
    }

    func showFailurePopup(with description: String) {
        hideNetworkActivity()

        let bodyString = """
        Unfortunately, the booking request could not be submitted due to \(description).

        Please retry by pressing the button below.

        If the issue persists contact us directly via telephone or chat widget located in the bottom right corner of the screen.
        """

        showCardAlertWith(title: "Request Not Processed", body: bodyString, buttonTitle: "Retry Submission", cancelButtonTitle: "Cancel request procedure") {
//            print("Should retry")
        }
    }

    func showDeclinedPopup(with description: String) {
        hideNetworkActivity()

        let bodyString = """
        Unfortunately, the attempt to authorize was declined due to \(description).

        Please try using a different card. If the issue persists contact us directly via telephone or chat widget located in the bottom right corner of the screen.
        """

        showCardAlertWith(title: "Card Authorization Failed", body: bodyString, buttonTitle: "Authorize a different Card", cancelButtonTitle: "Cancel request procedure") {
            print("Re try")
        }
    }

    func showErrorInforming(with info: PaymentResult) {
        hideNetworkActivity()

        let bodyString = """
        There was an error while saving your booking request, please contact ours Agents with the following reference:

        REF : \(info.reference)

        Please keep this reference in a safe place to inform about the payment.

        Thank you
        """
        
        showCardAlertWith(title: "Booking process failed", body: bodyString, buttonTitle: "Ok") {
//            print("Re try")
        }
    }

    // swiftlint:enable line_length
}
