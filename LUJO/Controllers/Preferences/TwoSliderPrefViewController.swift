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

class TwoSliderPrefViewController: UIViewController {
    
    //MARK: - 🎲 - Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "TwoSliderPrefViewController" }
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var imgPreference: UIImageView!
    @IBOutlet weak var lblPrefLabel: UILabel!
    @IBOutlet weak var lblPrefQuestion: UILabel!
    @IBOutlet weak var lblCorporate: UILabel!
    @IBOutlet weak var lblLeisure: UILabel!
    
    @IBOutlet weak var lblCorporateMin: UILabel!
    @IBOutlet weak var lblCorporateMax: UILabel!
    @IBOutlet weak var lblLeisureMin: UILabel!
    @IBOutlet weak var lblLeisureMax: UILabel!
    
    @IBOutlet weak var lblCorporateVaue: UILabel!
    @IBOutlet weak var sliderCorporate: UISlider!
    @IBOutlet weak var lblLeisureValue: UILabel!
    @IBOutlet weak var sliderLeisure: UISlider!
    @IBOutlet weak var btnNextStep: UIButton!
    

    private let naHUD = JGProgressHUD(style: .dark)
    var prefType: PrefType!
    var prefInformationType : PrefInformationType!
    var userPreferences: Preferences?
    var preferencesMasterData: PrefMasterData!
    
    //to check if any selection has been changed or not, so that we can change the bottom button text to next from skip
    var previouslySelectedItems:[Int] = []
    var sliderDefaultVal = 1
    
