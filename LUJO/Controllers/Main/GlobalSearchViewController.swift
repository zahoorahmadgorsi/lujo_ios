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
    
    @IBOutlet weak var property1viewMeasurements: UIView!
    @IBOutlet weak var property1viewLength: UIView!
    @IBOutlet weak var property1lblLength: UILabel!
    @IBOutlet weak var property1viewNumberOfGuests: UIView!
    @IBOutlet weak var property1lblNumberOfGuests: UILabel!
    @IBOutlet weak var property1viewCabins: UIView!
    @IBOutlet weak var property1lblCabins: UILabel!
    @IBOutlet weak var property1viewWashrooms: UIView!
    @IBOutlet weak var property1lblWashrooms: UILabel!
    @IBOutlet weak var property1viewEmpty: UIView!
    
    @IBOutlet weak var property2ContainerView: UIView!
    @IBOutlet weak var property2ImageView: UIImageView!
    @IBOutlet weak var property2NameLabel: UILabel!
    @IBOutlet weak var property2DateLabel: UILabel!
    @IBOutlet weak var property2TagContainerView: UIView!
    @IBOutlet weak var property2TagLabel: UILabel!
    
    @IBOutlet weak var property2viewMeasurements: UIView!
    @IBOutlet weak var property2viewLength: UIView!
    @IBOutlet weak var property2lblLength: UILabel!
    @IBOutlet weak var property2viewNumberOfGuests: UIView!
    @IBOutlet weak var property2lblNumberOfGuests: UILabel!
    @IBOutlet weak var property2viewCabins: UIView!
    @IBOutlet weak var property2lblCabins: UILabel!
    @IBOutlet weak var property2viewWashrooms: UIView!
    @IBOutlet weak var property2lblWashrooms: UILabel!
    @IBOutlet weak var property2viewEmpty: UIView!
    
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
    
    @IBOutlet weak var yacht1viewMeasurements: UIView!
    @IBOutlet weak var yacht1viewLength: UIView!
    @IBOutlet weak var yacht1lblLength: UILabel!
    @IBOutlet weak var yacht1viewNumberOfGuests: UIView!
    @IBOutlet weak var yacht1lblNumberOfGuests: UILabel!
    @IBOutlet weak var yacht1viewCabins: UIView!
    @IBOutlet weak var yacht1lblCabins: UILabel!
    @IBOutlet weak var yacht1viewWashrooms: UIView!
    @IBOutlet weak var yacht1lblWashrooms: UILabel!
    @IBOutlet weak var yacht1viewEmpty: UIView!
    
    @IBOutlet weak var yacht2ContainerView: UIView!
    @IBOutlet weak var yacht2ImageView: UIImageView!
    @IBOutlet weak var yacht2NameLabel: UILabel!
    @IBOutlet weak var yacht2DateLabel: UILabel!
    @IBOutlet weak var yacht2TagContainerView: UIView!
    @IBOutlet weak var yacht2TagLabel: UILabel!
    
    @IBOutlet weak var yacht2viewMeasurements: UIView!
    @IBOutlet weak var yacht2viewLength: UIView!
    @IBOutlet weak var yacht2lblLength: UILabel!
    @IBOutlet weak var yacht2viewNumberOfGuests: UIView!
    @IBOutlet weak var yacht2lblNumberOfGuests: UILabel!
    @IBOutlet weak var yacht2viewCabins: UIView!
    @IBOutlet weak var yacht2lblCabins: UILabel!
    @IBOutlet weak var yacht2viewWashrooms: UIView!
    @IBOutlet weak var yacht2lblWashrooms: UILabel!
    @IBOutlet weak var yacht2viewEmpty: UIView!
    
    @IBOutlet weak var yachtMoreContainerView: UIView!
    @IBOutlet weak var yachtMoreLabel: UILabel!
    
    // Restaurant
    @IBOutlet weak var restaurantContainerView: UIView!
    
    @IBOutlet weak var restaurant1ContainerView: UIView!
    @IBOutlet weak var restaurant1ImageView: UIImageView!
    @IBOutlet weak var restaurant1NameLabel: UILabel!
    @IBOutlet weak var restaurant1locationLabel: UILabel!
    @IBOutlet weak var restaurant1locationContainerView: UIView!
    
    @IBOutlet weak var restaurant2ContainerView: UIView!
    @IBOutlet weak var restaurant2ImageView: UIImageView!
    @IBOutlet weak var restaurant2NameLabel: UILabel!
    @IBOutlet weak var restaurant2locationLabel: UILabel!
    @IBOutlet weak var restaurant2locationContainerView: UIView!
    
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
    
