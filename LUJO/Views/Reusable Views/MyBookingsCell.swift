import UIKit

protocol MyBookingCellDelegate: class {
    func showPaymentInstructions(cell: MyBookingsCell)
    func showAdditionalPaymentInstructions(cell: MyBookingsCell)
}

class MyBookingsCell: UITableViewCell {
    static var cellID = "myBookingCellID"

    private static let detailsViewHeight: CGFloat = 180
    private var detailsViewHeightConstraint: NSLayoutConstraint!

    static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter
    }()

    weak var delegate: MyBookingCellDelegate?

    var bookingInfo: AviationBooking? {
        didSet {
            updateContent()

            self.layoutSubviews()
            self.updateConstraints()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        addContentViews()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    private func addContentViews() {
        contentView.addSubview(contentViewContainer)
        NSLayoutConstraint.activate([
            contentViewContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            contentViewContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            contentViewContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            contentViewContainer.heightAnchor.constraint(lessThanOrEqualTo: contentView.heightAnchor),
        ])

        contentViewContainer.addArrangedSubview(liftDetailsView)
        contentViewContainer.addArrangedSubview(segmentsView)
        contentViewContainer.addArrangedSubview(separator())
    }

    override func prepareForReuse() {
        contentViewContainer.removeArrangedSubview(priceDetailsView)
        contentViewContainer.removeArrangedSubview(paymentDetailsView)
        contentViewContainer.removeArrangedSubview(bottomView)
        priceDetailsView.removeFromSuperview()
        paymentDetailsView.removeFromSuperview()
        bottomView.removeFromSuperview()
    }

    @objc func showInstructions(_ sender: ActionButton) {
        delegate?.showPaymentInstructions(cell: self)
    }

    @objc func showAdditionalInstructions(_ sender: ActionButton) {
        delegate?.showAdditionalPaymentInstructions(cell: self)
    }

    // MARK: Contained views decalaration

    let contentViewContainer: UIStackView = {
        let view = UIStackView()

        view.axis = .vertical
        view.spacing = 0

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private func separator() -> UIView {
        let separator = UIView(frame: CGRect(x: 0, y: 0, width: contentViewContainer.bounds.size.width, height: 1))
        separator.backgroundColor = UIColor.backGround2
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return separator
    }
    
    private lazy var bottomView: UIView = {
        let bottomView = UIView(frame: CGRect(x: 0, y: 0, width: contentViewContainer.bounds.size.width, height: 16))
        bottomView.backgroundColor = UIColor.clear
        bottomView.heightAnchor.constraint(equalToConstant: 16).isActive = true
        return bottomView
    }()

    private lazy var segmentsView: BookingSegmentsSummaryView = {
        guard let segmentsView: BookingSegmentsSummaryView = BookingSegmentsSummaryView.instantiateFromNib() else {
            fatalError("Unable to instantiate Booking Segments Summary View")
        }
        return segmentsView
    }()

    private lazy var liftDetailsView: BookingRequestLiftInfo = {
        guard let liftInfo: BookingRequestLiftInfo = BookingRequestLiftInfo.instantiateFromNib() else {
            fatalError("Unable to instantiate Booking Lift Info View")
        }
        detailsViewHeightConstraint = liftInfo.heightAnchor.constraint(equalToConstant: MyBookingsCell.detailsViewHeight)
        detailsViewHeightConstraint.isActive = true

        return liftInfo
    }()

    private lazy var priceDetailsView: BookingPriceSummaryView = {
        guard let priceInfo: BookingPriceSummaryView = BookingPriceSummaryView.instantiateFromNib() else {
            fatalError("Unable to instantiate Booking Price Summary View")
        }

        priceInfo.message.text = "Based on the price stated above, please make the payment by following the button"
        priceInfo.heightAnchor.constraint(equalToConstant: 150).isActive = true

        priceInfo.viewInstructions.addTarget(self, action: #selector(self.showInstructions(_:)), for: .touchUpInside)

        return priceInfo
    }()

    private lazy var paymentDetailsView: BookingPaymentSummaryView = {
        guard let paymentInfo: BookingPaymentSummaryView = BookingPaymentSummaryView.instantiateFromNib() else {
            fatalError("Unable to instantiate Booking Payment Summary View")
        }

        paymentInfo.finalPrice.text = "[TBD]"
        paymentInfo.additionalExpenses.text = "[TBD]"
        paymentInfo.heightAnchor.constraint(equalToConstant: 301).isActive = true

        paymentInfo.viewPaymentInstructions.addTarget(self, action: #selector(self.showInstructions(_:)), for: .touchUpInside)
        paymentInfo.additionalPaymentInstructions.addTarget(self, action: #selector(self.showAdditionalInstructions(_:)), for: .touchUpInside)

        return paymentInfo
    }()

    private func totalPrice(for info: AviationBooking) -> Double? {
        guard let price = bookingInfo?.prices?.price,
            let markup = bookingInfo?.prices?.markup,
            let priceFet = bookingInfo?.prices?.priceFet
        else { return nil }

        let netPrice = price + (price * markup / 100)
        let fetPrice = netPrice * priceFet / 100 * netPrice

        var feesSum = 0.0

        if let priceFees = bookingInfo?.prices?.fees {
            for aFee in priceFees {
                feesSum += (aFee.type == "fixed" ? aFee.amount : (aFee.amount / 100 * netPrice))
            }
        }

        return netPrice + fetPrice + feesSum
    }

    fileprivate func setupPaymentsView(_ bookingInfo: AviationBooking) {
        contentViewContainer.addArrangedSubview(paymentDetailsView)
        contentViewContainer.addArrangedSubview(bottomView)

        if let totalPrice = bookingInfo.prices?.totalPrice ?? self.totalPrice(for: bookingInfo) {
            let priceStr = MyBookingsCell.formatter.string(from: totalPrice as NSNumber)
            paymentDetailsView.finalPrice.text = "[\(priceStr ?? "TBD")]"
        } else {
            paymentDetailsView.finalPrice.text = "[TBD]"
        }

        var totalAdditionalExpenses: Double = 0.0

        if let expenses = bookingInfo.additionalExpenses {
            for expense in expenses {
                for aFee in expense.fees {
                    switch aFee.type {
                    case "fixed":
                        totalAdditionalExpenses += aFee.amount
                    default:
                        totalAdditionalExpenses += (aFee.amount * expense.price / 100)
                    }
                }
            }

            let priceStr = MyBookingsCell.formatter.string(from: totalAdditionalExpenses as NSNumber)
            paymentDetailsView.additionalExpenses.text = "[\(priceStr ?? "TBD")]"
            paymentDetailsView.additionalExpencesPaid.setTitle(totalAdditionalExpenses == 0 ? "  No additional expenses at the moment" : "  Additional expenses have been paid", for: .normal)
            paymentDetailsView.additionalPaymentInstructions.isHidden = !(bookingInfo.additionalExpenses?.count ?? 0 > 0 && !(bookingInfo.additionalExpenses?[0].paid ?? true))
        } else {
            paymentDetailsView.additionalExpenses.text = "[TBD]"
            paymentDetailsView.additionalPaymentInstructions.isHidden = true
        }

        paymentDetailsView.viewPaymentInstructions.isHidden = bookingInfo.paid
    }

    fileprivate func setupPriceView(_ bookingInfo: AviationBooking) {
        contentViewContainer.addArrangedSubview(priceDetailsView)
        contentViewContainer.addArrangedSubview(bottomView)

        if let totalPrice = bookingInfo.prices?.totalPrice {
            let priceStr = MyBookingsCell.formatter.string(from: totalPrice as NSNumber)
            priceDetailsView.amount.text = "[\(priceStr ?? "TBD")]"
            priceDetailsView.currency.isHidden = false
        } else {
            priceDetailsView.amount.text = "TBD"
            priceDetailsView.currency.isHidden = true
        }

        if bookingInfo.stage == .stage3 || bookingInfo.stage == .stage4 {
            priceDetailsView.message.text = "VIEW PAYMENT INSTRUCTIONS"
            priceDetailsView.viewInstructions.isHidden = false
        } else {
            priceDetailsView.message.text = "Payment instructions will appear here soon."
            priceDetailsView.viewInstructions.isHidden = true
        }
    }

    private func updateContent() {
        guard let bookingInfo = bookingInfo else { return }

        let segments = bookingInfo.aircraft.aircraftItineraries.map({ $0.toAviationSegment() })

        if !segments.isEmpty {
            segmentsView.segments = segments
        }

        if let image = bookingInfo.aircraft.aircraftPhotos.first {
            let name = bookingInfo.aircraft.type
            let request = bookingInfo.number
            liftDetailsView.setInfo(request: request,
                                    image: image.imageURL,
                                    aircraft: name,
                                    multyleg: segments.count > 1,
                                    isTrip: bookingInfo.stage == .trip)
        }

        if bookingInfo.stage == .trip {
            setupPaymentsView(bookingInfo)
            detailsViewHeightConstraint.constant = MyBookingsCell.detailsViewHeight - 32
        } else {
            setupPriceView(bookingInfo)
            detailsViewHeightConstraint.constant = MyBookingsCell.detailsViewHeight
        }
    }
}
