//
//  MyPreferencesViewController.swift
//  LUJO
//
//  Created by iMac on 06/05/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import UIKit
import JGProgressHUD
import Mixpanel
import FirebaseCrashlytics

class PrefCollectionsViewController: UIViewController {
    
    //MARK: - 🎲 - Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "PrefCollectionsViewController" }
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var imgPreference: UIImageView!
    @IBOutlet weak var lblPrefLabel: UILabel!
    @IBOutlet weak var lblPrefQuestion: UILabel!
    @IBOutlet weak var collContainerView: UIView!
    @IBOutlet weak var txtPleaseSpecify: UITextField!
    @IBOutlet weak var btnNextStep: UIButton!
    
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.vertical
        let contentView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        contentView.dataSource = self
        contentView.delegate = self
        contentView.register(UINib(nibName: PrefCollViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: PrefCollViewCell.identifier)
        contentView.backgroundColor = .clear
        contentView.showsHorizontalScrollIndicator = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    var itemsList: [Taxonomy] = [] {
        didSet {
            collectionView.reloadData()
            collectionView.layoutIfNeeded() //forces the reload to happen immediately instead of on the next runloop cycle.
        }
    }
    //to check if any selection has been changed or not, so that we can change the bottom button text to next from skip
    var previouslySelectedItems:[String] = []
    
    private let naHUD = JGProgressHUD(style: .dark)
    var prefType: PrefType!
    var prefInformationType : PrefInformationType!
    var userPreferences: Preferences?
    var preferencesMasterData: PrefMasterData!
    var cellWidth : Int = 165
    
    /// Init method that will init and return view controller.
    //class func instantiate(user: LujoUser) -> MyPreferencesViewController {
    class func instantiate(prefType: PrefType, prefInformationType : PrefInformationType) -> PrefCollectionsViewController {
        let viewController = UIStoryboard.preferences.instantiate(identifier) as! PrefCollectionsViewController
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
    
        self.collContainerView.addSubview(collectionView)
        applyConstraints()
        
        txtPleaseSpecify.addTarget(self,
                             action: #selector(isSelectionChanged),
                             for: .editingChanged)
        
        switch prefType {
        case .gifts:
            imgPreference.image = UIImage(named: "Purchase Goods Icon")
            lblPrefLabel.text = "Gifts"
            switch prefInformationType {
            case .giftHabbits:
                lblPrefQuestion.text = "Tell us about your gift giving habits:"
                previouslySelectedItems = self.userPreferences?.gift.gift_habit_id ?? []
            case .giftCategories:
                lblPrefQuestion.text = "Preferred gift items:"
                previouslySelectedItems = self.userPreferences?.gift.gift_category_id ?? []
            case .giftPreferences:
                lblPrefQuestion.text = "Item Preferences:"
                //removing the duplicates
                previouslySelectedItems = Array(Set(self.userPreferences?.gift.gift_preferences_id ?? [])) //Order might change
                btnNextStep.setTitle("F I N I S H", for: .normal)
            default:
                print("Others")
            }
        case .aviation:
            imgPreference.image = UIImage(named: "aviation_icon")
            lblPrefLabel.text = "Aviation"
            switch prefInformationType {
            case .aviationHaveCharteredBefore:
                lblPrefQuestion.text = "Have you chartered before?"
                txtPleaseSpecify.isHidden = true
                if let value = self.userPreferences?.aviation.aviation_chartered_before{
                    previouslySelectedItems.append(value)
                }
            case .aviationInterestedIn:
                lblPrefQuestion.text = "Interested in?"
                txtPleaseSpecify.isHidden = true
                if let value = self.userPreferences?.aviation.aviation_interested_in{
                    previouslySelectedItems.append(value)
                }
            case .aviationPreferredCharter:
                lblPrefQuestion.text = "Preferred charter?"
                txtPleaseSpecify.isHidden = true
                if let value = self.userPreferences?.aviation.aviation_preferred_charter_range{
                    previouslySelectedItems.append(value)
                }
            case .aviationPreferredCuisine:
                lblPrefQuestion.text = "Preferred cuisine?"
                previouslySelectedItems = self.userPreferences?.aviation.aviation_preferred_cuisine_id ?? []
            case .aviationPreferredBevereges:
                lblPrefQuestion.text = "Preferred Beverages?"
                previouslySelectedItems = self.userPreferences?.aviation.aviation_preferred_beverage_id ?? []
                btnNextStep.setTitle("F I N I S H", for: .normal)
            default:
                print("Others")
            }
        case .yachts:
            imgPreference.image = UIImage(named: "Charter Yacht Icon")
            lblPrefLabel.text = "Yacht"
            switch prefInformationType {
            case .yachtHaveCharteredBefore:
                lblPrefQuestion.text = "Have you chartered a yacht before?"
                txtPleaseSpecify.isHidden = true
                if let value = self.userPreferences?.yacht.yacht_chartered_before{
                    previouslySelectedItems.append(value)
                }
            case .yachtInterestedIn:
                lblPrefQuestion.text = "Interested in?"
                txtPleaseSpecify.isHidden = true
                if let value = self.userPreferences?.yacht.yacht_interested_in{
                    previouslySelectedItems.append(value)
                }
            case .yachtType:
                lblPrefQuestion.text = "Preferred type of cruising/sailing:"
                txtPleaseSpecify.isHidden = true
                if let value = self.userPreferences?.yacht.yacht_type{
                    previouslySelectedItems.append(value)
                }
            case .yachtStyle:
                lblPrefQuestion.text = "Preferred style of yacht:"
                txtPleaseSpecify.isHidden = true
                if let value = self.userPreferences?.yacht.yacht_style{
                    previouslySelectedItems.append(value)
                }
            case .yachtPreferredCuisines:
                lblPrefQuestion.text = "Preferred cuisine?"
                txtPleaseSpecify.text = self.userPreferences?.yacht.yacht_preferred_cuisine_id_other
                previouslySelectedItems = self.userPreferences?.yacht.yacht_preferred_cuisine_id ?? []
            case .yachtOtherInterests:
                lblPrefQuestion.text = "For better experience tell us about your other interests?"
                txtPleaseSpecify.isHidden = true
                previouslySelectedItems = self.userPreferences?.yacht.yacht_interests_id ?? []
                btnNextStep.setTitle("F I N I S H", for: .normal)
            default:
                print("Others")
            }
        case .dining:
            imgPreference.image = UIImage(named: "Book Table Icon")
            lblPrefLabel.text = "Find a table"
            switch prefInformationType {
            case .diningCuisines:
                lblPrefQuestion.text = "What is your preferred cuisine type?"
                txtPleaseSpecify.text = self.userPreferences?.restaurant.restaurant_preferred_cuisine_id_other
                previouslySelectedItems = self.userPreferences?.restaurant.restaurant_preferred_cuisine_id ?? []
            case .diningAllergies:
                lblPrefQuestion.text = "Allergies"
                txtPleaseSpecify.isHidden = true
                previouslySelectedItems = self.userPreferences?.restaurant.restaurant_allergy_id ?? []
            case .diningPreferences:
                lblPrefQuestion.text = "Your dining preferences:"
                txtPleaseSpecify.text = self.userPreferences?.restaurant.restaurant_dinning_id_other
                previouslySelectedItems = self.userPreferences?.restaurant.restaurant_dinning_id ?? []
            case .diningTimings:
                lblPrefQuestion.text = "Preferred time of dining:"
                txtPleaseSpecify.isHidden = true
                previouslySelectedItems = self.userPreferences?.restaurant.restaurant_timing_id ?? []
            case .diningBeverages:
                lblPrefQuestion.text = "Preferred Beverages while dining:"
                txtPleaseSpecify.text = self.userPreferences?.restaurant.restaurant_beverage_id_other
                previouslySelectedItems = self.userPreferences?.restaurant.restaurant_beverage_id ?? []
            case .diningSeatings:
                lblPrefQuestion.text = "Preferred Seating:"
                txtPleaseSpecify.isHidden = true
                previouslySelectedItems = self.userPreferences?.restaurant.restaurant_seating_id ?? []
                btnNextStep.setTitle("F I N I S H", for: .normal)
            
            default:
                print("default of dining")
            }
        case .events:
            imgPreference.image = UIImage(named: "event_preference_icon")
            lblPrefLabel.text = "Events & Experiences"
            switch prefInformationType {
            case .eventCategory:
                lblPrefQuestion.text = "Type of Event/Experience:"
                txtPleaseSpecify.text = self.userPreferences?.event.event_category_id_other
                previouslySelectedItems = self.userPreferences?.event.event_category_id ?? []
            case .eventLocation:
                lblPrefQuestion.text = "Location"
                txtPleaseSpecify.isHidden = true
                previouslySelectedItems = self.userPreferences?.event.event_location_id ?? []
                btnNextStep.setTitle("F I N I S H", for: .normal)
            
            default:
                print("default of events")
            }
        case .travel:
            imgPreference.image = UIImage(named: "Find Hotel Icon")
            lblPrefLabel.text = "Travel"
            switch prefInformationType {
            case .travelAmenities:
                lblPrefQuestion.text = "Preferred Amenities"
                txtPleaseSpecify.text = self.userPreferences?.travel.travel_amenity_id_other
                previouslySelectedItems = self.userPreferences?.travel.travel_amenity_id ?? []
            case .travelAirplaneSeat:
                lblPrefQuestion.text = "Which seat do you prefer on a airplane?"
                txtPleaseSpecify.isHidden = true
                previouslySelectedItems = self.userPreferences?.travel.travel_airplane_seat ?? []
            case .travelMeals:
                lblPrefQuestion.text = "Preferred Meals"
                txtPleaseSpecify.isHidden = true
                previouslySelectedItems = self.userPreferences?.travel.travel_airplane_meals ?? []
            case .travelMedicalMeals:
                lblPrefQuestion.text = "Medical and Dietary Meals"
                txtPleaseSpecify.text = self.userPreferences?.travel.travel_medical_dietary_meal_other
                previouslySelectedItems = self.userPreferences?.travel.travel_medical_dietary_meal ?? []
            case .travelAllergies:
                lblPrefQuestion.text = "Allergies"
                txtPleaseSpecify.text = self.userPreferences?.travel.travel_allergy_id_other
                previouslySelectedItems = self.userPreferences?.travel.travel_allergy_id ?? []
                btnNextStep.setTitle("F I N I S H", for: .normal)
            default:
                print("default of travel")
            }
        case .villas:
            imgPreference.image = UIImage(named: "villa cta")
            lblPrefLabel.text = "Villa"
            switch prefInformationType {
            case .villaAmenities:
                lblPrefQuestion.text = "Preferred Amenities"
                txtPleaseSpecify.text = self.userPreferences?.villa.villa_preferred_amenities_id_other
                previouslySelectedItems = self.userPreferences?.villa.villa_preferred_amenities_id ?? []
            case .villaAccomodation:
                lblPrefQuestion.text = "Choice of Accomodation"
                txtPleaseSpecify.text = self.userPreferences?.villa.villa_preferred_accommodations_id_other
                previouslySelectedItems = self.userPreferences?.villa.villa_preferred_accommodations_id ?? []
                btnNextStep.setTitle("F I N I S H", for: .normal)
            default:
                print("default of villa")
            }
        default:
            print("Others")
        }
        getPrefMasterData()
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
    
    func getPrefMasterData() {
        //checking if the master data for preferences is cahced or not
        switch prefType {
            case .gifts:
                switch prefInformationType {
                case .giftHabbits:
                    if let cachedItems = preferencesMasterData.giftHabits , cachedItems.count > 0{  //if data is already cached or not
                        self.itemsList = cachedItems
                    }
                case .giftCategories:
                    if let cachedItems = preferencesMasterData.giftCategories , cachedItems.count > 0{  //if data is already cached or not
                        self.itemsList = cachedItems
                    }
                case .giftPreferences:
                    if let cachedItems = preferencesMasterData.giftPreferences , cachedItems.count > 0{  //if data is already cached or not
                        self.itemsList = cachedItems
                    }
                default:
                    print("This statement must not execute")
                }
            case .aviation:
                switch prefInformationType {
                case .aviationHaveCharteredBefore:
                    let taxonomyObj1 = Taxonomy(termId:"asdf1234qwer" , name: "Yes")
                    let taxonomyObj2 = Taxonomy(termId:"asdf1234qwer" , name: "No")
                    var taxonomies = [Taxonomy]()
                    taxonomies.append(taxonomyObj1)
                    taxonomies.append(taxonomyObj2)
                    self.itemsList = taxonomies
                case .aviationInterestedIn:
                    let taxonomyObj1 = Taxonomy(termId:"asdf1234qwer" , name: "Charter")
                    let taxonomyObj2 = Taxonomy(termId:"asdf1234qwer" , name: "Purchase")
                    let taxonomyObj3 = Taxonomy(termId:"asdf1234qwer" , name: "Both")
                    var taxonomies = [Taxonomy]()
                    taxonomies.append(taxonomyObj1)
                    taxonomies.append(taxonomyObj2)
                    taxonomies.append(taxonomyObj3)
                    self.itemsList = taxonomies
                case .aviationPreferredCharter:
                    let taxonomyObj1 = Taxonomy(termId:"asdf1234qwer" , name: "Short Range")
                    let taxonomyObj2 = Taxonomy(termId:"asdf1234qwer" , name: "Long Range")
                    let taxonomyObj3 = Taxonomy(termId:"asdf1234qwer" , name: "Both")
                    var taxonomies = [Taxonomy]()
                    taxonomies.append(taxonomyObj1)
                    taxonomies.append(taxonomyObj2)
                    taxonomies.append(taxonomyObj3)
                    self.itemsList = taxonomies
                case .aviationPreferredCuisine:
                    if let cachedItems = preferencesMasterData.cuisines , cachedItems.count > 0{  //if data is already cached or not
                        self.itemsList = cachedItems
                    }
                case .aviationPreferredBevereges:
                    if let cachedItems = preferencesMasterData.beverages , cachedItems.count > 0{  //if data is already cached or not
                        self.itemsList = cachedItems
                    }
                default:
                    print("Hard codes values for this case. No master data exist.")
                }
            case .yachts:
                switch prefInformationType {
                case .yachtHaveCharteredBefore:
                    let taxonomyObj1 = Taxonomy(termId:"asdf1234qwer" , name: "Yes")
                    let taxonomyObj2 = Taxonomy(termId:"asdf1234qwer" , name: "No")
                    var taxonomies = [Taxonomy]()
                    taxonomies.append(taxonomyObj1)
                    taxonomies.append(taxonomyObj2)
                    self.itemsList = taxonomies
                case .yachtInterestedIn:
                    let taxonomyObj1 = Taxonomy(termId:"asdf1234qwer" , name: "Charter")
                    let taxonomyObj2 = Taxonomy(termId:"asdf1234qwer" , name: "Purchase")
                    let taxonomyObj3 = Taxonomy(termId:"asdf1234qwer" , name: "Both")
                    var taxonomies = [Taxonomy]()
                    taxonomies.append(taxonomyObj1)
                    taxonomies.append(taxonomyObj2)
                    taxonomies.append(taxonomyObj3)
                    self.itemsList = taxonomies
                case .yachtType:
                    let taxonomyObj1 = Taxonomy(termId:"asdf1234qwer" , name: "Motor")
                    let taxonomyObj2 = Taxonomy(termId:"asdf1234qwer" , name: "Sail")
                    let taxonomyObj3 = Taxonomy(termId:"asdf1234qwer" , name: "Both")
                    var taxonomies = [Taxonomy]()
                    taxonomies.append(taxonomyObj1)
                    taxonomies.append(taxonomyObj2)
                    taxonomies.append(taxonomyObj3)
                    self.itemsList = taxonomies
                case .yachtStyle:
                    let taxonomyObj1 = Taxonomy(termId:"asdf1234qwer" , name: "Modern")
                    let taxonomyObj2 = Taxonomy(termId:"asdf1234qwer" , name: "Classic")
                    let taxonomyObj3 = Taxonomy(termId:"asdf1234qwer" , name: "Both")
                    var taxonomies = [Taxonomy]()
                    taxonomies.append(taxonomyObj1)
                    taxonomies.append(taxonomyObj2)
                    taxonomies.append(taxonomyObj3)
                    self.itemsList = taxonomies
                case .yachtPreferredCuisines:
                    if let cachedItems = preferencesMasterData.cuisines , cachedItems.count > 0{  //if data is already cached or not
                        self.itemsList = cachedItems
                    }
                case .yachtOtherInterests:
                    if let cachedItems = preferencesMasterData.otherInterests , cachedItems.count > 0{  //if data is already cached or not
                        self.itemsList = cachedItems
                    }
                default:
                    print("Hard codes values for this case. No master data exist.")
                }
            case .dining:
                switch prefInformationType {
                case .diningCuisines:
                    if let cachedItems = preferencesMasterData.cuisines , cachedItems.count > 0{  //if data is already cached or not
                        self.itemsList = cachedItems
                    }
                case .diningAllergies:
                    if let cachedItems = preferencesMasterData.diningAllergies , cachedItems.count > 0{  //if data is already cached or not
                        self.itemsList = cachedItems
                    }
                case .diningPreferences:
                    if let cachedItems = preferencesMasterData.diningPreferences , cachedItems.count > 0{  //if data is already cached or not
                        self.itemsList = cachedItems
                    }
                case .diningTimings:
                    if let cachedItems = preferencesMasterData.diningTimings , cachedItems.count > 0{  //if data is already cached or not
                        self.itemsList = cachedItems
                    }
                case .diningBeverages:
                    if let cachedItems = preferencesMasterData.beverages , cachedItems.count > 0{  //if data is already cached or not
                        self.itemsList = cachedItems
                    }
                case .diningSeatings:
                    if let cachedItems = preferencesMasterData.diningSeatings , cachedItems.count > 0{  //if data is already cached or not
                        self.itemsList = cachedItems
                    }
                default:
                    print("default of dining")
                }
            case .events:
                switch prefInformationType {
                case .eventCategory:
                    if let cachedItems = preferencesMasterData.eventCategory , cachedItems.count > 0{  //if data is already cached or not
                        self.itemsList = cachedItems
                    }
                case .eventLocation:
                    if let cachedItems = preferencesMasterData.eventLocation , cachedItems.count > 0{  //if data is already cached or not
                        self.itemsList = cachedItems
                    }
                default:
                    print("default of event")
                }
            case .travel:
                switch prefInformationType {
                case .travelAmenities:
                    if let cachedItems = preferencesMasterData.travelAmenities , cachedItems.count > 0{  //if data is already cached or not
                        self.itemsList = cachedItems
                    }
                case .travelAirplaneSeat:
                    let taxonomyObj1 = Taxonomy(termId:"asdf1234qwer" , name: "Aisle")
                    let taxonomyObj2 = Taxonomy(termId:"asdf1234qwer" , name: "Window")
                    var taxonomies = [Taxonomy]()
                    taxonomies.append(taxonomyObj1)
                    taxonomies.append(taxonomyObj2)
                    self.itemsList = taxonomies
                case .travelMeals:
                    if let cachedItems = preferencesMasterData.diningPreferences , cachedItems.count > 0{  //if data is already cached or not
                        self.itemsList = cachedItems
                    }
                case .travelMedicalMeals:
                    if let cachedItems = preferencesMasterData.travelMedicalMeals , cachedItems.count > 0{  //if data is already cached or not
                        self.itemsList = cachedItems
                    }
                case .travelAllergies:
                    if let cachedItems = preferencesMasterData.travelAllergies , cachedItems.count > 0{  //if data is already cached or not
                        self.itemsList = cachedItems
                    }
                default:
                    print("default of travel")
             }
            case .villas:
                switch prefInformationType {
                case .villaAmenities:
                    if let cachedItems = preferencesMasterData.villaAmenities , cachedItems.count > 0{  //if data is already cached or not
                        self.itemsList = cachedItems
                    }
                case .villaAccomodation:
                    if let cachedItems = preferencesMasterData.villaAccomodation , cachedItems.count > 0{  //if data is already cached or not
                        self.itemsList = cachedItems
                    }
                default:
                    print("default of villa")
             }
            default:
                print("Others")
            }
        if (self.itemsList.count == 0){
            self.showNetworkActivity()  //if no data is cached then fetch openly else silently
        }
        getPrefMasterData() {taxonomies, error in
            self.hideNetworkActivity()
            if let error = error {
                self.showError(error)
                return
            }
            if let informations = taxonomies {
                if informations.count > 0{  //it will contain zero in case of hard coded values
                    self.itemsList = informations
                }
            } else {
                let error = BackendError.parsing(reason: "Could not obtain Preferences information")
                self.showError(error)
            }
        }
    }

    func getPrefMasterData(completion: @escaping ([Taxonomy]?, Error?) -> Void) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            completion(nil, LoginError.errorLogin(description: "User does not exist or is not verified"))
            return
        }

        switch prefType {
        case .gifts:
            switch prefInformationType {
            case .giftHabbits:
                GoLujoAPIManager().getGiftHabbits() { taxonomies, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not obtain the Preferences information")
                        completion(nil, error)
                        return
                    }
                    //caching master data into userdefaults
                    if taxonomies?.count ?? 0 > 0{
                        self.preferencesMasterData.giftHabits = taxonomies
                        LujoSetup().store(preferencesMasterData: self.preferencesMasterData)
                    }
                    completion(taxonomies, error)
                }
            case .giftCategories:
                GoLujoAPIManager().getGiftCategories(token) { taxonomies, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not obtain the Preferences information")
                        completion(nil, error)
                        return
                    }
                    //caching master data into userdefaults
                    if taxonomies?.count ?? 0 > 0{
                        self.preferencesMasterData.giftCategories = taxonomies
                        LujoSetup().store(preferencesMasterData: self.preferencesMasterData)
                    }
                    completion(taxonomies, error)
                }
            case .giftPreferences:
                GoLujoAPIManager().getGiftPreferences() { taxonomies, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not obtain the Preferences information")
                        completion(nil, error)
                        return
                    }
                    //caching master data into userdefaults
                    if taxonomies?.count ?? 0 > 0{
                        self.preferencesMasterData.giftPreferences = taxonomies
                        LujoSetup().store(preferencesMasterData: self.preferencesMasterData)
                    }
                    completion(taxonomies, error)
                }
            default:
                print("This statement must not execute")
            }

        case .aviation:
            switch prefInformationType {
            case .aviationPreferredCuisine:
                GoLujoAPIManager().getCuisines(token) { taxonomies, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not obtain aviation information")
                        completion(nil, error)
                        return
                    }
                    //caching master data into userdefaults
                    if taxonomies?.count ?? 0 > 0{
                        self.preferencesMasterData.cuisines = taxonomies
                        LujoSetup().store(preferencesMasterData: self.preferencesMasterData)
                    }
                    completion(taxonomies, error)
                }
            case .aviationPreferredBevereges:
                GoLujoAPIManager().getAviationBeverages(token) { taxonomies, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not obtain the Preferences information")
                        completion(nil, error)
                        return
                    }
                    //caching master data into userdefaults
                    if taxonomies?.count ?? 0 > 0{
                        self.preferencesMasterData.beverages = taxonomies
                        LujoSetup().store(preferencesMasterData: self.preferencesMasterData)
                    }
                    completion(taxonomies, error)
                }
            default:
                print("Hard coded values, no master data exist.")
                completion([], nil)
            }
        case .yachts:
            switch prefInformationType {
            case .yachtPreferredCuisines:
                GoLujoAPIManager().getCuisines(token) { taxonomies, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not obtain yacht information")
                        completion(nil, error)
                        return
                    }
                    //caching master data into userdefaults
                    if taxonomies?.count ?? 0 > 0{
                        self.preferencesMasterData.cuisines = taxonomies
                        LujoSetup().store(preferencesMasterData: self.preferencesMasterData)
                    }
                    completion(taxonomies, error)
                }
            case .yachtOtherInterests:
                GoLujoAPIManager().getOtherInterests(token) { taxonomies, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not obtain the Preferences information")
                        completion(nil, error)
                        return
                    }
                    //caching master data into userdefaults
                    if taxonomies?.count ?? 0 > 0{
                        self.preferencesMasterData.otherInterests = taxonomies
                        LujoSetup().store(preferencesMasterData: self.preferencesMasterData)
                    }
                    completion(taxonomies, error)
                }
            default:
                print("Hard coded values, no master data exist.")
                completion([], nil)
            }
        case .dining:
           switch prefInformationType {
           case .diningCuisines:
                GoLujoAPIManager().getDiningCuisines(token) { taxonomies, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not obtain Dining information")
                        completion(nil, error)
                        return
                    }
                    //caching master data into userdefaults
                    if taxonomies?.count ?? 0 > 0{
                        self.preferencesMasterData.cuisines = taxonomies
                        LujoSetup().store(preferencesMasterData: self.preferencesMasterData)
                    }
                    completion(taxonomies, error)
                }
           case .diningAllergies:
                GoLujoAPIManager().getDiningAllergies(token) { taxonomies, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not obtain Dining information")
                        completion(nil, error)
                        return
                    }
                    //caching master data into userdefaults
                    if taxonomies?.count ?? 0 > 0{
                        self.preferencesMasterData.diningAllergies = taxonomies
                        LujoSetup().store(preferencesMasterData: self.preferencesMasterData)
                    }
                    completion(taxonomies, error)
                }
           case .diningPreferences:
                GoLujoAPIManager().getDiningPreferences(token) { taxonomies, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not obtain Dining information")
                        completion(nil, error)
                        return
                    }
                    //caching master data into userdefaults
                    if taxonomies?.count ?? 0 > 0{
                        self.preferencesMasterData.diningPreferences = taxonomies
                        LujoSetup().store(preferencesMasterData: self.preferencesMasterData)
                    }
                    completion(taxonomies, error)
                }
           case .diningTimings:
                GoLujoAPIManager().getDiningTimings(token) { taxonomies, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not obtain Dining information")
                        completion(nil, error)
                        return
                    }
                    //caching master data into userdefaults
                    if taxonomies?.count ?? 0 > 0{
                        self.preferencesMasterData.diningTimings = taxonomies
                        LujoSetup().store(preferencesMasterData: self.preferencesMasterData)
                    }
                    completion(taxonomies, error)
                }
           case .diningBeverages:
                GoLujoAPIManager().getDiningBeverages(token) { taxonomies, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not obtain Dining information")
                        completion(nil, error)
                        return
                    }
                    //caching master data into userdefaults
                    if taxonomies?.count ?? 0 > 0{
                        self.preferencesMasterData.beverages = taxonomies
                        LujoSetup().store(preferencesMasterData: self.preferencesMasterData)
                    }
                    completion(taxonomies, error)
                }
           case .diningSeatings:
                GoLujoAPIManager().getDiningSeatings(token) { taxonomies, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not obtain Dining information")
                        completion(nil, error)
                        return
                    }
                    //caching master data into userdefaults
                    if taxonomies?.count ?? 0 > 0{
                        self.preferencesMasterData.diningSeatings = taxonomies
                        LujoSetup().store(preferencesMasterData: self.preferencesMasterData)
                    }
                    completion(taxonomies, error)
                }
           default:
               print("default of dining")
           }
        case .events:
            switch prefInformationType {
            case .eventCategory:
                GoLujoAPIManager().getEventCategory() { taxonomies, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not obtain event category information")
                        completion(nil, error)
                        return
                    }
                    //caching master data into userdefaults
                    if taxonomies?.count ?? 0 > 0{
                        self.preferencesMasterData.eventCategory = taxonomies
                        LujoSetup().store(preferencesMasterData: self.preferencesMasterData)
                    }
                    completion(taxonomies, error)
                }
            case .eventLocation:
                GoLujoAPIManager().getEventLocation() { taxonomies, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not obtain event location information")
                        completion(nil, error)
                        return
                    }
                    //caching master data into userdefaults
                    if taxonomies?.count ?? 0 > 0{
                        self.preferencesMasterData.eventLocation = taxonomies
                        LujoSetup().store(preferencesMasterData: self.preferencesMasterData)
                    }
                    completion(taxonomies, error)
                }
            default:
                print("default of event")
        }
        case .travel:
            switch prefInformationType {
            case .travelAmenities:
                GoLujoAPIManager().getTravelAmenities(token) { taxonomies, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not obtain amenities information")
                        completion(nil, error)
                        return
                    }
                    //caching master data into userdefaults
                    if taxonomies?.count ?? 0 > 0{
                        self.preferencesMasterData.travelAmenities = taxonomies
                        LujoSetup().store(preferencesMasterData: self.preferencesMasterData)
                    }
                    completion(taxonomies, error)
                }
            case .travelMeals:
                //dining preferences and travel meals are same thing
                GoLujoAPIManager().getDiningPreferences(token) { taxonomies, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not obtain airline meals information")
                        completion(nil, error)
                        return
                    }
                    //caching master data into userdefaults
                    if taxonomies?.count ?? 0 > 0{
                        self.preferencesMasterData.diningPreferences = taxonomies
                        LujoSetup().store(preferencesMasterData: self.preferencesMasterData)
                    }
                    completion(taxonomies, error)
                }
            case .travelMedicalMeals:
                GoLujoAPIManager().getTravelMedicalMeals(token) { taxonomies, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not obtain airline medical meals information")
                        completion(nil, error)
                        return
                    }
                    //caching master data into userdefaults
                    if taxonomies?.count ?? 0 > 0{
                        self.preferencesMasterData.travelMedicalMeals = taxonomies
                        LujoSetup().store(preferencesMasterData: self.preferencesMasterData)
                    }
                    completion(taxonomies, error)
                }
            case .travelAllergies:
                //trave and dinnig
                GoLujoAPIManager().getDiningAllergies(token) { taxonomies, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not obtain airline allergies information")
                        completion(nil, error)
                        return
                    }
                    //caching master data into userdefaults
                    if taxonomies?.count ?? 0 > 0{
                        self.preferencesMasterData.travelAllergies = taxonomies
                        LujoSetup().store(preferencesMasterData: self.preferencesMasterData)
                    }
                    completion(taxonomies, error)
                }
            default:
                print("default of travel")
         }
        case .villas:
            switch self.prefInformationType {
                case .villaAmenities:
                    GoLujoAPIManager().getVillaAmenities(token) { taxonomies, error in
                        guard error == nil else {
                            Crashlytics.crashlytics().record(error: error!)
                            let error = BackendError.parsing(reason: "Could not obtain villa amenities information")
                            completion(nil, error)
                            return
                        }
                        //caching master data into userdefaults
                        if taxonomies?.count ?? 0 > 0{
                            self.preferencesMasterData.villaAmenities = taxonomies
                            LujoSetup().store(preferencesMasterData: self.preferencesMasterData)
                        }
                        completion(taxonomies, error)
                    }
                case .villaAccomodation:
                    GoLujoAPIManager().getVillaAccomodation(token) { taxonomies, error in
                        guard error == nil else {
                            Crashlytics.crashlytics().record(error: error!)
                            let error = BackendError.parsing(reason: "Could not obtain villa accomodation information")
                            completion(nil, error)
                            return
                        }
                        //caching master data into userdefaults
                        if taxonomies?.count ?? 0 > 0{
                            self.preferencesMasterData.villaAccomodation = taxonomies
                            LujoSetup().store(preferencesMasterData: self.preferencesMasterData)
                        }
                        completion(taxonomies, error)
                    }
                default:
                    print("Not yet required")
            }
        default:
            print("Others")
        }
    }
    
    //when user will click on the next button at the bottom
    @IBAction func btnNextTapped(_ sender: Any) {
        if (isSelectionChanged()){
            let valueSpecified:Int? = Int(txtPleaseSpecify.text ?? "") // firstText is UITextField
//            print(valueSpecified as Any)
            if (valueSpecified != nil) { //!= nill mean value has been typecasted hence its a numeric value
                // number is not allowed but alphanumeric
                let error = PreferenceError.onlyAlphaNumeric(reason: "Please specify a valid value")
                self.showError(error)
                return
            }
            
            var selectedArray = [String]()
            
            switch self.prefType {
                case .gifts:
                    switch self.prefInformationType {
                    case .giftHabbits:
                        if let ids = userPreferences?.gift.gift_habit_id{
                            for id in ids {
                                if id.count > 0{ //to avoid empty string
                                    selectedArray.append(id)
                                }
                            }
                        }
                    case .giftCategories:
                        if let ids = userPreferences?.gift.gift_category_id{
                            for id in ids {
                                if id.count > 0{ //to avoid empty string
                                    selectedArray.append(id)
                                }
                            }
                        }
                    case .giftPreferences:
                        if let ids = userPreferences?.gift.gift_preferences_id{
                            for id in ids {
                                if id.count > 0{ //to avoid empty string
                                    selectedArray.append(id)
                                }
                            }
                        }
                    default:
                        print("gifts default")
                    }
            case .aviation:
                switch self.prefInformationType {
                case .aviationHaveCharteredBefore:
                    if let str = userPreferences?.aviation.aviation_chartered_before {
                        selectedArray.append(str)
                    }
                case .aviationInterestedIn:
                    if let str = userPreferences?.aviation.aviation_interested_in{
                        selectedArray.append(str)
                    }
                case .aviationPreferredCharter:
                    if let str = userPreferences?.aviation.aviation_preferred_charter_range{
                        selectedArray.append(str)
                    }
                case .aviationPreferredCuisine:
                    if let ids = userPreferences?.aviation.aviation_preferred_cuisine_id{
                        for id in ids {
                            if id.count > 0{ //to avoid empty string
                                selectedArray.append(id)
                            }
                        }
                    }
                case .aviationPreferredBevereges:
                    if let ids = userPreferences?.aviation.aviation_preferred_beverage_id{
                        for id in ids {
                            if id.count > 0{ //to avoid empty string
                                selectedArray.append(id)
                            }
                        }
                    }
                default:
                    print("aviation default")
                }
            case .yachts:
                switch self.prefInformationType {
                case .yachtHaveCharteredBefore:
                    if let str = userPreferences?.yacht.yacht_chartered_before {
                        selectedArray.append(str)
                    }
                case .yachtInterestedIn:
                    if let str = userPreferences?.yacht.yacht_interested_in{
                        selectedArray.append(str)
                    }
                case .yachtType:
                    if let str = userPreferences?.yacht.yacht_type{
                        selectedArray.append(str)
                    }
                case .yachtStyle:
                    if let str = userPreferences?.yacht.yacht_style{
                        selectedArray.append(str)
                    }
                case .yachtPreferredCuisines:
                    if let ids = userPreferences?.yacht.yacht_preferred_cuisine_id{
                        for id in ids {
                            if id.count > 0{ //to avoid empty string
                                selectedArray.append(id)
                            }
                        }
                    }
                case .yachtOtherInterests:
                    if let ids = userPreferences?.yacht.yacht_interests_id{
                        for id in ids {
                            if id.count > 0{ //to avoid empty string
                                selectedArray.append(id)
                            }
                        }
                    }
                default:
                    print("yacht default")
                }
            case .dining:
               switch prefInformationType {
               case .diningCuisines:
                    if let ids = userPreferences?.restaurant.restaurant_preferred_cuisine_id{
                        for id in ids {
                            if id.count > 0{ //to avoid empty string
                                selectedArray.append(id)
                            }
                        }
                    }
               case .diningAllergies:
                    if let ids = userPreferences?.restaurant.restaurant_allergy_id{
                        for id in ids {
                            if id.count > 0{ //to avoid empty string
                                selectedArray.append(id)
                            }
                        }
                    }
                   
               case .diningPreferences:
                    if let ids = userPreferences?.restaurant.restaurant_dinning_id{
                        for id in ids {
                            if id.count > 0{ //to avoid empty string
                                selectedArray.append(id)
                            }
                        }
                    }
                   
               case .diningTimings:
                    if let ids = userPreferences?.restaurant.restaurant_timing_id{
                        for id in ids {
                            if id.count > 0{ //to avoid empty string
                                selectedArray.append(id)
                            }
                        }
                    }
                   
               case .diningBeverages:
                    if let ids = userPreferences?.restaurant.restaurant_beverage_id{
                        for id in ids {
                            if id.count > 0{ //to avoid empty string
                                selectedArray.append(id)
                            }
                        }
                    }
                   
               case .diningSeatings:
                    if let ids = userPreferences?.restaurant.restaurant_seating_id{
                        for id in ids {
                            if id.count > 0{ //to avoid empty string
                                selectedArray.append(id)
                            }
                        }
                    }
               
               default:
                   print("default of dining")
               }
            case .events:
                switch prefInformationType {
                case .eventCategory:
                    if let ids = userPreferences?.event.event_category_id{
                        for id in ids {
                            if id.count > 0{ //to avoid empty string
                                selectedArray.append(id)
                            }
                        }
                    }
                case .eventLocation:
                    if let ids = userPreferences?.event.event_location_id{
                        for id in ids {
                            if id.count > 0{ //to avoid empty string
                                selectedArray.append(id)
                            }
                        }
                    }

                default:
                    print("default of event")
            }
            case .travel:
                switch prefInformationType {
                case .travelAmenities:
                    if let ids = userPreferences?.travel.travel_amenity_id{
                        for id in ids {
                            if id.count > 0{ //to avoid empty string
                                selectedArray.append(id)
                            }
                        }
                    }
                case .travelAirplaneSeat:
                    if let ids = userPreferences?.travel.travel_airplane_seat{
                        for id in ids {
                            if id.count > 0{ //to avoid empty string
                                selectedArray.append(id)
                            }
                        }
                    }
                case .travelMeals:
                    if let ids = userPreferences?.travel.travel_airplane_meals{
                        for id in ids {
                            if id.count > 0{ //to avoid empty string
                                selectedArray.append(id)
                            }
                        }
                    }
                case .travelMedicalMeals:
                    if let ids = userPreferences?.travel.travel_medical_dietary_meal{
                        for id in ids {
                            if id.count > 0{ //to avoid empty string
                                selectedArray.append(id)
                            }
                        }
                    }
                case .travelAllergies:
                    if let ids = userPreferences?.travel.travel_allergy_id{
                        for id in ids {
                            if id.count > 0{ //to avoid empty string
                                selectedArray.append(id)
                            }
                        }
                    }
                default:
                    print("default of travel")
             }
            case .villas:
                switch self.prefInformationType {
                    case .villaAmenities:
                        if let ids = userPreferences?.villa.villa_preferred_amenities_id{
                            for id in ids {
                                if id.count > 0{ //to avoid empty string
                                    selectedArray.append(id)
                                }
                            }
                        }
                    case .villaAccomodation:
                        if let ids = userPreferences?.villa.villa_preferred_accommodations_id{
                            for id in ids {
                                if id.count > 0{ //to avoid empty string
                                    selectedArray.append(id)
                                }
                            }
                        }
                    default:
                        print("Not yet required")
                }
            default:
                print("Default of main switch")
            }
            if (selectedArray.count > 0 || txtPleaseSpecify.text?.count ?? 0 > 0) {   //something is there, so convert array to comma sepeated string
                let commaSeparatedString = selectedArray.map{String($0)}.joined(separator: ",")
                Mixpanel.mainInstance().track(event: "preferences_submitted",
                                              properties: ["Submitting" : prefInformationType.rawValue
                                                           ,"Values" : commaSeparatedString])
                setPreferences(commaSeparatedString: commaSeparatedString)
            }
            else{
                print("This line must not execute")
            }
        }else{
            Mixpanel.mainInstance().track(event: "preferences_skip_clicked",
                                          properties: ["SkippingFrom" : prefInformationType.rawValue])
            navigateToNextVC()
        }
    }
    
    func setPreferences(commaSeparatedString:String) {
        
        self.showNetworkActivity()
        setPreferencesInformation(commaSeparatedString: commaSeparatedString) {information, error in
            self.hideNetworkActivity()
            if let error = error {
                self.showError(error)
                return
            }
            if let informations = information {
                if var userPreferences = self.userPreferences{
                    let arr = commaSeparatedString.components(separatedBy: ",")
                    switch self.prefType {
                    case .gifts:
                        switch self.prefInformationType {
                        case .giftHabbits:
                            if arr.count > 0 && arr[0].count > 0{   //avoid empty string
                                userPreferences.gift.gift_habit_id = arr
                            }
                            LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                        case .giftCategories:
                            if arr.count > 0 && arr[0].count > 0{   //avoid empty string
                                userPreferences.gift.gift_category_id = arr
                            }
                            LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                        case .giftPreferences:
                            if arr.count > 0 && arr[0].count > 0{   //avoid empty string
                                userPreferences.gift.gift_preferences_id = arr
                            }
                            LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                        default:
                            print("gifts default")
                        }
                    case .aviation:
                        switch self.prefInformationType {
                        case .aviationHaveCharteredBefore:
                            if arr.count > 0 && arr[0].count > 0{   //avoid empty string
                                userPreferences.aviation.aviation_chartered_before = arr[0]
                                LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                            }
                        case .aviationInterestedIn:
                            if arr.count > 0 && arr[0].count > 0{   //avoid empty string
                                userPreferences.aviation.aviation_interested_in = arr[0]
                                LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                            }
                            
                        case .aviationPreferredCharter:
                            if arr.count > 0 && arr[0].count > 0{   //avoid empty string
                                userPreferences.aviation.aviation_preferred_charter_range = arr[0]
                                LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                            }
                            
                        case .aviationPreferredCuisine:
                            if arr.count > 0 && arr[0].count > 0{   //avoid empty string
                                userPreferences.aviation.aviation_preferred_cuisine_id = arr
                            }
                            LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                        case .aviationPreferredBevereges:
                            if arr.count > 0 && arr[0].count > 0{   //avoid empty string
                                userPreferences.aviation.aviation_preferred_beverage_id = arr
                            }
                            LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                        default:
                            print("aviation default")
                        }
                    case .yachts:
                        switch self.prefInformationType {
                        case .yachtHaveCharteredBefore:
                            if arr.count > 0 && arr[0].count > 0{   //avoid empty string
                                userPreferences.yacht.yacht_chartered_before = arr[0]
                                LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                            }
                        case .yachtInterestedIn:
                            if arr.count > 0 && arr[0].count > 0{   //avoid empty string
                                userPreferences.yacht.yacht_interested_in = arr[0]
                                LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                            }
                        case .yachtType:
                            if arr.count > 0 && arr[0].count > 0{   //avoid empty string
                                userPreferences.yacht.yacht_type = arr[0]
                                LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                            }
                        case .yachtStyle:
                            if arr.count > 0 && arr[0].count > 0{   //avoid empty string
                                userPreferences.yacht.yacht_style = arr[0]
                                LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                            }
                        case .yachtPreferredCuisines:
                            if arr.count > 0 && arr[0].count > 0{   //avoid empty string
                                userPreferences.yacht.yacht_preferred_cuisine_id = arr
                            }
                            userPreferences.yacht.yacht_preferred_cuisine_id_other = self.txtPleaseSpecify.text
                            LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                        case .yachtOtherInterests:
                            if arr.count > 0 && arr[0].count > 0{   //avoid empty string
                                userPreferences.yacht.yacht_interests_id = arr
                            }
                            LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                        default:
                            print("yacht default")
                        }
                    case .dining:
                        switch self.prefInformationType {
                        case .diningCuisines:
                            if arr.count > 0 && arr[0].count > 0{   //avoid empty string
                                userPreferences.restaurant.restaurant_preferred_cuisine_id = arr
                            }
                            userPreferences.restaurant.restaurant_preferred_cuisine_id_other = self.txtPleaseSpecify.text
                            LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                        case .diningAllergies:
                            if arr.count > 0 && arr[0].count > 0{   //avoid empty string
                                userPreferences.restaurant.restaurant_allergy_id = arr
                            }
                            LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                        case .diningPreferences:
                            if arr.count > 0 && arr[0].count > 0{   //avoid empty string
                                userPreferences.restaurant.restaurant_dinning_id = arr
                            }
                            userPreferences.restaurant.restaurant_dinning_id_other = self.txtPleaseSpecify.text
                            LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                        case .diningTimings:
                            if arr.count > 0 && arr[0].count > 0{   //avoid empty string
                                userPreferences.restaurant.restaurant_timing_id = arr
                            }
                            LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                        case .diningBeverages:
                            if arr.count > 0 && arr[0].count > 0{   //avoid empty string
                                userPreferences.restaurant.restaurant_beverage_id = arr
                            }
                            userPreferences.restaurant.restaurant_beverage_id_other = self.txtPleaseSpecify.text
                            LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                            break
                        case .diningSeatings:
                            if arr.count > 0 && arr[0].count > 0{   //avoid empty string
                                userPreferences.restaurant.restaurant_seating_id = arr
                            }
                            LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                        
                        default:
                            print("default of dining")
                        }
                    case .events:
                        switch self.prefInformationType {
                        case .eventCategory:
                            if arr.count > 0 && arr[0].count > 0{   //avoid empty string
                                userPreferences.event.event_category_id = arr
                            }
                            userPreferences.event.event_category_id_other = self.txtPleaseSpecify.text
                            LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                        case .eventLocation:
                            if arr.count > 0 && arr[0].count > 0{   //avoid empty string
                                userPreferences.event.event_location_id = arr
                            }
                            LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults

                        default:
                            print("default of event")
                    }
                    case .travel:
                        switch self.prefInformationType {
                        case .travelAmenities:
                            if arr.count > 0 && arr[0].count > 0{   //avoid empty string
                                userPreferences.travel.travel_amenity_id = arr
                            }
                            userPreferences.travel.travel_amenity_id_other = self.txtPleaseSpecify.text
                            LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                        case .travelAirplaneSeat:
                            if arr.count > 0 && arr[0].count > 0{   //avoid empty string
                                userPreferences.travel.travel_airplane_seat = arr
                                LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                            }
                        case .travelMeals:
                            if arr.count > 0 && arr[0].count > 0{   //avoid empty string
                                userPreferences.travel.travel_airplane_meals = arr
                            }
                            LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                        case .travelMedicalMeals:
                            if arr.count > 0 && arr[0].count > 0{   //avoid empty string
                                userPreferences.travel.travel_medical_dietary_meal = arr
                            }
                            userPreferences.travel.travel_medical_dietary_meal_other = self.txtPleaseSpecify.text
                            LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                        case .travelAllergies:
                            if arr.count > 0 && arr[0].count > 0{   //avoid empty string
                                userPreferences.travel.travel_allergy_id = arr
                            }
                            userPreferences.travel.travel_allergy_id_other = self.txtPleaseSpecify.text
                            LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                        default:
                            print("default of travel")
                     }
                    case .villas:
                        switch self.prefInformationType {
                            case .villaAmenities:
                                if arr.count > 0 && arr[0].count > 0{   //avoid empty string
                                    userPreferences.villa.villa_preferred_amenities_id = arr
                                }
                                userPreferences.villa.villa_preferred_amenities_id_other = self.txtPleaseSpecify.text
                                LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                            case .villaAccomodation:
                                if arr.count > 0 && arr[0].count > 0{   //avoid empty string
                                    userPreferences.villa.villa_preferred_accommodations_id = arr
                                }
                                userPreferences.villa.villa_preferred_accommodations_id_other = self.txtPleaseSpecify.text
                                LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                            default:
                                print("Not yet required")
                        }
                    default:
                        print("Default of main switch")
                    }
                }
                self.navigateToNextVC()
            } else {
                let error = BackendError.parsing(reason: "Could not set the Preferences")
                self.showError(error)
            }
        }
    }
    

    func setPreferencesInformation(commaSeparatedString:String, completion: @escaping (String?, Error?) -> Void) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            completion(nil, LoginError.errorLogin(description: "User does not exist or is not verified"))
            return
        }
        
        switch prefType {
            case .gifts:
                switch prefInformationType {
                case .giftHabbits:
                    GoLujoAPIManager().setGiftHabbits( commaSeparatedString: commaSeparatedString) { contentString, error in
                        guard error == nil else {
                            Crashlytics.crashlytics().record(error: error!)
                            let error = BackendError.parsing(reason: "Could not set the gift habbits preferences")
                            completion(nil, error)
                            return
                        }
                        completion(contentString, error)
                    }
                case .giftCategories:
                    GoLujoAPIManager().setGiftCategories(commaSeparatedString: commaSeparatedString) { contentString, error in
                        guard error == nil else {
                            Crashlytics.crashlytics().record(error: error!)
                            let error = BackendError.parsing(reason: "Could not set the gift categories preferences")
                            completion(nil, error)
                            return
                        }
                        completion(contentString, error)
                    }
                case .giftPreferences:
                    GoLujoAPIManager().setGiftPreferences(commaSeparatedString: commaSeparatedString) { contentString, error in
                        guard error == nil else {
                            Crashlytics.crashlytics().record(error: error!)
                            let error = BackendError.parsing(reason: "Could not set the gift preferences")
                            completion(nil, error)
                            return
                        }
                        completion(contentString, error)
                    }
                default:
                    print("nothing")
                    
            }
        case .aviation:
            switch prefInformationType {
                case .aviationHaveCharteredBefore:
                    GoLujoAPIManager().setAviationHaveCharteredBefore(token: token,commaSeparatedString: commaSeparatedString) { contentString, error in
                        guard error == nil else {
                            Crashlytics.crashlytics().record(error: error!)
                            let error = BackendError.parsing(reason: "Could not set the aviation charter preferences")
                            completion(nil, error)
                            return
                        }
                        completion(contentString, error)
                    }
                case .aviationInterestedIn:
                    GoLujoAPIManager().setAviationInterestedIn(token: token,commaSeparatedString: commaSeparatedString) { contentString, error in
                        guard error == nil else {
                            Crashlytics.crashlytics().record(error: error!)
                            let error = BackendError.parsing(reason: "Could not set the aviation interest preferences")
                            completion(nil, error)
                            return
                        }
                        completion(contentString, error)
                    }
                case .aviationPreferredCharter:
                    GoLujoAPIManager().setAviationPreferredCharter(token: token,commaSeparatedString: commaSeparatedString) { contentString, error in
                        guard error == nil else {
                            Crashlytics.crashlytics().record(error: error!)
                            let error = BackendError.parsing(reason: "Could not set the aviation preferred charter preferences")
                            completion(nil, error)
                            return
                        }
                        completion(contentString, error)
                    }
                case .aviationPreferredCuisine:
                    GoLujoAPIManager().setAviationPreferredCuisines(token: token,commaSeparatedString: commaSeparatedString, typedPreference: txtPleaseSpecify.text ?? "") { contentString, error in
                        guard error == nil else {
                            Crashlytics.crashlytics().record(error: error!)
                            let error = BackendError.parsing(reason: "Could not set the aviation cuisine preferences")
                            completion(nil, error)
                            return
                        }
                        completion(contentString, error)
                    }

                case .aviationPreferredBevereges:
                    GoLujoAPIManager().setAviationPreferredBeverages(token: token,commaSeparatedString: commaSeparatedString, typedPreference: txtPleaseSpecify.text ?? "") { contentString, error in
                        guard error == nil else {
                            Crashlytics.crashlytics().record(error: error!)
                            let error = BackendError.parsing(reason: "Could not set the aviation bevereges preferences")
                            completion(nil, error)
                            return
                        }
                        completion(contentString, error)
                    }
                default:
                    print("Not yet required")
                    completion("Success", nil)
            }
        case .yachts:
            switch prefInformationType {
                case .yachtHaveCharteredBefore:
                    GoLujoAPIManager().setYachtHaveCharteredBefore(token: token,commaSeparatedString: commaSeparatedString) { contentString, error in
                        guard error == nil else {
                            Crashlytics.crashlytics().record(error: error!)
                            let error = BackendError.parsing(reason: "Could not set the yacht charter before information")
                            completion(nil, error)
                            return
                        }
                        completion(contentString, error)
                    }
                case .yachtInterestedIn:
                    GoLujoAPIManager().setYachtInterestedIn(token: token,commaSeparatedString: commaSeparatedString) { contentString, error in
                        guard error == nil else {
                            Crashlytics.crashlytics().record(error: error!)
                            let error = BackendError.parsing(reason: "Could not set the yacht interest information")
                            completion(nil, error)
                            return
                        }
                        completion(contentString, error)
                    }
                case .yachtType:
                    GoLujoAPIManager().setYachtType(token: token,commaSeparatedString: commaSeparatedString) { contentString, error in
                        guard error == nil else {
                            Crashlytics.crashlytics().record(error: error!)
                            let error = BackendError.parsing(reason: "Could not set the yacht type preferences")
                            completion(nil, error)
                            return
                        }
                        completion(contentString, error)
                    }
                case .yachtStyle:
                    GoLujoAPIManager().setYachtStyle(token: token,commaSeparatedString: commaSeparatedString) { contentString, error in
                        guard error == nil else {
                            Crashlytics.crashlytics().record(error: error!)
                            let error = BackendError.parsing(reason: "Could not set the yacht style preferences")
                            completion(nil, error)
                            return
                        }
                        completion(contentString, error)
                    }
                case .yachtPreferredCuisines:
                    GoLujoAPIManager().setYachtPreferredCuisines(token: token,commaSeparatedString: commaSeparatedString, typedPreference: txtPleaseSpecify.text ?? "") { contentString, error in
                        guard error == nil else {
                            Crashlytics.crashlytics().record(error: error!)
                            let error = BackendError.parsing(reason: "Could not set the preferred yacht cuisines")
                            completion(nil, error)
                            return
                        }
                        completion(contentString, error)
                    }

                case .yachtOtherInterests:
                    GoLujoAPIManager().setYachtOtherInterests(token: token,commaSeparatedString: commaSeparatedString) { contentString, error in
                        guard error == nil else {
                            Crashlytics.crashlytics().record(error: error!)
                            let error = BackendError.parsing(reason: "Could not set the yacht others interest information")
                            completion(nil, error)
                            return
                        }
                        completion(contentString, error)
                    }
                default:
                    print("Not yet required")
                    completion("Success", nil)
            }
        case .dining:
            switch prefInformationType {
            case .diningCuisines:
                GoLujoAPIManager().setDiningCuisines(token: token,commaSeparatedString: commaSeparatedString, typedPreference: txtPleaseSpecify.text ?? "") { contentString, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not set the dining cuisines preferences")
                        completion(nil, error)
                        return
                    }
                    completion(contentString, error)
                }
            case .diningAllergies:
                GoLujoAPIManager().setDiningAllergies(token: token,commaSeparatedString: commaSeparatedString) { contentString, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not set the dining allergies preferences")
                        completion(nil, error)
                        return
                    }
                    completion(contentString, error)
                }
            case .diningPreferences:
                GoLujoAPIManager().setDiningPreferences(token: token,commaSeparatedString: commaSeparatedString, typedPreference: txtPleaseSpecify.text ?? "") { contentString, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not set the dining preferences")
                        completion(nil, error)
                        return
                    }
                    completion(contentString, error)
                }
            case .diningTimings:
                GoLujoAPIManager().setDiningTimings(token: token,commaSeparatedString: commaSeparatedString) { contentString, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not set the dining timing preferences")
                        completion(nil, error)
                        return
                    }
                    completion(contentString, error)
                }
            case .diningBeverages:
                GoLujoAPIManager().setDiningBeverages(token: token,commaSeparatedString: commaSeparatedString, typedPreference: txtPleaseSpecify.text ?? "") { contentString, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not set the dining bevereges preferences")
                        completion(nil, error)
                        return
                    }
                    completion(contentString, error)
                }
            case .diningSeatings:
                GoLujoAPIManager().setDiningSeatings(token: token,commaSeparatedString: commaSeparatedString) { contentString, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not set the dining seating preferences")
                        completion(nil, error)
                        return
                    }
                    completion(contentString, error)
                }
            
            default:
                print("default of dining")
            }
        case .events:
            switch prefInformationType {
            case .eventCategory:
                GoLujoAPIManager().setEventCategory(commaSeparatedString: commaSeparatedString) { contentString, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not set the event categories preferences")
                        completion(nil, error)
                        return
                    }
                    completion(contentString, error)
                }
            case .eventLocation:
                GoLujoAPIManager().setEventLocation(commaSeparatedString: commaSeparatedString) { contentString, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not set the event locations preferences")
                        completion(nil, error)
                        return
                    }
                    completion(contentString, error)
                }

            default:
                print("default of event")
        }
        case .travel:
            switch prefInformationType {
            case .travelAmenities:
                GoLujoAPIManager().setTravelAmenities(token: token,commaSeparatedString: commaSeparatedString, typedPreference: txtPleaseSpecify.text ?? "") { contentString, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not set the travel/hotel amenities preferences")
                        completion(nil, error)
                        return
                    }
                    completion(contentString, error)
                }
            case .travelAirplaneSeat:
                GoLujoAPIManager().setTravelAirplaneSeat(token: token, airplaneSeat: commaSeparatedString) { (contentString, error) in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not set the airplan seating preferences")
                        completion(nil, error)
                        return
                    }
                    completion(contentString, error)
                }
            case .travelMeals:
                GoLujoAPIManager().setTravelMeals(token: token, commaSeparatedString: commaSeparatedString) { (contentString, error) in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not set the travel meals preferences")
                        completion(nil, error)
                        return
                    }
                    completion(contentString, error)
                }
            case .travelMedicalMeals:
                GoLujoAPIManager().setTravelMedicalMeals(token: token, commaSeparatedString: commaSeparatedString, typedPreference: txtPleaseSpecify.text ?? "") { (contentString, error) in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not set the travel medical meal preferences")
                        completion(nil, error)
                        return
                    }
                    completion(contentString, error)
                }
            case .travelAllergies:
                GoLujoAPIManager().setTravelAllergies(token: token, commaSeparatedString: commaSeparatedString, typedPreference: txtPleaseSpecify.text ?? "") { (contentString, error) in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not set the travel allergies preferences")
                        completion(nil, error)
                        return
                    }
                    completion(contentString, error)
                }
            default:
                print("default of travel")
         }
        case .villas:
            switch self.prefInformationType {
                case .villaAmenities:
                    GoLujoAPIManager().setVillaAmenities(token: token, commaSeparatedString: commaSeparatedString, typedPreference: txtPleaseSpecify.text ?? "") { (contentString, error) in
                        guard error == nil else {
                            Crashlytics.crashlytics().record(error: error!)
                            let error = BackendError.parsing(reason: "Could not set the villa amenities preferences")
                            completion(nil, error)
                            return
                        }
                        completion(contentString, error)
                    }
                case .villaAccomodation:
                    GoLujoAPIManager().setVillaAccomodation(token: token, commaSeparatedString: commaSeparatedString, typedPreference: txtPleaseSpecify.text ?? "") { (contentString, error) in
                        guard error == nil else {
                            Crashlytics.crashlytics().record(error: error!)
                            let error = BackendError.parsing(reason: "Could not set the villa accomodation preferences")
                            completion(nil, error)
                            return
                        }
                        completion(contentString, error)
                    }
                default:
                    print("Not yet required")
            }
        default:
            print("Main switch default ")
        }
    }
    
    func navigateToNextVC(){
        switch self.prefType {
        case .gifts:
            switch self.prefInformationType {
                case .giftHabbits:
                    let viewController = PrefCollectionsViewController.instantiate(prefType: .gifts, prefInformationType: .giftCategories)
                    self.navigationController?.pushViewController(viewController, animated: true)
                case .giftCategories:
                    let viewController = PrefCollectionsViewController.instantiate(prefType: .gifts, prefInformationType: .giftPreferences)
                    self.navigationController?.pushViewController(viewController, animated: true)
                default:
                    self.skipTapped()
            }
        case .aviation:
            switch self.prefInformationType {
            case .aviationHaveCharteredBefore:
                let viewController = PrefCollectionsViewController.instantiate(prefType: .aviation, prefInformationType: .aviationInterestedIn)
                self.navigationController?.pushViewController(viewController, animated: true)
            case .aviationInterestedIn:
                let viewController = TwoSliderPrefViewController.instantiate(prefType: .aviation, prefInformationType: .aviationCharterFrequency)
                self.navigationController?.pushViewController(viewController, animated: true)
            case .aviationPreferredCharter:
                let viewController = PrefCollectionsViewController.instantiate(prefType: .aviation, prefInformationType: .aviationPreferredCuisine)
                self.navigationController?.pushViewController(viewController, animated: true)
            case .aviationPreferredCuisine:
                let viewController = PrefCollectionsViewController.instantiate(prefType: .aviation, prefInformationType: .aviationPreferredBevereges)
                self.navigationController?.pushViewController(viewController, animated: true)
            default:
                self.skipTapped()   //skip even for aviationPreferredBevereges
            }
        case .yachts:
            switch self.prefInformationType {
            case .yachtHaveCharteredBefore:
                let viewController = PrefCollectionsViewController.instantiate(prefType: .yachts, prefInformationType: .yachtInterestedIn)
                self.navigationController?.pushViewController(viewController, animated: true)
            case .yachtInterestedIn:
                let viewController = TwoSliderPrefViewController.instantiate(prefType: .yachts, prefInformationType: .yachtCharterFrequency)
                self.navigationController?.pushViewController(viewController, animated: true)
            case .yachtType:
                let viewController = PrefCollectionsViewController.instantiate(prefType: .yachts, prefInformationType: .yachtStyle)
                self.navigationController?.pushViewController(viewController, animated: true)
            case .yachtStyle:
                let viewController = PrefCollectionsViewController.instantiate(prefType: .yachts, prefInformationType: .yachtPreferredCuisines)
                self.navigationController?.pushViewController(viewController, animated: true)
            case .yachtPreferredCuisines:
                let viewController = PrefCollectionsViewController.instantiate(prefType: .yachts, prefInformationType: .yachtOtherInterests)
                self.navigationController?.pushViewController(viewController, animated: true)
            case .yachtOtherInterests:
                self.skipTapped()
            default:
                self.skipTapped()   //skip even for yachtPreferredBevereges
            }
        case .dining:
           switch prefInformationType {
           case .diningCuisines:
                let viewController = PrefCollectionsViewController.instantiate(prefType: .dining, prefInformationType: .diningAllergies)
                    self.navigationController?.pushViewController(viewController, animated: true)
           case .diningAllergies:
                let viewController = PrefCollectionsViewController.instantiate(prefType: .dining, prefInformationType: .diningPreferences)
                self.navigationController?.pushViewController(viewController, animated: true)
           case .diningPreferences:
                let viewController = PrefCollectionsViewController.instantiate(prefType: .dining, prefInformationType: .diningTimings)
                self.navigationController?.pushViewController(viewController, animated: true)
           case .diningTimings:
                let viewController = PrefCollectionsViewController.instantiate(prefType: .dining, prefInformationType: .diningBeverages)
                self.navigationController?.pushViewController(viewController, animated: true)
           case .diningBeverages:
                let viewController = PrefCollectionsViewController.instantiate(prefType: .dining, prefInformationType: .diningSeatings)
                self.navigationController?.pushViewController(viewController, animated: true)
           case .diningSeatings:
                self.skipTapped()
           default:
               print("default of dining")
           }
        case .events:
            switch prefInformationType {
            case .eventCategory:
                let viewController = PrefCollectionsViewController.instantiate(prefType: .events, prefInformationType: .eventLocation)
                self.navigationController?.pushViewController(viewController, animated: true)
            case .eventLocation:
                self.skipTapped()

            default:
                print("default of event")
        }
        case .travel:
            switch prefInformationType {
            case .travelAmenities:
                let viewController = PrefImagesCollViewController.instantiate(prefType: .travel, prefInformationType: .travelActivities)
                self.navigationController?.pushViewController(viewController, animated: true)
            case .travelAirplaneSeat:
                let viewController = TwoSliderPrefViewController.instantiate(prefType: .travel, prefInformationType: .travelCabinClass)
                self.navigationController?.pushViewController(viewController, animated: true)
            case .travelMeals:
                let viewController = PrefCollectionsViewController.instantiate(prefType: .travel, prefInformationType: .travelMedicalMeals)
                self.navigationController?.pushViewController(viewController, animated: true)
            case .travelMedicalMeals:
                let viewController = PrefImagesCollViewController.instantiate(prefType: .travel, prefInformationType: .travelHotelStyles)
                self.navigationController?.pushViewController(viewController, animated: true)
            case .travelAllergies:
                self.skipTapped()
            default:
                print("default of travel")
         }
        case .villas:
            switch self.prefInformationType {
            case .villaAmenities:
                let viewController = PrefCollectionsViewController.instantiate(prefType: .villas, prefInformationType: .villaAccomodation)
                self.navigationController?.pushViewController(viewController, animated: true)
            case .villaAccomodation:
                self.skipTapped()
            default:
                print("Not yet required")
            }
        default:
            print("default of main switch")
        }
    }
    
    //this method checks the value which were at the time of loading of this screen and current seletion. if loading time value has been changed then button text get changed
    @objc func isSelectionChanged() -> Bool{
        switch self.prefType {
            case .gifts:
                switch self.prefInformationType {
                case .giftHabbits:
                    let current = self.userPreferences?.gift.gift_habit_id ?? []
                    let previous = self.previouslySelectedItems
                    return !compare(current: current , previous: previous, previousTypedStr:"")
                case .giftCategories:
                    let current = self.userPreferences?.gift.gift_category_id ?? []
                    let previous = self.previouslySelectedItems
                    return !compare(current: current , previous: previous, previousTypedStr:"")
                case .giftPreferences:
                    let current = self.userPreferences?.gift.gift_preferences_id ?? []
                    let previous = self.previouslySelectedItems
                    return !compare(current: current , previous: previous, previousTypedStr:"")
                default:
                    print("This line will never execute")
                    return true
                }
        case .aviation:
            switch self.prefInformationType {
            case .aviationHaveCharteredBefore:
                let current = self.userPreferences?.aviation.aviation_chartered_before ?? ""
                var previous = ""
                if (self.previouslySelectedItems.count > 0 && !self.previouslySelectedItems[0].isEmpty){
                    previous = self.previouslySelectedItems[0]
                }
                return !compare(current: current , previous: previous)
            case .aviationInterestedIn:
                let current = self.userPreferences?.aviation.aviation_interested_in ?? ""
                var previous = ""
                if (self.previouslySelectedItems.count > 0 && !self.previouslySelectedItems[0].isEmpty){
                    previous = self.previouslySelectedItems[0]
                }
                return !compare(current: current , previous: previous)
            case .aviationPreferredCharter:
                let current = self.userPreferences?.aviation.aviation_preferred_charter_range ?? ""
                var previous = ""
                if (self.previouslySelectedItems.count > 0 && !self.previouslySelectedItems[0].isEmpty){
                    previous = self.previouslySelectedItems[0]
                }
                return !compare(current: current , previous: previous)
            case .aviationPreferredCuisine:
                let current = self.userPreferences?.aviation.aviation_preferred_cuisine_id ?? []
                let previous = self.previouslySelectedItems
                return !compare(current: current , previous: previous, previousTypedStr:"")
            case .aviationPreferredBevereges:
                let current = self.userPreferences?.aviation.aviation_preferred_beverage_id ?? []
                let previous = self.previouslySelectedItems
                return !compare(current: current , previous: previous, previousTypedStr:"")
            default:
                print("This will not call")
            }
        case .yachts:
            switch self.prefInformationType {
            case .yachtHaveCharteredBefore:
                let current = self.userPreferences?.yacht.yacht_chartered_before ?? ""
                var previous = ""
                if (self.previouslySelectedItems.count > 0 && !self.previouslySelectedItems[0].isEmpty){
                    previous = self.previouslySelectedItems[0]
                }
                return !compare(current: current , previous: previous)
            case .yachtInterestedIn:
                let current = self.userPreferences?.yacht.yacht_interested_in ?? ""
                var previous = ""
                if (self.previouslySelectedItems.count > 0 && !self.previouslySelectedItems[0].isEmpty){
                    previous = self.previouslySelectedItems[0]
                }
                return !compare(current: current , previous: previous)
            case .yachtType:
                let current = self.userPreferences?.yacht.yacht_type ?? ""
                var previous = ""
                if (self.previouslySelectedItems.count > 0 && !self.previouslySelectedItems[0].isEmpty){
                    previous = self.previouslySelectedItems[0]
                }
                return !compare(current: current , previous: previous)
            case .yachtStyle:
                let current = self.userPreferences?.yacht.yacht_style ?? ""
                var previous = ""
                if (self.previouslySelectedItems.count > 0 && !self.previouslySelectedItems[0].isEmpty){
                    previous = self.previouslySelectedItems[0]
                }
                return !compare(current: current , previous: previous)
            case .yachtPreferredCuisines:
                let current = self.userPreferences?.yacht.yacht_preferred_cuisine_id ?? []
                let previous = self.previouslySelectedItems
                let previouslyTypedStr = self.userPreferences?.yacht.yacht_preferred_cuisine_id_other ?? ""
                return !compare(current: current , previous: previous, previousTypedStr:previouslyTypedStr)
            case .yachtOtherInterests:
                let current = self.userPreferences?.yacht.yacht_interests_id ?? []
                let previous = self.previouslySelectedItems
                return !compare(current: current , previous: previous)
            default:
                print("This will not call")
            }
        case .dining:
           switch prefInformationType {
           case .diningCuisines:
                let current = self.userPreferences?.restaurant.restaurant_preferred_cuisine_id ?? []
                let previous = self.previouslySelectedItems
                let previouslyTypedStr = self.userPreferences?.restaurant.restaurant_preferred_cuisine_id_other ?? ""
                return !compare(current: current , previous: previous, previousTypedStr:previouslyTypedStr)
           case .diningAllergies:
                let current = self.userPreferences?.restaurant.restaurant_allergy_id ?? []
                let previous = self.previouslySelectedItems
                return !compare(current: current , previous: previous)
           case .diningPreferences:
                let current = self.userPreferences?.restaurant.restaurant_dinning_id ?? []
                let previous = self.previouslySelectedItems
                let previouslyTypedStr = self.userPreferences?.restaurant.restaurant_dinning_id_other ?? ""
                return !compare(current: current , previous: previous, previousTypedStr:previouslyTypedStr)
           case .diningTimings:
                let current = self.userPreferences?.restaurant.restaurant_timing_id ?? []
                let previous = self.previouslySelectedItems
                return !compare(current: current , previous: previous)
           case .diningBeverages:
                let current = self.userPreferences?.restaurant.restaurant_beverage_id ?? []
                let previous = self.previouslySelectedItems
                let previouslyTypedStr = self.userPreferences?.restaurant.restaurant_beverage_id_other ?? ""
                return !compare(current: current , previous: previous, previousTypedStr:previouslyTypedStr)
           case .diningSeatings:
                let current = self.userPreferences?.restaurant.restaurant_seating_id ?? []
                let previous = self.previouslySelectedItems
                return !compare(current: current , previous: previous)
           default:
               print("default of dining")
           }
        case .events:
            switch prefInformationType {
            case .eventCategory:
                let current = self.userPreferences?.event.event_category_id ?? []
                let previous = self.previouslySelectedItems
                let previouslyTypedStr = self.userPreferences?.event.event_category_id_other ?? ""
                return !compare(current: current , previous: previous, previousTypedStr:previouslyTypedStr)
            case .eventLocation:
                let current = self.userPreferences?.event.event_location_id ?? []
                let previous = self.previouslySelectedItems
                return !compare(current: current , previous: previous)

            default:
                print("default of event")
        }
        case .travel:
            switch prefInformationType {
            case .travelAmenities:
                let current = self.userPreferences?.travel.travel_amenity_id ?? []
                let previous = self.previouslySelectedItems
                let previouslyTypedStr = self.userPreferences?.travel.travel_amenity_id_other ?? ""
                return !compare(current: current , previous: previous, previousTypedStr:previouslyTypedStr)
            case .travelAirplaneSeat:
                let current = self.userPreferences?.travel.travel_airplane_seat ?? []
                let previous = self.previouslySelectedItems
                return !compare(current: current , previous: previous)
            case .travelMeals:
                let current = self.userPreferences?.travel.travel_airplane_meals ?? []
                let previous = self.previouslySelectedItems
                return !compare(current: current , previous: previous)
            case .travelMedicalMeals:
                let current = self.userPreferences?.travel.travel_medical_dietary_meal ?? []
                let previous = self.previouslySelectedItems
                return !compare(current: current , previous: previous)
            case .travelAllergies:
                let current = self.userPreferences?.travel.travel_allergy_id ?? []
                let previous = self.previouslySelectedItems
                let previouslyTypedStr = self.userPreferences?.travel.travel_allergy_id_other ?? ""
                return !compare(current: current , previous: previous, previousTypedStr:previouslyTypedStr)
            default:
                print("default of travel")
         }
        case .villas:
            switch self.prefInformationType {
            case .villaAmenities:
                let current = self.userPreferences?.villa.villa_preferred_amenities_id ?? []
                let previous = self.previouslySelectedItems
                let previouslyTypedStr = self.userPreferences?.villa.villa_preferred_amenities_id_other ?? ""
                return !compare(current: current , previous: previous, previousTypedStr:previouslyTypedStr)
            case .villaAccomodation:
                let current = self.userPreferences?.villa.villa_preferred_accommodations_id ?? []
                let previous = self.previouslySelectedItems
                let previouslyTypedStr = self.userPreferences?.villa.villa_preferred_accommodations_id_other ?? ""
                return !compare(current: current , previous: previous, previousTypedStr:previouslyTypedStr)
            default:
                print("Not yet required")
            }
        default:
            print("default claus of main switch")
        }
        return true
    }
    
    func compare(current:String , previous:String) -> Bool{
        if previous == current{
//            btnNextStep.setTitle("S K I P", for: .normal)
            btnNextStep.setTitle("N E X T", for: .normal)
            return true
        }else{
            btnNextStep.setTitle("N E X T", for: .normal)
            return false
        }
    }
    
    func compare(current:[String] , previous:[String] , previousTypedStr:String? = nil) -> Bool{
        let currentTypedStr = self.txtPleaseSpecify.text
        if (Set(previous ) == Set(current) && (previousTypedStr ?? currentTypedStr == self.txtPleaseSpecify.text)){
//            btnNextStep.setTitle("S K I P", for: .normal)
            btnNextStep.setTitle("N E X T", for: .normal)
            return true
        }else{
            btnNextStep.setTitle("N E X T", for: .normal)
            return false
        }
    }
    
    @objc func skipTapped(){
        Mixpanel.mainInstance().track(event: "preferences_skip_all_clicked",
                                      properties: ["SkippingFrom" : prefInformationType.rawValue])
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
    
    private func applyConstraints() {
        collectionView.leadingAnchor.constraint(equalTo: self.collContainerView.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.collContainerView.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: self.collContainerView.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.collContainerView.bottomAnchor).isActive = true
//        self.collContainerView.heightAnchor.constraint(equalTo: collectionView.heightAnchor).isActive = true
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
}

extension PrefCollectionsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PrefCollViewCell.identifier, for: indexPath) as! PrefCollViewCell
        let model = itemsList[indexPath.row]
        cell.lblTitle.text = model.name
        
        switch self.prefType {
            case .gifts:
                switch self.prefInformationType {
                case .giftHabbits:
                    if let ids = userPreferences?.gift.gift_habit_id{
                        if (ids.contains(String(model.termId))){
                            cell.containerView.backgroundColor = UIColor.rgMid
                            cell.lblTitle.textColor = UIColor.white
                        }else{
                            cell.containerView.backgroundColor = UIColor.clear
                            cell.lblTitle.textColor = UIColor.rgMid
                        }
                    }
                case .giftCategories:
                    if let ids = userPreferences?.gift.gift_category_id{
                        if (ids.contains(String(model.termId))){
                            cell.containerView.backgroundColor = UIColor.rgMid
                            cell.lblTitle.textColor = UIColor.white
                        }else{
                            cell.containerView.backgroundColor = UIColor.clear
                            cell.lblTitle.textColor = UIColor.rgMid
                        }
                    }
                case .giftPreferences:
                    if let ids = userPreferences?.gift.gift_preferences_id{
                        if (ids.contains(String(model.termId))){
                            cell.containerView.backgroundColor = UIColor.rgMid
                            cell.lblTitle.textColor = UIColor.white
                        }else{
                            cell.containerView.backgroundColor = UIColor.clear
                            cell.lblTitle.textColor = UIColor.rgMid
                        }
                    }
                default:
                    print("gifts default")
                }
        case .aviation:
            switch self.prefInformationType {
            case .aviationHaveCharteredBefore:
                if let str = userPreferences?.aviation.aviation_chartered_before{
                    if(str.contains(model.name.lowercased()) ){
                        cell.containerView.backgroundColor = UIColor.rgMid
                        cell.lblTitle.textColor = UIColor.white
                    }else{
                        cell.containerView.backgroundColor = UIColor.clear
                        cell.lblTitle.textColor = UIColor.rgMid
                    }
                }
            case .aviationInterestedIn:
                if let str = userPreferences?.aviation.aviation_interested_in{
                    if(str.contains(model.name.lowercased()) ){
                        cell.containerView.backgroundColor = UIColor.rgMid
                        cell.lblTitle.textColor = UIColor.white
                    }else{
                        cell.containerView.backgroundColor = UIColor.clear
                        cell.lblTitle.textColor = UIColor.rgMid
                    }
                }
            case .aviationPreferredCharter:
                if let str = userPreferences?.aviation.aviation_preferred_charter_range{
                    if(model.name.lowercased().contains(str) ){ //model name is longer in length then the str i.e. Long Range and long respectively
                        cell.containerView.backgroundColor = UIColor.rgMid
                        cell.lblTitle.textColor = UIColor.white
                    }else{
                        cell.containerView.backgroundColor = UIColor.clear
                        cell.lblTitle.textColor = UIColor.rgMid
                    }
                }
            case .aviationPreferredCuisine:
                if let ids = userPreferences?.aviation.aviation_preferred_cuisine_id{
                    if (ids.contains(String(model.termId))){
                        cell.containerView.backgroundColor = UIColor.rgMid
                        cell.lblTitle.textColor = UIColor.white
                    }else{
                        cell.containerView.backgroundColor = UIColor.clear
                        cell.lblTitle.textColor = UIColor.rgMid
                    }
                }
            case .aviationPreferredBevereges:
                if let ids = userPreferences?.aviation.aviation_preferred_beverage_id{
                    if (ids.contains(String(model.termId))){
                        cell.containerView.backgroundColor = UIColor.rgMid
                        cell.lblTitle.textColor = UIColor.white
                    }else{
                        cell.containerView.backgroundColor = UIColor.clear
                        cell.lblTitle.textColor = UIColor.rgMid
                    }
                }
            default:
                print("aviation default")
            }
        case .yachts:
            switch self.prefInformationType {
            case .yachtHaveCharteredBefore:
                if let str = userPreferences?.yacht.yacht_chartered_before{
                    if(str.contains(model.name.lowercased()) ){
                        cell.containerView.backgroundColor = UIColor.rgMid
                        cell.lblTitle.textColor = UIColor.white
                    }else{
                        cell.containerView.backgroundColor = UIColor.clear
                        cell.lblTitle.textColor = UIColor.rgMid
                    }
                }
            case .yachtInterestedIn:
                if let str = userPreferences?.yacht.yacht_interested_in{
                    if(str.contains(model.name.lowercased()) ){
                        cell.containerView.backgroundColor = UIColor.rgMid
                        cell.lblTitle.textColor = UIColor.white
                    }else{
                        cell.containerView.backgroundColor = UIColor.clear
                        cell.lblTitle.textColor = UIColor.rgMid
                    }
                }
            case .yachtType:
                if let str = userPreferences?.yacht.yacht_type{
                    if(model.name.lowercased().contains(str) ){ //model name is longer in length then the str i.e. Long Range and long respectively
                        cell.containerView.backgroundColor = UIColor.rgMid
                        cell.lblTitle.textColor = UIColor.white
                    }else{
                        cell.containerView.backgroundColor = UIColor.clear
                        cell.lblTitle.textColor = UIColor.rgMid
                    }
                }
            case .yachtStyle:
                if let str = userPreferences?.yacht.yacht_style{
                    if(model.name.lowercased().contains(str) ){ //model name is longer in length then the str i.e. Long Range and long respectively
                        cell.containerView.backgroundColor = UIColor.rgMid
                        cell.lblTitle.textColor = UIColor.white
                    }else{
                        cell.containerView.backgroundColor = UIColor.clear
                        cell.lblTitle.textColor = UIColor.rgMid
                    }
                }
            case .yachtPreferredCuisines:
                if let ids = userPreferences?.yacht.yacht_preferred_cuisine_id{
                    if (ids.contains(String(model.termId))){
                        cell.containerView.backgroundColor = UIColor.rgMid
                        cell.lblTitle.textColor = UIColor.white
                    }else{
                        cell.containerView.backgroundColor = UIColor.clear
                        cell.lblTitle.textColor = UIColor.rgMid
                    }
                }
            case .yachtOtherInterests:
                if let ids = userPreferences?.yacht.yacht_interests_id{
                    if (ids.contains(String(model.termId))){
                        cell.containerView.backgroundColor = UIColor.rgMid
                        cell.lblTitle.textColor = UIColor.white
                    }else{
                        cell.containerView.backgroundColor = UIColor.clear
                        cell.lblTitle.textColor = UIColor.rgMid
                    }
                }
            default:
                print("yacht default")
            }
        case .dining:
            switch prefInformationType {
            case .diningCuisines:
                if let ids = userPreferences?.restaurant.restaurant_preferred_cuisine_id{
                    if (ids.contains(String(model.termId))){
                        cell.containerView.backgroundColor = UIColor.rgMid
                        cell.lblTitle.textColor = UIColor.white
                    }else{
                        cell.containerView.backgroundColor = UIColor.clear
                        cell.lblTitle.textColor = UIColor.rgMid
                    }
                }
            case .diningAllergies:
                if let ids = userPreferences?.restaurant.restaurant_allergy_id{
                    if (ids.contains(String(model.termId))){
                        cell.containerView.backgroundColor = UIColor.rgMid
                        cell.lblTitle.textColor = UIColor.white
                    }else{
                        cell.containerView.backgroundColor = UIColor.clear
                        cell.lblTitle.textColor = UIColor.rgMid
                    }
                }
            case .diningPreferences:
                if let ids = userPreferences?.restaurant.restaurant_dinning_id{
                    if (ids.contains(String(model.termId))){
                        cell.containerView.backgroundColor = UIColor.rgMid
                        cell.lblTitle.textColor = UIColor.white
                    }else{
                        cell.containerView.backgroundColor = UIColor.clear
                        cell.lblTitle.textColor = UIColor.rgMid
                    }
                }
            case .diningTimings:
                if let ids = userPreferences?.restaurant.restaurant_timing_id{
                    if (ids.contains(String(model.termId))){
                        cell.containerView.backgroundColor = UIColor.rgMid
                        cell.lblTitle.textColor = UIColor.white
                    }else{
                        cell.containerView.backgroundColor = UIColor.clear
                        cell.lblTitle.textColor = UIColor.rgMid
                    }
                }
            case .diningBeverages:
                if let ids = userPreferences?.restaurant.restaurant_beverage_id{
                    if (ids.contains(String(model.termId))){
                        cell.containerView.backgroundColor = UIColor.rgMid
                        cell.lblTitle.textColor = UIColor.white
                    }else{
                        cell.containerView.backgroundColor = UIColor.clear
                        cell.lblTitle.textColor = UIColor.rgMid
                    }
                }
            case .diningSeatings:
                if let ids = userPreferences?.restaurant.restaurant_seating_id{
                    if (ids.contains(String(model.termId))){
                        cell.containerView.backgroundColor = UIColor.rgMid
                        cell.lblTitle.textColor = UIColor.white
                    }else{
                        cell.containerView.backgroundColor = UIColor.clear
                        cell.lblTitle.textColor = UIColor.rgMid
                    }
                }
            
            default:
                print("default of dining")
            }
        case .events:
            switch prefInformationType {
            case .eventCategory:
                if let ids = userPreferences?.event.event_category_id{
                    if (ids.contains(String(model.termId))){
                        cell.containerView.backgroundColor = UIColor.rgMid
                        cell.lblTitle.textColor = UIColor.white
                    }else{
                        cell.containerView.backgroundColor = UIColor.clear
                        cell.lblTitle.textColor = UIColor.rgMid
                    }
                }
            case .eventLocation:
                if let ids = userPreferences?.event.event_location_id{
                    if (ids.contains(String(model.termId))){
                        cell.containerView.backgroundColor = UIColor.rgMid
                        cell.lblTitle.textColor = UIColor.white
                    }else{
                        cell.containerView.backgroundColor = UIColor.clear
                        cell.lblTitle.textColor = UIColor.rgMid
                    }
                }

            default:
                print("default of event")
        }
        case .travel:
            switch prefInformationType {
            case .travelAmenities:
                if let ids = userPreferences?.travel.travel_amenity_id{
                    if (ids.contains(String(model.termId))){
                        cell.containerView.backgroundColor = UIColor.rgMid
                        cell.lblTitle.textColor = UIColor.white
                    }else{
                        cell.containerView.backgroundColor = UIColor.clear
                        cell.lblTitle.textColor = UIColor.rgMid
                    }
                }
            case .travelAirplaneSeat:
                if let str = userPreferences?.travel.travel_airplane_seat{
                    if(str.contains(model.name.lowercased()) ){
                        cell.containerView.backgroundColor = UIColor.rgMid
                        cell.lblTitle.textColor = UIColor.white
                    }else{
                        cell.containerView.backgroundColor = UIColor.clear
                        cell.lblTitle.textColor = UIColor.rgMid
                    }
                }
            case .travelMeals:
                if let str = userPreferences?.travel.travel_airplane_meals{
                    if(str.contains(String(model.termId)) ){
                        cell.containerView.backgroundColor = UIColor.rgMid
                        cell.lblTitle.textColor = UIColor.white
                    }else{
                        cell.containerView.backgroundColor = UIColor.clear
                        cell.lblTitle.textColor = UIColor.rgMid
                    }
                }
            case .travelMedicalMeals:
                if let str = userPreferences?.travel.travel_medical_dietary_meal{
                    if(str.contains(String(model.termId)) ){
                        cell.containerView.backgroundColor = UIColor.rgMid
                        cell.lblTitle.textColor = UIColor.white
                    }else{
                        cell.containerView.backgroundColor = UIColor.clear
                        cell.lblTitle.textColor = UIColor.rgMid
                    }
                }
            case .travelAllergies:
                if let str = userPreferences?.travel.travel_allergy_id{
                    if(str.contains(String(model.termId)) ){
                        cell.containerView.backgroundColor = UIColor.rgMid
                        cell.lblTitle.textColor = UIColor.white
                    }else{
                        cell.containerView.backgroundColor = UIColor.clear
                        cell.lblTitle.textColor = UIColor.rgMid
                    }
                }
            default:
                print("default of travel")
         }
        case .villas:
            switch self.prefInformationType {
            case .villaAmenities:
                if let str = userPreferences?.villa.villa_preferred_amenities_id{
                    if(str.contains(String(model.termId)) ){
                        cell.containerView.backgroundColor = UIColor.rgMid
                        cell.lblTitle.textColor = UIColor.white
                    }else{
                        cell.containerView.backgroundColor = UIColor.clear
                        cell.lblTitle.textColor = UIColor.rgMid
                    }
                }
            case .villaAccomodation:
                if let str = userPreferences?.villa.villa_preferred_accommodations_id{
                    if(str.contains(String(model.termId)) ){
                        cell.containerView.backgroundColor = UIColor.rgMid
                        cell.lblTitle.textColor = UIColor.white
                    }else{
                        cell.containerView.backgroundColor = UIColor.clear
                        cell.lblTitle.textColor = UIColor.rgMid
                    }
                }
            default:
                print("Not yet required")
            }
        default:
            print("default statement of main switch")
        }

        return cell
        // swiftlint:enable force_cast
    }
}

