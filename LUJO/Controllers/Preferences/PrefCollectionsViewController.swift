//
//  MyPreferencesViewController.swift
//  LUJO
//
//  Created by iMac on 06/05/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import UIKit
import JGProgressHUD

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
                    txtPleaseSpecify.text = self.userPreferences?.gift.gift_habit_id_other
                    previouslySelectedItems = self.userPreferences?.gift.gift_habit_id ?? []
                case .giftCategories:
                    lblPrefQuestion.text = "Preferred gift items:"
                    txtPleaseSpecify.text = self.userPreferences?.gift.gift_category_id_other
                    previouslySelectedItems = self.userPreferences?.gift.gift_category_id ?? []
                case .giftPreferences:
                    lblPrefQuestion.text = "Item Preferences:"
                    txtPleaseSpecify.text = self.userPreferences?.gift.gift_preferences_id_other
                    //removing the duplicates
                    previouslySelectedItems = Array(Set(self.userPreferences?.gift.gift_preferences_id ?? [])) //Order might change
                    btnNextStep.setTitle("D O N E", for: .normal)
                default:
                    print("Others")
                }
            case .aviation:
                imgPreference.image = UIImage(named: "aviation_icon")
                lblPrefLabel.text = "Aviation"
                switch prefInformationType {
                case .aviationHaveCharteredBefore:
                    lblPrefQuestion.text = "Have you chartered before?:"
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
                    txtPleaseSpecify.text = self.userPreferences?.aviation.aviation_preferred_cuisine_id_other
                    previouslySelectedItems = self.userPreferences?.aviation.aviation_preferred_cuisine_id ?? []
                case .aviationPreferredBevereges:
                    lblPrefQuestion.text = "Preferred Beverages?"
                    txtPleaseSpecify.text = self.userPreferences?.aviation.aviation_preferred_beverage_id_other
                    previouslySelectedItems = self.userPreferences?.aviation.aviation_preferred_beverage_id ?? []
                    btnNextStep.setTitle("D O N E", for: .normal)
                default:
                    print("Others")
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
                        let taxonomyObj1 = Taxonomy(termId:-1 , name: "Yes")
                        let taxonomyObj2 = Taxonomy(termId:-1 , name: "No")
                        var taxonomies = [Taxonomy]()
                        taxonomies.append(taxonomyObj1)
                        taxonomies.append(taxonomyObj2)
                        self.itemsList = taxonomies
                    case .aviationInterestedIn:
                        let taxonomyObj1 = Taxonomy(termId:-1 , name: "Charter")
                        let taxonomyObj2 = Taxonomy(termId:-1 , name: "Purchase")
                        var taxonomies = [Taxonomy]()
                        taxonomies.append(taxonomyObj1)
                        taxonomies.append(taxonomyObj2)
                        self.itemsList = taxonomies
                    case .aviationPreferredCharter:
                        let taxonomyObj1 = Taxonomy(termId:-1 , name: "Short Range")
                        let taxonomyObj2 = Taxonomy(termId:-1 , name: "Long Range")
                        var taxonomies = [Taxonomy]()
                        taxonomies.append(taxonomyObj1)
                        taxonomies.append(taxonomyObj2)
                        self.itemsList = taxonomies
                    case .aviationPreferredCuisine:
                        if let cachedItems = preferencesMasterData.aviationCuisines , cachedItems.count > 0{  //if data is already cached or not
                            self.itemsList = cachedItems
                        }
                    case .aviationPreferredBevereges:
                        if let cachedItems = preferencesMasterData.aviationBeverages , cachedItems.count > 0{  //if data is already cached or not
                            self.itemsList = cachedItems
                        }
                    default:
                        print("Hard codes values for this case. No master data exist.")
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
                    GoLujoAPIManager().getGiftHabbits(token) { taxonomies, error in
                        guard error == nil else {
                            Crashlytics.sharedInstance().recordError(error!)
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
                            Crashlytics.sharedInstance().recordError(error!)
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
                    GoLujoAPIManager().getGiftPreferences(token) { taxonomies, error in
                        guard error == nil else {
                            Crashlytics.sharedInstance().recordError(error!)
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
                        GoLujoAPIManager().getAviationCuisine(token) { taxonomies, error in
                            guard error == nil else {
                                Crashlytics.sharedInstance().recordError(error!)
                                let error = BackendError.parsing(reason: "Could not obtain Dining information")
                                completion(nil, error)
                                return
                            }
                            //caching master data into userdefaults
                            if taxonomies?.count ?? 0 > 0{
                                self.preferencesMasterData.aviationCuisines = taxonomies
                                LujoSetup().store(preferencesMasterData: self.preferencesMasterData)
                            }
                            completion(taxonomies, error)
                        }
                    case .aviationPreferredBevereges:
                        GoLujoAPIManager().getAviationBeverages(token) { taxonomies, error in
                            guard error == nil else {
                                Crashlytics.sharedInstance().recordError(error!)
                                let error = BackendError.parsing(reason: "Could not obtain the Preferences information")
                                completion(nil, error)
                                return
                            }
                            //caching master data into userdefaults
                            if taxonomies?.count ?? 0 > 0{
                                self.preferencesMasterData.aviationBeverages = taxonomies
                                LujoSetup().store(preferencesMasterData: self.preferencesMasterData)
                            }
                            completion(taxonomies, error)
                        }
                    default:
                        print("Hard coded values, no master data exist.")
                        completion([], nil)
                    }
                default:
                    print("Others")
            }
    }
    
    //when user will click on the next button at the bottom
    @IBAction func btnNextTapped(_ sender: Any) {
        if (isSelectionChanged()){
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
                default:
                    print("Others")
            }
            if (selectedArray.count > 0 || txtPleaseSpecify.text?.count ?? 0 > 0) {   //something is there, so convert array to comma sepeated string
                let commaSeparatedString = selectedArray.map{String($0)}.joined(separator: ",")
                setPreferences(commaSeparatedString: commaSeparatedString)
            }
            else{
                print("This line must not execute")
            }
        }else{
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
                            userPreferences.gift.gift_habit_id_other = self.txtPleaseSpecify.text
                            LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                        case .giftCategories:
                            if arr.count > 0 && arr[0].count > 0{   //avoid empty string
                                userPreferences.gift.gift_category_id = arr
                            }
                            userPreferences.gift.gift_category_id_other = self.txtPleaseSpecify.text
                            LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                        case .giftPreferences:
                            if arr.count > 0 && arr[0].count > 0{   //avoid empty string
                                userPreferences.gift.gift_preferences_id = arr
                            }
                            userPreferences.gift.gift_preferences_id_other = self.txtPleaseSpecify.text
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
                            userPreferences.aviation.aviation_preferred_cuisine_id_other = self.txtPleaseSpecify.text
                            LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                        case .aviationPreferredBevereges:
                            if arr.count > 0 && arr[0].count > 0{   //avoid empty string
                                userPreferences.aviation.aviation_preferred_beverage_id = arr
                            }
                            userPreferences.aviation.aviation_preferred_beverage_id_other = self.txtPleaseSpecify.text
                            LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                        default:
                            print("aviation default")
                        }
                        default:
                            print("Others")
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
                    GoLujoAPIManager().setGiftHabbits(token: token,commSepeartedString: commaSeparatedString, typedPreference: txtPleaseSpecify.text ?? "") { contentString, error in
                        guard error == nil else {
                            Crashlytics.sharedInstance().recordError(error!)
                            let error = BackendError.parsing(reason: "Could not obtain the Preferences information")
                            completion(nil, error)
                            return
                        }
                        completion(contentString, error)
                    }
                case .giftCategories:
                    GoLujoAPIManager().setGiftCategories(token: token,commSepeartedString: commaSeparatedString, typedPreference: txtPleaseSpecify.text ?? "") { contentString, error in
                        guard error == nil else {
                            Crashlytics.sharedInstance().recordError(error!)
                            let error = BackendError.parsing(reason: "Could not obtain the Preferences information")
                            completion(nil, error)
                            return
                        }
                        completion(contentString, error)
                    }
                case .giftPreferences:
                    GoLujoAPIManager().setGiftPreferences(token: token,commSepeartedString: commaSeparatedString, typedPreference: txtPleaseSpecify.text ?? "") { contentString, error in
                        guard error == nil else {
                            Crashlytics.sharedInstance().recordError(error!)
                            let error = BackendError.parsing(reason: "Could not obtain the Preferences information")
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
                    GoLujoAPIManager().setAviationHaveCharteredBefore(token: token,commSepeartedString: commaSeparatedString) { contentString, error in
                        guard error == nil else {
                            Crashlytics.sharedInstance().recordError(error!)
                            let error = BackendError.parsing(reason: "Could not obtain the Preferences information")
                            completion(nil, error)
                            return
                        }
                        completion(contentString, error)
                    }
                case .aviationInterestedIn:
                    GoLujoAPIManager().setAviationWantToPurchase(token: token,commSepeartedString: commaSeparatedString) { contentString, error in
                        guard error == nil else {
                            Crashlytics.sharedInstance().recordError(error!)
                            let error = BackendError.parsing(reason: "Could not obtain the Preferences information")
                            completion(nil, error)
                            return
                        }
                        completion(contentString, error)
                    }
                case .aviationPreferredCharter:
                    GoLujoAPIManager().setAviationPreferredCharter(token: token,commSepeartedString: commaSeparatedString) { contentString, error in
                        guard error == nil else {
                            Crashlytics.sharedInstance().recordError(error!)
                            let error = BackendError.parsing(reason: "Could not obtain the Preferences information")
                            completion(nil, error)
                            return
                        }
                        completion(contentString, error)
                    }
                case .aviationPreferredCuisine:
                    GoLujoAPIManager().setAviationPreferredCuisine(token: token,commSepeartedString: commaSeparatedString, typedPreference: txtPleaseSpecify.text ?? "") { contentString, error in
                        guard error == nil else {
                            Crashlytics.sharedInstance().recordError(error!)
                            let error = BackendError.parsing(reason: "Could not obtain the Preferences information")
                            completion(nil, error)
                            return
                        }
                        completion(contentString, error)
                    }

                case .aviationPreferredBevereges:
                    GoLujoAPIManager().setAviationPreferredBeverages(token: token,commSepeartedString: commaSeparatedString, typedPreference: txtPleaseSpecify.text ?? "") { contentString, error in
                        guard error == nil else {
                            Crashlytics.sharedInstance().recordError(error!)
                            let error = BackendError.parsing(reason: "Could not obtain the Preferences information")
                            completion(nil, error)
                            return
                        }
                        completion(contentString, error)
                    }
                default:
                    print("Not yet required")
                    completion("Success", nil)
            }
            default:
                print("Others")
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
        default:
            print("Others")
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
                    let previouslyTypedStr = self.userPreferences?.gift.gift_habit_id_other ?? ""
                    return !compare(current: current , previous: previous, previousTypedStr:previouslyTypedStr)
                case .giftCategories:
                    let current = self.userPreferences?.gift.gift_category_id ?? []
                    let previous = self.previouslySelectedItems
                    let previouslyTypedStr = self.userPreferences?.gift.gift_category_id_other ?? ""
                    return !compare(current: current , previous: previous, previousTypedStr:previouslyTypedStr)
                case .giftPreferences:
                    let current = self.userPreferences?.gift.gift_preferences_id ?? []
                    let previous = self.previouslySelectedItems
                    let previouslyTypedStr = self.userPreferences?.gift.gift_preferences_id_other ?? ""
                    return !compare(current: current , previous: previous, previousTypedStr:previouslyTypedStr)
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
                let previouslyTypedStr = self.userPreferences?.aviation.aviation_preferred_cuisine_id_other ?? ""
                return !compare(current: current , previous: previous, previousTypedStr:previouslyTypedStr)
            case .aviationPreferredBevereges:
                let current = self.userPreferences?.aviation.aviation_preferred_beverage_id ?? []
                let previous = self.previouslySelectedItems
                let previouslyTypedStr = self.userPreferences?.aviation.aviation_preferred_beverage_id_other ?? ""
                return !compare(current: current , previous: previous, previousTypedStr:previouslyTypedStr)
            default:
                print("This will not call")
            }
            default:
                print("Others")
        }
        return true
    }
    
    func compare(current:String , previous:String) -> Bool{
        if previous == current{
            btnNextStep.setTitle("S K I P", for: .normal)
            return true
        }else{
            btnNextStep.setTitle("S A V E", for: .normal)
            return false
        }
    }
    
    func compare(current:[String] , previous:[String] , previousTypedStr:String? = nil) -> Bool{
        let currentTypedStr = self.txtPleaseSpecify.text
        if (Set(previous ) == Set(current) && (previousTypedStr ?? currentTypedStr == self.txtPleaseSpecify.text)){
            btnNextStep.setTitle("S K I P", for: .normal)
            return true
        }else{
            btnNextStep.setTitle("S A V E", for: .normal)
            return false
        }
    }
    
    //@objc func skipTapped(sender: UIBarButtonItem){
    @objc func skipTapped(){
        if let viewController = navigationController?.viewControllers.first(where: {$0 is PreferencesHomeViewController}) {
              navigationController?.popToViewController(viewController, animated: true)
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
                            cell.backgroundColor = UIColor.rgMid
                            cell.lblTitle.textColor = UIColor.white
                        }else{
                            cell.backgroundColor = UIColor.clear
                            cell.lblTitle.textColor = UIColor.rgMid
                        }
                    }
                case .giftCategories:
                    if let ids = userPreferences?.gift.gift_category_id{
                        if (ids.contains(String(model.termId))){
                            cell.backgroundColor = UIColor.rgMid
                            cell.lblTitle.textColor = UIColor.white
                        }else{
                            cell.backgroundColor = UIColor.clear
                            cell.lblTitle.textColor = UIColor.rgMid
                        }
                    }
                case .giftPreferences:
                    if let ids = userPreferences?.gift.gift_preferences_id{
                        if (ids.contains(String(model.termId))){
                            cell.backgroundColor = UIColor.rgMid
                            cell.lblTitle.textColor = UIColor.white
                        }else{
                            cell.backgroundColor = UIColor.clear
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
                        cell.backgroundColor = UIColor.rgMid
                        cell.lblTitle.textColor = UIColor.white
                    }else{
                        cell.backgroundColor = UIColor.clear
                        cell.lblTitle.textColor = UIColor.rgMid
                    }
                }
            case .aviationInterestedIn:
                if let str = userPreferences?.aviation.aviation_interested_in{
                    if(str.contains(model.name.lowercased()) ){
                        cell.backgroundColor = UIColor.rgMid
                        cell.lblTitle.textColor = UIColor.white
                    }else{
                        cell.backgroundColor = UIColor.clear
                        cell.lblTitle.textColor = UIColor.rgMid
                    }
                }
            case .aviationPreferredCharter:
                if let str = userPreferences?.aviation.aviation_preferred_charter_range{
                    if(model.name.lowercased().contains(str) ){ //model name is longer in length then the str i.e. Long Range and long respectively
                        cell.backgroundColor = UIColor.rgMid
                        cell.lblTitle.textColor = UIColor.white
                    }else{
                        cell.backgroundColor = UIColor.clear
                        cell.lblTitle.textColor = UIColor.rgMid
                    }
                }
            case .aviationPreferredCuisine:
                if let ids = userPreferences?.aviation.aviation_preferred_cuisine_id{
                    if (ids.contains(String(model.termId))){
                        cell.backgroundColor = UIColor.rgMid
                        cell.lblTitle.textColor = UIColor.white
                    }else{
                        cell.backgroundColor = UIColor.clear
                        cell.lblTitle.textColor = UIColor.rgMid
                    }
                }
            case .aviationPreferredBevereges:
                if let ids = userPreferences?.aviation.aviation_preferred_beverage_id{
                    if (ids.contains(String(model.termId))){
                        cell.backgroundColor = UIColor.rgMid
                        cell.lblTitle.textColor = UIColor.white
                    }else{
                        cell.backgroundColor = UIColor.clear
                        cell.lblTitle.textColor = UIColor.rgMid
                    }
                }
            default:
                print("aviation default")
            }
        default:
            print("Others")
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
                }else{
                    userPreferences?.aviation.aviation_interested_in = "purchase"
                }
                self.collectionView.reloadData()    //reload every thing in case of single selection i.e. yes or no
                isSelectionChanged()
                return  // else reloadData() and isSelectionChanged() would be called again
            case .aviationPreferredCharter:
                if (indexPath.row == 0){
                    userPreferences?.aviation.aviation_preferred_charter_range = "short"
                }else{
                    userPreferences?.aviation.aviation_preferred_charter_range = "long"
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
        default:
            print("Others")
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
            return CGSize(width: width, height: PrefCollSize.itemHeight.rawValue)
        case .aviationHaveCharteredBefore:  fallthrough
        case .aviationInterestedIn:       fallthrough
        case .aviationPreferredCharter:
            //width is same as collection container's view i.e. full width
            return CGSize(width: Int(Double(width) * 0.7) , height: PrefCollSize.itemHeight.rawValue)    //70% of the width of collectionveiew
        default:
            //width is half as collection container's view minus margin
            let itemWidth = Int(width / 2)  - PrefCollSize.itemMargin.rawValue / 2    //to keep horizontal and vertical margin same
//            print(width , itemWidth)
            return CGSize(width: itemWidth, height: PrefCollSize.itemHeight.rawValue)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        switch prefInformationType {
        case .aviationHaveCharteredBefore:  fallthrough
        case .aviationInterestedIn:       fallthrough
        case .aviationPreferredCharter:
            // since these are fixed limited values so doubling the margin with the question title
            return UIEdgeInsets(top: CGFloat(PrefCollSize.itemMargin.rawValue * 2), left: 0, bottom: 0, right: 0)
        default:
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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
        case .aviationPreferredCharter:
            // since these are fixed limited values so doubling the margin between the cells
            return CGFloat(PrefCollSize.itemMargin.rawValue * 2)    //vertical margin between cells
        default:
            return CGFloat(PrefCollSize.itemMargin.rawValue)    //vertical margin between cells
        }
        
    }
}

