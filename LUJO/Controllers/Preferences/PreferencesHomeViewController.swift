//
//  MyPreferencesViewController.swift
//  LUJO
//
//  Created by iMac on 06/05/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import UIKit
import JGProgressHUD

enum PrefCollSize:Int{
//    case aviationItemWidth = 250
    case itemHeight = 40
    case itemCategoryHeight = 50
//    case itemHorizontalMargin = 16
    case itemMargin = 24    //both horizontal and vertical
    case itemCategoryVerticalMargin = 8
}
enum CabinClass:String{
    case First
    case Business
    case Economy
}

enum PrefType:String{
    case gifts
    case aviation
    case dining
    case travel
    case villas
    case yachts
    case events
    case profile
}

enum PrefInformationType:String{
    case giftHabbits
    case giftCategories
    case giftPreferences
    case aviationHaveCharteredBefore
    case aviationInterestedIn
    case aviationCharterFrequency
    case aviationPreferredDestination
    case aviationPreferredAirport
    case aviationAircraftCategory
    case aviationPreferredCharter
    case aviationPreferredCuisine
    case aviationPreferredBevereges
    case yachtHaveCharteredBefore
    case yachtInterestedIn
    case yachtCharterFrequency
    case yachtPreferredRegions
    case yachtPreferredLength
    case yachtType
    case yachtStyle
    case yachtPreferredCuisines
    case yachtOtherInterests
    case diningAllergies
    case diningPreferences
    case diningTimings
    case diningSeatings
    case diningBeverages
    case diningCuisines
    case eventCategory
    case eventLocation
    
    case travelFrequency
    case travelDestinations
    case travelHotelRating
    case travelDestinationType
    case travelHotelGroups
    case travelAmenities
    case travelActivities
    case travelAirlines
    case travelAirplaneSeat
    case travelCabinClass
    case travelMeals
    case travelMedicalMeals
    case travelHotelStyles
    case travelAllergies
    
    case villaDestinations
    case villaAmenities
    case villaAccomodation
    case profile
}

enum PreferenceError: Error {
    case onlyAlphaNumeric(reason: String)
}
extension PreferenceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .onlyAlphaNumeric(reason):
            return NSLocalizedString(reason, comment: "")
        }
    }
}



class PreferencesHomeViewController: UIViewController {
    
    //MARK: - 🎲 - Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "PreferencesHomeViewController" }
    
    @IBOutlet weak var viewGifts: UIView!
    @IBOutlet weak var viewAviation: UIView!
    @IBOutlet weak var viewDining: UIView!
    @IBOutlet weak var viewTravel: UIView!
    @IBOutlet weak var viewVillas: UIView!
    @IBOutlet weak var viewYachts: UIView!
    @IBOutlet weak var viewEvents: UIView!
    /// Init method that will init and return view controller.
    //class func instantiate(user: LujoUser) -> MyPreferencesViewController {
    class func instantiate() -> PreferencesHomeViewController {
        let viewController = UIStoryboard.preferences.instantiate(identifier) as! PreferencesHomeViewController
//        viewController.user = user
        return viewController
    }
    private let naHUD = JGProgressHUD(style: .dark)
    
