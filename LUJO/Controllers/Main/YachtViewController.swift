//
//  YachtViewController.swift
//  LUJO
//
//  Created by Nemanja Djurisic on 11/26/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import JGProgressHUD
import Mixpanel

class YachtViewController: UIViewController {
    
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "YachtViewController" }
    
    private(set) var product: Product!
    
    /// Init method that will init and return view controller.
    class func instantiate(product: Product) -> YachtViewController {
        let viewController = UIStoryboard.customRequest.instantiate(identifier) as! YachtViewController
        viewController.product = product
        return viewController
    }

    //MARK:- Globals
    @IBOutlet weak var yachtCharterLabel: UILabel!
    @IBOutlet weak var yachtCharterButton: UIButton!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var yachtNameTextField: UITextField!
    @IBOutlet weak var yachtTypeLabel: UILabel!
    @IBOutlet weak var yachtTypeButton: UIButton!
    @IBOutlet weak var yachtBudgetLabel: UILabel!
    @IBOutlet weak var yachtBudgetButton: UIButton!
    @IBOutlet weak var lenghtButton: UIButton!
    @IBOutlet weak var lenghtLabel: UILabel!
    @IBOutlet weak var guestsLabel: UILabel!
    @IBOutlet weak var fromDateLabel: LujoIconLabel!
    @IBOutlet weak var toDateLabel: LujoIconLabel!
   
    @IBOutlet weak var viewDestination: UIView!
    private var selectedYachtType: String?
    private var selectedYachtLenght: String?
    private var selectedYachtBudget: String?
    private var selectedYachtCharter: String?
    
    private var guestsCount: Int = 0 {
        didSet {
            guestsLabel.text = "\(guestsCount)"
        }
    }
    
    private let naHUD = JGProgressHUD(style: .dark)
    
    private var dateTime: SearchTime = SearchTime(date: "", time: "")
    private var returnDateTime: SearchTime = SearchTime(date: "", time: "")
    
    var charterPicker: ikDataPickerManger?
    var typeDataPicker: ikDataPickerManger?
    var budgetPicker: ikDataPickerManger?
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

        yachtCharterButton.layer.borderWidth = 1
        yachtCharterButton.layer.borderColor = UIColor.inputBorderNoFocus.cgColor
        
        yachtTypeButton.layer.borderWidth = 1
        yachtTypeButton.layer.borderColor = UIColor.inputBorderNoFocus.cgColor
        
        yachtBudgetButton.layer.borderWidth = 1
        yachtBudgetButton.layer.borderColor = UIColor.inputBorderNoFocus.cgColor
        
        lenghtButton.layer.borderWidth = 1
        lenghtButton.layer.borderColor = UIColor.inputBorderNoFocus.cgColor
        
        guestsCount = 2
        
        addGestureRecognizers()
        if let product = self.product{
            self.yachtNameTextField.text = product.name
            selectedYachtLenght = product.lengthM
            self.lenghtLabel.text = product.lengthM
            
            //Setting location
            var locationText = ""
            if let cityName = product.location?.first?.city?.name {
                locationText = "\(cityName), "
            }
            locationText += product.location?.first?.country.name ?? ""
//            destinationTextField.text = locationText.lowercased()
            destinationTextField.text = locationText
 
        }
        viewDestination.layer.masksToBounds = true
        viewDestination.layer.borderColor = UIColor.lightGray.cgColor //yourColor.CGColor
        viewDestination.layer.borderWidth = 1.0
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
    
    @IBAction func budgetPickerButton_onClick(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if budgetPicker == nil {
            let dataSource: [[String]] = [["10,000 - 30,000" ,"30,000 - 60,000", "60,000 - 100,000", "100,000 - 150,000", "150,000 - 200,000", "200,000 - 300,000" , "300,00+"]]
            budgetPicker = ikDataPickerManger.create(owner: self, sourceView: sender, title: "Select budget for the yacht charter", dataSource: dataSource, callback: { values in
                self.selectedYachtBudget = values[0]
                self.yachtBudgetLabel.text = values[0]
            })
        }
        
        budgetPicker?.present()
    }
    
    @IBAction func yachtCharterButton_onClick(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if charterPicker == nil {
            let dataSource: [[String]] = [["Day charter" ,"Multi Days/Week charter"]]
            charterPicker = ikDataPickerManger.create(owner: self, sourceView: sender, title: "Select yacht charter", dataSource: dataSource, callback: { [self] values in
                //print(values[0],dataSource[0][0])
                self.selectedYachtCharter = values[0]
                self.yachtCharterLabel.text = values[0]
                if(values[0] == dataSource[0][0]){  //hiding to date label if one day charter is selected
                    self.toDateLabel.isHidden = true
                }else{
                    self.toDateLabel.isHidden = false
                }
            })
        }
        
        charterPicker?.present()
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
        
        guard let yachtCharter = selectedYachtCharter, !yachtCharter.isEmpty else {
            showInformationPopup(withTitle: "Info", message:"Please choose yacht charter.")
            return
        }
        
        guard let destination = destinationTextField.text, !destination.isEmpty else {
            showInformationPopup(withTitle: "Info", message:"Please enter you destination.")
            return
        }
        
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            showInformationPopup(withTitle: "Info", message:"User does not exist or is not verified.")
            return
        }
        
