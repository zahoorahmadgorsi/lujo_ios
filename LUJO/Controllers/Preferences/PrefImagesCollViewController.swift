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

class PrefImagesCollViewController: UIViewController {
    
    //MARK: - 🎲 - Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "PrefImagesCollViewController" }
    
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
        contentView.register(UINib(nibName: PrefImageCollViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: PrefImageCollViewCell.identifier)
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
    var cellWidth : Int = 84
    var cellHeight : Int = 114
    var cornerRadius : CGFloat = 12.0
    
    /// Init method that will init and return view controller.
    //class func instantiate(user: LujoUser) -> MyPreferencesViewController {
    class func instantiate(prefType: PrefType, prefInformationType : PrefInformationType) -> PrefImagesCollViewController {
        let viewController = UIStoryboard.preferences.instantiate(identifier) as! PrefImagesCollViewController
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
            case .travel:
                imgPreference.image = UIImage(named: "Find Hotel Icon")
                lblPrefLabel.text = "Travel"
                switch prefInformationType {
                case .travelDestinationType:
                    lblPrefQuestion.text = "Destination type preferences:"
                    txtPleaseSpecify.isHidden = true
                    previouslySelectedItems = self.userPreferences?.travel.travel_destination_type ?? []
                case .travelHotelGroups:
                    lblPrefQuestion.text = "Are there hotels or hotel groups do you prefer?"
                    txtPleaseSpecify.isHidden = true
                    previouslySelectedItems = self.userPreferences?.travel.travel_hotel_group ?? []
                case .travelActivities:
                    lblPrefQuestion.text = "Which activities do you enjoy when traveling somewhere?"
                    txtPleaseSpecify.isHidden = true
                    previouslySelectedItems = self.userPreferences?.travel.travel_activity_id ?? []
                case .travelAirlines:
                    lblPrefQuestion.text = "Are there any airlines you prefer?"
                    txtPleaseSpecify.isHidden = true
                    previouslySelectedItems = self.userPreferences?.travel.travel_airline_id ?? []
                case .travelHotelStyles:
                    lblPrefQuestion.text = "What style of hotels do you like?"
//                    txtPleaseSpecify.text = self.userPreferences?.travel.event_category_id_other
                    txtPleaseSpecify.isHidden = true
                    previouslySelectedItems = self.userPreferences?.travel.travel_hotel_styles ?? []
                default:
                    print("default of travel")
                }
            case .profile:
                self.navigationItem.rightBarButtonItem = nil     //hiding skip  button
                self.navigationItem.setHidesBackButton(true, animated: true)    //hiding back all button
                navigationItem.title = "Welcome"
                imgPreference.image = UIImage(named: "Lujo Logo")
                lblPrefLabel.isHidden = true
                btnNextStep.setTitle("S U B M I T", for: .normal)
                
                lblPrefQuestion.text = "Interested In"
                txtPleaseSpecify.isHidden = true
                previouslySelectedItems = self.userPreferences?.profile ?? []
                if let bgImage = UIImage(named: "general_preference_bg"){   //setting background image on profile preference
                    self.view.backgroundColor = UIColor(patternImage:  bgImage)
                }
                
                default:
                    print("Others")
        }
        getPrefMasterData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        switch prefType {
            case .profile:
                navigationItem.title = "Welcome"
            default:
                navigationItem.title = "Preferences"
        }
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
        case .travel:
            switch prefInformationType {
            case .travelDestinationType:
                let taxonomyObj1 = Taxonomy(termId:-1 , name: "Adventure")
                let taxonomyObj2 = Taxonomy(termId:-1 , name: "Ski")
                let taxonomyObj3 = Taxonomy(termId:-1 , name: "Beach")
                let taxonomyObj4 = Taxonomy(termId:-1 , name: "Nature")
                let taxonomyObj5 = Taxonomy(termId:-1 , name: "Urban")
                let taxonomyObj6 = Taxonomy(termId:-1 , name: "Wellness")
                var taxonomies = [Taxonomy]()
                taxonomies.append(taxonomyObj1)
                taxonomies.append(taxonomyObj2)
                taxonomies.append(taxonomyObj3)
                taxonomies.append(taxonomyObj4)
                taxonomies.append(taxonomyObj5)
                taxonomies.append(taxonomyObj6)
                self.itemsList = taxonomies
            case .travelHotelGroups:
                if let cachedItems = preferencesMasterData.travelHotelGroups , cachedItems.count > 0{  //if data is already cached or not
                    self.itemsList = cachedItems
                }
            case .travelActivities:
                if let cachedItems = preferencesMasterData.travelActivities , cachedItems.count > 0{  //if data is already cached or not
                    self.itemsList = cachedItems
                }
            case .travelAirlines:
                let taxonomyObj1 = Taxonomy(termId:-1 , name: "American")
                let taxonomyObj2 = Taxonomy(termId:-1 , name: "British")
                let taxonomyObj3 = Taxonomy(termId:-1 , name: "Delta")
                let taxonomyObj4 = Taxonomy(termId:-1 , name: "Emirates")
                let taxonomyObj5 = Taxonomy(termId:-1 , name: "KLM")
                let taxonomyObj6 = Taxonomy(termId:-1 , name: "Lufthansa")
                let taxonomyObj7 = Taxonomy(termId:-1 , name: "Qantas")
                let taxonomyObj8 = Taxonomy(termId:-1 , name: "Air France")
                let taxonomyObj9 = Taxonomy(termId:-1 , name: "United")
                let taxonomyObj10 = Taxonomy(termId:-1 , name: "Japan Airlines")
                let taxonomyObj11 = Taxonomy(termId:-1 , name: "South African")
                let taxonomyObj12 = Taxonomy(termId:-1 , name: "Singapore Airlines")
                let taxonomyObj13 = Taxonomy(termId:-1 , name: "Air India")
                let taxonomyObj14 = Taxonomy(termId:-1 , name: "Saudia")
                let taxonomyObj15 = Taxonomy(termId:-1 , name: "Qatar")
                var taxonomies = [Taxonomy]()
                taxonomies.append(taxonomyObj1)
                taxonomies.append(taxonomyObj2)
                taxonomies.append(taxonomyObj3)
                taxonomies.append(taxonomyObj4)
                taxonomies.append(taxonomyObj5)
                taxonomies.append(taxonomyObj6)
                taxonomies.append(taxonomyObj7)
                taxonomies.append(taxonomyObj8)
                taxonomies.append(taxonomyObj9)
                taxonomies.append(taxonomyObj10)
                taxonomies.append(taxonomyObj11)
                taxonomies.append(taxonomyObj12)
                taxonomies.append(taxonomyObj13)
                taxonomies.append(taxonomyObj14)
                taxonomies.append(taxonomyObj15)
                self.itemsList = taxonomies
            case .travelHotelStyles:
                let taxonomyObj1 = Taxonomy(termId:-1 , name: "Chain(Brand)")
                let taxonomyObj2 = Taxonomy(termId:-1 , name: "Modern")
                let taxonomyObj3 = Taxonomy(termId:-1 , name: "Boutique")
                let taxonomyObj4 = Taxonomy(termId:-1 , name: "Traditional")
                var taxonomies = [Taxonomy]()
                taxonomies.append(taxonomyObj1)
                taxonomies.append(taxonomyObj2)
                taxonomies.append(taxonomyObj3)
                taxonomies.append(taxonomyObj4)
                self.itemsList = taxonomies
            default:
                print("default of travel")
            }
        case .profile:
            let taxonomyObj1 = Taxonomy(termId:-1 , name: "aviation")
            let taxonomyObj2 = Taxonomy(termId:-1 , name: "dining")
            let taxonomyObj3 = Taxonomy(termId:-1 , name: "events")
            let taxonomyObj4 = Taxonomy(termId:-1 , name: "experience")
            let taxonomyObj5 = Taxonomy(termId:-1 , name: "gifts")
            let taxonomyObj6 = Taxonomy(termId:-1 , name: "travel")
            let taxonomyObj7 = Taxonomy(termId:-1 , name: "properties")
            let taxonomyObj8 = Taxonomy(termId:-1 , name: "yachting")
            
            var taxonomies = [Taxonomy]()
            taxonomies.append(taxonomyObj1)
            taxonomies.append(taxonomyObj2)
            taxonomies.append(taxonomyObj3)
            taxonomies.append(taxonomyObj4)
            taxonomies.append(taxonomyObj5)
            taxonomies.append(taxonomyObj6)
            taxonomies.append(taxonomyObj7)
            taxonomies.append(taxonomyObj8)
            self.itemsList = taxonomies

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
        case .travel:
            switch prefInformationType {
            case .travelDestinationType:
                print("Not required for hard coded data")
                completion(self.itemsList, nil)
            case .travelHotelGroups:
                GoLujoAPIManager().getTravelHotelGroups(token) { taxonomies, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not obtain travel information")
                        completion(nil, error)
                        return
                    }
                    //caching master data into userdefaults
                    if let items = taxonomies ,  items.count > 0{
//                        self.addSelectiveItem(items:items)
                        self.preferencesMasterData.travelHotelGroups = taxonomies
                        LujoSetup().store(preferencesMasterData: self.preferencesMasterData)
                    }
                    completion(taxonomies, error)
                }
            case .travelActivities:
                GoLujoAPIManager().getTravelActivities(token) { taxonomies, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not obtain travel information")
                        completion(nil, error)
                        return
                    }
                    //caching master data into userdefaults
                    if let items = taxonomies ,  items.count > 0{
//                        self.addSelectiveItem(items:items)
                        self.preferencesMasterData.travelActivities = taxonomies
                        LujoSetup().store(preferencesMasterData: self.preferencesMasterData)
                    }
                    completion(taxonomies, error)
                }
            case .travelAirlines:
                print("Not required for hard coded data")
                completion(self.itemsList, nil)
            case .travelHotelStyles:
                print("Not required for hard coded data")
                completion(self.itemsList, nil)
            default:
                print("default of travel")
            }
        case .profile:
            print("Not required for hard coded data")
            completion(self.itemsList, nil)
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
            case .travel:
                switch prefInformationType {
                case .travelDestinationType:
                    if let ids = userPreferences?.travel.travel_destination_type{
                        for id in ids {
                            if id.count > 0{ //to avoid empty string
                                selectedArray.append(id)
                            }
                        }
                    }
                case .travelHotelGroups:
                    if let ids = userPreferences?.travel.travel_hotel_group{
                        for id in ids {
                            if id.count > 0{ //to avoid empty string
                                selectedArray.append(id)
                            }
                        }
                    }
                case .travelActivities:
                    if let ids = userPreferences?.travel.travel_activity_id{
                        for id in ids {
                            if id.count > 0{ //to avoid empty string
                                selectedArray.append(id)
                            }
                        }
                    }
                case .travelAirlines:
                    if let ids = userPreferences?.travel.travel_airline_id{
                        for id in ids {
                            if id.count > 0{ //to avoid empty string
                                selectedArray.append(id)
                            }
                        }
                    }
                case .travelHotelStyles:
                    if let ids = userPreferences?.travel.travel_hotel_styles{
                        for id in ids {
                            if id.count > 0{ //to avoid empty string
                                selectedArray.append(id)
                            }
                        }
                    }
                default:
                    print("default of travel")
             }
            case .profile:
                if let types = userPreferences?.profile{
                    for type in types {
                        if type.count > 0{ //to avoid empty string
                            selectedArray.append(type) //making lowercased, Aviation to aviation
                        }
                    }
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
                    case .travel:
                        switch self.prefInformationType {
                        case .travelDestinationType:
                            if arr.count > 0 && arr[0].count > 0{   //avoid empty string
                                userPreferences.travel.travel_destination_type = arr
                            }
                            LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                        case .travelHotelGroups:
                            if arr.count > 0 && arr[0].count > 0{   //avoid empty string
                                userPreferences.travel.travel_hotel_group = arr
                            }
                            LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                        case .travelActivities:
                            if arr.count > 0 && arr[0].count > 0{   //avoid empty string
                                userPreferences.travel.travel_activity_id = arr
                            }
//                            userPreferences.travel.event_category_id_other = self.txtPleaseSpecify.text
                            LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                        case .travelAirlines:
                            if arr.count > 0 && arr[0].count > 0{   //avoid empty string
                                userPreferences.travel.travel_airline_id = arr
                            }
                            LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                        case .travelHotelStyles:
                            if arr.count > 0 && arr[0].count > 0{   //avoid empty string
                                userPreferences.travel.travel_hotel_styles = arr
                            }
                            LujoSetup().store(userPreferences: userPreferences)
                        default:
                            print("default of travel")
                     }
                    case .profile:
                        if arr.count > 0 && arr[0].count > 0{   //avoid empty string
                            userPreferences.profile = arr
                        }
                        LujoSetup().store(userPreferences: userPreferences)
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
        case .travel:
            switch prefInformationType {
            case .travelDestinationType:
                GoLujoAPIManager().setTravelDestinationType(token: token,commaSeparatedString: commaSeparatedString) { contentString, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not set the Preferences information")
                        completion(nil, error)
                        return
                    }
                    completion(contentString, error)
                }
            case .travelHotelGroups:
                GoLujoAPIManager().setTravelHotelGroups(token: token,commaSeparatedString: commaSeparatedString) { contentString, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not set the Preferences information")
                        completion(nil, error)
                        return
                    }
                    completion(contentString, error)
                }
            case .travelActivities:
                GoLujoAPIManager().setTravelActivities(token: token,commaSeparatedString: commaSeparatedString) { contentString, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not set the Preferences information")
                        completion(nil, error)
                        return
                    }
                    completion(contentString, error)
                }
            case .travelAirlines:
                GoLujoAPIManager().setTravelAirlines(token: token,commaSeparatedString: commaSeparatedString) { contentString, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not set the Preferences information")
                        completion(nil, error)
                        return
                    }
                    completion(contentString, error)
                }
            case .travelHotelStyles:
                GoLujoAPIManager().setTravelHotelStyles(token: token,commaSeparatedString: commaSeparatedString) { contentString, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not set the Preferences information")
                        completion(nil, error)
                        return
                    }
                    completion(contentString, error)
                }
            default:
                print("default of travel")
            }
        case .profile:
            GoLujoAPIManager().setProfilePreferences(token: token,commaSeparatedString: commaSeparatedString) { contentString, error in
                guard error == nil else {
                    Crashlytics.crashlytics().record(error: error!)
                    let error = BackendError.parsing(reason: "Could not set the profile preferences")
                    completion(nil, error)
                    return
                }
                completion(contentString, error)
            }
        default:
            print("Main switch default ")
        }
    }
    
    func navigateToNextVC(){
        switch self.prefType {
        case .travel:
            switch prefInformationType {
            case .travelDestinationType:
                let viewController = PrefImagesCollViewController.instantiate(prefType: .travel, prefInformationType: .travelHotelGroups)
                self.navigationController?.pushViewController(viewController, animated: true)
            case .travelHotelGroups:
                let viewController = PrefCollectionsViewController.instantiate(prefType: .travel, prefInformationType: .travelAmenities)
                self.navigationController?.pushViewController(viewController, animated: true)
            case .travelActivities:
                let viewController = PrefImagesCollViewController.instantiate(prefType: .travel, prefInformationType: .travelAirlines)
                self.navigationController?.pushViewController(viewController, animated: true)
            case .travelAirlines:
                let viewController = PrefCollectionsViewController.instantiate(prefType: .travel, prefInformationType: .travelAirplaneSeat)
                self.navigationController?.pushViewController(viewController, animated: true)
            case .travelHotelStyles:
                let viewController = PrefCollectionsViewController.instantiate(prefType: .travel, prefInformationType: .travelAllergies)
                self.navigationController?.pushViewController(viewController, animated: true)
            default:
                print("default of travel")
        }
        case .profile:
            self.navigationController?.popViewController(animated: true)
        default:
            print("default of main switch")
        }
    }
    
    //this method checks the value which were at the time of loading of this screen and current seletion. if loading time value has been changed then button text get changed
    @objc func isSelectionChanged() -> Bool{
        switch self.prefType {
        case .travel:
            switch prefInformationType {
            case .travelDestinationType:
                let current = self.userPreferences?.travel.travel_destination_type ?? []
                let previous = self.previouslySelectedItems
                return !compare(current: current , previous: previous)
            case .travelHotelGroups:
                let current = self.userPreferences?.travel.travel_hotel_group ?? []
                let previous = self.previouslySelectedItems
                return !compare(current: current , previous: previous)
            case .travelActivities:
                let current = self.userPreferences?.travel.travel_activity_id ?? []
                let previous = self.previouslySelectedItems
//                let previouslyTypedStr = self.userPreferences?.travel.event_category_id_other ?? ""
//                return !compare(current: current , previous: previous, previousTypedStr:previouslyTypedStr)
                return !compare(current: current , previous: previous)
            case .travelAirlines:
                let current = self.userPreferences?.travel.travel_airline_id ?? []
                let previous = self.previouslySelectedItems
                return !compare(current: current , previous: previous)
            case .travelHotelStyles:
                let current = self.userPreferences?.travel.travel_hotel_styles ?? []
                let previous = self.previouslySelectedItems
                return !compare(current: current , previous: previous)
            default:
                print("default of travel")
        }
        case .profile:
            let current = self.userPreferences?.profile ?? []
            let previous = self.previouslySelectedItems
            return !compare(current: current , previous: previous)
        default:
            print("default clause of main switch")
        }
        return true
    }
    
    func compare(current:String , previous:String) -> Bool{
        if previous == current{
//            btnNextStep.setTitle("S K I P", for: .normal)
//            btnNextStep.setTitle("N E X T", for: .normal)
            return true
        }else{
//            btnNextStep.setTitle("N E X T", for: .normal)
            return false
        }
    }
    
    func compare(current:[String] , previous:[String] , previousTypedStr:String? = nil) -> Bool{
        let currentTypedStr = self.txtPleaseSpecify.text
        if (Set(previous ) == Set(current) && (previousTypedStr ?? currentTypedStr == self.txtPleaseSpecify.text)){
//            btnNextStep.setTitle("S K I P", for: .normal)
//            btnNextStep.setTitle("N E X T", for: .normal)
            return true
        }else{
//            btnNextStep.setTitle("N E X T", for: .normal)
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

extension PrefImagesCollViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PrefImageCollViewCell.identifier, for: indexPath) as! PrefImageCollViewCell
        let model = itemsList[indexPath.row]
        cell.lblTitle.text = model.name
        
        
        switch self.prefType {
        case .travel:
            switch prefInformationType {
            case .travelDestinationType:
                cell.imgView.image = UIImage(named: model.name + " travel")
                if let ids = userPreferences?.travel.travel_destination_type{
                    if (ids.contains(model.name)){
                        cell.viewContent.addViewBorder( borderColor: UIColor.rgMid.cgColor, borderWidth: 1.0, borderCornerRadius: cornerRadius)
                    }else{
                        cell.viewContent.addViewBorder( borderColor: UIColor.clear.cgColor, borderWidth: 1.0, borderCornerRadius: cornerRadius)
                    }
                }
            case .travelHotelGroups:
//                cell.lblTitle.text = ""
                cell.imgView.backgroundColor = UIColor.white
                cell.imgView.addViewBorder( borderColor: UIColor.clear.cgColor, borderWidth: 1.0, borderCornerRadius: cornerRadius)
                cell.imgView.image = UIImage(named: model.name + " travel")
                if let ids = userPreferences?.travel.travel_hotel_group{
                    if (ids.contains(String(model.termId))){
                        cell.viewContent.addViewBorder( borderColor: UIColor.rgMid.cgColor, borderWidth: 1.0, borderCornerRadius: cornerRadius)
                    }else{
                        cell.viewContent.addViewBorder( borderColor: UIColor.clear.cgColor, borderWidth: 1.0, borderCornerRadius: cornerRadius)
                    }
                }
            case .travelActivities:
                cell.imgView.image = UIImage(named: model.name + " travel")
                if let ids = userPreferences?.travel.travel_activity_id{
                    if (ids.contains(String(model.termId))){
                        cell.viewContent.addViewBorder( borderColor: UIColor.rgMid.cgColor, borderWidth: 1.0, borderCornerRadius: cornerRadius)
                    }else{
                        cell.viewContent.addViewBorder( borderColor: UIColor.clear.cgColor, borderWidth: 1.0, borderCornerRadius: cornerRadius)
                    }
                }
            case .travelAirlines:
                cell.imgView.image = UIImage(named: model.name + " airline")
                if let ids = userPreferences?.travel.travel_airline_id{
                    if (ids.contains(model.name)){
                        cell.viewContent.addViewBorder( borderColor: UIColor.rgMid.cgColor, borderWidth: 1.0, borderCornerRadius: cornerRadius)
                    }else{
                        cell.viewContent.addViewBorder( borderColor: UIColor.clear.cgColor, borderWidth: 1.0, borderCornerRadius: cornerRadius)
                    }
                }
            case .travelHotelStyles:
                cell.imgView.image = UIImage(named: model.name + " travel")
                if let ids = userPreferences?.travel.travel_hotel_styles{
                    if (ids.contains(model.name)){
                        cell.viewContent.addViewBorder( borderColor: UIColor.rgMid.cgColor, borderWidth: 1.0, borderCornerRadius: cornerRadius)
                    }else{
                        cell.viewContent.addViewBorder( borderColor: UIColor.clear.cgColor, borderWidth: 1.0, borderCornerRadius: cornerRadius)
                    }
                }
            default:
                print("default of travel")
         }
        case .profile:
            cell.imgView.image = UIImage(named: model.name + " general white")
            cell.lblTitle.text = model.name.capitalizingFirstLetter()
            cell.lblTitle.textColor = .white
            if let ids = userPreferences?.profile{
                if (ids.contains(model.name)){
                    cell.imgView.image = UIImage(named: model.name + " general selected")
                    cell.lblTitle.textColor = .rgMid
                }
            }
        default:
            print("default statement of main switch")
        }

        return cell
        // swiftlint:enable force_cast
    }
}