    //MARK:- Globals
    
//    private(set) var user: LujoUser!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Tapped event on full gifts view
        let tgr1 = UITapGestureRecognizer(target: self, action: #selector(tappedOnView))
        viewGifts.isUserInteractionEnabled = true
        viewGifts.addGestureRecognizer(tgr1)
        //Tapped event on full aviation view
        let tgr2 = UITapGestureRecognizer(target: self, action: #selector(tappedOnView))
        viewAviation.isUserInteractionEnabled = true
        viewAviation.addGestureRecognizer(tgr2)
        //Tapped event on full viewDining view
        let tgr3 = UITapGestureRecognizer(target: self, action: #selector(tappedOnView))
        viewDining.isUserInteractionEnabled = true
        viewDining.addGestureRecognizer(tgr3)
        //Tapped event on full viewTravel view
        let tgr4 = UITapGestureRecognizer(target: self, action: #selector(tappedOnView))
        viewTravel.isUserInteractionEnabled = true
        viewTravel.addGestureRecognizer(tgr4)
        //Tapped event on full viewVillas view
        let tgr5 = UITapGestureRecognizer(target: self, action: #selector(tappedOnView))
        viewVillas.isUserInteractionEnabled = true
        viewVillas.addGestureRecognizer(tgr5)
        //Tapped event on full viewYachts view
        let tgr6 = UITapGestureRecognizer(target: self, action: #selector(tappedOnView))
        viewYachts.isUserInteractionEnabled = true
        viewYachts.addGestureRecognizer(tgr6)
        //Tapped event on full viewEvents view
        let tgr7 = UITapGestureRecognizer(target: self, action: #selector(tappedOnView))
        viewEvents.isUserInteractionEnabled = true
        viewEvents.addGestureRecognizer(tgr7)
        
        let opacity = 0.3
        let user = LujoSetup().getLujoUser()
        if (user?.membershipPlan?.plan == "All" ){ //free
            print("All preferences are visible to those who has full membership")
        }else if (user?.membershipPlan?.plan == "Dining" ){ //dining
            //hide all except aviation
            viewGifts.isUserInteractionEnabled = false
            viewGifts.alpha = CGFloat(opacity)
            
            viewTravel.isUserInteractionEnabled = false
            viewTravel.alpha = CGFloat(opacity)
            
            viewVillas.isUserInteractionEnabled = false
            viewVillas.alpha = CGFloat(opacity)
            
            viewYachts.isUserInteractionEnabled = false
            viewYachts.alpha = CGFloat(opacity)
            
            viewEvents.isUserInteractionEnabled = false
            viewEvents.alpha = CGFloat(opacity)
        }else{//all user?.membershipPlan = nil
            //hide all except aviation
            viewGifts.isUserInteractionEnabled = false
//            viewGifts.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            viewGifts.alpha = CGFloat(opacity)
            
            viewDining.isUserInteractionEnabled = false
            viewDining.alpha = CGFloat(opacity)
            
            viewTravel.isUserInteractionEnabled = false
            viewTravel.alpha = CGFloat(opacity)
            
            viewVillas.isUserInteractionEnabled = false
            viewVillas.alpha = CGFloat(opacity)
            
            viewYachts.isUserInteractionEnabled = false
            viewYachts.alpha = CGFloat(opacity)
            
            viewEvents.isUserInteractionEnabled = false
            viewEvents.alpha = CGFloat(opacity)
        }
        //getAllUserPreferences is in homeviewcontroller
        NotificationCenter.default.post(name: Notification.Name(rawValue: "getAllUserPreferences"), object: nil)
        //getAllUserPreferences()    //fetching all preferences from the server
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = "My Preferences"
        activateKeyboardManager()
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationItem.title = ""
        self.tabBarController?.tabBar.isHidden = false
    }
    
    //when user will click on the back button at the bottom
    @IBAction func btnBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //when user will click on the chat button at the bottom
    @IBAction func requestBooking(_ sender: Any) {
        sendInitialInformation()
    }
    
    fileprivate func sendInitialInformation() {
        if LujoSetup().getLujoUser()?.membershipPlan != nil {
            guard let userFirstName = LujoSetup().getLujoUser()?.firstName else { return }
            let initialMessage = """
            Hi Concierge team,
            
            I want to know the details about my preferences, can you please assist me?
            
            \(userFirstName)
            """
            
            let viewController = AdvanceChatViewController()
            viewController.product = Product(id: -1 , type: "Preferences" , name: "Preferences Inquiry")
            viewController.initialMessage = initialMessage
            self.navigationController?.pushViewController(viewController,animated: true)
        } else {
            showInformationPopup()
        }
        
    }
    
    @objc func tappedOnView(_ sender:AnyObject){
        switch sender.view.tag {
        case 0:
            let viewController = PrefCollectionsViewController.instantiate(prefType: .gifts, prefInformationType: .giftHabbits)
            self.navigationController?.pushViewController(viewController, animated: true)
        case 1:
            let viewController = PrefCollectionsViewController.instantiate(prefType: .aviation, prefInformationType: .aviationHaveCharteredBefore)
            self.navigationController?.pushViewController(viewController, animated: true)
        case 2:
            let viewController = PrefCollectionsViewController.instantiate(prefType: .dining, prefInformationType: .diningCuisines)
            self.navigationController?.pushViewController(viewController, animated: true)
        case 3:
            let viewController = TwoSliderPrefViewController.instantiate(prefType: .travel, prefInformationType: .travelFrequency)
            self.navigationController?.pushViewController(viewController, animated: true)
        case 4:
            let viewController = PreferredDestinationaViewController.instantiate(prefType: .villas, prefInformationType: .villaDestinations)
            self.navigationController?.pushViewController(viewController, animated: true)
        case 5:
            let viewController = PrefCollectionsViewController.instantiate(prefType: .yachts, prefInformationType: .yachtHaveCharteredBefore)
            self.navigationController?.pushViewController(viewController, animated: true)
        case 6:
            let viewController = PrefCollectionsViewController.instantiate(prefType: .events, prefInformationType: .eventCategory)
            self.navigationController?.pushViewController(viewController, animated: true)
        default:
            print("Others")
        }
    }
}
