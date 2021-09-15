//
//  AccountViewController.swift
//  LUJO
//
//  Created by Iker Kristian on 8/30/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import JGProgressHUD
import Kingfisher
import Delighted

class AccountViewController: UIViewController {
    
    
    //MARK: - 🎲 - Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "AccountViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate(user: LujoUser) -> AccountViewController {
        let viewController = UIStoryboard.accountNEW.instantiate(identifier) as! AccountViewController
        viewController.user = user
        return viewController
    }
    
    //MARK:- Globals
    
    private(set) var user: LujoUser!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var pictureUpdateLabel: UILabel!
    @IBOutlet weak var lblMyBookings: UILabel!
    @IBOutlet weak var lblMyPreferences: UILabel!
    @IBOutlet weak var lujoCreditsLabel: UILabel!
    
    @IBOutlet weak var updateProfileLabel: UILabel!
    @IBOutlet weak var logoutLabel: UILabel!
    
    private let naHUD = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pictureTapResponder = UITapGestureRecognizer(target: self, action: #selector(updateUserPicture(_:)))
        userImage.addGestureRecognizer(pictureTapResponder)
        
        let labelTapResponder = UITapGestureRecognizer(target: self, action: #selector(updateUserPicture(_:)))
        pictureUpdateLabel.addGestureRecognizer(labelTapResponder)
        
        let lblMyBookingsTapResponder = UITapGestureRecognizer(target: self, action: #selector(lblMyBookingsTapped))
        lblMyBookings.addGestureRecognizer(lblMyBookingsTapResponder)
        
        let lblMyPreferencesTapResponder = UITapGestureRecognizer(target: self, action: #selector(lblMyPreferencesTapped))
        lblMyPreferences.addGestureRecognizer(lblMyPreferencesTapResponder)
        
        let userProfileTapResponder = UITapGestureRecognizer(target: self, action: #selector(presentUserProfileViewController))
        updateProfileLabel.addGestureRecognizer(userProfileTapResponder)

        let logoutTapResponder = UITapGestureRecognizer(target: self, action: #selector(requestLogout))
        logoutLabel.addGestureRecognizer(logoutTapResponder)
        
        if let user = LujoSetup().getLujoUser(), user.id > 0 {
            let person = Person(
                name: user.firstName + " " + user.lastName,
                email: user.email,
                phoneNumber: user.phoneNumber.readableNumber
            )

            let eligibilityOverrides = EligibilityOverrides(
//                testMode: true
                testMode: false
                ,initialDelay: 86400
            )
            
            Delighted.survey(delightedID: "mobile-sdk-RuEQ5n7SDsCU6roX", person: person, eligibilityOverrides: eligibilityOverrides , callback: { (status) in
                switch status {
                case let .failedClientEligibility(status):
                    print(status)
                    print("Eligibility check failed")
                    // Maybe log this?
                    // Do any view/screen changes that you need
                case let .error(status):
                    print(status)
                    print("An error occurred")
                    // Maybe log this?
                case let .surveyClosed(status):
                    print(status)
                    print("Survey closed")
                    // Re-register for keyboard notifications if unregistered
                    // Do any view/screen changes that you need
                }
            })
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = "My Account"
        lujoCreditsLabel.text = "\(user.points)"
        activateKeyboardManager()
        setupUserImage()
        setupWelcomeMessage()
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationItem.title = ""
        self.tabBarController?.tabBar.isHidden = false
    }

    fileprivate func setupUserImage() {
        if UIDevice.isiPhone5 || UIDevice.isIphone6Zoomed {
            stackView.spacing = 16
        } else if UIDevice.isiPhone6 || UIDevice.isIphone6PlusZoomed {
            stackView.spacing = 20
        }
        
        if let url = URL(string: user.avatar) {
            self.userImage.kf.setImage(with: url, placeholder: UIImage(named: "placeholder-img"), completionHandler: { result in
                switch result {
                case .success(_):
                    DispatchQueue.main.async {
                        self.userImage.contentMode = .scaleAspectFill
                        self.pictureUpdateLabel.text = "Change profile photo"
                    }
                case .failure(_):
                    DispatchQueue.main.async {
                        self.userImage.image = UIImage(named: "User Anonimous Image")
                        self.userImage.tintColor = #colorLiteral(red: 0.5019036531, green: 0.5019937158, blue: 0.5018979907, alpha: 1)
                        self.userImage.contentMode = .center
                        self.pictureUpdateLabel.text = "Add profile photo"
                    }
                }
            })
        }
        
        userImage.setRounded()
    }
    
    fileprivate func setupWelcomeMessage() {
        let userInformation = LujoSetup().getLujoUser()
        
        var welcomeText = ""
        if let title = userInformation?.title {
            welcomeText += "\(title) "
        }
        if let firstName = userInformation?.firstName {
            welcomeText += "\(firstName) "
        }
        if let lastName = userInformation?.lastName {
            welcomeText += "\(lastName)"
        }
        welcomeLabel.text = welcomeText.isEmpty ? "-" : welcomeText
    }
    
    @IBAction func updateUserPicture(_: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            let imagePicker = UIImagePickerController()
            
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @objc func lblMyBookingsTapped() {
//        print("lblMyBookingsTapped")
        let viewController = BookingsViewController.instantiate()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func lblMyPreferencesTapped() {
        print("lblMyPreferencesTapped")
        let viewController = PreferencesHomeViewController.instantiate()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func inviteFriendsButton_onClick(_ sender: Any) {
        let activityViewController = UIActivityViewController(
            activityItems: ["""
            It's my pleasure to invite you to join Lujo our new ultimate lifestyle management platform filled with curated content that brings the world's best experiences to your fingertips. Download Lujo for iPhone https://apps.apple.com/us/app/lujo/id1233843327 and become a member to enjoy the finest that the world has to offer. Mmbership awaits you with a unique code \(user.referralCode).
            """],
            applicationActivities: nil
        )
        
        present(activityViewController, animated: true, completion: nil)
    }
    
    @objc func presentUserProfileViewController() {
        let viewController = UserProfileViewController.instantiate(user: user)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func requestLogout() {
        showCardAlertWith(title: "Log out", body: "Are you sure you want to log out?", buttonTitle: "Yes", cancelButtonTitle: "No") {
             self.logoutUser()
        }
    }
    
    func showError(_ error: Error) {
        showErrorPopup(withTitle: "Events Error", error: error)
    }
    
    func showFeedback(_ message: String) {
        showInformationPopup(withTitle: "Information", message: message)
    }
    
    func showNetworkActivity() {
        naHUD.show(in: view)
    }
    
    func hideNetworkActivity() {
        naHUD.dismiss()
    }
    
    @IBAction func membershipButton_onClick(_ sender: UIButton) {
        if let userFullname = self.welcomeLabel.text {
            let hasMembership = LujoSetup().getLujoUser()?.membershipPlan ?? nil != nil
            let viewController = MembershipViewControllerNEW.instantiate(userFullname: userFullname, screenType: hasMembership ? .viewMembership : .buyMembership, paymentType: LujoSetup().getLujoUser()?.membershipPlan?.target == "dining" ? .dining : .all)
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

extension AccountViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[.editedImage] as? UIImage else {
//            print("No image selected")
            return
        }
        
        showNetworkActivity()
        GoLujoAPIManager().update(user: self.user, image: image) { path, error in
            self.hideNetworkActivity()
            if let path = path {
//                print("😇😇😇😇😇😇😇😇😇😇😇😇😇\(path)")
                KingfisherManager.shared.cache.store(image, forKey: path)
                if let user = LujoSetup().getLujoUser() {
                    user.avatar = path  
                    LujoSetup().store(userInfo: user)
                    self.pictureUpdateLabel.text = "Change profile photo"
                    self.showFeedback("You successfully changed your profile image")
                }
                
            } else if let error = error {
                self.showError(error)
                self.userImage.downloadImageFrom(link: LujoSetup().getLujoUser()?.avatar ?? "", contentMode: .scaleAspectFill)
            }
        }
        
        DispatchQueue.main.async {
            self.userImage.image = image
            self.userImage.contentMode = .scaleAspectFill
        }
    }
}

extension AccountViewController {
    
    func logoutUser() {
        guard let userId = LujoSetup().getLujoUser()?.id else {
//            print("NO USER ID ERROR!!!")
            return
        }
        
        showNetworkActivity()
        logoutUser { _ in
            self.hideNetworkActivity()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.removePushToken(userId: userId)
          
            // Present login view controller using VIPER.
            appDelegate.windowRouter.navigate(from: "/", data: [:])
        }
        //deleting every thing from user defaults
        let appDomain = Bundle.main.bundleIdentifier!
        //Calling this method is equivalent to initializing a user defaults object with init(suiteName:) passing domainName, and calling the removeObject(forKey:) method on each of its keys.
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
    }
    
    func logoutUser(completion: @escaping (Error?) -> Void) {
        LujoSetup().deleteCurrentUser()
        completion(nil)
    }
    
}
