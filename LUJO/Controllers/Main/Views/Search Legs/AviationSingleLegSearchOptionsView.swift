import UIKit

struct AviationSegmentInformation {
    var startAirport: Airport?
    var endAirport: Airport?
    var departureDateTime: SearchTime
    var returnDateTime: SearchTime?
    var passengers: Int
    var luggage: AviationLuggage?
}

extension AviationSegmentInformation {
    init(_ segment: AviationSegment) throws {
        self.init(startAirport: segment.startAirport,
                  endAirport: segment.endAirport,
                  departureDateTime: segment.dateTime,
                  returnDateTime: segment.returnDate,
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
                                                 departureDateTime: SearchTime(date: "", time: ""),
                                                 returnDateTime: nil,
                                                 passengers: 1,
                                                 luggage: nil) {
        didSet { updateAllLabels() }
    }

    weak var aviationSearchCriteriaDelegate: AviationSearchCriteriaDelegate?

    private let formatter = DateFormatter()
    private let timeFormatter = DateFormatter()

    private var newOriginTime: Date?
    private var newReturnTime: Date?

    var legNumber: Int?
    let originTimePicker = UIDatePicker(frame: .zero)
    let destinTimePicker = UIDatePicker(frame: .zero)
    
    private lazy var originTimePickerView: UIView = {
        let pickerView = UIView(frame: .zero)
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.backgroundColor = UIColor(named: "Black Backgorund")?.withAlphaComponent(0.75)
        pickerView.isHidden = true
            
        addSubview(pickerView)

        //constrainings for outer uiView
        NSLayoutConstraint.activate(
            [
                pickerView.topAnchor.constraint(equalTo: topAnchor),
             pickerView.bottomAnchor.constraint(equalTo: bottomAnchor),
             pickerView.leadingAnchor.constraint(equalTo: leadingAnchor),
             pickerView.trailingAnchor.constraint(equalTo: trailingAnchor)]
        )

//        let originTimePicker = UIDatePicker(frame: .zero)
        originTimePicker.translatesAutoresizingMaskIntoConstraints = false
        originTimePicker.datePickerMode = .time
//        originTimePicker.backgroundColor = UIColor.inputFieldText
        if #available(iOS 14.0, *) {
            originTimePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        originTimePicker.addTarget(self, action: #selector(originTimeChanged(picker:)), for: .valueChanged)
        // swiftlint:disable line_length
        originTimePicker.date = segmentData.departureDateTime.time.isEmpty ? Date() : timeFormatter.date(from: segmentData.departureDateTime.time) ?? Date()
        // swiftlint:enable line_length
        pickerView.addSubview(originTimePicker)
            NSLayoutConstraint.activate(
                [originTimePicker.bottomAnchor.constraint(equalTo: pickerView.bottomAnchor),
                 originTimePicker.leadingAnchor.constraint(equalTo: pickerView.leadingAnchor),
                 originTimePicker.trailingAnchor.constraint(equalTo: pickerView.trailingAnchor)
                 ]
            )
        
        // Toolbar
        let toolbar = UIToolbar()
        toolbar.barStyle = .black
        toolbar.tintColor = .rgMid
        toolbar.sizeToFit()

        // swiftlint:disable line_length
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneOriginDatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelOriginDatePicker))

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


    private lazy var destinationTimePickerView: UIView = {
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

            
            destinTimePicker.translatesAutoresizingMaskIntoConstraints = false
            destinTimePicker.datePickerMode = .time
//        destinTimePicker.backgroundColor = UIColor.inputFieldText
            if #available(iOS 14.0, *) {
                destinTimePicker.preferredDatePickerStyle = .wheels
            } else {
                // Fallback on earlier versions
            }
            destinTimePicker.addTarget(self, action: #selector(returnTimeChanged(picker:)), for: .valueChanged)
            if let returnTime = segmentData.returnDateTime?.time {
                destinTimePicker.date = timeFormatter.date(from: returnTime) ?? Date()
            } else {
                destinTimePicker.date = Date()
                
            }

            pickerView.addSubview(destinTimePicker)

            NSLayoutConstraint.activate(
                [destinTimePicker.bottomAnchor.constraint(equalTo: pickerView.bottomAnchor),
                 destinTimePicker.leadingAnchor.constraint(equalTo: pickerView.leadingAnchor),
                 destinTimePicker.trailingAnchor.constraint(equalTo: pickerView.trailingAnchor)]
            )

        // Toolbar
        let toolbar = UIToolbar()
        toolbar.barStyle = .black
        toolbar.tintColor = .rgMid
        toolbar.sizeToFit()

        // swiftlint:disable line_length
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(destinationDoneDatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(destinationCancelDatePicker))

        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        pickerView.addSubview(toolbar)

        NSLayoutConstraint.activate(
            [toolbar.bottomAnchor.constraint(equalTo: destinTimePicker.topAnchor),
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
                                                        action: #selector(selectDepartureDate(sender:)))
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
        
        let returnTimeTapRecognizer = UITapGestureRecognizer(target: self,
                                                        action: #selector(selectReturnTimes(sender:)))
        returnTimeTapRecognizer.delegate = self
        returnTimeLabel.addGestureRecognizer(returnTimeTapRecognizer)
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

        guard !segmentData.departureDateTime.date.isEmpty else { return }

        datesLabel.text = segmentData.departureDateTime.date

        guard let returnDate = segmentData.returnDateTime?.date, !returnDate.isEmpty else { return }

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

        guard !segmentData.departureDateTime.time.isEmpty else { return }

        timesLabel.text = segmentData.departureDateTime.time

        guard let returnTime = segmentData.returnDateTime?.time, !returnTime.isEmpty else { return }

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
        
        #if DEBUG
        let startAirport = Airport(id: "aport-5199", name: "ALLAMA IQBAL INTL", city: "LAHORE", country: Country(code: "PK", name: "Pakistan"), icao: "OPLA", iata: "LHE", faaId: nil, type: "airports")

        let endAirport = Airport(id: "aport-5191", name: "JINNAH INTL", city: "KARACHI", country: Country(code: "PK", name: "Pakistan"), icao: "OPKC", iata: "KHI", faaId: nil, type: "airports")

        segmentData.startAirport = startAirport
        segmentData.endAirport = endAirport

        var dayComponent = DateComponents()
        dayComponent.day = 0 // 0 mean today. For removing one day (yesterday): -1
        let theCalendar = Calendar.current
        if let nextDate = theCalendar.date(byAdding: dayComponent, to: Date()){
            segmentData.departureDateTime.date = formatter.string(from: nextDate)
            segmentData.departureDateTime.time =  timeFormatter.string(from: nextDate)
        }
        #endif
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
        segmentData.departureDateTime.date = formatter.string(from: departure)
        print(segmentData.departureDateTime.date)
        if let returnDate = returnDate {
            if(segmentData.returnDateTime == nil){
                //initializing empty object of return date time
                let _returnDateTime = SearchTime(date: "", time:  "")
                segmentData.returnDateTime = _returnDateTime
            }
            segmentData.returnDateTime?.date = formatter.string(from: returnDate)
        } else {
            segmentData.returnDateTime?.date = ""
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
        guard let originAirport = segmentData.startAirport else {
            let error = AviationError.general(description: "Please provide a valid departure airport.")
            aviationSearchCriteriaDelegate?.showError(error: error)
            return
        }
        
        guard
            let destinationAirport = segmentData.endAirport else {
            let error = AviationError.general(description: "Please provide a valid arrival airport.")
            aviationSearchCriteriaDelegate?.showError(error: error)
            return
        }
        
        guard !segmentData.departureDateTime.isDateEmpty else {
            let error = AviationError.general(description: "Please provide a valid departure date.")
            aviationSearchCriteriaDelegate?.showError(error: error)
            return
        }

        guard !segmentData.departureDateTime.isTimeEmpty else {
            let error = AviationError.general(description: "Valid departure time is required.")
            aviationSearchCriteriaDelegate?.showError(error: error)
            return
        }
        
        var returnDateTime: SearchTime?

        if tripType == .roundTrip {
            guard
                let returnDate = segmentData.returnDateTime , !returnDate.isDateEmpty else {
                let error = AviationError.general(description: "Please provide a valid return date.")
                aviationSearchCriteriaDelegate?.showError(error: error)
                return
            }
            guard !returnDate.isTimeEmpty else {
                let error = AviationError.general(description: "Valid return time is required.")
                aviationSearchCriteriaDelegate?.showError(error: error)
                return
            }
            if let _returnDate = returnDate.toDate, let _departureDate = segmentData.departureDateTime.toDate ,
                _returnDate <= _departureDate{
                let error = AviationError.general(description: "Return date time must be ahead of departure date time.")
                aviationSearchCriteriaDelegate?.showError(error: error)
                return
            }
            returnDateTime = returnDate
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
                                      dateTime: segmentData.departureDateTime,
                                      returnDate: returnDateTime,
                                      passengers: passengersInfo,
                                      luggage: luggage)

        let criteria = AviationSearch(customerId: customerId,
                                      data: [segment],
                                      additional: AviationAditionalRequirements(smoker: smokingSwitch.isOn ? 1 : 0))

        aviationSearchCriteriaDelegate?.search(using: criteria)
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
        aviationSearchCriteriaDelegate?.get(destination: airportType)
    }

    @IBAction func selectDepartureDate(sender: UIGestureRecognizer) {
  
        //if tripType == .roundTrip, segmentData.returnDate == nil {
        if segmentData.returnDateTime == nil {
        //zahoor end
            segmentData.returnDateTime = SearchTime(date: "", time: "")
        }
        aviationSearchCriteriaDelegate?.getTripDates(from: Date().utcToLocal().stripTime(), isReturnDate: false)
    }
    
    @IBAction func selectReturnDate(sender: UIGestureRecognizer) {
        if segmentData.departureDateTime.date == "" {
            showCardAlertWith(title: "Info", body: "You must first select departure date.")
            return
        }
//        print(segmentData.departureDateTime.toDate , segmentData.departureDateTime.toDate?.utcToLocal())
        aviationSearchCriteriaDelegate?.getTripDates(from: segmentData.departureDateTime.toDate?.stripTime(), isReturnDate: true)
    }

    @IBAction func selectTimes(sender: UIGestureRecognizer) {        if newOriginTime == nil {
            newOriginTime = Date()
        }

//        if newReturnTime == nil {
//            newReturnTime = Date()
//        }

        originTimePickerView.isHidden = false
        originTimePicker.setValue(UIColor.whiteText, forKey: "textColor")
        originTimePicker.backgroundColor = UIColor(named: "Black Backgorund")    //so that there should be noting in the background
    }

    
    
    @IBAction func selectReturnTimes(sender: UIGestureRecognizer) {
//        if newOriginTime == nil {
//            newOriginTime = Date()
//        }
        if newReturnTime == nil {
            newReturnTime = Date()
        }

        destinationTimePickerView.isHidden = false
        destinTimePicker.setValue(UIColor.whiteText, forKey: "textColor")
        destinTimePicker.backgroundColor = UIColor(named: "Black Backgorund")   //so that there should be noting in the background
    }
    
    @IBAction func doneOriginDatePicker() {
        if let time = newOriginTime { segmentData.departureDateTime.time = timeFormatter.string(from: time) }
        if tripType == .roundTrip {
            if let time = newReturnTime { segmentData.returnDateTime?.time = timeFormatter.string(from: time) }
        }
        originTimePickerView.isHidden = true
    }

    @IBAction func cancelOriginDatePicker() {
        originTimePickerView.isHidden = true
    }

    @IBAction func destinationDoneDatePicker() {
        if let time = newOriginTime { segmentData.departureDateTime.time = timeFormatter.string(from: time) }
        if tripType == .roundTrip {
            if let time = newReturnTime { segmentData.returnDateTime?.time = timeFormatter.string(from: time) }
        }
        destinationTimePickerView.isHidden = true
    }

    @IBAction func destinationCancelDatePicker() {
        destinationTimePickerView.isHidden = true
    }
    
    @IBAction func setLuggage(_ sender: Any) {
        aviationSearchCriteriaDelegate?.getLuggage(from: segmentData.luggage)
    }
}

extension AviationSingleLegSearchOptionsView {
    func setupAsNextLegFor(departure airport: Airport) {
        segmentData = AviationSegmentInformation(startAirport: airport,
                                                 endAirport: nil,
                                                 departureDateTime: SearchTime(date: "", time: ""),
                                                 returnDateTime: nil,
                                                 passengers: 1,
                                                 luggage: nil)
        departureLabel.isUserInteractionEnabled = false
    }

    func resetValues() {
        segmentData = AviationSegmentInformation(startAirport: nil,
                                                 endAirport: nil,
                                                 departureDateTime: SearchTime(date: "", time: ""),
                                                 returnDateTime: nil,
                                                 passengers: 1,
                                                 luggage: nil)
        departureLabel.isUserInteractionEnabled = true
    }
}
