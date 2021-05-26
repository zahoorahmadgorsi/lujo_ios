//
//  MyPreferencesViewController.swift
//  LUJO
//
//  Created by iMac on 06/05/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import UIKit
import JGProgressHUD

class TwoSliderPrefViewController: UIViewController {
    
    //MARK: - 🎲 - Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "TwoSliderPrefViewController" }
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var imgPreference: UIImageView!
    @IBOutlet weak var lblPrefLabel: UILabel!
    @IBOutlet weak var lblPrefQuestion: UILabel!
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
                    let corporateValue = userPreferences?.aviation.aviation_times_charter_corporate_jet ?? 1
                    let leisureValue = userPreferences?.aviation.aviation_times_charter_leisure_jet ?? 1
                    self.sliderCorporate.value = Float(corporateValue)
                    self.sliderLeisure.value = Float(leisureValue)
                    self.lblCorporateVaue.text = String(corporateValue) + " time" + ( corporateValue > 1 ? "s" : "")
                    self.lblLeisureValue.text = String(leisureValue) + " time" +  ( leisureValue > 1 ? "s" : "")
                    previouslySelectedItems.append(corporateValue)
                    previouslySelectedItems.append(leisureValue)
                    
                    default:
                        print("Others")
                }
            default:
                print("Others")
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
        GoLujoAPIManager().setAviationCharterFrequency(token: token,corporateFrequency: corporateFrequency , leisureFrequency: leisureFrequency) { contentString, error in
            guard error == nil else {
                Crashlytics.sharedInstance().recordError(error!)
                let error = BackendError.parsing(reason: "Could not obtain the Preferences information")
                completion(nil, error)
                return
            }
            completion(contentString, error)
        }
    }
    
    func navigateToNextVC(){
        let viewController = PreferredDestinationaViewController.instantiate(prefType: .aviation, prefInformationType: .aviationPreferredDestination)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    //this method checks the value which were at the time of loading of this screen and current seletion. if loading time value has been changed then button text get changed
    @objc func isSelectionChanged() -> Bool{
        switch self.prefType {
        case .aviation:
            switch self.prefInformationType {
            case .aviationCharterFrequency:
                if (self.userPreferences?.aviation.aviation_times_charter_corporate_jet == self.previouslySelectedItems[0]
                    && self.userPreferences?.aviation.aviation_times_charter_leisure_jet == self.previouslySelectedItems[1]){
                    btnNextStep.setTitle("S K I P", for: .normal)
                    return false
                }else{
                    btnNextStep.setTitle("S A V E", for: .normal)
                    return true
                }
            default:
                print("This will not call")
            }
            default:
                print("Others")
        }
        return true
    }
    
    //@objc func skipTapped(sender: UIBarButtonItem){
    @objc func skipTapped(){
        if let viewController = navigationController?.viewControllers.first(where: {$0 is PreferencesHomeViewController}) {
              navigationController?.popToViewController(viewController, animated: true)
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
        self.userPreferences?.aviation.aviation_times_charter_corporate_jet = currentValue
        isSelectionChanged()
    }
    
    @IBAction func LeisureSliderValueChanged(_ sender: Any) {
        let currentValue = Int(sliderLeisure.value)
//        print("LeisureSliderValueChanged to \(currentValue)")
        DispatchQueue.main.async {
            self.lblLeisureValue.text = "\(currentValue) " + ( currentValue > 1 ? "times" : "time")
        }
        self.userPreferences?.aviation.aviation_times_charter_leisure_jet = currentValue
        isSelectionChanged()
    }
    
}

