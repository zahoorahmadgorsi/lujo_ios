//
//  MyPreferencesViewController.swift
//  LUJO
//
//  Created by iMac on 06/05/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import UIKit
import JGProgressHUD
import Cosmos
import Mixpanel
import Mixpanel

class StarRatingViewController: UIViewController {
    
    //MARK: - 🎲 - Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "StarRatingViewController" }
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var imgPreference: UIImageView!
    @IBOutlet weak var lblPrefLabel: UILabel!
    @IBOutlet weak var lblPrefQuestion: UILabel!
    @IBOutlet weak var lblCorporate: UILabel!
    @IBOutlet weak var lblLeisure: UILabel!
    
    @IBOutlet weak var businessStarRatingView: CosmosView!
    @IBOutlet weak var leisureStarRatingView: CosmosView!
    
    @IBOutlet weak var btnNextStep: UIButton!
    

    private let naHUD = JGProgressHUD(style: .dark)
    var prefType: PrefType!
    var prefInformationType : PrefInformationType!
    var userPreferences: Preferences?
    var preferencesMasterData: PrefMasterData!
    
    //to check if any selection has been changed or not, so that we can change the bottom button text to next from skip
    var previouslySelectedItems:[Int] = []
    var starDefaultRating = 4
    
    /// Init method that will init and return view controller.
    //class func instantiate(user: LujoUser) -> MyPreferencesViewController {
    class func instantiate(prefType: PrefType, prefInformationType : PrefInformationType) -> StarRatingViewController {
        let viewController = UIStoryboard.preferences.instantiate(identifier) as! StarRatingViewController
        viewController.prefType = prefType
        viewController.prefInformationType = prefInformationType
        return viewController
    }

    //MARK:- Globals
    
//    private(set) var user: LujoUser!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Skip all", style: .plain, target: self, action: #selector(skipTapped))
//        self.contentView.addViewBorder( borderColor: UIColor.white.cgColor, borderWith: 1.0,borderCornerRadius: 12.0)
        self.userPreferences = LujoSetup().getUserPreferences()  //get user preferences from the userdefaults
        self.preferencesMasterData = LujoSetup().getPreferencesMasterData() ?? PrefMasterData() //initialize if not found in the userdefaults
        
        switch prefType {
            case .travel:
                imgPreference.image = UIImage(named: "Find Hotel Icon")
                lblPrefLabel.text = "Travel"
                switch prefInformationType {
                case .travelHotelRating:
                    lblPrefQuestion.text = "What’s the star rating of hotels usually stay in?"
                    lblCorporate.text = "Business"
                    lblLeisure.text = "Leisure"
                    let corporateValue = userPreferences?.travel.travel_rating_business_hotels ?? starDefaultRating
                    let leisureValue = userPreferences?.travel.travel_rating_leisure_hotels ?? starDefaultRating
                    self.businessStarRatingView.rating = Double(corporateValue)
                    self.leisureStarRatingView.rating = Double(leisureValue)
                    self.previouslySelectedItems.append(corporateValue)
                    self.previouslySelectedItems.append(leisureValue)
                    
                default:
                    print("default of prefInformationType")
                }
            default:
                print("default of main switch")
        }
        
        // A closure that is called when user changes the rating by touching the view.
        // This can be used to update UI as the rating is being changed by moving a finger.
        self.businessStarRatingView.didTouchCosmos = { rating in
//            print(rating)
            self.businessStarRatingValueChanged()
        }
        
        // Called when user finishes changing the rating by lifting the finger from the view.
        // This may be a good place to save the rating in the database or send to the server.
//        self.businessStarRatingView.didFinishTouchingCosmos = { rating in
//            print(rating)
//        }
        
