import ActiveLabel
import UIKit

class AviationEmptyResultsView: UIView {
    @IBOutlet var contentVIew: UIView!
    @IBOutlet var searchAgainButton: UIButton!

    @IBOutlet var customRequestLabel: ActiveLabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    fileprivate func commonInit() {
        Bundle.main.loadNibNamed("AviationEmptyResult", owner: self, options: nil)
        addSubview(contentVIew)
        contentVIew.frame = bounds
        contentVIew.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        setupActiveLabels()
    }

    fileprivate func setupActiveLabels() {
        let termsOfUseType = ActiveType.custom(pattern: "\\scustom request\\b")
        customRequestLabel.enabledTypes = [termsOfUseType]

        customRequestLabel.customize { label in
            label.text = "or create a custom request"
            label.font = UIFont.systemFont(ofSize: 17, weight: .light)
            label.textColor = UIColor.whiteText
            label.customColor[termsOfUseType] = UIColor.rgMid
            label.handleCustomTap(for: termsOfUseType) { [weak self] _ in
                if LujoSetup().getLujoUser()?.membershipPlan != nil {
                    guard let userFirstName = LujoSetup().getLujoUser()?.firstName else { return }
                    let initialMessage = """
                    Hi Concierge team,

                    How can i book a flight, can you please assist me?

                    \(userFirstName)
                    """
                    //Checking if user is able to logged in to Twilio or not, if not then getClient will login
                    if ConversationsManager.sharedConversationsManager.getClient() != nil
                    {
                        let viewController = AdvanceChatViewController()
                        viewController.salesforceRequest = SalesforceRequest(id: "616cfe0f7c13a8001be01e43" , type: "aviation" , name: "Flight Booking Inquiry", sfRequestType: .CUSTOM)
                        viewController.initialMessage = initialMessage
                        let navController = UINavigationController(rootViewController:viewController)
                        UIApplication.topViewController()?.present(navController, animated: true, completion: nil)
                        
                    }else{
                        let error = BackendError.parsing(reason: "Chat option is not available, please try again later")
                        self?.parentViewController?.showErrorPopup(withTitle: "Error", error: error)
                        print("Twilio: Not logged in")
                    }
                    
                    self?.isHidden = true
                } else {
                    self?.parentViewController?.showInformationPopup()
                }
            }
        }
    }

    @IBAction func requestNewSearch(_ sender: Any) {
        isHidden = true
    }
    

}
