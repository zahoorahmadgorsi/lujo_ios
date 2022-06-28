import UIKit

struct PaymentMethodInfo {
    var icon: String
    var name: String
    var comment: String
    var enabled: Bool
}

class PaymentMethodCell: UITableViewCell {
    @IBOutlet var icon: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var comment: UILabel!

    @IBOutlet var selectedIndicator: UIView!

    @IBOutlet var disabledOverlay: UIView!
    @IBOutlet var disabledLabel: LujoInsetLabel!

    static let id = "PaymentMethodCell"

    var enabled: Bool = true {
        didSet {
            disabledLabel.isHidden = enabled
            disabledOverlay.isHidden = enabled
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        selectionStyle = .none
        selectedIndicator.isHidden = true
        disabledLabel.layer.cornerRadius = disabledLabel.bounds.height / 2
    }

    func set(method info: PaymentMethodInfo) {
        icon.image = UIImage(named: info.icon)
        name.text = info.name
        comment.text = info.comment

        enabled = info.enabled
        isUserInteractionEnabled = enabled
    }

    override func prepareForReuse() {
        selectedIndicator.isHidden = true
        isUserInteractionEnabled = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        selectedIndicator.isHidden = !selected
        super.setSelected(selected, animated: animated)
    }
}

class BookingStep2: UIViewController {
    @IBOutlet var paymentMethods: UITableView!
    weak var paymentDelegate: PaymentSelectionDelegate?

    var paymentData: PaymentData?

    private let availableMethods: [PaymentMethodInfo] = [
        PaymentMethodInfo(icon: "Wire Transfer Payment Type",
                          name: "Wire transfer",
                          comment: "*we ask clients to cover bank charges on wire payments",
                          enabled: true)
        ,PaymentMethodInfo(icon: "Credit Card Payment Type",
                          name: "Credit Card",
                          comment: "*some cards are subject to a small merchant processing fee",
                          //enabled: false),
                          enabled: true),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        paymentMethods.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activateKeyboardManager()
    }

    @IBAction func nextStep(_ sender: Any) {
        guard let selectedIndex = paymentMethods.indexPathForSelectedRow?.row else {
            return
        }

        guard availableMethods[selectedIndex].enabled == true else {
            return
        }

        if selectedIndex == 0 { // Wire transfer
            performSegue(withIdentifier: "wireTransfer", sender: nil)
        } else { // Credit card
            // Nothing to do here as it is not enabled yet
            performSegue(withIdentifier: "wireTransfer", sender: nil)   //as per sahle it would be the same
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "wireTransfer" {
            guard let nextStep = segue.destination as? BookingStep3 else { return }
            nextStep.paymentData = paymentData
            nextStep.paymentDelegate = paymentDelegate
        }
    }

    @IBAction func cancelBookingRequest(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func chatButton_onClick(_ sender: UIButton) {
        if LujoSetup().getLujoUser()?.membershipPlan != nil {
            guard let userFirstName = LujoSetup().getLujoUser()?.firstName else { return }
            let initialMessage = """
            Hi Concierge team,
            
            I want to choose one preferred payment method, can you please assist me?
            
            \(userFirstName)
            """
            //Checking if user is able to logged in to Twilio or not, if not then getClient will login
            if ConversationsManager.sharedConversationsManager.getClient() != nil
            {
                let viewController = AdvanceChatViewController()
                viewController.salesforceRequest = SalesforceRequest(id: "616cfe0f7c13a8001be01e43" , type: "aviation" , name: "Choose preferred payment method")
                viewController.initialMessage = initialMessage
                let navController = UINavigationController(rootViewController:viewController)
                UIApplication.topViewController()?.present(navController, animated: true, completion: nil)
            }else{
                let error = BackendError.parsing(reason: "Chat option is not available, please try again later")
                self.showError(error)
                print("Twilio: Not logged in")
            }
            
        } else {
            showInformationPopup()
        }
            //startChatWithInitialMessage()
    }
    
    func showError(_ error: Error) {
        showErrorPopup(withTitle: "Error", error: error)
    }
}

extension BookingStep2: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableMethods.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable force_cast line_length
        let cell = paymentMethods.dequeueReusableCell(withIdentifier: PaymentMethodCell.id, for: indexPath) as! PaymentMethodCell
        // swiftlint:enable force_cast line_length
        let methodInfo = availableMethods[indexPath.row]
        cell.set(method: methodInfo)

        return cell
    }
}
