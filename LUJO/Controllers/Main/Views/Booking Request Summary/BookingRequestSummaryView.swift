import UIKit

class BookingRequestSummaryView: UIViewController {
    @IBOutlet private var scrollView: UIScrollView!

    var segmentData: [AviationSegment]
    var liftData: Lift
    var totalPrice: String
    weak var paymentDelegate: PaymentSelectionDelegate?

    init(_ segments: [AviationSegment], lift: Lift) {
        segmentData = segments
        liftData = lift

        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0

        totalPrice = formatter.string(from: NSNumber(value: liftData.aircraft.nonMemberPrice)) ?? "0.00"

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.addSubview(scrollViewContainer)
        scrollViewContainer.addArrangedSubview(liftDetailsView)
        scrollViewContainer.addArrangedSubview(separator())
        scrollViewContainer.addArrangedSubview(segmentsView)
        scrollViewContainer.addArrangedSubview(separator())
        scrollViewContainer.addArrangedSubview(priceDetailsView)

        scrollViewContainer.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        scrollViewContainer.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        scrollViewContainer.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        scrollViewContainer.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        // this is important for scrolling
        scrollViewContainer.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
    }

    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func proceedToPayment(_ sender: Any) {
        let stbrd = UIStoryboard(name: "Booking", bundle: nil)
        // swiftlint:disable force_cast
        let bookingVC = stbrd.instantiateViewController(withIdentifier: "Step1") as! BookingStep2
        // swiftlint:enable force_cast
        bookingVC.paymentDelegate = paymentDelegate
        let userId = LujoSetup().getLujoUser()!.id

        // TODO: Move amount to setup
        bookingVC.paymentData = PaymentData(id: "0000001",
                                            description: liftData.aircraft.name,
                                            amount: 500.00, // Amount for reservation
                                            currency: .dollar,
                                            country: "US",
                                            reference: liftData.id,
                                            locale: "en_US",
                                            shopper: "customer\(userId)")

        present(bookingVC, animated: true, completion: nil)
    }

    let scrollViewContainer: UIStackView = {
        let view = UIStackView()

        view.axis = .vertical
        view.spacing = 0

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private func separator() -> UIView {
        let separator = UIView.createHorizSeparator(size: CGSize(width: scrollViewContainer.bounds.size.width, height: 1),
                                                    margin: 16, background: UIColor.backGround2)
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return separator
    }

    private lazy var segmentsView: BookingSegmentsSummaryView = {
        guard let segmentsView: BookingSegmentsSummaryView = BookingSegmentsSummaryView.instantiateFromNib() else {
            fatalError("Unable to instantiate Booking Segments Summary View")
        }
        segmentsView.segments = segmentData
        return segmentsView
    }()

    private lazy var liftDetailsView: BookingRequestLiftInfo = {
        guard let liftInfo: BookingRequestLiftInfo = BookingRequestLiftInfo.instantiateFromNib() else {
            fatalError("Unable to instantiate Booking Lift Info View")
        }
        liftInfo.lift = liftData
        liftInfo.heightAnchor.constraint(equalToConstant: 207).isActive = true

        return liftInfo
    }()

    private lazy var priceDetailsView: BookingPriceSummaryView = {
        guard let priceInfo: BookingPriceSummaryView = BookingPriceSummaryView.instantiateFromNib() else {
            fatalError("Unable to instantiate Booking Lift Info View")
        }

        priceInfo.amount.text = totalPrice
        priceInfo.message.text = "Based on the price stated above, please make the payment by following the button"
        priceInfo.heightAnchor.constraint(equalToConstant: 144).isActive = true

        return priceInfo
    }()
}
