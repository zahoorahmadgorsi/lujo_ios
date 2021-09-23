//
//  HotelViewController.swift
//  LUJO
//
//  Created by Nemanja Djurisic on 11/27/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import JGProgressHUD
import Mixpanel

class HotelViewController: UIViewController {
    
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "HotelViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate() -> HotelViewController {
        return UIStoryboard.customRequest.instantiate(identifier)
    }
    
    //MARK:- Globals
    @IBOutlet weak var hotelNameTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var adultsLabel: UILabel!
    @IBOutlet weak var roomsLabel: UILabel!
    @IBOutlet weak var checkInLabel: LujoIconLabel!
    @IBOutlet weak var checkOutLabel: LujoIconLabel!
    
    @IBOutlet var starButtons: [UIButton]!
    
    private var adultsCount: Int = 0 {
        didSet {
            adultsLabel.text = "\(adultsCount)"
        }
    }
    
    private var roomsCount: Int = 0 {
        didSet {
            roomsLabel.text = "\(roomsCount)"
        }
    }
    
    private let naHUD = JGProgressHUD(style: .dark)
    
    private var checkInDateTime: SearchTime = SearchTime(date: "", time: "")
    private var checkOutDateTime: SearchTime = SearchTime(date: "", time: "")
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "us_US")
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }()
//    var delegate: ProductDetailDelegate?
    
    //MARK:- Life cicyle

    override func viewDidLoad() {
        super.viewDidLoad()

        adultsCount = 2
        roomsCount = 1
        
        addGestureRecognizers()
        

    }

    //MARK: - User interaction
    
    @IBAction func cancelButton_onClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func distanceSlider_onChange(_ sender: UISlider) {
        distanceLabel.text =  String.localizedStringWithFormat("%.0f mi", sender.value)
    }
    
    @IBAction func decreaseAdultsButton_onClick(_ sender: Any) {
        if adultsCount > 1 {
            adultsCount -= 1
        }
    }
    
    @IBAction func increaseAdultsButton_onClick(_ sender: Any) {
        adultsCount += 1
    }
    
    @IBAction func decreaseRoomsButton_onClick(_ sender: Any) {
        if roomsCount > 1 {
            roomsCount -= 1
        }
    }
    
    @IBAction func increaseRoomsButton_onClick(_ sender: Any) {
        roomsCount += 1
    }
    
    @IBAction func starButton_onClick(_ sender: UIButton) {
        for button in starButtons {
            button.isSelected = sender.tag >= button.tag
        }
    }
    
    @IBAction func requestButton_onClick(_ sender: Any) {
        guard let cityName = cityTextField.text, !cityName.isEmpty else {
            showInformationPopup(withTitle: "Info", message:"Please enter city or neighborhood where you want to stay.")
            return
        }
        
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            showInformationPopup(withTitle: "Info", message:"User does not exist or is not verified.")
            return
        }
        
        guard !checkInDateTime.date.isEmpty else {
            showInformationPopup(withTitle: "Info", message:"Please select check in date.")
            return
        }
        
        guard !checkOutDateTime.date.isEmpty else {
            showInformationPopup(withTitle: "Info", message:"Please select check out date.")
            return
        }
        
        guard let checkInDateString = checkInDateTime.formatedDateForServer else {
            showInformationPopup(withTitle: "Info", message:"Check in date is not in correct format.")
            return
        }
        
        guard let checkOutDateString = checkOutDateTime.formatedDateForServer else {
            showInformationPopup(withTitle: "Info", message:"Check out date is not in correct format.")
            return
        }
        
        guard let lastButton = starButtons.last(where: { $0.isSelected == true}) else {
            showInformationPopup(withTitle: "Info", message:"Please select hotel stars.")
            return
        }
        
        Mixpanel.mainInstance().track(event: "Hotel Custom Request",
                                      properties: ["Hotel City" : cityName
                                                   ,"Hotel Check In Date" : checkInDateString
                                                   ,"Hotel Check Out Date" : checkOutDateString])
        
        let initialMessage = """
        Hi Concierge team,
        
        I would like to book \(roomsCount) room\(roomsCount > 1 ? "s" : "") for \(adultsCount) adults in \(lastButton.tag) stars \(hotelNameTextField.text?.count ?? 0 > 0 ? "\(hotelNameTextField.text!) " : "")hotel in \(cityName) from \(checkInDateString) to \(checkOutDateString). I also accept hotels with \(lastButton.tag) stars in range of \(String.localizedStringWithFormat("%.0f", distanceSlider.value)) miles. Can you assist me?
        
        \(LujoSetup().getLujoUser()?.firstName ?? "User")
        """
        
        showNetworkActivity()
        CustomRequestAPIManager.shared.findHotel(cityName: cityName, hotelName: hotelNameTextField.text, hotelRadius: String.localizedStringWithFormat("%.0f", distanceSlider.value), checkInDate: checkInDateString, checkOutDate: checkOutDateString, adultsCount: adultsCount, roomsCount: roomsCount, hotelStars: lastButton.tag, token: token) { error in
            DispatchQueue.main.async {
                self.hideNetworkActivity()
                if let error = error {
                    print ("ERROR: \(error.localizedDescription)")
                    //self.showErrorPopup(withTitle: "Error", error:error)
                    return
                }

//                print ("Success: custom request table.")
                let viewController = BasicChatViewController()
                viewController.product = Product(id: -1, type: "travel" , name: "Hotel in " + cityName)
                viewController.initialMessage = initialMessage
                let navController = UINavigationController(rootViewController:viewController)
                UIApplication.topViewController()?.present(navController, animated: true, completion: nil)
                //Zahoor end
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
                                                       action: #selector(selectCheckInDate(sender:)))
        dateTapRecognizer.delegate = self
        checkInLabel.addGestureRecognizer(dateTapRecognizer)
        
        let returnDateTapRecognizer = UITapGestureRecognizer(target: self,
                                                             action: #selector(selectCheckOutDate(sender:)))
        returnDateTapRecognizer.delegate = self
        checkOutLabel.addGestureRecognizer(returnDateTapRecognizer)
    }
    
    func showNetworkActivity() {
        naHUD.show(in: view)
    }
    
    func hideNetworkActivity() {
        naHUD.dismiss()
    }
}

extension HotelViewController: UIGestureRecognizerDelegate {
    @IBAction func selectCheckInDate(sender: UIGestureRecognizer) {
        self.view.endEditing(true)
        let viewController = CalendarViewController.instantiate(firstValidDate: Date(), oneWay: true, customTitle: "Check in")
        viewController.delegate = self
        present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func selectCheckOutDate(sender: UIGestureRecognizer) {
        self.view.endEditing(true)
        if checkInDateTime.date == "" {
            showCardAlertWith(title: "Info", body: "You must first select from date.")
            return
        }
        
        let viewController = CalendarViewController.instantiate(firstValidDate: checkInDateTime.toDate, oneWay: false, customTitle: "Check out")
        viewController.delegate = self
        present(viewController, animated: true, completion: nil)
    }
}

extension HotelViewController: CalendarViewDelegate {
    func tripDatesSelected(departure: Date, return returnDate: Date?) {
        checkInDateTime.date = dateFormatter.string(from: departure)
        
        if let returnDate = returnDate {
            checkOutDateTime.date = dateFormatter.string(from: returnDate)
        } else {
            checkOutDateTime.date = ""
        }
        
        checkInLabel.text = ""
        checkOutLabel.text = ""
        
        guard !checkInDateTime.date.isEmpty else { return }
        checkInLabel.text = checkInDateTime.date
        
        guard !checkOutDateTime.date.isEmpty else { return }
        checkOutLabel.text = checkOutDateTime.date
    }
}
