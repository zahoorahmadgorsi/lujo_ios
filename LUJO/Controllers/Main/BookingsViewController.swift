//
//  BookingsViewController.swift
//  LUJO
//
//  Created by Iker Kristian on 8/29/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import JGProgressHUD

class BookingsViewController: UIViewController {
    
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "BookingsViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate() -> BookingsViewController {
        return UIStoryboard.main.instantiate(identifier)
    }
    
    //MARK:- Globals
    
    @IBOutlet var informationSelector: UISegmentedControl!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var placeholderStackView: UIStackView!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var placeholderButton: UIButton!
    
    @IBOutlet var lineViewHorizontalConstraint: NSLayoutConstraint!
    
    private var networkActivityCounter = 0
    private let naHUD = JGProgressHUD(style: .dark)
    
    private var allBookings = [Booking]()
    private var bookingRequests = [Booking]()
    private var upcomingBookings = [Booking]()
    private var bookings = [AviationBooking]()
    private var trips = [AviationBooking]()
    
    private let tripSelectFont = UIFont.systemFont(ofSize: 14, weight: .regular)
    private lazy var selectedAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white,
                                           NSAttributedString.Key.font: self.tripSelectFont]
    private lazy var unselectedAttributes = [NSAttributedString.Key.foregroundColor: UIColor.inputFieldText,
                                             NSAttributedString.Key.font: self.tripSelectFont]
    private lazy var countAttributes = [NSAttributedString.Key.foregroundColor: UIColor.rgMid,
                                        NSAttributedString.Key.font: self.tripSelectFont]
    
    private var forceReload: Bool = false
    private var shouldLoadAgain: Bool = true
    private var selectedBooking: Booking?
    
    override func viewDidLoad() {
        setupInfoKindView()
        
        tableView.register(UINib(nibName: "BookingDetailCell", bundle: nil),
                           forCellReuseIdentifier: BookingDetailCell.cellID)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        activateKeyboardManager()
        if shouldLoadAgain {
            getMyAllBookings()
        } else {
            shouldLoadAgain = true
        }
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func update(bookings list: [AviationBooking]) {
        tableView.isHidden = list.isEmpty
        placeholderLabel.isHidden = !list.isEmpty
        bookings = list
        updateInformationCounters()
        tableView.reloadData()
    }
    
    func update(trips list: [AviationBooking]) {
        if !list.isEmpty { tableView.isHidden = false }
        trips = list
        updateInformationCounters()
        tableView.reloadData()
    }
    
    func update(allBookings list: [Booking]) {
        tableView.isHidden = list.isEmpty
        allBookings = list
        bookingRequests = []
        upcomingBookings = []
        for request in allBookings {
            if let aviationRequest = request.bookingAviation {
                if aviationRequest.paid {
                   upcomingBookings.append(request)
                } else {
                    bookingRequests.append(request)
                }
            } else if let status = request.bookingStatus {
                if status == "confirmed" {
                    upcomingBookings.append(request)
                } else {
                    bookingRequests.append(request)
                }
            }
        }
        updatePlaceholderView()
        updateInformationCounters()
        tableView.reloadData()
    }
    
    private func updateInformationCounters() {}
    
    private func updatePlaceholderView() {
        placeholderStackView.isHidden = informationSelector.selectedSegmentIndex == 0 ? !upcomingBookings.isEmpty : !bookingRequests.isEmpty
        if !placeholderStackView.isHidden {
            placeholderLabel.text =  informationSelector.selectedSegmentIndex == 0 ? "You have no upcoming arrangements" : "You have no requests"
            placeholderButton.setTitle("SEND A CUSTOM REQUEST", for: .normal)
        }
    }
    
    @IBAction func infoSelectionChanged(_ sender: Any) {
        self.lineViewHorizontalConstraint.isActive = self.informationSelector.selectedSegmentIndex == 0
        forceReload = true
        tableView.reloadData()
        
        updatePlaceholderView()
        updateInformationCounters()
        
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false) { _ in
            self.tableView.reloadData()
        }
    }
    
    @IBAction func placeholderButton_onClick(_ sender: Any) {
        if LujoSetup().getLujoUser()?.membershipPlan != nil {
            guard let userFirstName = LujoSetup().getLujoUser()?.firstName else { return }
            let initialMessage = """
            Hi Concierge team,
            
            How can i book some thing like an event, experience, villa, yacht, private jet or a luxurious good, can you please assist me?
            
            \(userFirstName)
            """
            if ConversationsManager.sharedConversationsManager.getClient() != nil
            {
                let viewController = AdvanceChatViewController()
                viewController.product = Product(id: -1 , type: "My Bookings" , name: "Booking Inquiry")
                viewController.initialMessage = initialMessage
                self.navigationController?.pushViewController(viewController,animated: true)
            }else{
                let error = BackendError.parsing(reason: "Chat option is not available, please try again later")
                self.showError(error)
                print("Twilio: Not logged in")
            }
            
        } else {
            showInformationPopup()
        }
    }
    
    @IBAction func startSearching(_ sender: Any) {
        //navigate(to: "Aviation")
    }
    
    @objc func backButton_onClick(_ sender: UIBarButtonItem) {
        //navigate(to: "Aviation")
    }
    
    func showNetworkActivity() {
        if networkActivityCounter == 0 { naHUD.show(in: view) }
        networkActivityCounter += 1
    }
    
    func hideNetworkActivity() {
        if networkActivityCounter > 0 { networkActivityCounter -= 1 }
        if networkActivityCounter == 0 { naHUD.dismiss() }
    }
    
    func showError(_ error: Error) {
        showErrorPopup(withTitle: "Error", error: error)
    }
    
    private func pushPaymentInstructionsViewController(booking: Booking, showAdditionalInfo: Bool) {
        shouldLoadAgain = false
        let viewController = BookingsPaymentInstructionsViewController.instantiate(booking: booking, showAdditionalInfo: showAdditionalInfo)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    fileprivate func setupInfoKindView() {
        informationSelector.backgroundColor = .clear
        informationSelector.tintColor = .clear
        
        let informationSelectFont = UIFont.systemFont(ofSize: 13, weight: .regular)
        informationSelector.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white,
                                                    NSAttributedString.Key.font: informationSelectFont], for: .selected)
        informationSelector.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.inputFieldText,
                                                    NSAttributedString.Key.font: informationSelectFont], for: .normal)
    }
    
}

