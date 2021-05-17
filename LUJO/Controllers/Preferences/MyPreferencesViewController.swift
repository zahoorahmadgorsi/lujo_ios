//
//  MyPreferencesViewController.swift
//  LUJO
//
//  Created by iMac on 06/05/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import UIKit

class MyPreferencesViewController: UIViewController {
    
    //MARK: - 🎲 - Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "MyPreferencesViewController" }
    
    @IBOutlet weak var viewGifts: UIView!
    @IBOutlet weak var viewAnimation: UIView!
    @IBOutlet weak var viewDining: UIView!
    @IBOutlet weak var viewTravel: UIView!
    @IBOutlet weak var viewVillas: UIView!
    @IBOutlet weak var viewYachts: UIView!
    /// Init method that will init and return view controller.
    //class func instantiate(user: LujoUser) -> MyPreferencesViewController {
    class func instantiate() -> MyPreferencesViewController {
        let viewController = UIStoryboard.preferences.instantiate(identifier) as! MyPreferencesViewController
//        viewController.user = user
        return viewController
    }

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
        viewAnimation.isUserInteractionEnabled = true
        viewAnimation.addGestureRecognizer(tgr2)
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
        guard let userFirstName = LujoSetup().getLujoUser()?.firstName else { return }
        let initialMessage = """

        Hi Concierge team,
        
        I want to know the details about my preferences, can you please assist me?
        
        \(userFirstName)
        """
        
        startChatWithInitialMessage(initialMessage)
        
    }
    
    @objc func tappedOnView(_ sender:AnyObject){
        switch sender.view.tag {
        case 0:
            let viewController = PrefCollectionsViewController.instantiate(prefType: .gifts, prefInformationType: .giftHabbits)
            self.navigationController?.pushViewController(viewController, animated: true)
        case 1:
            let viewController = PrefCollectionsViewController.instantiate(prefType: .aviation, prefInformationType: .aviationHaveCharteredBefore)
            self.navigationController?.pushViewController(viewController, animated: true)
        default:
            print("Others")
        }
        
        
    }
}
