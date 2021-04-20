//
//  VillaViewController.swift
//  LUJO
//
//  Created by hafsa lodhi on 21/02/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//


import UIKit
import JGProgressHUD
import Mixpanel
import Intercom

class VillaViewController: UIViewController {
    
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "VillaViewController" }
    
    private(set) var product: Product?
    
    /// Init method that will init and return view controller.
    class func instantiate(product: Product) -> VillaViewController {
        let viewController = UIStoryboard.customRequest.instantiate(identifier) as! VillaViewController
        viewController.product = product
        return viewController
    }

    //MARK:- Globals
//    @IBOutlet weak var villaCharterLabel: UILabel!
//    @IBOutlet weak var villaCharterButton: UIButton!
//    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var villaNameTextField: UITextField!
//    @IBOutlet weak var villaTypeLabel: UILabel!
//    @IBOutlet weak var villaTypeButton: UIButton!
//    @IBOutlet weak var villaBudgetLabel: UILabel!
//    @IBOutlet weak var villaBudgetButton: UIButton!
//    @IBOutlet weak var lenghtButton: UIButton!
//    @IBOutlet weak var lenghtLabel: UILabel!

    @IBOutlet weak var fromDateLabel: LujoIconLabel!
    @IBOutlet weak var toDateLabel: LujoIconLabel!

    @IBOutlet weak var guestsLabel: UILabel!
    
//    private var selectedVillaType: String?
//    private var selectedVillaLenght: String?
//    private var selectedVillaBudget: String?
//    private var selectedVillaCharter: String?
    
    private var guestsCount: Int = 0 {
        didSet {
            guestsLabel.text = "\(guestsCount)"
        }
    }
    
    private let naHUD = JGProgressHUD(style: .dark)
    
    private var dateTime: SearchTime = SearchTime(date: "", time: "")
    private var returnDateTime: SearchTime = SearchTime(date: "", time: "")
    
//    var charterPicker: ikDataPickerManger?
    var typeDataPicker: ikDataPickerManger?
//    var budgetPicker: ikDataPickerManger?
//    var lenghtDataPicker: ikDataPickerManger?
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "us_US")
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }()
    
    //MARK:- Life cicyle
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        villaCharterButton.layer.borderWidth = 1
//        villaCharterButton.layer.borderColor = UIColor.inputBorderNoFocus.cgColor
        
//        villaTypeButton.layer.borderWidth = 1
//        villaTypeButton.layer.borderColor = UIColor.inputBorderNoFocus.cgColor
        
//        villaBudgetButton.layer.borderWidth = 1
//        villaBudgetButton.layer.borderColor = UIColor.inputBorderNoFocus.cgColor
        
//        lenghtButton.layer.borderWidth = 1
//        lenghtButton.layer.borderColor = UIColor.inputBorderNoFocus.cgColor
        
        guestsCount = 2
        
        addGestureRecognizers()
        if let product = self.product{
            self.villaNameTextField.text = product.name
//            selectedVillaLenght = product.lengthM
//            self.lenghtLabel.text = product.lengthM
//
//            //Setting location
//            var locationText = ""
//            if let cityName = product.location?.first?.city?.name {
//                locationText = "\(cityName), "
//            }
//            locationText += product.location?.first?.country.name ?? ""
//            destinationTextField.text = locationText.lowercased()
 
        }
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
    
//    @IBAction func dropDownButton_onClick(_ sender: UIButton) {
//        self.view.endEditing(true)
//
//        if typeDataPicker == nil {
//            let dataSource: [[String]] = [["Any", "Motorboat", "Sailboat"]]
//            typeDataPicker = ikDataPickerManger.create(owner: self, sourceView: sender, title: "Select villa type", dataSource: dataSource, callback: { values in
//                self.selectedVillaType = values[0]
//                self.villaTypeLabel.text = values[0]
//            })
//        }
//
//        typeDataPicker?.present()
//    }
    
//    @IBAction func budgetPickerButton_onClick(_ sender: UIButton) {
//        self.view.endEditing(true)
//
//        if budgetPicker == nil {
//            let dataSource: [[String]] = [["10,000 - 30,000" ,"30,000 - 60,000", "60,000 - 100,000", "100,000 - 150,000", "150,000 - 200,000", "200,000 - 300,000" , "300,00+"]]
//            budgetPicker = ikDataPickerManger.create(owner: self, sourceView: sender, title: "Select budget for the villa charter", dataSource: dataSource, callback: { values in
//                self.selectedVillaBudget = values[0]
//                self.villaBudgetLabel.text = values[0]
//            })
//        }
//
//        budgetPicker?.present()
//    }
    