extension PrefCollectionsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let termId = String(itemsList[indexPath.row].termId)
        switch self.prefType {
        case .gifts:
            switch self.prefInformationType {
            case .giftHabbits:
                if var ids = userPreferences?.gift.gift_habit_id{
                    if ids.contains(termId){
                        //remove all occurances in case there is duplication i.e. dirty data
                        ids.removeAll{ value in return value == termId}
                        userPreferences?.gift.gift_habit_id = ids
                    }else{
                        userPreferences?.gift.gift_habit_id?.append(termId)
                    }
                }else{
                    userPreferences?.gift.gift_habit_id = []    //initializing first
                    userPreferences?.gift.gift_habit_id?.append(termId)
                }
            case .giftCategories:
                if var ids = userPreferences?.gift.gift_category_id{
                    if ids.contains(termId){
                        //remove all occurances in case there is duplication i.e. dirty data
                        ids.removeAll{ value in return value == termId}
                        userPreferences?.gift.gift_category_id = ids
                    }else{
                        userPreferences?.gift.gift_category_id?.append(termId)
                    }
                    
                }else{
                    userPreferences?.gift.gift_category_id = []    //initializing first
                    userPreferences?.gift.gift_category_id?.append(termId)
                }
            case .giftPreferences:
                if var ids = userPreferences?.gift.gift_preferences_id{
                    if ids.contains(termId){
                        //remove all occurances in case there is duplication i.e. dirty data
                        ids.removeAll{ value in return value == termId}
                        userPreferences?.gift.gift_preferences_id = ids
                    }else{
                        userPreferences?.gift.gift_preferences_id?.append(termId)
                    }
                }else{
                    userPreferences?.gift.gift_preferences_id = []    //initializing first
                    userPreferences?.gift.gift_preferences_id?.append(termId)
                }
            default:
                print("gifts default")
            }
        case .aviation:
            switch self.prefInformationType {
            case .aviationHaveCharteredBefore:
                if (indexPath.row == 0){
                    userPreferences?.aviation.aviation_chartered_before = "yes"
                }else{
                    userPreferences?.aviation.aviation_chartered_before = "no"
                }
                self.collectionView.reloadData()    //reload every thing in case of single selection i.e. yes or no
                isSelectionChanged()
                return  // else reloadData() and isSelectionChanged() would be called again
            case .aviationInterestedIn:
                if (indexPath.row == 0){
                    userPreferences?.aviation.aviation_interested_in = "charter"
                }else if (indexPath.row == 1){
                    userPreferences?.aviation.aviation_interested_in = "purchase"
                }else {
                    userPreferences?.aviation.aviation_interested_in = "both"
                }
                self.collectionView.reloadData()    //reload every thing in case of single selection i.e. yes or no
                isSelectionChanged()
                return  // else reloadData() and isSelectionChanged() would be called again
            case .aviationPreferredCharter:
                if (indexPath.row == 0){
                    userPreferences?.aviation.aviation_preferred_charter_range = "short"
                }else if (indexPath.row == 1){
                    userPreferences?.aviation.aviation_preferred_charter_range = "long"
                }else {
                    userPreferences?.aviation.aviation_preferred_charter_range = "both"
                }
                self.collectionView.reloadData()    //reload every thing in case of single selection i.e. yes or no
                isSelectionChanged()
                return  // else reloadData() and isSelectionChanged() would be called again
            case .aviationPreferredCuisine:
                if var ids = userPreferences?.aviation.aviation_preferred_cuisine_id{
                    if ids.contains(termId){
                        //remove all occurances in case there is duplication i.e. dirty data
                        ids.removeAll{ value in return value == termId}
                        userPreferences?.aviation.aviation_preferred_cuisine_id = ids
                    }else{
                        userPreferences?.aviation.aviation_preferred_cuisine_id?.append(termId)
                    }
                    self.collectionView.reloadItems(at: [indexPath])    //only refresh current selection
                }else{
                    userPreferences?.aviation.aviation_preferred_cuisine_id = []    //initializing first
                    userPreferences?.aviation.aviation_preferred_cuisine_id?.append(termId)
                }
            case .aviationPreferredBevereges:
                if var ids = userPreferences?.aviation.aviation_preferred_beverage_id{
                    if ids.contains(termId){
                        //remove all occurances in case there is duplication i.e. dirty data
                        ids.removeAll{ value in return value == termId}
                        userPreferences?.aviation.aviation_preferred_beverage_id = ids
                    }else{
                        userPreferences?.aviation.aviation_preferred_beverage_id?.append(termId)
                    }
                }else{
                    userPreferences?.aviation.aviation_preferred_beverage_id = []    //initializing first
                    userPreferences?.aviation.aviation_preferred_beverage_id?.append(termId)
                }
            default:
                print("aviation default")
            }
        case .yachts:
            switch self.prefInformationType {
            case .yachtHaveCharteredBefore:
                if (indexPath.row == 0){
                    userPreferences?.yacht.yacht_chartered_before = "yes"
                }else{
                    userPreferences?.yacht.yacht_chartered_before = "no"
                }
                self.collectionView.reloadData()    //reload every thing in case of single selection i.e. yes or no
                isSelectionChanged()
                return  // else reloadData() and isSelectionChanged() would be called again
            case .yachtInterestedIn:
                if (indexPath.row == 0){
                    userPreferences?.yacht.yacht_interested_in = "charter"
                }else if (indexPath.row == 1){
                    userPreferences?.yacht.yacht_interested_in = "purchase"
                }else {
                    userPreferences?.yacht.yacht_interested_in = "both"
                }
                self.collectionView.reloadData()    //reload every thing in case of single selection i.e. yes or no
                isSelectionChanged()
                return  // else reloadData() and isSelectionChanged() would be called again
            case .yachtType:
                if (indexPath.row == 0){
                    userPreferences?.yacht.yacht_type = "motor"
                }else if (indexPath.row == 1){
                    userPreferences?.yacht.yacht_type = "sail"
                }else{
                    userPreferences?.yacht.yacht_type = "both"
                }
                self.collectionView.reloadData()    //reload every thing in case of single selection i.e. yes or no
                isSelectionChanged()
                return  // else reloadData() and isSelectionChanged() would be called again
            case .yachtStyle:
                if (indexPath.row == 0){
                    userPreferences?.yacht.yacht_style = "modern"
                }else if (indexPath.row == 1){
                    userPreferences?.yacht.yacht_style = "classic"
                }else{
                    userPreferences?.yacht.yacht_style = "both"
                }
                self.collectionView.reloadData()    //reload every thing in case of single selection i.e. yes or no
                isSelectionChanged()
                return  // else reloadData() and isSelectionChanged() would be called again
            case .yachtPreferredCuisines:
                if var ids = userPreferences?.yacht.yacht_preferred_cuisine_id{
                    if ids.contains(termId){
                        //remove all occurances in case there is duplication i.e. dirty data
                        ids.removeAll{ value in return value == termId}
                        userPreferences?.yacht.yacht_preferred_cuisine_id = ids
                    }else{
                        userPreferences?.yacht.yacht_preferred_cuisine_id?.append(termId)
                    }
                    self.collectionView.reloadItems(at: [indexPath])    //only refresh current selection
                }else{
                    userPreferences?.yacht.yacht_preferred_cuisine_id = []    //initializing first
                    userPreferences?.yacht.yacht_preferred_cuisine_id?.append(termId)
                }
            case .yachtOtherInterests:
                if var ids = userPreferences?.yacht.yacht_interests_id{
                    if ids.contains(termId){
                        //remove all occurances in case there is duplication i.e. dirty data
                        ids.removeAll{ value in return value == termId}
                        userPreferences?.yacht.yacht_interests_id = ids
                    }else{
                        userPreferences?.yacht.yacht_interests_id?.append(termId)
                    }
                }else{
                    userPreferences?.yacht.yacht_interests_id = []    //initializing first
                    userPreferences?.yacht.yacht_interests_id?.append(termId)
                }
            default:
                print("yacht default")
            }
        case .dining:
            switch prefInformationType {
            case .diningCuisines:
                if var ids = userPreferences?.restaurant.restaurant_preferred_cuisine_id{
                    if ids.contains(termId){
                        //remove all occurances in case there is duplication i.e. dirty data
                        ids.removeAll{ value in return value == termId}
                        userPreferences?.restaurant.restaurant_preferred_cuisine_id = ids
                    }else{
                        userPreferences?.restaurant.restaurant_preferred_cuisine_id?.append(termId)
                    }
                }else{
                    userPreferences?.restaurant.restaurant_preferred_cuisine_id = []    //initializing first
                    userPreferences?.restaurant.restaurant_preferred_cuisine_id?.append(termId)
                }
            case .diningAllergies:
                if var ids = userPreferences?.restaurant.restaurant_allergy_id{
                    if ids.contains(termId){
                        //remove all occurances in case there is duplication i.e. dirty data
                        ids.removeAll{ value in return value == termId}
                        userPreferences?.restaurant.restaurant_allergy_id = ids
                    }else{
                        userPreferences?.restaurant.restaurant_allergy_id?.append(termId)
                    }
                }else{
                    userPreferences?.restaurant.restaurant_allergy_id = []    //initializing first
                    userPreferences?.restaurant.restaurant_allergy_id?.append(termId)
                }
            case .diningPreferences:
                if var ids = userPreferences?.restaurant.restaurant_dinning_id{
                    if ids.contains(termId){
                        //remove all occurances in case there is duplication i.e. dirty data
                        ids.removeAll{ value in return value == termId}
                        userPreferences?.restaurant.restaurant_dinning_id = ids
                    }else{
                        userPreferences?.restaurant.restaurant_dinning_id?.append(termId)
                    }
                }else{
                    userPreferences?.restaurant.restaurant_dinning_id = []    //initializing first
                    userPreferences?.restaurant.restaurant_dinning_id?.append(termId)
                }
            case .diningTimings:
                if var ids = userPreferences?.restaurant.restaurant_timing_id{
                    if ids.contains(termId){
                        //remove all occurances in case there is duplication i.e. dirty data
                        ids.removeAll{ value in return value == termId}
                        userPreferences?.restaurant.restaurant_timing_id = ids
                    }else{
                        userPreferences?.restaurant.restaurant_timing_id?.append(termId)
                    }
                }else{
                    userPreferences?.restaurant.restaurant_timing_id = []    //initializing first
                    userPreferences?.restaurant.restaurant_timing_id?.append(termId)
                }
            case .diningBeverages:
                if var ids = userPreferences?.restaurant.restaurant_beverage_id{
                    if ids.contains(termId){
                        //remove all occurances in case there is duplication i.e. dirty data
                        ids.removeAll{ value in return value == termId}
                        userPreferences?.restaurant.restaurant_beverage_id = ids
                    }else{
                        userPreferences?.restaurant.restaurant_beverage_id?.append(termId)
                    }
                }else{
                    userPreferences?.restaurant.restaurant_beverage_id = []    //initializing first
                    userPreferences?.restaurant.restaurant_beverage_id?.append(termId)
                }
            case .diningSeatings:
                if var ids = userPreferences?.restaurant.restaurant_seating_id{
                    if ids.contains(termId){
                        //remove all occurances in case there is duplication i.e. dirty data
                        ids.removeAll{ value in return value == termId}
                        userPreferences?.restaurant.restaurant_seating_id = ids
                    }else{
                        userPreferences?.restaurant.restaurant_seating_id?.append(termId)
                    }
                }else{
                    userPreferences?.restaurant.restaurant_seating_id = []    //initializing first
                    userPreferences?.restaurant.restaurant_seating_id?.append(termId)
                }
            
            default:
                print("default of dining")
            }
        case .events:
            switch prefInformationType {
            case .eventCategory:
                if var ids = userPreferences?.event.event_category_id{
                    if ids.contains(termId){
                        //remove all occurances in case there is duplication i.e. dirty data
                        ids.removeAll{ value in return value == termId}
                        userPreferences?.event.event_category_id = ids
                    }else{
                        userPreferences?.event.event_category_id?.append(termId)
                    }
                }else{
                    userPreferences?.event.event_category_id = []    //initializing first
                    userPreferences?.event.event_category_id?.append(termId)
                }
            case .eventLocation:
                if var ids = userPreferences?.event.event_location_id{
                    if ids.contains(termId){
                        //remove all occurances in case there is duplication i.e. dirty data
                        ids.removeAll{ value in return value == termId}
                        userPreferences?.event.event_location_id = ids
                    }else{
                        userPreferences?.event.event_location_id?.append(termId)
                    }
                }else{
                    userPreferences?.event.event_location_id = []    //initializing first
                    userPreferences?.event.event_location_id?.append(termId)
                }

            default:
                print("default of event")
        }
        case .travel:
            switch prefInformationType {
            case .travelAmenities:
                if var ids = userPreferences?.travel.travel_amenity_id{
                    if ids.contains(termId){
                        //remove all occurances in case there is duplication i.e. dirty data
                        ids.removeAll{ value in return value == termId}
                        userPreferences?.travel.travel_amenity_id = ids
                    }else{
                        userPreferences?.travel.travel_amenity_id?.append(termId)
                    }
                }else{
                    userPreferences?.travel.travel_amenity_id = []    //initializing first
                    userPreferences?.travel.travel_amenity_id?.append(termId)
                }
            case .travelAirplaneSeat:
                userPreferences?.travel.travel_airplane_seat = []   //making it empty
                if (indexPath.row == 0){
                    userPreferences?.travel.travel_airplane_seat?.append("aisle")
                }else{
                    userPreferences?.travel.travel_airplane_seat?.append("window")
                }
                self.collectionView.reloadData()    //reload every thing in case of single selection i.e. yes or no
                isSelectionChanged()
                return  // else reloadData() and isSelectionChanged() would be called again
            case .travelMeals:
                if var ids = userPreferences?.travel.travel_airplane_meals{
                    if ids.contains(termId){
                        //remove all occurances in case there is duplication i.e. dirty data
                        ids.removeAll{ value in return value == termId}
                        userPreferences?.travel.travel_airplane_meals = ids
                    }else{
                        userPreferences?.travel.travel_airplane_meals?.append(termId)
                    }
                }else{
                    userPreferences?.travel.travel_airplane_meals = []    //initializing first
                    userPreferences?.travel.travel_airplane_meals?.append(termId)
                }
            case .travelMedicalMeals:
                if var ids = userPreferences?.travel.travel_medical_dietary_meal{
                    if ids.contains(termId){
                        //remove all occurances in case there is duplication i.e. dirty data
                        ids.removeAll{ value in return value == termId}
                        userPreferences?.travel.travel_medical_dietary_meal = ids
                    }else{
                        userPreferences?.travel.travel_medical_dietary_meal?.append(termId)
                    }
                }else{
                    userPreferences?.travel.travel_medical_dietary_meal = []    //initializing first
                    userPreferences?.travel.travel_medical_dietary_meal?.append(termId)
                }
            case .travelAllergies:
                if var ids = userPreferences?.travel.travel_allergy_id{
                    if ids.contains(termId){
                        //remove all occurances in case there is duplication i.e. dirty data
                        ids.removeAll{ value in return value == termId}
                        userPreferences?.travel.travel_allergy_id = ids
                    }else{
                        userPreferences?.travel.travel_allergy_id?.append(termId)
                    }
                }else{
                    userPreferences?.travel.travel_allergy_id = []    //initializing first
                    userPreferences?.travel.travel_allergy_id?.append(termId)
                }
            default:
                print("default of travel")
         }
        case .villas:
            switch self.prefInformationType {
            case .villaAmenities:
                if var ids = userPreferences?.villa.villa_preferred_amenities_id{
                    if ids.contains(termId){
                        //remove all occurances in case there is duplication i.e. dirty data
                        ids.removeAll{ value in return value == termId}
                        userPreferences?.villa.villa_preferred_amenities_id = ids
                    }else{
                        userPreferences?.villa.villa_preferred_amenities_id?.append(termId)
                    }
                }else{
                    userPreferences?.villa.villa_preferred_amenities_id = []    //initializing first
                    userPreferences?.villa.villa_preferred_amenities_id?.append(termId)
                }
            case .villaAccomodation:
                if var ids = userPreferences?.villa.villa_preferred_accommodations_id{
                    if ids.contains(termId){
                        //remove all occurances in case there is duplication i.e. dirty data
                        ids.removeAll{ value in return value == termId}
                        userPreferences?.villa.villa_preferred_accommodations_id = ids
                    }else{
                        userPreferences?.villa.villa_preferred_accommodations_id?.append(termId)
                    }
                }else{
                    userPreferences?.villa.villa_preferred_accommodations_id = []    //initializing first
                    userPreferences?.villa.villa_preferred_accommodations_id?.append(termId)
                }
            default:
                print("Not yet required")
            }
        default:
            print("default statement of main switch")
        }
        self.collectionView.reloadItems(at: [indexPath])    //only refresh current selection
        isSelectionChanged()
    }
}