extension PrefImagesCollViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let termId = String(itemsList[indexPath.row].termId)
        let name = String(itemsList[indexPath.row].name)
        
        switch self.prefType {
        case .travel:
            switch prefInformationType {
            case .travelDestinationType:
                if var ids = userPreferences?.travel.travel_destination_type{
                    if ids.contains(name){
                        //remove all occurances in case there is duplication i.e. dirty data
                        ids.removeAll{ value in return value == name}
                        userPreferences?.travel.travel_destination_type = ids
                    }else{
                        userPreferences?.travel.travel_destination_type?.append(name)
                    }
                }else{
                    userPreferences?.travel.travel_destination_type = []    //initializing first
                    userPreferences?.travel.travel_destination_type?.append(name)
                }
            case .travelHotelGroups:
                if var ids = userPreferences?.travel.travel_hotel_group{
                    if ids.contains(termId){
                        //remove all occurances in case there is duplication i.e. dirty data
                        ids.removeAll{ value in return value == termId}
                        userPreferences?.travel.travel_hotel_group = ids
                    }else{
                        userPreferences?.travel.travel_hotel_group?.append(termId)
                    }
                }else{
                    userPreferences?.travel.travel_hotel_group = []    //initializing first
                    userPreferences?.travel.travel_hotel_group?.append(termId)
                }
            case .travelActivities:
                if var ids = userPreferences?.travel.travel_activity_id{
                    if ids.contains(termId){
                        //remove all occurances in case there is duplication i.e. dirty data
                        ids.removeAll{ value in return value == termId}
                        userPreferences?.travel.travel_activity_id = ids
                    }else{
                        userPreferences?.travel.travel_activity_id?.append(termId)
                    }
                }else{
                    userPreferences?.travel.travel_activity_id = []    //initializing first
                    userPreferences?.travel.travel_activity_id?.append(termId)
                }
            case .travelAirlines:
                if var ids = userPreferences?.travel.travel_airline_id{
                    if ids.contains(name){
                        //remove all occurances in case there is duplication i.e. dirty data
                        ids.removeAll{ value in return value == name}
                        userPreferences?.travel.travel_airline_id = ids
                    }else{
                        userPreferences?.travel.travel_airline_id?.append(name)
                    }
                }else{
                    userPreferences?.travel.travel_airline_id = []    //initializing first
                    userPreferences?.travel.travel_airline_id?.append(name)
                }
            case .travelHotelStyles:
                if var ids = userPreferences?.travel.travel_hotel_styles{
                    if ids.contains(name){
                        //remove all occurances in case there is duplication i.e. dirty data
                        ids.removeAll{ value in return value == name}
                        userPreferences?.travel.travel_hotel_styles = ids
                    }else{
                        userPreferences?.travel.travel_hotel_styles?.append(name)
                    }
                }else{
                    userPreferences?.travel.travel_hotel_styles = []    //initializing first
                    userPreferences?.travel.travel_hotel_styles?.append(name)
                }
            default:
                print("default of travel")
        }
        case .profile:
            if var types = userPreferences?.profile{
                if types.contains(name){
                    //remove all occurances in case there is duplication i.e. dirty data
                    types.removeAll{ value in return value == name}
                    userPreferences?.profile = types
                }else{
                    userPreferences?.profile?.append(name)
                }
            }else{
                userPreferences?.profile = []    //initializing first
                userPreferences?.profile?.append(name)
            }
        default:
            print("default statement of main switch")
        }
        self.collectionView.reloadItems(at: [indexPath])    //only refresh current selection
        isSelectionChanged()
    }
}

