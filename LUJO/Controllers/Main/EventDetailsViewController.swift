//
//  EventDetailsViewController.swift
//  LUJO
//
//  Created by Iker Kristian on 8/28/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit

class EventDetailsViewController: UIViewController {
    
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "EventDetailsViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate(event: EventsExperiences) -> EventDetailsViewController {
        let viewController = UIStoryboard.main.instantiate(identifier) as! EventDetailsViewController
        viewController.event = event
        return viewController
    }
    
    //MARK:- Globals
    
    private(set) var event: EventsExperiences!
    
    @IBOutlet var mainImageView: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var dateLocationContainerView: UIView!
    @IBOutlet var dateContainerView: UIView!
    @IBOutlet var locationContainerView: UIView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var descriptionTextView: UITextView!
    
    @IBOutlet var requestButton: ActionButton!
    @IBOutlet var chatButton: UIButton!
    
    @IBOutlet weak var bottomLineViewHeight: NSLayoutConstraint!
    
    var isEventPast: Bool = false
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "us_US")
        formatter.dateFormat = "MMM"
        return formatter
    }()
    
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "GMT")
        formatter.dateFormat = "HH:mm'h'"
        return formatter
    }()
    
    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch event.type {
            case "event":         fallthrough
            case "special-event": setupEvents(event)
            case "experience":    setupExperience(event)
            default: break
        }
        bottomLineViewHeight.constant = UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20 ? 34 : 0
        //zahoor
        setRecentlyViewed()
            
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activateKeyboardManager()
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func requestBooking(_ sender: Any) {
        sendInitialInformation()
    }
    
    @IBAction func viewGalleryButton_onClick(_ sender: UIButton) {
        presentGalleryViewControllerIfNeeded()
    }
    
    private func presentGalleryViewControllerIfNeeded() {
        let dataSource = event.getAllImagesURL()
        if dataSource.isEmpty {
            showInformationPopup(withTitle: "Info", message: "There are no images in the gallery, sorry!")
        } else {
            let viewController = GalleryViewControllerNEW.instantiate(dataSource: dataSource)
            self.present(viewController, animated: true, completion: nil)
        }
    }
}

extension EventDetailsViewController {
    
    fileprivate func setupEvents(_ event: EventsExperiences) {
        // imagesList.imageURLList = event.allImages ?? []
        if let firstImageLink = event.getAllImagesURL().first {
            mainImageView.downloadImageFrom(link: firstImageLink, contentMode: .scaleAspectFill)
        }
        name.text = event.name
        
        var locationText = ""
        if let cityName = event.location.first?.city?.name {
            locationText = "\(cityName), "
        }
        locationText += event.location.first?.country.name ?? ""
        locationLabel.text = locationText.uppercased()
        locationContainerView.isHidden = locationText.isEmpty
        
        var startDateText = ""
        var startTimeText = ""
        
        if let startDate = event.startDate {
            startDateText = EventDetailsViewController.convertDateFormate(date: startDate)
            startTimeText = EventDetailsViewController.timeFormatter.string(from: startDate)
        }
        
        var endDateText = ""
        if let eventEndDate = event.endDate {
            endDateText = EventDetailsViewController.convertDateFormate(date: eventEndDate)
        }
        
        if let timezone = event.timezone {
            startTimeText = "\(startTimeText) (\(timezone))"
        }
        
        if event.startDate != nil {
            dateLabel.text = endDateText != "" ? "\(startDateText) - \(endDateText)" : "\(startDateText) \(startTimeText)"
        }
        
        dateContainerView.isHidden = event.startDate == nil
        dateLocationContainerView.isHidden = event.startDate == nil && locationText.isEmpty
        descriptionTextView.attributedText = convertToAttributedString(event.description)
        
        chatButton.isEnabled = !isEventPast
        requestButton.isEnabled = !isEventPast
        if event.type == "special-event" {
            requestButton.setTitle("R E Q U E S T", for: .normal)
        }
        
        if isEventPast {
            requestButton.setDisabled()
        }
    }
    
    fileprivate func setupExperience(_ experience: EventsExperiences) {
        if let firstImageLink = experience.getAllImagesURL().first {
            mainImageView.downloadImageFrom(link: firstImageLink, contentMode: .scaleAspectFill)
        }
        name.text = experience.name
        
        var locationText = ""
        if let cityName = experience.location.first?.city?.name {
            locationText = "\(cityName), "
        }
        locationText += experience.location.first?.country.name ?? ""
        locationLabel.text = locationText.uppercased()
        
        dateContainerView.isHidden = true
        
        descriptionTextView.attributedText = convertToAttributedString(experience.description)
        requestButton.setTitle("R E Q U E S T", for: .normal)
    }
    
    static func convertDateFormate(date: Date) -> String {
        let calendar = Calendar.current
        let anchorComponents = calendar.dateComponents([.day, .month, .year], from: date)
        
        let newDate = EventDetailsViewController.dateFormatter.string(from: date)
        let dateDay = EventDetailsViewController.numberFormatter.string(from: NSNumber(value: anchorComponents.day!))
        
        return dateDay! + " " + newDate
    }
    
    private func convertToAttributedString(_ text: String) -> NSAttributedString {
        let range = NSRange(location: 0, length: text.count)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        let aString = NSMutableAttributedString(string: text)
        aString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 15, weight: .light), range: range)
        aString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: range)
        aString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: range)
        return aString
    }
}

// Chat functionality
extension EventDetailsViewController {
    
    fileprivate func sendInitialInformation() {
        guard let userFirstName = LujoSetup().getLujoUser()?.firstName else { return }
        
        EEAPIManager().sendRequestForSalesForce(itemId: event.id)
        
        let initialMessage = """
        Hi Concierge team,
        
        I am interested in \(event.name), can you assist me?
        
        \(userFirstName)
        """
        
        startChatWithInitialMessage(initialMessage)
    }
    
    //Zahoor Started
    fileprivate func setRecentlyViewed() {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            self.showError(LoginError.errorLogin(description: "User does not exist or is not verified"))
            return
        }
//        print(event.id)
        RecentlyViewedAPIManager().setRecenltyViewed(token: token, id: event.id){response, error in
            if let error = error{
                print(error.localizedDescription );
            }else{
                print(response ?? "Error setting recent value");
            }
        }
    }
    
    func showError(_ error: Error) {
        showErrorPopup(withTitle: "Recently Viewed Error", error: error)
    }
    //Zahoor finished
}