//        guard let lenghtText = selectedYachtLenght, !lenghtText.isEmpty else {
//            showInformationPopup(withTitle: "Info", message:"Please choose yacht lenght.")
//            return
//        }
        
        guard !dateTime.date.isEmpty else {
            showInformationPopup(withTitle: "Info", message:"Please select embarkation date.")
            return
        }
        
        if let yachtCharter = selectedYachtCharter{
            if yachtCharter != "Day charter"{
                guard !returnDateTime.date.isEmpty else{
                    showInformationPopup(withTitle: "Info", message:"Please select disembarkation date.")
                    return
                }
            }
        }
        
        
        guard let dateString = dateTime.formatedDateForServer else {
            showInformationPopup(withTitle: "Info", message:"Start date is not in correct format.")
            return
        }
        
        var returnDateString = ""
        if let yachtCharter = selectedYachtCharter{
            if yachtCharter != "Day charter"{
                guard let returnDateStr = returnDateTime.formatedDateForServer else {
                    showInformationPopup(withTitle: "Info", message:"Return date is not in correct format.")
                    return
                }
                returnDateString = returnDateStr
            }
        }
        
        // if return date is empty then from date is the return date
        returnDateString = (returnDateString.count == 0 ? dateString : returnDateString)
        
        let initialMessage = """
        Hi Concierge team,

        I would like to \(yachtCharter.lowercased()) a \(selectedYachtType != nil ? "\(selectedYachtType!.lowercased())\(selectedYachtType!.lowercased() == "sailboat" ? "" : " yacht")" : "yacht") \(yachtNameTextField.text?.count ?? 0 > 0 ? "name \(yachtNameTextField.text!) " : "")to travel to \(destination) from \(dateString) to \(returnDateString). I need it for \(guestsCount) \(guestsCount > 1 ? "people" : "person"), can you please assist me?

        \(LujoSetup().getLujoUser()?.firstName ?? "User")
        """
        
        showNetworkActivity()
        CustomRequestAPIManager.shared.requestYacht(destination: destination, yachtName: yachtNameTextField.text, yachtCharter: yachtCharter, dateFrom: dateString, dateTo: returnDateString, guestsCount: guestsCount, token: token) { error in
            DispatchQueue.main.async {
                self.hideNetworkActivity()
                if let error = error {
                    print ("ERROR: \(error.localizedDescription)")
                    //self.showErrorPopup(withTitle: "Error", error:error)
//                    return
                }

                print ("Success: custom request yacht.")
//                self.dismiss(animated: true, completion: nil)
                //this VC is always get called from ProductDetailsViewController only
                if let presentingViewController = self.presentingViewController as? ProductDetailsViewController {
                    self.dismiss(animated: true) {
                        presentingViewController.sendInitialInformation(initialMsg: initialMessage)
                    }
                }
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