extension PrefCollectionsViewController: UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = Int(collectionView.bounds.size.width)
        switch prefInformationType {
        case .giftHabbits:
            return CGSize(width: Int(width), height: PrefCollSize.itemHeight.rawValue)
        case .aviationHaveCharteredBefore:  fallthrough
        case .aviationInterestedIn:       fallthrough
        case .aviationPreferredCharter: fallthrough
            
        case .yachtHaveCharteredBefore:  fallthrough
        case .yachtInterestedIn:       fallthrough
        case .yachtType:       fallthrough
        case .yachtStyle: fallthrough
        case .travelAirplaneSeat:
            //width is same as collection container's view i.e. full width
            cellWidth = Int(Float(width)  * 0.7)
            return CGSize(width: cellWidth , height: PrefCollSize.itemHeight.rawValue)    //70% of the width of collectionveiew
        default:
            //width is half as collection container's view minus margin
            cellWidth = width / 2  - PrefCollSize.itemMargin.rawValue / 2    //to keep horizontal and vertical margin same
            return CGSize(width: cellWidth, height: PrefCollSize.itemHeight.rawValue)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        //Where elements_count is the count of all your items in that
        //Collection view...
        let cellCount = CGFloat(self.itemsList.count)
        var topMargin:CGFloat = 0.0
        
        switch prefInformationType {
        case .aviationHaveCharteredBefore:  fallthrough
        case .aviationInterestedIn:       fallthrough
        case .aviationPreferredCharter: fallthrough

        case .yachtHaveCharteredBefore:  fallthrough
        case .yachtInterestedIn:       fallthrough
        case .yachtType:       fallthrough
        case .yachtStyle: fallthrough
        case .travelAirplaneSeat:
            // since these are fixed limited values so doubling the margin with the question title
            topMargin = CGFloat(PrefCollSize.itemMargin.rawValue * 2)
        default:
            if self.itemsList.count == 1{
                topMargin = CGFloat(PrefCollSize.itemMargin.rawValue * 2)
            }else{
                topMargin = 0
            }
        }
        if cellCount ==  1 {
            let padding = (collectionView.frame.size.width - CGFloat(cellWidth)) / 2.0
            return UIEdgeInsets(top: topMargin, left: padding, bottom: 0, right: padding)
        }else{
            return UIEdgeInsets(top: topMargin, left: 0, bottom: 0, right: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        //return CGFloat(PrefCollSize.itemMargin.rawValue)    //horizonntal margin between cells
        return 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch prefInformationType {
        case .aviationHaveCharteredBefore:  fallthrough
        case .aviationInterestedIn:       fallthrough
        case .aviationPreferredCharter: fallthrough
        case .yachtHaveCharteredBefore:  fallthrough
        case .yachtInterestedIn:       fallthrough
        case .yachtType:       fallthrough
        case .yachtStyle: fallthrough
        case .travelAirplaneSeat:
            // since these are fixed limited values so doubling the margin between the cells
            return CGFloat(PrefCollSize.itemMargin.rawValue * 2)    //vertical margin between cells
        default:
            return CGFloat(PrefCollSize.itemMargin.rawValue)    //vertical margin between cells
        }
        
    }
}

