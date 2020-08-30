//
//  FeatureListView.swift
//  LUJO
//
//  Created by Nemanja Djurisic on 8/9/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import JGProgressHUD
import UIKit

class FeatureListView: UIViewController, LoginViewProtocol {
    var presenter: LoginViewResponder?
    private let naHUD = JGProgressHUD(style: .dark)

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        presenter?.update(view: self)
    }

    @IBAction func startBorwsingButton_onClick(_ sender: Any) {
        presenter?.showHomeScreen()
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
