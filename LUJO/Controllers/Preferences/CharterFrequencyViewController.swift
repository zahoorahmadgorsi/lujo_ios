//
//  MyPreferencesViewController.swift
//  LUJO
//
//  Created by iMac on 06/05/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import UIKit
import JGProgressHUD

class CharterFrequencyViewController: UIViewController {
    
    //MARK: - 🎲 - Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "CharterFrequencyViewController" }
    
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

    
    /// Init method that will init and return view controller.
    //class func instantiate(user: LujoUser) -> MyPreferencesViewController {
    class func instantiate() -> CharterFrequencyViewController {
        let viewController = UIStoryboard.preferences.instantiate(identifier) as! CharterFrequencyViewController
        return viewController
    }

    //MARK:- Globals
    
//    private(set) var user: LujoUser!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Skip for now", style: .plain, target: self, action: #selector(skipTapped))
        self.contentView.addViewBorder( borderColor: UIColor.white.cgColor, borderWith: 1.0,borderCornerRadius: 12.0)
        
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
        skipTapped()
    }
    
    func setPreferences(commaSeperatedString:String) {
        self.showNetworkActivity()
        setPreferencesInformation(commaSeperatedString: commaSeperatedString) {information, error in
            self.hideNetworkActivity()
            if let error = error {
                self.showError(error)
                return
            }
            if let informations = information {
                self.navigateToNextVC()
            } else {
                let error = BackendError.parsing(reason: "Could not set the Preferences")
                self.showError(error)
            }
        }
    }
    
    func navigateToNextVC(){
        let viewController = PrefCollectionsViewController.instantiate(prefType: .gifts, prefInformationType: .giftPreferences)
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    func setPreferencesInformation(commaSeperatedString:String, completion: @escaping (String?, Error?) -> Void) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            completion(nil, LoginError.errorLogin(description: "User does not exist or is not verified"))
            return
        }
        GoLujoAPIManager().setGiftHabbits(token: token,commSepeartedString: commaSeperatedString) { contentString, error in
            guard error == nil else {
                Crashlytics.sharedInstance().recordError(error!)
                let error = BackendError.parsing(reason: "Could not obtain the Preferences information")
                completion(nil, error)
                return
            }
            completion(contentString, error)
        }
        
        
    }
    
    //@objc func skipTapped(sender: UIBarButtonItem){
    @objc func skipTapped(){
        if let viewController = navigationController?.viewControllers.first(where: {$0 is MyPreferencesViewController}) {
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
            self.lblCorporateVaue.text = "\(currentValue) times"
        }
    }
    
    @IBAction func LeisureSliderValueChanged(_ sender: Any) {
        let currentValue = Int(sliderLeisure.value)
//        print("LeisureSliderValueChanged to \(currentValue)")
        DispatchQueue.main.async {
            self.lblLeisureValue.text = "\(currentValue) times"
        }
    }
    
}

