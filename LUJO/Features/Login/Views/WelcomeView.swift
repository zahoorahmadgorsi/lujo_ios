//
//  WelcomeView.swift
//  LUJO
//
//  Created by Nemanja Djurisic on 8/8/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import JGProgressHUD
import UIKit
import Mixpanel

class WelcomeView: UIViewController, LoginViewProtocol {
    var presenter: LoginViewResponder?
    private let naHUD = JGProgressHUD(style: .dark)

    @IBOutlet var welcomeLabel: UILabel!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var wineImageView: UIImageView!
    @IBOutlet var seaImageView: UIImageView!
    @IBOutlet var foodImageView: UIImageView!
    @IBOutlet var sportImageView: UIImageView!
    @IBOutlet var avioImageView: UIImageView!
    @IBOutlet var watchImageView: UIImageView!
    @IBOutlet weak var nextButton: DarkActionButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        presenter?.update(view: self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUI()
    }

    private func updateUI() {
        
        // Ensure all future events sent from
        // the library will have the distinct_id -13793
        if let id = LujoSetup().getLujoUser()?.id{
            Mixpanel.mainInstance().identify(distinctId: String(id))
        }else{
            Mixpanel.mainInstance().identify(distinctId: "-13793")
        }
        
        welcomeLabel.text = "Welcome to LUJO,\n\(LujoSetup().getLujoUser()?.firstName ?? "") \(LujoSetup().getLujoUser()?.lastName ?? "")"

        UIView.animate(withDuration: 0.3) {
            self.wineImageView.alpha = 1
        }

        UIView.animate(withDuration: 0.3, delay: 0.15, options: .curveEaseIn, animations: {
            self.watchImageView.alpha = 1
        })

        UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseIn, animations: {
            self.seaImageView.alpha = 1
        })

        UIView.animate(withDuration: 0.3, delay: 0.45, options: .curveEaseIn, animations: {
            self.sportImageView.alpha = 1
        })

        UIView.animate(withDuration: 0.3, delay: 0.6, options: .curveEaseIn, animations: {
            self.foodImageView.alpha = 1
        })

        UIView.animate(withDuration: 0.3, delay: 0.75, options: .curveEaseIn, animations: {
            self.avioImageView.alpha = 1
        }, completion: { _ in
            self.nextButton.isEnabled = true
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.registerForPushNotifications()
        })
    }

    @IBAction func nextButton_onClick(_ sender: Any) {
        PreloadDataManager.UserEntryType.isOldUser = false
        presenter?.showHomeScreen()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "showFeaturesListView" {
            guard let featrueList = segue.destination as? FeatureListView else { return }
            featrueList.presenter = presenter
            return
        }
    }

    func showView(_ id: String, data _: [String: Any]?) {
        if canPerformSegue(withIdentifier: id) {
            performSegue(withIdentifier: id, sender: self)
        }
        return
    }

    func showError(_ error: Error) {
        showErrorPopup(withTitle: "Verification Error", error: error)
    }

    func showNetworkActivity() {
        naHUD.show(in: view)
    }

    func hideNetworkActivity() {
        naHUD.dismiss()
    }

    func showFeedback(_ message: String) {
        showInformationPopup(withTitle: "Information", message: message)
    }
}
