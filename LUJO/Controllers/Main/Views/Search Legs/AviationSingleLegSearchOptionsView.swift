import UIKit

struct AviationSegmentInformation {
    var startAirport: Airport?
    var endAirport: Airport?
    var dateTime: SearchTime
    var returnDate: SearchTime?
    var passengers: Int
    var luggage: AviationLuggage?
}

extension AviationSegmentInformation {
    init(_ segment: AviationSegment) throws {
        self.init(startAirport: segment.startAirport,
                  endAirport: segment.endAirport,
                  dateTime: segment.dateTime,
                  returnDate: segment.returnDate,
                  passengers: segment.passengers.adults,
                  luggage: segment.luggage)
    }
}

class AviationSingleLegSearchOptionsView: UIView, SearchCriteriaDelegate {
    static let maxPassengerNumber = 50

    @IBOutlet var departureLabel: LujoIconLabel!
    @IBOutlet var arrivalLabel: LujoIconLabel!
    @IBOutlet var datesLabel: LujoIconLabel!
    @IBOutlet var timesLabel: LujoIconLabel!
    @IBOutlet var returnDateLabel: LujoIconLabel!
    @IBOutlet var returnTimeLabel: LujoIconLabel!

    @IBOutlet var addLuggageButton: UIButton!
    @IBOutlet var luggageCountLabel: UILabel!
    @IBOutlet var passengersNumber: UILabel!
    @IBOutlet var smokingSwitch: UISwitch!

    @IBOutlet var searchButton: ActionButton!

    @IBOutlet var returnStackView: UIStackView!

    var tripType: AviationTripType = .oneWay {
        didSet {
            if tripType == .multiCity {
                searchButton.setTitle("SAVE", for: .normal)
            } else {
                searchButton.setTitle("SEARCH", for: .normal)
            }

            returnStackView.isHidden = tripType != .roundTrip
        }
    }

    var customerId: Int = 0

    var segmentData = AviationSegmentInformation(startAirport: nil,
                                                 endAirport: nil,
                                                 dateTime: SearchTime(date: "", time: ""),
                                                 returnDate: nil,
                                                 passengers: 1,
                                                 luggage: nil) {
        didSet { updateAllLabels() }
    }

    weak var delegate: AviationSearchCriteriaDelegate?

    private let formatter = DateFormatter()
    private let timeFormatter = DateFormatter()

    private var newOriginTime: Date?
    private var newReturnTime: Date?

    var legNumber: Int?

    private lazy var timePickerView: UIView = {
        let pickerView = UIView(frame: .zero)
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.backgroundColor = UIColor(named: "Black Backgorund")?.withAlphaComponent(0.75)
        pickerView.isHidden = true

        addSubview(pickerView)
        NSLayoutConstraint.activate(
            [pickerView.topAnchor.constraint(equalTo: topAnchor),
             pickerView.bottomAnchor.constraint(equalTo: bottomAnchor),
             pickerView.leadingAnchor.constraint(equalTo: leadingAnchor),
             pickerView.trailingAnchor.constraint(equalTo: trailingAnchor)]
        )

        let originTimePicker = UIDatePicker(frame: .zero)
        originTimePicker.translatesAutoresizingMaskIntoConstraints = false
        originTimePicker.datePickerMode = .time
        originTimePicker.backgroundColor = UIColor.inputFieldText
        originTimePicker.addTarget(self, action: #selector(originTimeChanged(picker:)), for: .valueChanged)
        // swiftlint:disable line_length
        originTimePicker.date = segmentData.dateTime.time.isEmpty ? Date() : timeFormatter.date(from: segmentData.dateTime.time) ?? Date()
        // swiftlint:enable line_length
        pickerView.addSubview(originTimePicker)

        if tripType == .roundTrip {
            let destinTimePicker = UIDatePicker(frame: .zero)
            destinTimePicker.translatesAutoresizingMaskIntoConstraints = false
            destinTimePicker.datePickerMode = .time
            destinTimePicker.backgroundColor = UIColor.inputFieldText
            destinTimePicker.addTarget(self, action: #selector(returnTimeChanged(picker:)), for: .valueChanged)
            if let returnTime = segmentData.returnDate?.time {
                destinTimePicker.date = timeFormatter.date(from: returnTime) ?? Date()
            } else { destinTimePicker.date = Date() }

            pickerView.addSubview(destinTimePicker)

            NSLayoutConstraint.activate(
                [originTimePicker.bottomAnchor.constraint(equalTo: pickerView.bottomAnchor),
                 originTimePicker.leadingAnchor.constraint(equalTo: pickerView.leadingAnchor),
                 originTimePicker.trailingAnchor.constraint(equalTo: destinTimePicker.leadingAnchor, constant: -5),
                 originTimePicker.widthAnchor.constraint(equalTo: destinTimePicker.widthAnchor, multiplier: 1),
                 destinTimePicker.bottomAnchor.constraint(equalTo: pickerView.bottomAnchor),
                 destinTimePicker.leadingAnchor.constraint(equalTo: originTimePicker.trailingAnchor, constant: 5),
                 destinTimePicker.trailingAnchor.constraint(equalTo: pickerView.trailingAnchor)]
            )
        } else {
            NSLayoutConstraint.activate(
                [originTimePicker.bottomAnchor.constraint(equalTo: pickerView.bottomAnchor),
                 originTimePicker.leadingAnchor.constraint(equalTo: pickerView.leadingAnchor),
                 originTimePicker.trailingAnchor.constraint(equalTo: pickerView.trailingAnchor)]
            )
        }
        // Toolbar
        let toolbar = UIToolbar()
        toolbar.barStyle = .black
        toolbar.tintColor = .rgMid
        toolbar.sizeToFit()

        // swiftlint:disable line_length
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneDatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker))

        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        pickerView.addSubview(toolbar)

        NSLayoutConstraint.activate(
            [toolbar.bottomAnchor.constraint(equalTo: originTimePicker.topAnchor),
             toolbar.leadingAnchor.constraint(equalTo: pickerView.leadingAnchor),
             toolbar.trailingAnchor.constraint(equalTo: pickerView.trailingAnchor),
             toolbar.heightAnchor.constraint(equalToConstant: 50)]
        )

        return pickerView
    }()

