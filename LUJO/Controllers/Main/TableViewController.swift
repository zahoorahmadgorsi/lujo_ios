//
//  TableViewController.swift
//  LUJO
//
//  Created by Nemanja Djurisic on 11/24/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import JGProgressHUD

class TableViewController: UIViewController, UIGestureRecognizerDelegate {
    
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "TableViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate() -> TableViewController {
        return UIStoryboard.customRequest.instantiate(identifier)
    }
    
    //MARK:- Globals
    @IBOutlet weak var locationTextFiled: UITextField!
    @IBOutlet weak var restaurantNameTextField: UITextField!
    @IBOutlet weak var dropDownButton: UIButton!
    @IBOutlet weak var cuisineLabel: UILabel!
    @IBOutlet weak var dateLabel: LujoIconLabel!
    @IBOutlet weak var timeLabel: LujoIconLabel!
    @IBOutlet weak var guestsLabel: UILabel!
    
    private var guestsCount: Int = 0 {
        didSet {
            guestsLabel.text = "\(guestsCount)"
        }
    }
    
    private let naHUD = JGProgressHUD(style: .dark)
    private var categories: [Cuisine] = []
    private var selectedCategory: Cuisine? {
        didSet {
            cuisineLabel.text = selectedCategory?.name
        }
    }
    
    private var dateTime: SearchTime = SearchTime(date: "", time: "") {
        didSet {
            updateTimeAndDateLabels()
        }
    }
    
    var categoryDataPicker: ikDataPickerManger?
    
    private var newOriginTime: Date?
    
    private lazy var timePickerView: UIView = {
        let pickerView = UIView(frame: .zero)
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.backgroundColor = UIColor(named: "Black Backgorund")?.withAlphaComponent(0.75)
        pickerView.isHidden = true
        
        view.addSubview(pickerView)
        NSLayoutConstraint.activate(
            [pickerView.topAnchor.constraint(equalTo: view.topAnchor),
             pickerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
             pickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             pickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)]
        )
        
        let originTimePicker = UIDatePicker(frame: .zero)
        originTimePicker.translatesAutoresizingMaskIntoConstraints = false
        originTimePicker.datePickerMode = .time
        originTimePicker.backgroundColor = UIColor.inputFieldText
        originTimePicker.addTarget(self, action: #selector(originTimeChanged(picker:)), for: .valueChanged)
        // swiftlint:disable line_length
        originTimePicker.date = dateTime.time.isEmpty ? Date() : timeFormatter.date(from: dateTime.time) ?? Date()
        
        let startHour: Int = 8
        let endHour: Int = 24
        let date1: Date = Date()
        let gregorian: Calendar = Calendar(identifier: .gregorian)
        var components: DateComponents = gregorian.dateComponents([.day, .month, .year], from: date1)
        components.hour = startHour
        components.minute = 0
        components.second = 0
        let startDate: Date = gregorian.date(from: components)!
        components.hour = endHour
        components.minute = 0
        components.second = 0
        let endDate: Date = gregorian.date(from: components)!
        
        originTimePicker.minimumDate = startDate
        originTimePicker.maximumDate = endDate
        originTimePicker.minuteInterval = 30
        
        // swiftlint:enable line_length
        pickerView.addSubview(originTimePicker)
        
        NSLayoutConstraint.activate(
            [originTimePicker.bottomAnchor.constraint(equalTo: pickerView.bottomAnchor),
             originTimePicker.leadingAnchor.constraint(equalTo: pickerView.leadingAnchor),
             originTimePicker.trailingAnchor.constraint(equalTo: pickerView.trailingAnchor)]
        )
        
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

    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "us_US")
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }()
    
    let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "us_US")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    //MARK:- Life cicyle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dropDownButton.layer.borderWidth = 1
        dropDownButton.layer.borderColor = UIColor.inputBorderNoFocus.cgColor
        
        guestsCount = 2
        
        loadCategories()
        addGestureRecognizers()
    }
    
    //MARK: - User interaction

    @IBAction func cancelButton_onClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func decreaseButton_onClick(_ sender: Any) {
        if guestsCount > 2 {
            guestsCount -= 1
        }
    }
    
    @IBAction func increaseButton_onClick(_ sender: Any) {
        guestsCount += 1
    }
    
    @IBAction func dropDownButton_onClick(_ sender: UIButton) {
        if categoryDataPicker == nil {
            let dataSource: [[String]] = [categories.map({ $0.name })]
            categoryDataPicker = ikDataPickerManger.create(owner: self, sourceView: sender, title: "Select cuisine category", dataSource: dataSource, callback: { values in
                self.selectedCategory = self.categories.first(where: { $0.name == values[0] })
            })
        }
        
        categoryDataPicker?.present()
    }
    
    @IBAction func requestButton_onClick(_ sender: Any) {
        guard let location = locationTextFiled.text, !location.isEmpty else {
            showInformationPopup(withTitle: "Info", message:"Please tell us where you are looking for table.")
            return
        }
        
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            showInformationPopup(withTitle: "Info", message:"User does not exist or is not verified.")
            return
        }
        
        guard !dateTime.isEmpty else {
            showInformationPopup(withTitle: "Info", message:"Please select date and time.")
            return
        }
        
        guard let dateString = dateTime.formatedDateForServer else {
            showInformationPopup(withTitle: "Info", message:"Date is not in correct format.")
            return
        }
        
        let initialMessage = """
        Hi Concierge team,
        
        I would like to book a table for \(guestsCount) \(guestsCount > 1 ? "people" : "person"), at\(restaurantNameTextField.text?.count ?? 0 > 0 ? " \(restaurantNameTextField.text!)" : "") restaurant\(selectedCategory?.name.count ?? 0 > 0 ? " with \(selectedCategory!.name.lowercased()) cuisine" : "") in \(location) on \(dateString) at \(dateTime.time)h, can you assist me?
        
        \(LujoSetup().getLujoUser()?.firstName ?? "User")
        """
        
        startChatWithInitialMessage(initialMessage)
        
        //showNetworkActivity()
        CustomRequestAPIManager.shared.findATable(location: location, restaurantName:restaurantNameTextField.text, cuisine: selectedCategory, date: dateString, time: dateTime.time, guestsCount: guestsCount, token: token) { error in
            DispatchQueue.main.async {
                //self.hideNetworkActivity()
                if let error = error {
                    print ("ERROR: \(error.localizedDescription)")
                    //self.showErrorPopup(withTitle: "Error", error:error)
                    return
                }

                print ("Success: custom request table.")
                self.dismiss(animated: true, completion: nil)
                /*
                showCardAlertWith(title: "Info", body: "Your request is being processed. We will get back to you shortly. You can follow the status of your request in My bookings.", buttonTitle: "Ok", cancelButtonTitle: nil, buttonTapHandler: {
                    self.dismiss(animated: true, completion: nil)
                })
                */
            }
        }
    }
    //MARK: - Logic
    
    fileprivate func addGestureRecognizers() {
        let datesTapRecognizer = UITapGestureRecognizer(target: self,
                                                        action: #selector(selectDates(sender:)))
        datesTapRecognizer.delegate = self
        dateLabel.addGestureRecognizer(datesTapRecognizer)
        
        let timesTapRecognizer = UITapGestureRecognizer(target: self,
                                                        action: #selector(selectTimes(sender:)))
        timesTapRecognizer.delegate = self
        timeLabel.addGestureRecognizer(timesTapRecognizer)
    }

    @IBAction func selectDates(sender: UIGestureRecognizer) {
        let viewController = CalendarViewController.instantiate(firstValidDate: Date(), oneWay: true, customTitle: "Date")
        viewController.delegate = self
        present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func selectTimes(sender: UIGestureRecognizer) {
        if newOriginTime == nil {
            newOriginTime = Date()
        }
        
        timePickerView.isHidden = false
    }
    
    @IBAction func doneDatePicker() {
        if let time = newOriginTime { dateTime.time = timeFormatter.string(from: time) }
        timePickerView.isHidden = true
    }
    
    @IBAction func originTimeChanged(picker: UIDatePicker) {
        newOriginTime = picker.date
    }
    
    @IBAction func cancelDatePicker() {
        timePickerView.isHidden = true
    }

    func loadCategories() {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            showInformationPopup(withTitle: "Info", message:"User does not exist or is not verified.")
            return
        }
        
        showNetworkActivity()
        
        CustomRequestAPIManager.shared.getCuisineCategories(token: token) { cuisines, error in
            DispatchQueue.main.async {
                self.hideNetworkActivity()
                if let error = error {
                    self.showErrorPopup(withTitle: "Error", error:error)
                } else {
                    self.categories = cuisines
                }
            }
        }
        
        AviationAPIManagerNEW.shared.authorisationToken = LujoSetup().getCurrentUser()?.token
        AviationAPIManagerNEW.shared.getBookings(type: .active) { cuisines, error in
            
            
        }
    }
    
    private func updateTimeAndDateLabels() {
        dateLabel.text = ""
        
        guard !dateTime.date.isEmpty else { return }
        
        dateLabel.text = dateTime.date
        
        timeLabel.text = ""
        
        guard !dateTime.time.isEmpty else { return }
        
        timeLabel.text = dateTime.time
    }
    
    func showNetworkActivity() {
        naHUD.show(in: view)
    }
    
    func hideNetworkActivity() {
        naHUD.dismiss()
    }
}

extension TableViewController: CalendarViewDelegate {
    func tripDatesSelected(departure: Date, return returnDate: Date?) {
        dateTime.date = dateFormatter.string(from: departure)
    }
}