extension BookingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if forceReload {
            forceReload = false
            return 0
        }
        
        return informationSelector.selectedSegmentIndex == 0 ? upcomingBookings.count : bookingRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let info = informationSelector.selectedSegmentIndex == 0 ? upcomingBookings[indexPath.row] : bookingRequests[indexPath.row]
        
        if let bookingAviation = info.bookingAviation {
            let cell = tableView.dequeueReusableCell(withIdentifier: MyBookingsCell.cellID, for: indexPath) as! MyBookingsCell
            
            cell.bookingInfo = bookingAviation
            cell.delegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: BookingDetailCell.cellID, for: indexPath) as! BookingDetailCell
            
            cell.bookingInfo = info
            cell.delegate = self
            
            return cell
        }
        
    }
}

extension BookingsViewController: MyBookingCellDelegate {
    
    func `showPaymentInstructions`(cell: MyBookingsCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let booking = bookingRequests[indexPath.row]
            pushPaymentInstructionsViewController(booking: booking, showAdditionalInfo: false)
        }
    }

    func showAdditionalPaymentInstructions(cell: MyBookingsCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let booking = bookingRequests[indexPath.row]
            pushPaymentInstructionsViewController(booking: booking, showAdditionalInfo: true)
        }
    }
    
}

extension BookingsViewController: BookingDetailCellDelegate {
    func showPaymentInstructions(cell: BookingDetailCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let booking = bookingRequests[indexPath.row]
            
            if let qoute = booking.bookingQuote {
                let formatter = NumberFormatter()
                formatter.numberStyle = .currency
                formatter.locale = Locale(identifier: "en_US")
                formatter.usesSignificantDigits = true
                
                showPayAlertWith(title: "Booking request payment", body: "Your amount due for this booking is \(formatter.string(for: qoute)!)", buttonTitle: "PAY", cancelButtonTitle: "Cancel") {
                    self.selectedBooking = booking
                    let viewController = PurchaseViewController.instantiate(amount: qoute, screenType: .booking)
                    viewController.paymentDelegate = self
                    self.present(viewController, animated: true, completion: nil)
                }
            }
        }
    }
}

extension BookingsViewController {
    
    func getMyAllBookings() {
        showNetworkActivity()
        
        AviationAPIManagerNEW.shared.authorisationToken = LujoSetup().getCurrentUser()?.token
        AviationAPIManagerNEW.shared.getAllBookings { bookings, error in
            self.hideNetworkActivity()
            if let error = error {
                self.showError(error)
            } else {
                self.update(allBookings: bookings)
            }
        }
    }
    
    func getMyBookings() {
        showNetworkActivity()
        
        AviationAPIManagerNEW.shared.authorisationToken = LujoSetup().getCurrentUser()?.token
        AviationAPIManagerNEW.shared.getBookings(type: .active) { bookings, error in
            self.hideNetworkActivity()
            if let error = error {
                self.showError(error)
            } else {
                self.update(bookings: bookings)
            }
        }
    }
    
    func getMyTrips() {
        showNetworkActivity()
        
        AviationAPIManagerNEW.shared.authorisationToken = LujoSetup().getCurrentUser()?.token
        AviationAPIManagerNEW.shared.getBookings(type: .trip) { trips, error in
            self.hideNetworkActivity()
            if let error = error {
                self.showError(error)
            } else {
                self.update(trips: trips)
            }
        }
    }
}

extension BookingsViewController: PurchasePaymentDelegate {
    
    func paymentCompleted() {}
    
    func paymentFished(with result: PaymentResult, at session: PaymentSession?, completion: @escaping (Error?) -> Void) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty, let bookingId = selectedBooking?.bookingId else {
            return completion(LoginError.errorLogin(description: "User does not exist or is not verified or there is no valid bookiing selected"))
        }
        
        PaymentAPIManagerNEW.shared.confirmBookingPayment(bookingId: bookingId, transactionId: result.reference, amount: result.amount, token: token) { error in
            self.selectedBooking = nil
            completion(error)
        }
    }
}