//    private var dataSource: [City] = [] {
//        didSet {
//            tableView.reloadData()
//        }
//    }
    private var dataSource: [Taxonomy] = [] {
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
        propertyMoreContainerView.isHidden = informations.property.totalCount ?? 0 < 3
        propertyMoreLabel.text = "+ \(informations.property.totalCount ?? 0 - 2) more"
        property2ContainerView.alpha = informations.property.items.count < 2 ? 0 : 1
        
        for (index,property) in informations.property.items.enumerated() {
            if index == 0 {
                property1NameLabel.text = property.name
                if let city = property.locations?.city {
                    property1DateLabel.text = city.name.uppercased()
                }

                if property.tags?.count ?? 0 > 0, let fistTag = property.tags?[0] {
                    property1ContainerView.isHidden = false
                    property1TagLabel.text = fistTag.name.uppercased()
                } else {
                    property1TagContainerView.isHidden = true
                }
                
                if let mediaLink = property.thumbnail?.mediaUrl, property.thumbnail?.mediaType == "image" {
                    property1ImageView.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
                }
                
                //Updateing the measurements
                property1viewLength.isHidden = true     //villa dont have length
                if let val = property.numberOfGuests, val > 0{
                    property1viewNumberOfGuests.isHidden = false
                    property1lblNumberOfGuests.text = String(val)
                }else{
                    property1viewNumberOfGuests.isHidden = true
                }
                if let val = property.numberOfBedrooms, val > 0{
                    property1viewCabins.isHidden = false
                    property1lblCabins.text = String(val)
                }else{
                    property1viewCabins.isHidden = true
                }
                if let val = property.numberOfBathrooms, val > 0{
                    property1viewWashrooms.isHidden = false
                    property1lblWashrooms.text = String(val)
                }else{
                    property1viewWashrooms.isHidden = true
                }
            } else if index == 1 {
                property2NameLabel.text = property.name
                if let city = property.locations?.city {
                    property2DateLabel.text = city.name.uppercased()
                }

                if property.tags?.count ?? 0 > 0, let fistTag = property.tags?[0] {
                    property2ContainerView.isHidden = false
                    property2TagLabel.text = fistTag.name.uppercased()
                } else {
                    property2TagContainerView.isHidden = true
                }
                
                if let mediaLink = property.thumbnail?.mediaUrl, property.thumbnail?.mediaType == "image" {
                    property2ImageView.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
                }
                
                //Updateing the measurements
                property2viewLength.isHidden = true     //villa dont have length
                if let val = property.numberOfGuests, val > 0{
                    property2viewNumberOfGuests.isHidden = false
                    property2lblNumberOfGuests.text = String(val)
                }else{
                    property2viewNumberOfGuests.isHidden = true
                }
                if let val = property.numberOfBedrooms, val > 0{
                    property2viewCabins.isHidden = false
                    property2lblCabins.text = String(val)
                }else{
                    property2viewCabins.isHidden = true
                }
                if let val = property.numberOfBathrooms, val > 0{
                    property2viewWashrooms.isHidden = false
                    property2lblWashrooms.text = String(val)
                }else{
                    property2viewWashrooms.isHidden = true
                }
            }
        }
        
        //events
        eventMoreContainerView.isHidden = informations.event.totalCount ?? 0 < 3
        eventMoreLabel.text = "+ \((informations.event.totalCount ?? 0) - 2) more"
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
        yachtMoreContainerView.isHidden = informations.yacht.totalCount ?? 0 < 3
        yachtMoreLabel.text = "+ \((informations.yacht.totalCount ?? 0) - 2) more"
        yacht2ContainerView.alpha = informations.yacht.items.count < 2 ? 0 : 1
        
        for (index,yacht) in informations.yacht.items.enumerated() {
            if index == 0 {
                yacht1NameLabel.text = yacht.name

                if let city = yacht.locations?.city {
                    yacht1DateLabel.text = city.name.uppercased()
                }
                if yacht.tags?.count ?? 0 > 0, let fistTag = yacht.tags?[0] {
                    yacht1ContainerView.isHidden = false
                    yacht1TagLabel.text = fistTag.name.uppercased()
                } else {
                    yacht1TagContainerView.isHidden = true
                }
                
                if let mediaLink = yacht.thumbnail?.mediaUrl, yacht.thumbnail?.mediaType == "image" {
                    yacht1ImageView.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
                }
                //updating yacht's measurements
                yacht1viewWashrooms.isHidden = true      //yacht dont have washroom
                if let val = yacht.lengthM, val.count > 0{
                    yacht1viewLength.isHidden = false
                    yacht1lblLength.text = val
                }else{
                    yacht1viewLength.isHidden = true
                }
                if let val = yacht.guestsNumber, val.count > 0{
                    yacht1viewNumberOfGuests.isHidden = false
                    yacht1lblNumberOfGuests.text = val
                }else{
                    yacht1viewNumberOfGuests.isHidden = true
                }
                if let val = yacht.cabinNumber, val.count > 0{
                    yacht1viewCabins.isHidden = false
                    yacht1lblCabins.text = val
                }else{
                    yacht1viewCabins.isHidden = true
                }
            } else if index == 1 {
                yacht2NameLabel.text = yacht.name
                
                if let city = yacht.locations?.city {
                    yacht1DateLabel.text = city.name.uppercased()
                }

                if yacht.tags?.count ?? 0 > 0, let fistTag = yacht.tags?[0] {
                    yacht2ContainerView.isHidden = false
                    yacht2TagLabel.text = fistTag.name.uppercased()
                } else {
                    yacht2TagContainerView.isHidden = true
                }
                
                if let mediaLink = yacht.thumbnail?.mediaUrl, yacht.thumbnail?.mediaType == "image" {
                    yacht2ImageView.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
                }
                //updating yacht's measurements
                yacht2viewWashrooms.isHidden = true      //yacht dont have washroom
                if let val = yacht.lengthM, val.count > 0{
                    yacht2viewLength.isHidden = false
                    yacht2lblLength.text = val
                }else{
                    yacht2viewLength.isHidden = true
                }
                if let val = yacht.guestsNumber, val.count > 0{
                    yacht2viewNumberOfGuests.isHidden = false
                    yacht2lblNumberOfGuests.text = val
                }else{
                    yacht2viewNumberOfGuests.isHidden = true
                }
                if let val = yacht.cabinNumber, val.count > 0{
                    yacht2viewCabins.isHidden = false
                    yacht2lblCabins.text = val
                }else{
                    yacht2viewCabins.isHidden = true
                }
            }
        }
        
        // restaurant
        restaurantMoreContainerView.isHidden = informations.restaurant.totalCount ?? 0 < 3
        print("Total Count: \(informations.restaurant.totalCount)")
        restaurantMoreLabel.text = "+ \((informations.restaurant.totalCount ?? 0) - 2) more"
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
            }
        }
        
        // experience
        experienceMoreContainerView.isHidden = informations.experience.totalCount ?? 0 < 3
        experienceMoreLabel.text = "+ \((informations.experience.totalCount ?? 0) - 2) more"
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
            self.navigationController?.pushViewController(ProductsViewController.instantiate(category: .villa, dataSource: [], city: Cities(termId: termId, name: cityInformation?.property.items.first?.locations?.city?.name ?? "", itemsNum: cityInformation?.property.totalCount ?? 0 ?? 0, items: [])), animated: true)
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
            self.navigationController?.pushViewController(ProductsViewController.instantiate(category: .event, dataSource: [], city: Cities(termId: termId, name: cityInformation?.event.items.first?.locations?.city?.name ?? "", itemsNum: cityInformation?.event.totalCount ?? 0 ?? 0, items: [])), animated: true)
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
            self.navigationController?.pushViewController(ProductsViewController.instantiate(category: .yacht, dataSource: [], city: Cities(termId: termId, name: cityInformation?.yacht.items.first?.locations?.city?.name ?? "", itemsNum: cityInformation?.yacht.totalCount ?? 0 ?? 0, items: [])), animated: true)
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
            self.navigationController?.pushViewController(RestaurantListViewController.instantiate(dataSource: [], city: Cities(termId: termId, name: cityInformation?.restaurant.items.first?.locations?.city?.name ?? "", itemsNum: cityInformation?.restaurant.totalCount ?? 0 ?? 0, items: [])), animated: true)
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
        cell.cityNameLabel.text = Utility.getCityStateCountryName(from: dataSource[indexPath.row])
        let colorView = UIView()
        colorView.backgroundColor = UIColor.clear
        UITableViewCell.appearance().selectedBackgroundView = colorView
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(dataSource[indexPath.row].cityName)
        let model = dataSource[indexPath.row]
        
        searchTextField.text = Utility.getCityStateCountryName(from:model)
        searchTextField.resignFirstResponder()
        fetchDataForCity(model)
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
        // this api is searching cities from google
        //EEAPIManager().search(token: token, searchText: text) { (cities, error) in
        EEAPIManager().searchCities(searchText: text) { (cities, error) in
            if let error = error {
                Crashlytics.crashlytics().record(error: error)
                self.showFeedback(error.localizedDescription)
            } else {
                self.dataSource = cities
            }
        }
    }
    
//    func fetchDataForCity(_ city: City) {
//        showNetworkActivity()
//
//        EEAPIManager().getInfoForCity( cityId: city.placeId) { (informations, error) in
//            self.hideNetworkActivity()
//
//            if let error = error {
//                Crashlytics.crashlytics().record(error: error)
//                self.showFeedback(error.localizedDescription)
//            } else if let informations = informations {
//                self.updateUI(informations: informations)
//            } else {
//                self.showFeedback("There is no content for this city.")
//            }
//        }
//    }
    
    func fetchDataForCity(_ city: Taxonomy) {
        showNetworkActivity()
        
        EEAPIManager().getInfoForCity( cityId: city.termId) { (informations, error) in
            self.hideNetworkActivity()
            
            if let error = error {
                Crashlytics.crashlytics().record(error: error)
                if error._code == 403{
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.logoutUser()
                }else{
                    self.showFeedback(error.localizedDescription)
                }
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