        self.leisureStarRatingView.didTouchCosmos = { rating in
//            print(rating)
            self.leisureStarRatingValueChanged()
        }
//        self.leisureStarRatingView.didFinishTouchingCosmos = { rating in
//            print(rating)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = "Preferences"
        activateKeyboardManager()
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationItem.title = ""
        self.tabBarController?.tabBar.isHidden = false
    }
    
    //when user will click on the back button at the bottom
    @IBAction func btnNextTapped(_ sender: Any) {
        if (isSelectionChanged()){
            let businessRating = Int(self.businessStarRatingView.rating)
            let leisureRating = Int(self.leisureStarRatingView.rating)
            
            self.showNetworkActivity()
            setPreferencesInformation(businessRating: businessRating , leisureRating:leisureRating)  {information, error in
                self.hideNetworkActivity()
                if let error = error {
                    self.showError(error)
                    return
                }
                if let informations = information {
                    if var userPreferences = self.userPreferences{
                        userPreferences.aviation.aviation_times_charter_corporate_jet = businessRating
                        userPreferences.aviation.aviation_times_charter_leisure_jet = leisureRating
                        LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                    }
                    self.navigateToNextVC()
                } else {
                    let error = BackendError.parsing(reason: "Could not set the Preferences")
                    self.showError(error)
                }
            }
        }else{
            navigateToNextVC()
        }
    }
    
    func setPreferencesInformation( businessRating: Int , leisureRating: Int, completion: @escaping (String?, Error?) -> Void) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            completion(nil, LoginError.errorLogin(description: "User does not exist or is not verified"))
            return
        }
        switch self.prefType {
        case .travel:
            switch self.prefInformationType {
            case .travelHotelRating:
                GoLujoAPIManager().setTravelHotelRating(token: token, businessStarRating: businessRating , leisureStarRating: leisureRating) { contentString, error in
                    guard error == nil else {
                        Crashlytics.sharedInstance().recordError(error!)
                        let error = BackendError.parsing(reason: "Could not obtain the preferences information")
                        completion(nil, error)
                        return
                    }
                    completion(contentString, error)
                }
            default:
                print("This will not call")
            }
        default:
            print("Main default")
        }
    }
    
    func navigateToNextVC(){
        switch self.prefType {
        case .travel:
            switch self.prefInformationType {
            case .travelHotelRating:
                let viewController = PrefImagesCollViewController.instantiate(prefType: .travel, prefInformationType: .travelDestinationType)
                self.navigationController?.pushViewController(viewController, animated: true)
            default:
                print("This will not call")
            }
        default:
            print("Main default")
        }
    }
    
    //this method checks the value which were at the time of loading of this screen and current seletion. if loading time value has been changed then button text get changed
    @objc func isSelectionChanged() -> Bool{
        switch self.prefType {
        case .travel:
            switch self.prefInformationType {
            case .travelHotelRating:
                var current :[Int] = []
                current.append(self.userPreferences?.travel.travel_rating_business_hotels ?? starDefaultRating)  //default value is set to 1
                current.append(self.userPreferences?.travel.travel_rating_leisure_hotels ?? starDefaultRating)
                let previous = self.previouslySelectedItems
                return !compare(current: current , previous: previous)
            default:
                print("This will not call")
            }
        default:
            print("Main default")
        }
        return true
    }
    
    func compare(current:[Int] , previous:[Int] ) -> Bool{
        if (Set(previous ) == Set(current)){
            btnNextStep.setTitle("N E X T", for: .normal)
            return true
        }else{
            btnNextStep.setTitle("N E X T", for: .normal)
            return false
        }
    }
    //@objc func skipTapped(sender: UIBarButtonItem){
    @objc func skipTapped(){
        Mixpanel.mainInstance().track(event: "preferences_skip_all_clicked",
                                      properties: ["SkippingAllFrom" : prefInformationType.rawValue])
        if let viewController = navigationController?.viewControllers.first(where: {$0 is PreferencesHomeViewController}) {
            //if user came from my preferences
            navigationController?.popToViewController(viewController, animated: true)
        }else if let viewController = navigationController?.viewControllers.first(where: {$0 is PerCityViewController}) {
            //if user came from per city view controler
            navigationController?.popToViewController(viewController, animated: true)
        }else if let viewController = navigationController?.viewControllers.first(where: {$0 is ProductsViewController}) {
            //if user came from Products view controler
            navigationController?.popToViewController(viewController, animated: true)
        }else if let viewController = navigationController?.viewControllers.first(where: {$0 is AviationViewController}) {
            //if user came from Aviation view controler
            navigationController?.popToViewController(viewController, animated: true)
        }else{
            //if user came from home screen
            self.navigationController?.popToRootViewController(animated: true)
        }
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
    
    func showError(_ error: Error) {
        showErrorPopup(withTitle: "Preferences Error", error: error)
    }
    
    func businessStarRatingValueChanged() {
        let currentValue = Int(businessStarRatingView.rating)
//        print("corporateSliderValueChanged to \(currentValue)")
        switch self.prefType {
        case .travel:
            switch self.prefInformationType {
            case .travelHotelRating:
                self.userPreferences?.travel.travel_rating_business_hotels = currentValue
            default:
                print("This will not call")
            }
        default:
            print("Main default")
        }
        
        isSelectionChanged()
    }
    
    func leisureStarRatingValueChanged() {
        let currentValue = Int(leisureStarRatingView.rating)
//        print("LeisureSliderValueChanged to \(currentValue)")
        switch self.prefType {
        case .travel:
            switch self.prefInformationType {
            case .travelHotelRating:
                self.userPreferences?.travel.travel_rating_leisure_hotels = currentValue
            default:
                print("This will not call")
            }
        default:
            print("Main default")
        }
        
        isSelectionChanged()
    }
    
}

