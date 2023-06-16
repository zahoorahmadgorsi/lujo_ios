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

class VillaViewController: UIViewController {
    
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "VillaViewController" }
    
    private(set) var product: Product!
    
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
    @IBOutlet weak var lblTitle: UILabel!
    
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
            if product.type == "travel"{
                self.lblTitle.text = "Book a hotel"
            }
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
    

    
    @IBAction func requestButton_onClick(_ sender: Any) {
        
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            showInformationPopup(withTitle: "Info", message:"User does not exist or is not verified.")
            return
        }
        
        guard let villaName = villaNameTextField.text, villaNameTextField.text?.count ?? 0 > 0 else {
            showInformationPopup(withTitle: "Info", message:"Please enter villa name.")
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
        
        let initialMessage = """
        Hi Concierge team,

        I would like to rent \(villaName) from \(dateString) to \(returnDateString). I need it for \(guestsCount) \(guestsCount > 1 ? "people" : "person"), can you assist me, please?

        \(LujoSetup().getLujoUser()?.firstName ?? "User")
        """
        
        self.dismiss(animated: true) {
            //Checking if user is able to logged in to Twilio or not, if not then getClient will login
            if ConversationsManager.sharedConversationsManager.getClient() != nil
            {
                let viewController = AdvanceChatViewController()
                let sfRequest = SalesforceRequest(id: self.product.id
                                                  ,type: self.product.type
                                                  ,name: self.product.name
                                                  ,villa_check_in: dateString
                                                  ,villa_check_out: returnDateString
                                                  ,villa_guests: self.guestsCount
                                                  )
                viewController.salesforceRequest = sfRequest
                viewController.initialMessage = initialMessage
                let navController = UINavigationController(rootViewController:viewController)
                UIApplication.topViewController()?.present(navController, animated: true, completion: nil)
            }else{
                let error = BackendError.parsing(reason: "Chat option is not available, please try again later")
                self.showError(error)
                print("Twilio: Not logged in")
            }
            
        }
    }
    
    func showError(_ error: Error) {
        showErrorPopup(withTitle: "Error", error: error)
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

