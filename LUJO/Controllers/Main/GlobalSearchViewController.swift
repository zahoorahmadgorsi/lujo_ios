//
//  GlobalSearchViewController.swift
//  LUJO
//
//  Created by Nemanja Djurisic on 10/15/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import FirebaseCrashlytics
import IQKeyboardManagerSwift
import JGProgressHUD
import Mixpanel

class GlobalSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    //MARK:- Init
    
    private let naHUD = JGProgressHUD(style: .dark)
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!

    // Properties
    @IBOutlet weak var propertyContainerView: UIView!
    
    @IBOutlet weak var property1ContainerView: UIView!
    @IBOutlet weak var property1ImageView: UIImageView!
    @IBOutlet weak var property1NameLabel: UILabel!
    @IBOutlet weak var property1DateLabel: UILabel!
    @IBOutlet weak var property1TagContainerView: UIView!
    @IBOutlet weak var property1TagLabel: UILabel!
    
    @IBOutlet weak var property2ContainerView: UIView!
    @IBOutlet weak var property2ImageView: UIImageView!
    @IBOutlet weak var property2NameLabel: UILabel!
    @IBOutlet weak var property2DateLabel: UILabel!
    @IBOutlet weak var property2TagContainerView: UIView!
    @IBOutlet weak var property2TagLabel: UILabel!
    
    @IBOutlet weak var propertyMoreContainerView: UIView!
    @IBOutlet weak var propertyMoreLabel: UILabel!
    
    // Event
    @IBOutlet weak var eventContainerView: UIView!
    
    @IBOutlet weak var event1ContainerView: UIView!
    @IBOutlet weak var event1ImageView: UIImageView!
    @IBOutlet weak var event1NameLabel: UILabel!
    @IBOutlet weak var event1DateLabel: UILabel!
    @IBOutlet weak var event1TagContainerView: UIView!
    @IBOutlet weak var event1TagLabel: UILabel!
    
    @IBOutlet weak var event2ContainerView: UIView!
    @IBOutlet weak var event2ImageView: UIImageView!
    @IBOutlet weak var event2NameLabel: UILabel!
    @IBOutlet weak var event2DateLabel: UILabel!
    @IBOutlet weak var event2TagContainerView: UIView!
    @IBOutlet weak var event2TagLabel: UILabel!
    
    @IBOutlet weak var eventMoreContainerView: UIView!
    @IBOutlet weak var eventMoreLabel: UILabel!
    
    // Yachts
    @IBOutlet weak var yachtContainerView: UIView!
    
    @IBOutlet weak var yacht1ContainerView: UIView!
    @IBOutlet weak var yacht1ImageView: UIImageView!
    @IBOutlet weak var yacht1NameLabel: UILabel!
    @IBOutlet weak var yacht1DateLabel: UILabel!
    @IBOutlet weak var yacht1TagContainerView: UIView!
    @IBOutlet weak var yacht1TagLabel: UILabel!
    
    @IBOutlet weak var yacht2ContainerView: UIView!
    @IBOutlet weak var yacht2ImageView: UIImageView!
    @IBOutlet weak var yacht2NameLabel: UILabel!
    @IBOutlet weak var yacht2DateLabel: UILabel!
    @IBOutlet weak var yacht2TagContainerView: UIView!
    @IBOutlet weak var yacht2TagLabel: UILabel!
    
    @IBOutlet weak var yachtMoreContainerView: UIView!
    @IBOutlet weak var yachtMoreLabel: UILabel!
    
    // Restaurant
    @IBOutlet weak var restaurantContainerView: UIView!
    
    @IBOutlet weak var restaurant1ContainerView: UIView!
    @IBOutlet weak var restaurant1ImageView: UIImageView!
    @IBOutlet weak var restaurant1NameLabel: UILabel!
    @IBOutlet weak var restaurant1locationLabel: UILabel!
    @IBOutlet weak var restaurant1locationContainerView: UIView!