extension PrefImagesCollViewController: UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = Int(collectionView.bounds.size.width)
        cellWidth = width / 4  - PrefCollSize.itemMargin.rawValue / 4    //to keep horizontal and vertical margin same
        switch prefInformationType {
        case .travelHotelStyles:
            cellWidth = width / 3  - PrefCollSize.itemMargin.rawValue / 3    //to keep horizontal and vertical margin same
            return CGSize(width: cellWidth, height: cellWidth + 30)
        case .profile:
            return CGSize(width: cellWidth, height: cellWidth)
        default:
            return CGSize(width: cellWidth, height: cellWidth + 30)
        }   
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        switch prefInformationType {
        case .travelHotelStyles:
            return UIEdgeInsets(top: CGFloat(PrefCollSize.itemMargin.rawValue) , left: CGFloat(PrefCollSize.itemMargin.rawValue) * 1.5, bottom: 0, right: CGFloat(PrefCollSize.itemMargin.rawValue) * 1.5)
        default:
            return UIEdgeInsets(top: CGFloat(PrefCollSize.itemMargin.rawValue), left: CGFloat(PrefCollSize.itemMargin.rawValue), bottom: 0, right: CGFloat(PrefCollSize.itemMargin.rawValue))
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
        case .travelHotelGroups:
            return CGFloat(PrefCollSize.itemMargin.rawValue) / 2    //vertical margin between cells
        default:
            return CGFloat(PrefCollSize.itemMargin.rawValue)    //vertical margin between cells
        }
        
        
    }
}

