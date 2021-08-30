//
//  GlobalSearchViewController.swift
//  LUJO
//
//  Created by Nemanja Djurisic on 10/15/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import Crashlytics
import IQKeyboardManagerSwift
import JGProgressHUD
import Mixpanel

class GlobalSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    //MARK:- Init
    
    private let naHUD = JGProgressHUD(style: .dark)
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
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
    
    // Restaurant
    @IBOutlet weak var restaurantContainerView: UIView!
    
    @IBOutlet weak var restaurant1ContainerView: UIView!
    @IBOutlet weak var restaurant1ImageView: UIImageView!
    @IBOutlet weak var restaurant1NameLabel: UILabel!
    @IBOutlet weak var restaurant1locationLabel: UILabel!
    @IBOutlet weak var restaurant1locationContainerView: UIView!
    @IBOutlet weak var restaurant1starCountLabel: UILabel!
    @IBOutlet weak var restaurant1starImageContainerView: UIView!
    
    @IBOutlet weak var restaurant2ContainerView: UIView!
    @IBOutlet weak var restaurant2ImageView: UIImageView!
    @IBOutlet weak var restaurant2NameLabel: UILabel!
    @IBOutlet weak var restaurant2locationLabel: UILabel!
    @IBOutlet weak var restaurant2locationContainerView: UIView!
    @IBOutlet weak var restaurant2starCountLabel: UILabel!
    @IBOutlet weak var restaurant2starImageContainerView: UIView!
    
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
        eventContainerView.isHidden = informations.event.items.isEmpty
        restaurantContainerView.isHidden = informations.restaurant.items.isEmpty
        experienceContainerView.isHidden = informations.experience.items.isEmpty
        
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
                
                if let mediaLink = event.primaryMedia?.mediaUrl, event.primaryMedia?.type == "image" {
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
                
                if let mediaLink = event.primaryMedia?.mediaUrl, event.primaryMedia?.type == "image" {
                    event2ImageView.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
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
                
                if let mediaLink = restaurant.primaryMedia?.mediaUrl, restaurant.primaryMedia?.type == "image" {
                    restaurant1ImageView.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
                }
                
                if let city = restaurant.location?.first?.city {
                    restaurant1locationContainerView.isHidden = false
                    restaurant1locationLabel.text = city.name.uppercased()
                } else {
                    restaurant1locationContainerView.isHidden = true
                }
                
                if let star = restaurant.michelinStar?.first {
                    restaurant1starImageContainerView.isHidden = false
                    restaurant1starCountLabel.text = star.name.uppercased()
                } else {
                    restaurant1starImageContainerView.isHidden = true
                }
                
            } else if index == 1 {
                restaurant2NameLabel.text = restaurant.name
                
                if let mediaLink = restaurant.primaryMedia?.mediaUrl, restaurant.primaryMedia?.type == "image" {
                    restaurant2ImageView.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
                }
                
                if let city = restaurant.location?.first?.city {
                    restaurant2locationContainerView.isHidden = false
                    restaurant2locationLabel.text = city.name.uppercased()
                } else {
                    restaurant2locationContainerView.isHidden = true
                }
                
                if let star = restaurant.michelinStar?.first {
                    restaurant2starImageContainerView.isHidden = false
                    restaurant2starCountLabel.text = star.name.uppercased()
                } else {
                    restaurant2starImageContainerView.isHidden = true
                }
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
                
                if let mediaLink = experience.primaryMedia?.mediaUrl, experience.primaryMedia?.type == "image" {
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
                
                if let mediaLink = experience.primaryMedia?.mediaUrl, experience.primaryMedia?.type == "image" {
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
    
    @IBAction func eventButton_onClick(_ sender: UIButton) {
        if let event = cityInformation?.event.items[sender.tag] {
//            self.navigationController?.pushViewController(EventDetailsViewController.instantiate(event: event), animated: true)
            let viewController = ProductDetailsViewController.instantiate(product: event)
    //        // B1 - 4
            //That is how you configure a present custom transition. But it is not how you configure a push custom transition.
//            viewController.transitioningDelegate = self
            viewController.modalPresentationStyle = .overFullScreen
            viewController.delegate = self
            present(viewController, animated: true)
        }
    }
    
    @IBAction func restaurantButton_onClick(_ sender: UIButton) {
        if let restaurant = cityInformation?.restaurant.items[sender.tag] {
            let viewController = ProductDetailsViewController.instantiate(product: restaurant)
            viewController.modalPresentationStyle = .overFullScreen
            viewController.delegate = self
            present(viewController, animated: true)
        }
    }
    
    @IBAction func experianceButton_onClick(_ sender: UIButton) {
        if let experience = cityInformation?.experience.items[sender.tag] {
//            self.navigationController?.pushViewController(EventDetailsViewController.instantiate(event: experience), animated: true)
            let viewController = ProductDetailsViewController.instantiate(product: experience)
            viewController.modalPresentationStyle = .overFullScreen
            viewController.delegate = self
            present(viewController, animated: true)
        }
    }
    
    @IBAction func seeAllEventsButton_onClick(_ sender: Any) {
        if let termId = cityInformation?.event.items.first?.location?.first?.city?.termId {
            self.navigationController?.pushViewController(ProductsViewController.instantiate(category: .event, dataSource: [], city: DiningCity(termId: termId, name: cityInformation?.event.items.first?.location?.first?.city?.name ?? "", restaurantsNum: cityInformation?.event.num ?? 0, restaurants: [])), animated: true)
        }
    }
    
    @IBAction func seeAllRestaurantsButton_onClick(_ sender: Any) {
        if let termId = cityInformation?.restaurant.items.first?.location?.first?.city?.termId {
            self.navigationController?.pushViewController(RestaurantListViewController.instantiate(dataSource: [], city: DiningCity(termId: termId, name: cityInformation?.restaurant.items.first?.location?.first?.city?.name ?? "", restaurantsNum: cityInformation?.restaurant.num ?? 0, restaurants: [])), animated: true)
        }
    }
    
    @IBAction func seeAllExperiancesButton_onClick(_ sender: Any) {
        if let termId = cityInformation?.experience.items.first?.location?.first?.city?.termId {
            self.navigationController?.pushViewController(ProductsViewController.instantiate(category: .experience, dataSource: [], city: DiningCity(termId: termId, name: cityInformation?.experience.items.first?.location?.first?.city?.name ?? "", restaurantsNum: cityInformation?.experience.num ?? 0, restaurants: [])), animated: true)
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
                Crashlytics.sharedInstance().recordError(error)
                self.showFeedback(error.localizedDescription)
            } else {
                self.dataSource = cities
            }
        }
    }
    
    func fetchDataForCity(_ city: City) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            showFeedback("User does not exist or is not verified")
            return
        }
        
        showNetworkActivity()
        
        EEAPIManager().getInfoForCity(token: token, cityId: city.placeId) { (informations, error) in
            self.hideNetworkActivity()
            
            if let error = error {
                Crashlytics.sharedInstance().recordError(error)
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

extension GlobalSearchViewController : ProductDetailDelegate{
    func tappedOnBookRequest(viewController:UIViewController) {
        // Initialize a navigation controller, with your view controller as its root
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true, completion: nil)
    }
}

// B1 - 1
//extension HomeViewController: UIViewControllerTransitioningDelegate {
//
//    // B1 - 2
//    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
////        return nil
//        // B2 - 16
////        We are preparing the properties to initialize an instance of Animator. If it fails, return nil to use default animation. Then assign it to the animator instance that we just created.
//        guard let firstViewController = source as? HomeViewController,
//            let secondViewController = presented as? EventDetailsViewController,
//            let selectedCellImageViewSnapshot = selectedCellImageViewSnapshot
//            else {
//                return nil
//            }
////        print(animationtype)
//        if animationtype == .slider{
//            sliderToDetailAnimator = HomeSliderAnimator(type: .present, firstViewController: firstViewController, secondViewController: secondViewController, selectedCellImageViewSnapshot: selectedCellImageViewSnapshot)
//            return sliderToDetailAnimator
//        }else if animationtype == .featured{
//            featuredToDetailAnimator = HomeFeaturedAnimator(type: .present, firstViewController: firstViewController, secondViewController: secondViewController, selectedCellImageViewSnapshot: selectedCellImageViewSnapshot)
//            return featuredToDetailAnimator
//        }else {
//            return nil
//        }
//    }
//
//    // B1 - 3
//    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
////        return nil
//        // B2 - 17
////        We are preparing the properties to initialize an instance of Animator. If it fails, return nil to use default animation. Then assign it to the animator instance that we just created.
//        guard let secondViewController = dismissed as? EventDetailsViewController,
//            let selectedCellImageViewSnapshot = selectedCellImageViewSnapshot
//            else {
//                return nil
//            }
//        if animationtype == .slider{
//            sliderToDetailAnimator = HomeSliderAnimator(type: .dismiss, firstViewController: self, secondViewController: secondViewController, selectedCellImageViewSnapshot: selectedCellImageViewSnapshot)
//            return sliderToDetailAnimator
//        }else if animationtype == .featured{
//            featuredToDetailAnimator = HomeFeaturedAnimator(type: .dismiss, firstViewController: self, secondViewController: secondViewController, selectedCellImageViewSnapshot: selectedCellImageViewSnapshot)
//            return featuredToDetailAnimator
//        }else {
//            return nil
//        }
//    }
//}

//extension HomeViewController: UINavigationControllerDelegate{
//    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
//    {
//        switch operation {
//            case .push:
//                return animationController(forPresented: toVC , presenting: fromVC, source: fromVC)
//            case .pop:
//                return animationController(forDismissed: fromVC)
//            default:
//                return nil
//        }
//
//    }
//}