//    @IBOutlet weak var restaurant1starCountLabel: UILabel!
//    @IBOutlet weak var restaurant1starImageContainerView: UIView!
    
    @IBOutlet weak var restaurant2ContainerView: UIView!
    @IBOutlet weak var restaurant2ImageView: UIImageView!
    @IBOutlet weak var restaurant2NameLabel: UILabel!
    @IBOutlet weak var restaurant2locationLabel: UILabel!
    @IBOutlet weak var restaurant2locationContainerView: UIView!
//    @IBOutlet weak var restaurant2starCountLabel: UILabel!
//    @IBOutlet weak var restaurant2starImageContainerView: UIView!
    
    @IBOutlet weak var restaurantMoreContainerView: UIView!
    @IBOutlet weak var restaurantMoreLabel: UILabel!
    
    // Experience
    @IBOutlet weak var experienceContainerView: UIView!
    
    @IBOutlet weak var experience1ContainerView: UIView!
    @IBOutlet weak var experience1ImageView: UIImageView!
    @IBOutlet weak var experience1NameLabel: UILabel!
    @IBOutlet weak var experience1TagContainerView: UIView!
    @IBOutlet weak var experience1TagLabel: UILabel!
    
    @IBOutlet weak var experience2ContainerView: UIView!
    @IBOutlet weak var experience2ImageView: UIImageView!
    @IBOutlet weak var experience2NameLabel: UILabel!
    @IBOutlet weak var experience2TagContainerView: UIView!
    @IBOutlet weak var experience2TagLabel: UILabel!
    
    @IBOutlet weak var experienceMoreContainerView: UIView!
    @IBOutlet weak var experienceMoreLabel: UILabel!
    
    /// Class storyboard identifier.
    class var identifier: String { return "GlobalSearchViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate() -> GlobalSearchViewController {
        return UIStoryboard.main.instantiate(identifier)
    }
    
    //MARK:- Globals
    
    private var dataSource: [City] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    private var cityInformation: CityInfo?
    
    private var previousRun = Date()
    private let minInterval = 0.05
    
    //MARK:- Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Search all content"
        searchTextField.becomeFirstResponder()
        scrollView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        IQKeyboardManager.shared.enable = false
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func updateUI(informations: CityInfo) {
        cityInformation = informations
        scrollView.isHidden = false
        searchTextField.isEnabled = false
        
        propertyContainerView.isHidden = informations.property.items.isEmpty
        eventContainerView.isHidden = informations.event.items.isEmpty
        yachtContainerView.isHidden = informations.yacht.items.isEmpty
        restaurantContainerView.isHidden = informations.restaurant.items.isEmpty
        experienceContainerView.isHidden = informations.experience.items.isEmpty
        
        //properties
        propertyMoreContainerView.isHidden = informations.property.num < 3
        propertyMoreLabel.text = "+ \(informations.property.num - 2) more"
        property2ContainerView.alpha = informations.property.items.count < 2 ? 0 : 1
        
        for (index,property) in informations.property.items.enumerated() {
            
//            let startDateText = ProductDetailsViewController.convertDateFormate(date: property.startDate!)
//            var startTimeText = ProductDetailsViewController.timeFormatter.string(from: property.startDate!)
//
//            var endDateText = ""
//            if let propertyEndDate = property.endDate {
//                endDateText = ProductDetailsViewController.convertDateFormate(date: propertyEndDate)
//            }
//
//            if let timezone = property.timezone {
//                startTimeText = "\(startTimeText) (\(timezone))"
//            }
            
            if index == 0 {
                property1NameLabel.text = property.name
                
//                property1DateLabel.text = endDateText != "" ? "\(startDateText) - \(endDateText)" : "\(startDateText) \(startTimeText)"
                
                if let city = property.locations?.city {
//                    restaurant1locationContainerView.isHidden = false
                    property1DateLabel.text = city.name.uppercased()
                }
//                else {
//                    restaurant1locationContainerView.isHidden = true
//                }
                
                if property.tags?.count ?? 0 > 0, let fistTag = property.tags?[0] {
                    property1ContainerView.isHidden = false
                    property1TagLabel.text = fistTag.name.uppercased()
                } else {
                    property1TagContainerView.isHidden = true
                }
                
                if let mediaLink = property.thumbnail?.mediaUrl, property.thumbnail?.mediaType == "image" {
                    property1ImageView.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
                }
            } else if index == 1 {
                property2NameLabel.text = property.name
                
//                property2DateLabel.text = endDateText != "" ? "\(startDateText) - \(endDateText)" : "\(startDateText) \(startTimeText)"
//
                if let city = property.locations?.city {
//                    restaurant1locationContainerView.isHidden = false
                    property2DateLabel.text = city.name.uppercased()
                }
//                else {
//                    restaurant1locationContainerView.isHidden = true
//                }
                
                if property.tags?.count ?? 0 > 0, let fistTag = property.tags?[0] {
                    property2ContainerView.isHidden = false
                    property2TagLabel.text = fistTag.name.uppercased()
                } else {
                    property2TagContainerView.isHidden = true
                }
                
                if let mediaLink = property.thumbnail?.mediaUrl, property.thumbnail?.mediaType == "image" {
                    property2ImageView.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
                }
            }
        }
        
        //events
        eventMoreContainerView.isHidden = informations.event.num < 3
        eventMoreLabel.text = "+ \(informations.event.num - 2) more"
        event2ContainerView.alpha = informations.event.items.count < 2 ? 0 : 1
        
        for (index,event) in informations.event.items.enumerated() {
            
            let startDateText = ProductDetailsViewController.convertDateFormate(date: event.startDate!)
            var startTimeText = ProductDetailsViewController.timeFormatter.string(from: event.startDate!)
            
            var endDateText = ""
            if let eventEndDate = event.endDate {
                endDateText = ProductDetailsViewController.convertDateFormate(date: eventEndDate)
            }
            
            if let timezone = event.timezone {
                startTimeText = "\(startTimeText) (\(timezone))"
            }
            
            if index == 0 {
                event1NameLabel.text = event.name
                event1DateLabel.text = endDateText != "" ? "\(startDateText) - \(endDateText)" : "\(startDateText) \(startTimeText)"
                
                if event.tags?.count ?? 0 > 0, let fistTag = event.tags?[0] {
                    event1ContainerView.isHidden = false
                    event1TagLabel.text = fistTag.name.uppercased()
                } else {
                    event1TagContainerView.isHidden = true
                }
                
                if let mediaLink = event.thumbnail?.mediaUrl, event.thumbnail?.mediaType == "image" {
                    event1ImageView.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
                }
            } else if index == 1 {
                event2NameLabel.text = event.name
                event2DateLabel.text = endDateText != "" ? "\(startDateText) - \(endDateText)" : "\(startDateText) \(startTimeText)"
                
                if event.tags?.count ?? 0 > 0, let fistTag = event.tags?[0] {
                    event2ContainerView.isHidden = false
                    event2TagLabel.text = fistTag.name.uppercased()
                } else {
                    event2TagContainerView.isHidden = true
                }
                
                if let mediaLink = event.thumbnail?.mediaUrl, event.thumbnail?.mediaType == "image" {
                    event2ImageView.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
                }
            }
        }
        
        //yachts
        yachtMoreContainerView.isHidden = informations.yacht.num < 3
        yachtMoreLabel.text = "+ \(informations.yacht.num - 2) more"
        yacht2ContainerView.alpha = informations.yacht.items.count < 2 ? 0 : 1
        
        for (index,yacht) in informations.yacht.items.enumerated() {
            
//            let startDateText = ProductDetailsViewController.convertDateFormate(date: yacht.startDate!)
//            var startTimeText = ProductDetailsViewController.timeFormatter.string(from: yacht.startDate!)
            
//            var endDateText = ""
//            if let yachtEndDate = yacht.endDate {
//                endDateText = ProductDetailsViewController.convertDateFormate(date: yachtEndDate)
//            }
            
//            if let timezone = yacht.timezone {
//                startTimeText = "\(startTimeText) (\(timezone))"
//            }
            
            if index == 0 {
                yacht1NameLabel.text = yacht.name
                
//                yacht1DateLabel.text = endDateText != "" ? "\(startDateText) - \(endDateText)" : "\(startDateText) \(startTimeText)"
                
                if let city = yacht.locations?.city {
//                    restaurant1locationContainerView.isHidden = false
                    yacht1DateLabel.text = city.name.uppercased()
                }
//                else {
//                    restaurant1locationContainerView.isHidden = true
//                }
                
                if yacht.tags?.count ?? 0 > 0, let fistTag = yacht.tags?[0] {
                    yacht1ContainerView.isHidden = false
                    yacht1TagLabel.text = fistTag.name.uppercased()
                } else {
                    yacht1TagContainerView.isHidden = true
                }
                
                if let mediaLink = yacht.thumbnail?.mediaUrl, yacht.thumbnail?.mediaType == "image" {
                    yacht1ImageView.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
                }
            } else if index == 1 {
                yacht2NameLabel.text = yacht.name
//                yacht2DateLabel.text = endDateText != "" ? "\(startDateText) - \(endDateText)" : "\(startDateText) \(startTimeText)"
                
                if let city = yacht.locations?.city {
//                    restaurant1locationContainerView.isHidden = false
                    yacht1DateLabel.text = city.name.uppercased()
                }
//                else {
//                    restaurant1locationContainerView.isHidden = true
//                }
                
                if yacht.tags?.count ?? 0 > 0, let fistTag = yacht.tags?[0] {
                    yacht2ContainerView.isHidden = false
                    yacht2TagLabel.text = fistTag.name.uppercased()
                } else {
                    yacht2TagContainerView.isHidden = true
                }
                
                if let mediaLink = yacht.thumbnail?.mediaUrl, yacht.thumbnail?.mediaType == "image" {
                    yacht2ImageView.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
                }
            }
        }
        
        // restaurant
        restaurantMoreContainerView.isHidden = informations.restaurant.num < 3
        restaurantMoreLabel.text = "+ \(informations.restaurant.num - 2) more"
        restaurant2ContainerView.alpha = informations.restaurant.items.count < 2 ? 0 : 1
        
        for (index,restaurant) in informations.restaurant.items.enumerated() {
            
            if index == 0 {
                restaurant1NameLabel.text = restaurant.name
                
                if let mediaLink = restaurant.thumbnail?.mediaUrl, restaurant.thumbnail?.mediaType == "image" {
                    restaurant1ImageView.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
                }
                
                if let city = restaurant.locations?.city {
                    restaurant1locationContainerView.isHidden = false
                    restaurant1locationLabel.text = city.name.uppercased()
                } else {
                    restaurant1locationContainerView.isHidden = true
                }
                
//                if let star = restaurant.michelinStar?.first {
//                    restaurant1starImageContainerView.isHidden = false
//                    restaurant1starCountLabel.text = star.name.uppercased()
//                } else {
//                    restaurant1starImageContainerView.isHidden = true
//                }
                
            } else if index == 1 {
                restaurant2NameLabel.text = restaurant.name
                
                if let mediaLink = restaurant.thumbnail?.mediaUrl, restaurant.thumbnail?.mediaType == "image" {
                    restaurant2ImageView.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
                }
                
                if let city = restaurant.locations?.city {
                    restaurant2locationContainerView.isHidden = false
                    restaurant2locationLabel.text = city.name.uppercased()
                } else {
                    restaurant2locationContainerView.isHidden = true
                }
                
//                if let star = restaurant.michelinStar?.first {
//                    restaurant2starImageContainerView.isHidden = false
//                    restaurant2starCountLabel.text = star.name.uppercased()
//                } else {
//                    restaurant2starImageContainerView.isHidden = true
//                }
            }
        }
        
        // experience
        experienceMoreContainerView.isHidden = informations.experience.num < 3
        experienceMoreLabel.text = "+ \(informations.experience.num - 2) more"
        experience2ContainerView.alpha = informations.experience.items.count < 2 ? 0 : 1
        
        for (index,experience) in informations.experience.items.enumerated() {
            
            if index == 0 {
                experience1NameLabel.text = experience.name
                
                if experience.tags?.count ?? 0 > 0, let fistTag = experience.tags?[0] {
                    experience1TagContainerView.isHidden = false
                    experience1TagLabel.text = fistTag.name.uppercased()
                } else {
                    experience1TagContainerView.isHidden = true
                }
                
                if let mediaLink = experience.thumbnail?.mediaUrl, experience.thumbnail?.mediaType == "image" {
                    experience1ImageView.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
                }
            } else if index == 1 {
                experience2NameLabel.text = experience.name
                
                if experience.tags?.count ?? 0 > 0, let fistTag = experience.tags?[0] {
                    experience2TagContainerView.isHidden = false
                    experience2TagLabel.text = fistTag.name.uppercased()
                } else {
                    experience2TagContainerView.isHidden = true
                }
                
                if let mediaLink = experience.thumbnail?.mediaUrl, experience.thumbnail?.mediaType == "image" {
                    experience2ImageView.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
                }
            }
        }
    }
    
    //MARK:- User interaction
    
    @IBAction func clearButton_onClick(_ sender: Any) {
        scrollView.isHidden = true
        cityInformation = nil
        searchTextField.isEnabled = true
        searchTextField.text = ""
        searchTextField.becomeFirstResponder()
        dataSource = []
    }

    @IBAction func villaButton_onClick(_ sender: UIButton) {
        if let item = cityInformation?.property.items[sender.tag] {
            let viewController = ProductDetailsViewController.instantiate(product: item)
            viewController.modalPresentationStyle = .overFullScreen
            present(viewController, animated: true)
        }
    }
    
    @IBAction func seeAllVillaButton_onClick(_ sender: Any) {
        if let termId = cityInformation?.property.items.first?.locations?.city?.termId {
            self.navigationController?.pushViewController(ProductsViewController.instantiate(category: .villa, dataSource: [], city: Cities(termId: termId, name: cityInformation?.property.items.first?.locations?.city?.name ?? "", itemsNum: cityInformation?.property.num ?? 0, items: [])), animated: true)
        }
    }
    
    @IBAction func eventButton_onClick(_ sender: UIButton) {
        if let event = cityInformation?.event.items[sender.tag] {
            let viewController = ProductDetailsViewController.instantiate(product: event)
            viewController.modalPresentationStyle = .overFullScreen
            present(viewController, animated: true)
        }
    }
    
    @IBAction func seeAllEventsButton_onClick(_ sender: Any) {
        if let termId = cityInformation?.event.items.first?.locations?.city?.termId {
            self.navigationController?.pushViewController(ProductsViewController.instantiate(category: .event, dataSource: [], city: Cities(termId: termId, name: cityInformation?.event.items.first?.locations?.city?.name ?? "", itemsNum: cityInformation?.event.num ?? 0, items: [])), animated: true)
        }
    }
    
    @IBAction func yachtButton_onClick(_ sender: UIButton) {
        if let item = cityInformation?.yacht.items[sender.tag] {
            let viewController = ProductDetailsViewController.instantiate(product: item)
            viewController.modalPresentationStyle = .overFullScreen
            present(viewController, animated: true)
        }
    }
    
    @IBAction func seeAllYachtButton_onClick(_ sender: Any) {
        if let termId = cityInformation?.yacht.items.first?.locations?.city?.termId {
            self.navigationController?.pushViewController(ProductsViewController.instantiate(category: .yacht, dataSource: [], city: Cities(termId: termId, name: cityInformation?.yacht.items.first?.locations?.city?.name ?? "", itemsNum: cityInformation?.yacht.num ?? 0, items: [])), animated: true)
        }
    }
    
    @IBAction func restaurantButton_onClick(_ sender: UIButton) {
        if let restaurant = cityInformation?.restaurant.items[sender.tag] {
            let viewController = ProductDetailsViewController.instantiate(product: restaurant)
            viewController.modalPresentationStyle = .overFullScreen
            present(viewController, animated: true)
        }
    }
    
    @IBAction func seeAllRestaurantsButton_onClick(_ sender: Any) {
        if let termId = cityInformation?.restaurant.items.first?.locations?.city?.termId {
            self.navigationController?.pushViewController(RestaurantListViewController.instantiate(dataSource: [], city: Cities(termId: termId, name: cityInformation?.restaurant.items.first?.locations?.city?.name ?? "", itemsNum: cityInformation?.restaurant.num ?? 0, items: [])), animated: true)
        }
    }
    
    @IBAction func experianceButton_onClick(_ sender: UIButton) {
        if let experience = cityInformation?.experience.items[sender.tag] {
            let viewController = ProductDetailsViewController.instantiate(product: experience)
            viewController.modalPresentationStyle = .overFullScreen
            present(viewController, animated: true)
        }
    }
    
    @IBAction func seeAllExperiancesButton_onClick(_ sender: Any) {
        if let termId = cityInformation?.experience.items.first?.locations?.city?.termId {
            self.navigationController?.pushViewController(ProductsViewController.instantiate(category: .experience, dataSource: [], city: Cities(termId: termId, name: cityInformation?.experience.items.first?.locations?.city?.name ?? "", itemsNum: cityInformation?.experience.num ?? 0, items: [])), animated: true)
        }
    }
    
    //MARK:- TableView delegate methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CityCell.identifier, for: indexPath) as! CityCell
        cell.cityNameLabel.text = dataSource[indexPath.row].cityName
        let colorView = UIView()
        colorView.backgroundColor = UIColor.clear
        UITableViewCell.appearance().selectedBackgroundView = colorView
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(dataSource[indexPath.row].cityName)
        let city = dataSource[indexPath.row]
        searchTextField.text = city.cityName
        searchTextField.resignFirstResponder()
        fetchDataForCity(city)
    }
    
    //MARK:- TextField delegate methods
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // get the current text, or use an empty string if that failed
        let currentText = textField.text ?? ""
        
        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        // add their new text to the existing text
        let textToSearch = currentText.replacingCharacters(in: stringRange, with: string)
        
        guard !textToSearch.isEmpty else {
            dataSource = []
            return true
        }
        
        if Date().timeIntervalSince(previousRun) > minInterval, textToSearch.count > 2 {
            previousRun = Date()
            fetchResults(for: textToSearch)
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK:- Util methods
    
    func showFeedback(_ message: String) {
        showInformationPopup(withTitle: "Information", message: message)
    }
    
    func showNetworkActivity() {
        naHUD.show(in: view)
    }
    
    func hideNetworkActivity() {
        // Safe guard that will call dismiss only if HUD is shown on screen.
        if naHUD.isVisible {
            naHUD.dismiss()
        }
    }
    
    //MARK:- API methods
    
    func fetchResults(for text: String) {
//        print("Text Searched: \(text)")
        
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            showFeedback("User does not exist or is not verified")
            return
        }
        
        Mixpanel.mainInstance().track(event: "GlobalSearch",
              properties: ["SearchedText" : text])
        
        EEAPIManager().search(token: token, searchText: text) { (cities, error) in
            if let error = error {
                Crashlytics.crashlytics().record(error: error)
                self.showFeedback(error.localizedDescription)
            } else {
                self.dataSource = cities
            }
        }
    }
    
    func fetchDataForCity(_ city: City) {
//        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
//            showFeedback("User does not exist or is not verified")
//            return
//        }
        
        showNetworkActivity()
        
        EEAPIManager().getInfoForCity( cityId: city.placeId) { (informations, error) in
            self.hideNetworkActivity()
            
            if let error = error {
                Crashlytics.crashlytics().record(error: error)
                self.showFeedback(error.localizedDescription)
            } else if let informations = informations {
                self.updateUI(informations: informations)
            } else {
                self.showFeedback("There is no content for this city.")
            }
        }
    }
}

class CityCell: UITableViewCell {
    static let identifier = "CityCell"
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var lineView: UIView!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        lineView.backgroundColor = UIColor.rgMid
    }
}