//    @IBAction func villaCharterButton_onClick(_ sender: UIButton) {
//        self.view.endEditing(true)
//
//        if charterPicker == nil {
//            let dataSource: [[String]] = [["Day charter" ,"Multi Days/Week charter"]]
//            charterPicker = ikDataPickerManger.create(owner: self, sourceView: sender, title: "Select villa charter", dataSource: dataSource, callback: { [self] values in
//                //print(values[0],dataSource[0][0])
//                self.selectedVillaCharter = values[0]
//                self.villaCharterLabel.text = values[0]
//                if(values[0] == dataSource[0][0]){  //hiding checkin date label if one day charter is selected
//                    self.toDateLabel.isHidden = true
//                }else{
//                    self.toDateLabel.isHidden = false
//                }
//            })
//        }
//
//        charterPicker?.present()
//    }
    
    
//    @IBAction func lenghtButton_onClick(_ sender: UIButton) {
//        self.view.endEditing(true)
//
//        if lenghtDataPicker == nil {
//            let dataSource: [[String]] = [["1-20", "20-35", "35-75", "75-90", "90+"]]
//            lenghtDataPicker = ikDataPickerManger.create(owner: self, sourceView: sender, title: "Select villa lenght(m)", dataSource: dataSource, callback: { values in
//                self.selectedVillaLenght = values[0]
//                self.lenghtLabel.text = values[0]
//            })
//        }
//
//        lenghtDataPicker?.present()
//    }
    
    @IBAction func requestButton_onClick(_ sender: Any) {
        
        guard let villaName = villaNameTextField.text, villaNameTextField.text?.count ?? 0 > 0 else {
            showInformationPopup(withTitle: "Info", message:"Please enter villa name.")
            return
        }
        
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            showInformationPopup(withTitle: "Info", message:"User does not exist or is not verified.")
            return
        }
        
        guard !dateTime.date.isEmpty else {
            showInformationPopup(withTitle: "Info", message:"Please select checkin date.")
            return
        }
        
        guard !returnDateTime.date.isEmpty else{
            showInformationPopup(withTitle: "Info", message:"Please select checkout date.")
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
        
        Mixpanel.mainInstance().track(event: "Villa Custom Request",
                                      properties: ["villa Name" : villaName
                                                   ,"Villa Check In Date" : dateString
                                                   ,"Villa Check Out Date" : returnDateString])
        

        EEAPIManager().sendRequestForSalesForce(itemId: product?.id ?? -1){ customBookingResponse, error in
            guard error == nil else {
                Crashlytics.sharedInstance().recordError(error!)
                BackendError.parsing(reason: "Could not obtain the salesforce_id")
                return
            }
            //https://developers.intercom.com/installing-intercom/docs/ios-configuration
            if let user = LujoSetup().getLujoUser(), user.id > 0 {
                Intercom.logEvent(withName: "custom_request", metaData:[
                                    "sales_force_yacht_intent_id": customBookingResponse?.salesforceId ?? "NoSalesForceId"
                                    ,"user_id":user.id])
            }
        }
        
        let initialMessage = """
        Hi Concierge team

        I would like to rent \(villaName) from \(dateString) to \(returnDateString). I need it for \(guestsCount) \(guestsCount > 1 ? "people" : "person"), can you assist me?
        
        \(LujoSetup().getLujoUser()?.firstName ?? "User")
        """
        
        startChatWithInitialMessage(initialMessage)
        
        //showNetworkActivity()
        CustomRequestAPIManager.shared.requestVilla( villaName: villaName, dateFrom: dateString, dateTo: returnDateString, guestsCount: guestsCount, token: token) { error in
            DispatchQueue.main.async {
                //self.hideNetworkActivity()
                if let error = error {
                    print ("ERROR: \(error.localizedDescription)")
                    //self.showErrorPopup(withTitle: "Error", error:error)
                    return
                }

                print ("Success: custom request villa.")
                self.dismiss(animated: true, completion: nil)
                
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

extension VillaViewController: UIGestureRecognizerDelegate {
    @IBAction func selectDate(sender: UIGestureRecognizer) {
        self.view.endEditing(true)
        let viewController = CalendarViewController.instantiate(firstValidDate: Date(), oneWay: true, customTitle: "Checkout date")
        viewController.delegate = self
        present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func selectReturnDate(sender: UIGestureRecognizer) {
        self.view.endEditing(true)
        if dateTime.date == "" {
            showCardAlertWith(title: "Info", body: "You must first select checkout date.")
            return
        }
        
        let viewController = CalendarViewController.instantiate(firstValidDate: dateTime.toDate, oneWay: false, customTitle: "Checkout date")
        viewController.delegate = self
        present(viewController, animated: true, completion: nil)
    }
}

extension VillaViewController: CalendarViewDelegate {
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