    /// Init method that will init and return view controller.
    //class func instantiate(user: LujoUser) -> MyPreferencesViewController {
    class func instantiate(prefType: PrefType, prefInformationType : PrefInformationType) -> TwoSliderPrefViewController {
        let viewController = UIStoryboard.preferences.instantiate(identifier) as! TwoSliderPrefViewController
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
            case .aviation:
                imgPreference.image = UIImage(named: "aviation_icon")
                lblPrefLabel.text = "Aviation"
                switch prefInformationType {
                case .aviationCharterFrequency:
                    lblPrefQuestion.text = "How many times per year do you charter a jet?"
                    let corporateValue = userPreferences?.aviation.aviation_times_charter_corporate_jet ?? sliderDefaultVal
                    let leisureValue = userPreferences?.aviation.aviation_times_charter_leisure_jet ?? sliderDefaultVal
                    self.sliderCorporate.value = Float(corporateValue)
                    self.sliderLeisure.value = Float(leisureValue)
                    self.lblCorporateVaue.text = String(corporateValue) + " time" + ( corporateValue > 1 ? "s" : "")
                    self.lblLeisureValue.text = String(leisureValue) + " time" +  ( leisureValue > 1 ? "s" : "")
                    self.previouslySelectedItems.append(corporateValue)
                    self.previouslySelectedItems.append(leisureValue)
                    
                default:
                    print("Others")
                }
            case .yachts:
                imgPreference.image = UIImage(named: "Charter Yacht Icon")
                lblPrefLabel.text = "Yacht"
                switch prefInformationType {
                case .yachtCharterFrequency:
                    lblPrefQuestion.text = "How many times per year do you charter a yacht?"
                    lblCorporate.text = "Weekly Charter"
                    lblLeisure.text = "Day Charter"
                    let corporateValue = userPreferences?.yacht.yacht_times_charter_corporate_jet ?? sliderDefaultVal
                    let leisureValue = userPreferences?.yacht.yacht_times_charter_leisure_jet ?? sliderDefaultVal
                    self.sliderCorporate.value = Float(corporateValue)
                    self.sliderLeisure.value = Float(leisureValue)
                    self.lblCorporateVaue.text = String(corporateValue) + " time" + ( corporateValue > 1 ? "s" : "")
                    self.lblLeisureValue.text = String(leisureValue) + " time" +  ( leisureValue > 1 ? "s" : "")
                    self.previouslySelectedItems.append(corporateValue)
                    self.previouslySelectedItems.append(leisureValue)
                    
                default:
                    print("default of prefInformationType")
                }
            case .travel:
                imgPreference.image = UIImage(named: "Find Hotel Icon")
                lblPrefLabel.text = "Travel"
                switch prefInformationType {
                case .travelFrequency:
                    lblPrefQuestion.text = "Approximately how many times do you travel in a year?"
                    lblCorporate.text = "Business"
                    lblLeisure.text = "Leisure"
                    let corporateValue = userPreferences?.travel.travel_times_business ?? sliderDefaultVal
                    let leisureValue = userPreferences?.travel.travel_times_leisure ?? sliderDefaultVal
                    self.sliderCorporate.value = Float(corporateValue)
                    self.sliderLeisure.value = Float(leisureValue)
                    self.lblCorporateVaue.text = String(corporateValue) + " time" + ( corporateValue > 1 ? "s" : "")
                    self.lblLeisureValue.text = String(leisureValue) + " time" +  ( leisureValue > 1 ? "s" : "")
                    self.previouslySelectedItems.append(corporateValue)
                    self.previouslySelectedItems.append(leisureValue)
                case .travelCabinClass:
                    lblPrefQuestion.text = "Which cabin class do you prefer?"
                    lblCorporate.text = "Business"
                    lblLeisure.text = "Leisure"
                    lblCorporateMin.text = CabinClass.Economy.rawValue
                    lblCorporateMax.text = CabinClass.Business.rawValue
                    lblLeisureMin.text = CabinClass.Economy.rawValue
                    lblLeisureMax.text = CabinClass.Business.rawValue
                    self.sliderCorporate.minimumValue = 0
                    self.sliderCorporate.maximumValue = 3
                    self.sliderLeisure.minimumValue = 0
                    self.sliderLeisure.maximumValue = 3
                    let corporateValue = userPreferences?.travel.travel_airplane_business_cabin_class?[0] ?? intToCabinClass(int: sliderDefaultVal)
                    let leisureValue = userPreferences?.travel.travel_airplane_leisure_cabin_class?[0] ?? intToCabinClass(int: sliderDefaultVal)
                    self.sliderCorporate.value = Float(cabinClassToInt(cabinClass: corporateValue))
                    self.sliderLeisure.value = Float(cabinClassToInt(cabinClass: leisureValue))
                    self.lblCorporateVaue.text = corporateValue
                    self.lblLeisureValue.text = leisureValue
                    self.previouslySelectedItems.append(Int(cabinClassToInt(cabinClass: corporateValue)))
                    self.previouslySelectedItems.append(Int(cabinClassToInt(cabinClass: leisureValue)))
                default:
                    print("default of prefInformationType")
                }
            default:
                print("default of main switch")
        }
    }

    func cabinClassToInt(cabinClass: String)-> Int{
        if cabinClass.equals(rhs: CabinClass.Economy.rawValue){
            return 0
        }else if cabinClass.equals(rhs: CabinClass.Business.rawValue){
            return 1
        }else if cabinClass.equals(rhs: CabinClass.First.rawValue){
            return 2
        }else{
            return 1
        }
    }
    
    func intToCabinClass(int: Int)-> String{
        if int == 0 {
            return CabinClass.Economy.rawValue
        }else if int == 1{
            return CabinClass.Business.rawValue
        }else if int == 2{
            return CabinClass.First.rawValue
        }else{
            return CabinClass.Economy.rawValue
        }
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
            let corporateFrequency = Int(self.sliderCorporate.value)
            let leisureFrequency = Int(self.sliderLeisure.value)
            
            self.showNetworkActivity()
            setPreferencesInformation(corporateFrequency: corporateFrequency , leisureFrequency:leisureFrequency)  {information, error in
                self.hideNetworkActivity()
                if let error = error {
                    self.showError(error)
                    return
                }
                if let informations = information {
                    if var userPreferences = self.userPreferences{
                        userPreferences.aviation.aviation_times_charter_corporate_jet = corporateFrequency
                        userPreferences.aviation.aviation_times_charter_leisure_jet = leisureFrequency
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
    
    func setPreferencesInformation( corporateFrequency: Int , leisureFrequency: Int, completion: @escaping (String?, Error?) -> Void) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            completion(nil, LoginError.errorLogin(description: "User does not exist or is not verified"))
            return
        }
        switch self.prefType {
        case .aviation:
            switch self.prefInformationType {
            case .aviationCharterFrequency:
                GoLujoAPIManager().setAviationCharterFrequency(token: token,corporateFrequency: corporateFrequency , leisureFrequency: leisureFrequency) { contentString, error in
                    guard error == nil else {
                        Crashlytics.sharedInstance().recordError(error!)
                        let error = BackendError.parsing(reason: "Could not obtain the Preferences information")
                        completion(nil, error)
                        return
                    }
                    completion(contentString, error)
                }
            default:
                print("This will not call")
            }
        case .yachts:
            switch self.prefInformationType {
            case .yachtCharterFrequency:
                GoLujoAPIManager().setYachtCharterFrequency(token: token,corporateFrequency: corporateFrequency , leisureFrequency: leisureFrequency) { contentString, error in
                    guard error == nil else {
                        Crashlytics.sharedInstance().recordError(error!)
                        let error = BackendError.parsing(reason: "Could not obtain the Preferences information")
                        completion(nil, error)
                        return
                    }
                    completion(contentString, error)
                }
            default:
                print("This will not call")
            }
        case .travel:
            switch self.prefInformationType {
            case .travelFrequency:
                GoLujoAPIManager().setTravelFrequency(token: token, corporateFrequency: corporateFrequency , leisureFrequency: leisureFrequency) { contentString, error in
                    guard error == nil else {
                        Crashlytics.sharedInstance().recordError(error!)
                        let error = BackendError.parsing(reason: "Could not obtain the preferences information")
                        completion(nil, error)
                        return
                    }
                    completion(contentString, error)
                }
            case .travelCabinClass:
                GoLujoAPIManager().setTravelCabinClass(token: token, cabinClass: intToCabinClass(int: corporateFrequency), leisureClass: intToCabinClass(int: leisureFrequency)) { (contentString, error) in
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
        case .aviation:
            switch self.prefInformationType {
            case .aviationCharterFrequency:
                let viewController = PreferredDestinationaViewController.instantiate(prefType: .aviation, prefInformationType: .aviationPreferredDestination)
                self.navigationController?.pushViewController(viewController, animated: true)
            default:
                print("This will not call")
            }
        case .yachts:
            switch self.prefInformationType {
            case .yachtCharterFrequency:
                let viewController = PreferredDestinationaViewController.instantiate(prefType: .yachts, prefInformationType: .yachtPreferredRegions)
                self.navigationController?.pushViewController(viewController, animated: true)
            default:
                print("This will not call")
            }
        case .travel:
            switch self.prefInformationType {
            case .travelFrequency:
                let viewController = PreferredDestinationaViewController.instantiate(prefType: .travel, prefInformationType: .travelDestinations)
                self.navigationController?.pushViewController(viewController, animated: true)
            case .travelCabinClass:
                let viewController = PrefCollectionsViewController.instantiate(prefType: .travel, prefInformationType: .travelMeals)
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
        case .aviation:
            switch self.prefInformationType {
            case .aviationCharterFrequency:
                var current :[Int] = []
                current.append(self.userPreferences?.aviation.aviation_times_charter_corporate_jet ?? sliderDefaultVal)  //default value is set to 1
                current.append(self.userPreferences?.aviation.aviation_times_charter_leisure_jet ?? sliderDefaultVal)
                let previous = self.previouslySelectedItems
                return !compare(current: current , previous: previous)
            default:
                print("This will not call")
            }
        case .yachts:
            switch self.prefInformationType {
            case .yachtCharterFrequency:
                var current :[Int] = []
                current.append(self.userPreferences?.yacht.yacht_times_charter_corporate_jet ?? sliderDefaultVal)  //default value is set to 1
                current.append(self.userPreferences?.yacht.yacht_times_charter_leisure_jet ?? sliderDefaultVal)
                let previous = self.previouslySelectedItems
                return !compare(current: current , previous: previous)
            default:
                print("This will not call")
            }
        case .travel:
            switch self.prefInformationType {
            case .travelFrequency:
                var current :[Int] = []
                current.append(self.userPreferences?.travel.travel_times_business ?? sliderDefaultVal)  //default value is set to 1
                current.append(self.userPreferences?.travel.travel_times_leisure ?? sliderDefaultVal)
                let previous = self.previouslySelectedItems
                return !compare(current: current , previous: previous)
            case .travelCabinClass:
                var current :[Int] = []
                let businessClass = cabinClassToInt(cabinClass: self.userPreferences?.travel.travel_airplane_business_cabin_class?[0] ?? "")
                let leisureClass = cabinClassToInt(cabinClass: self.userPreferences?.travel.travel_airplane_leisure_cabin_class?[0] ?? "")
                
                current.append(businessClass)  //default value is set to firstclass
                current.append(leisureClass)
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
//            btnNextStep.setTitle("S K I P", for: .normal)
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
    
    @IBAction func corporateSliderValueChanged(_ sender: Any) {
        let currentValue = Int(sliderCorporate.value)
//        print("corporateSliderValueChanged to \(currentValue)")
        DispatchQueue.main.async {
            self.lblCorporateVaue.text = "\(currentValue) " + ( currentValue > 1 ? "times" : "time")
        }
        switch self.prefType {
        case .aviation:
            switch self.prefInformationType {
            case .aviationCharterFrequency:
                self.userPreferences?.aviation.aviation_times_charter_corporate_jet = currentValue
            default:
                print("This will not call")
            }
        case .yachts:
            switch self.prefInformationType {
            case .yachtCharterFrequency:
                self.userPreferences?.yacht.yacht_times_charter_corporate_jet = currentValue
            default:
                print("This will not call")
            }
        case .travel:
            switch self.prefInformationType {
            case .travelFrequency:
                self.userPreferences?.travel.travel_times_business = currentValue
            case .travelCabinClass:
                let strCurrentVal = intToCabinClass( int: currentValue)
                DispatchQueue.main.async {
                    self.lblCorporateVaue.text = strCurrentVal
                }
                self.userPreferences?.travel.travel_airplane_business_cabin_class = []
                self.userPreferences?.travel.travel_airplane_business_cabin_class?.append(strCurrentVal)
            default:
                print("This will not call")
            }
        default:
            print("Main default")
        }
        
        isSelectionChanged()
    }
    
    @IBAction func LeisureSliderValueChanged(_ sender: Any) {
        let currentValue = Int(sliderLeisure.value)
//        print("LeisureSliderValueChanged to \(currentValue)")
        DispatchQueue.main.async {
            self.lblLeisureValue.text = "\(currentValue) " + ( currentValue > 1 ? "times" : "time")
        }
        switch self.prefType {
        case .aviation:
            switch self.prefInformationType {
            case .aviationCharterFrequency:
                self.userPreferences?.aviation.aviation_times_charter_leisure_jet = currentValue
            default:
                print("This will not call")
            }
        case .yachts:
            switch self.prefInformationType {
            case .yachtCharterFrequency:
                self.userPreferences?.yacht.yacht_times_charter_leisure_jet = currentValue
            default:
                print("This will not call")
            }
        case .travel:
            switch self.prefInformationType {
            case .travelFrequency:
                self.userPreferences?.travel.travel_times_leisure = currentValue
            case .travelCabinClass:
                let strCurrentVal = intToCabinClass( int: currentValue)
                DispatchQueue.main.async {
                    self.lblLeisureValue.text = strCurrentVal
                }
                self.userPreferences?.travel.travel_airplane_leisure_cabin_class = []
                self.userPreferences?.travel.travel_airplane_leisure_cabin_class?.append(strCurrentVal)
            default:
                print("This will not call")
            }
        default:
            print("Main default")
        }
        
        isSelectionChanged()
    }
    
}