    fileprivate func addGestureRecognizers() {
        let departureTapRecognizer = UITapGestureRecognizer(target: self,
                                                            action: #selector(selectAirport(sender:)))
        departureTapRecognizer.delegate = self
        departureLabel.addGestureRecognizer(departureTapRecognizer)

        let arrivalTapRecognizer = UITapGestureRecognizer(target: self,
                                                          action: #selector(selectAirport(sender:)))
        arrivalTapRecognizer.delegate = self
        arrivalLabel.addGestureRecognizer(arrivalTapRecognizer)

        let datesTapRecognizer = UITapGestureRecognizer(target: self,
                                                        action: #selector(selectDates(sender:)))
        datesTapRecognizer.delegate = self
        datesLabel.addGestureRecognizer(datesTapRecognizer)
        
        let returnDateTapRecognizer = UITapGestureRecognizer(target: self,
                                                        action: #selector(selectReturnDate(sender:)))
        returnDateTapRecognizer.delegate = self
        returnDateLabel.addGestureRecognizer(returnDateTapRecognizer)

        let timesTapRecognizer = UITapGestureRecognizer(target: self,
                                                        action: #selector(selectTimes(sender:)))
        timesTapRecognizer.delegate = self
        timesLabel.addGestureRecognizer(timesTapRecognizer)
    }

    fileprivate func updateAirportsLabels() {
        if segmentData.startAirport != nil {
            departureLabel.text = segmentData.startAirport!.name
        } else {
            departureLabel.text = ""
        }

        if segmentData.endAirport != nil {
            arrivalLabel.text = segmentData.endAirport!.name
        } else {
            arrivalLabel.text = ""
        }
    }

    fileprivate func updateSelectedDatesLabel() {
        datesLabel.text = ""
        returnDateLabel.text = ""

        guard !segmentData.dateTime.date.isEmpty else { return }

        datesLabel.text = segmentData.dateTime.date

        guard let returnDate = segmentData.returnDate?.date, !returnDate.isEmpty else { return }

        returnDateLabel.text = returnDate
    }

    fileprivate func updateSelectedLuggagesLabel() {
        guard let luggageSelection = segmentData.luggage, luggageSelection.totalBags > 0 else {
            addLuggageButton.setTitle("ADD", for: .normal)
            luggageCountLabel.text = ""
            return
        }

        addLuggageButton.setTitle("EDIT", for: .normal)
        luggageCountLabel.text = "\(luggageSelection.totalBags)"
    }

    fileprivate func updatePassengersLabel() {
        passengersNumber.text = String(segmentData.passengers)
    }

    fileprivate func updateTimeLabel() {
        timesLabel.text = ""
        returnTimeLabel.text = ""

        guard !segmentData.dateTime.time.isEmpty else { return }

        timesLabel.text = segmentData.dateTime.time

        guard let returnTime = segmentData.returnDate?.time, !returnTime.isEmpty else { return }

        returnTimeLabel.text = returnTime
    }

    fileprivate func updateAllLabels() {
        updateAirportsLabels()
        updateTimeLabel()
        updatePassengersLabel()
        updateSelectedDatesLabel()
        updateSelectedLuggagesLabel()
    }

    fileprivate func setupVars() {
        formatter.dateFormat = "MM/dd/yyyy"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale

        timeFormatter.dateFormat = "HH:mm"
        timeFormatter.timeZone = Calendar.current.timeZone
        timeFormatter.locale = Calendar.current.locale
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addGestureRecognizers()

        setupVars()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        addGestureRecognizers()
        setupVars()
    }

    func set(_ airport: Airport, for destination: OriginAirport) {
        switch destination {
        case .departureAirport:
            segmentData.startAirport = airport
        case .returnAirport:
            segmentData.endAirport = airport
        }
    }

    func set(departure: Date, returnDate: Date?) {
        segmentData.dateTime.date = formatter.string(from: departure)
        if let returnDate = returnDate {
            segmentData.returnDate?.date = formatter.string(from: returnDate)
        } else {
            segmentData.returnDate?.date = ""
        }
    }

    func set(luggage: AviationLuggage) {
        segmentData.luggage = luggage
    }

    @IBAction func increasePassengers(_ sender: Any) {
        if segmentData.passengers < AviationSingleLegSearchOptionsView.maxPassengerNumber {
            segmentData.passengers += 1
        }
    }

    @IBAction func decreasePassengers(_ sender: Any) {
        if segmentData.passengers > 0 {
            segmentData.passengers -= 1
        }
    }

    @IBAction func smokingUpdate(_ sender: UISwitch) {}

    @IBAction func performSearch(_ sender: Any) {
        guard let originAirport = segmentData.startAirport,
            let destinationAirport = segmentData.endAirport,
            !segmentData.dateTime.isEmpty else {
            // TODO: Present error on missing information
            return
        }

        var returnDateTime: SearchTime?

        if tripType == .roundTrip {
            guard segmentData.returnDate != nil else {
                // TODO: Present error for return information
                return
            }
            returnDateTime = segmentData.returnDate
        }

        let passengersInfo = AviationPassengers(adults: segmentData.passengers,
                                                children: 0,
                                                infants: 0,
                                                pets: 0)
        let luggage = segmentData.luggage ?? AviationLuggage(carryOn: 0,
                                                             hold: 0,
                                                             golfBag: 0,
                                                             skis: 0,
                                                             other: 0)

        let segment = AviationSegment(startAirport: originAirport,
                                      endAirport: destinationAirport,
                                      dateTime: segmentData.dateTime,
                                      returnDate: returnDateTime,
                                      passengers: passengersInfo,
                                      luggage: luggage)

        let criteria = AviationSearch(customerId: customerId,
                                      data: [segment],
                                      additional: AviationAditionalRequirements(smoker: smokingSwitch.isOn ? 1 : 0))

        delegate?.search(using: criteria)
        legNumber = nil
    }

    @IBAction func originTimeChanged(picker: UIDatePicker) {
        newOriginTime = picker.date
    }

    @IBAction func returnTimeChanged(picker: UIDatePicker) {
        newReturnTime = picker.date
    }
}

extension AviationSingleLegSearchOptionsView: UIGestureRecognizerDelegate {
    @IBAction private func selectAirport(sender: UIGestureRecognizer) {
        let airportType = sender.view == departureLabel ? OriginAirport.departureAirport : OriginAirport.returnAirport
        delegate?.get(destination: airportType)
    }

    @IBAction func selectDates(sender: UIGestureRecognizer) {
        if tripType == .roundTrip, segmentData.returnDate == nil {
            segmentData.returnDate = SearchTime(date: "", time: "")
        }
        delegate?.getTripDates(from: Date(), isReturnDate: false)
    }
    
    @IBAction func selectReturnDate(sender: UIGestureRecognizer) {
        if segmentData.dateTime.date == "" {
            showCardAlertWith(title: "Info", body: "You must first select departure date.")
            return
        }
        delegate?.getTripDates(from: segmentData.dateTime.toDate, isReturnDate: true)
    }

    @IBAction func selectTimes(sender: UIGestureRecognizer) {
        if newOriginTime == nil {
            newOriginTime = Date()
        }

        if newReturnTime == nil {
            newReturnTime = Date()
        }

        timePickerView.isHidden = false
    }

    @IBAction func doneDatePicker() {
        if let time = newOriginTime { segmentData.dateTime.time = timeFormatter.string(from: time) }
        if tripType == .roundTrip {
            if let time = newReturnTime { segmentData.returnDate?.time = timeFormatter.string(from: time) }
        }
        timePickerView.isHidden = true
    }

    @IBAction func cancelDatePicker() {
        timePickerView.isHidden = true
    }

    @IBAction func setLuggage(_ sender: Any) {
        delegate?.getLuggage(from: segmentData.luggage)
    }
}

extension AviationSingleLegSearchOptionsView {
    func setupAsNextLegFor(departure airport: Airport) {
        segmentData = AviationSegmentInformation(startAirport: airport,
                                                 endAirport: nil,
                                                 dateTime: SearchTime(date: "", time: ""),
                                                 returnDate: nil,
                                                 passengers: 1,
                                                 luggage: nil)
        departureLabel.isUserInteractionEnabled = false
    }

    func resetValues() {
        segmentData = AviationSegmentInformation(startAirport: nil,
                                                 endAirport: nil,
                                                 dateTime: SearchTime(date: "", time: ""),
                                                 returnDate: nil,
                                                 passengers: 1,
                                                 luggage: nil)
        departureLabel.isUserInteractionEnabled = true
    }
}
