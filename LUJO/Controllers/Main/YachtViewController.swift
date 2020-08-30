//
//  YachtViewController.swift
//  LUJO
//
//  Created by Nemanja Djurisic on 11/26/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import JGProgressHUD

class YachtViewController: UIViewController {
    
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "YachtViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate() -> YachtViewController {
        return UIStoryboard.customRequest.instantiate(identifier)
    }

    //MARK:- Globals
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var yachtNameTextField: UITextField!
    @IBOutlet weak var yachtTypeLabel: UILabel!
    @IBOutlet weak var yachtTypeButton: UIButton!
    @IBOutlet weak var lenghtButton: UIButton!
    @IBOutlet weak var lenghtLabel: UILabel!
    @IBOutlet weak var guestsLabel: UILabel!
    @IBOutlet weak var fromDateLabel: LujoIconLabel!
    @IBOutlet weak var toDateLabel: LujoIconLabel!
   
    private var selectedYachtType: String?
    private var selectedYachtLenght: String?
    
    private var guestsCount: Int = 0 {
        didSet {
            guestsLabel.text = "\(guestsCount)"
        }
    }
    
    private let naHUD = JGProgressHUD(style: .dark)
    
    private var dateTime: SearchTime = SearchTime(date: "", time: "")
    private var returnDateTime: SearchTime = SearchTime(date: "", time: "")
    
    var typeDataPicker: ikDataPickerManger?
    var lenghtDataPicker: ikDataPickerManger?
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "us_US")
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }()
    
    //MARK:- Life cicyle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        yachtTypeButton.layer.borderWidth = 1
        yachtTypeButton.layer.borderColor = UIColor.inputBorderNoFocus.cgColor
        
        lenghtButton.layer.borderWidth = 1
        lenghtButton.layer.borderColor = UIColor.inputBorderNoFocus.cgColor
        
        guestsCount = 2
        
        addGestureRecognizers()
    }

    //MARK: - User interaction
    
    @IBAction func cancelButton_onClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func decreaseButton_onClick(_ sender: Any) {
        if guestsCount > 1 {
            guestsCount -= 1
        }
    }
    
    @IBAction func increaseButton_onClick(_ sender: Any) {
        guestsCount += 1
    }
    
    @IBAction func dropDownButton_onClick(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if typeDataPicker == nil {
            let dataSource: [[String]] = [["Any", "Motorboat", "Sailboat"]]
            typeDataPicker = ikDataPickerManger.create(owner: self, sourceView: sender, title: "Select yacht type", dataSource: dataSource, callback: { values in
                self.selectedYachtType = values[0]
                self.yachtTypeLabel.text = values[0]
            })
        }
        
        typeDataPicker?.present()
    }
    
    @IBAction func lenghtButton_onClick(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if lenghtDataPicker == nil {
            let dataSource: [[String]] = [["1-20", "20-35", "35-75", "75-90", "90+"]]
            lenghtDataPicker = ikDataPickerManger.create(owner: self, sourceView: sender, title: "Select yacht lenght(m)", dataSource: dataSource, callback: { values in
                self.selectedYachtLenght = values[0]
                self.lenghtLabel.text = values[0]
            })
        }
        
        lenghtDataPicker?.present()
    }
    
    @IBAction func requestButton_onClick(_ sender: Any) {
        guard let destination = destinationTextField.text, !destination.isEmpty else {
            showInformationPopup(withTitle: "Info", message:"Please enter you destination.")
            return
        }
        
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            showInformationPopup(withTitle: "Info", message:"User does not exist or is not verified.")
            return
        }
        
        guard let lenghtText = selectedYachtLenght, !lenghtText.isEmpty else {
            showInformationPopup(withTitle: "Info", message:"Please choose yacht lenght.")
            return
        }
        
        guard !dateTime.date.isEmpty else {
            showInformationPopup(withTitle: "Info", message:"Please select start date.")
            return
        }
        
        guard !returnDateTime.date.isEmpty else {
            showInformationPopup(withTitle: "Info", message:"Please select return date.")
            return
        }
        
        guard let dateString = dateTime.formatedDateForServer else {
            showInformationPopup(withTitle: "Info", message:"Start date is not in correct format.")
            return
        }
        
        guard let returnDateString = returnDateTime.formatedDateForServer else {
            showInformationPopup(withTitle: "Info", message:"Return date is not in correct format.")
            return
        }
        
        let initialMessage = """
        Hi Concierge team,
        
        I would like to charter a \(selectedYachtType != nil ? "\(selectedYachtType!.lowercased())\(selectedYachtType!.lowercased() == "sailboat" ? "" : " yacht")" : "yacht") \(yachtNameTextField.text?.count ?? 0 > 0 ? "name \(yachtNameTextField.text!) " : "")with lenght of \(lenghtText)m, to travel to \(destination) from \(dateString) to \(returnDateString). I need it for \(guestsCount) \(guestsCount > 1 ? "people" : "person"), can you assist me?
        
        \(LujoSetup().getLujoUser()?.firstName ?? "User")
        """
        
        startChatWithInitialMessage(initialMessage)
        
        //showNetworkActivity()
        CustomRequestAPIManager.shared.requestYacht(destination: destination, yachtName: yachtNameTextField.text, yachtType: selectedYachtType, yachtLenght: lenghtText, dateFrom: dateString, dateTo: returnDateString, guestsCount: guestsCount, token: token) { error in
            DispatchQueue.main.async {
                //self.hideNetworkActivity()
                if let error = error {
                    print ("ERROR: \(error.localizedDescription)")
                    //self.showErrorPopup(withTitle: "Error", error:error)
                    return
                }

                print ("Success: custom request yacht.")
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
    
    private func addGestureRecognizers() {
        let dateTapRecognizer = UITapGestureRecognizer(target: self,
                                                        action: #selector(selectDate(sender:)))
        dateTapRecognizer.delegate = self
        fromDateLabel.addGestureRecognizer(dateTapRecognizer)
        
        let returnDateTapRecognizer = UITapGestureRecognizer(target: self,
                                                             action: #selector(selectReturnDate(sender:)))
        returnDateTapRecognizer.delegate = self
        toDateLabel.addGestureRecognizer(returnDateTapRecognizer)
    }
    
    func showNetworkActivity() {
        naHUD.show(in: view)
    }
    
    func hideNetworkActivity() {
        naHUD.dismiss()
    }
}

extension YachtViewController: UIGestureRecognizerDelegate {
    @IBAction func selectDate(sender: UIGestureRecognizer) {
        self.view.endEditing(true)
        let viewController = CalendarViewController.instantiate(firstValidDate: Date(), oneWay: true, customTitle: "Departure date")
        viewController.delegate = self
        present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func selectReturnDate(sender: UIGestureRecognizer) {
        self.view.endEditing(true)
        if dateTime.date == "" {
            showCardAlertWith(title: "Info", body: "You must first select from date.")
            return
        }
        
        let viewController = CalendarViewController.instantiate(firstValidDate: dateTime.toDate, oneWay: false, customTitle: "Return date")
        viewController.delegate = self
        present(viewController, animated: true, completion: nil)
    }
}

extension YachtViewController: CalendarViewDelegate {
    func tripDatesSelected(departure: Date, return returnDate: Date?) {
        dateTime.date = dateFormatter.string(from: departure)
        
        if let returnDate = returnDate {
            returnDateTime.date = dateFormatter.string(from: returnDate)
        } else {
            returnDateTime.date = ""
        }
        
        fromDateLabel.text = ""
        toDateLabel.text = ""
        
        guard !dateTime.date.isEmpty else { return }
        fromDateLabel.text = dateTime.date
        
        guard !returnDateTime.date.isEmpty else { return }
        toDateLabel.text = returnDateTime.date
    }
}
