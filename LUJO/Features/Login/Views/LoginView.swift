import ActiveLabel
import JGProgressHUD
import SwiftEntryKit
import UIKit

class LoginView: UIViewController, LoginViewProtocol {
    var presenter: LoginViewResponder?
    private let naHUD = JGProgressHUD(style: .dark)

    @IBOutlet var splashView: UIView!
    @IBOutlet var splashImageView: UIImageView!

    @IBOutlet var loginButton: ActionButton!
    @IBOutlet var registerButton: DarkActionButton!

    override func viewDidLoad() {
        // View Customisation
//        naHUD.textLabel.text = "Login in ..."
        navigationController?.navigationBar.barStyle = .default
    }

    override func viewWillAppear(_: Bool) {
        // splashView.alpha = 1
        navigationController?.navigationBar.isHidden = true
        presenter?.update(view: self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        hideNetworkActivity()
    }

    func showError(_ error: Error) {
        showErrorPopup(withTitle: "Login Error", error: error)
    }

    func showFeedback(_ message: String) {
        showInformationPopup(withTitle: "Information", message: message)
    }

    func showNetworkActivity() {
        DispatchQueue.main.async {
            self.naHUD.show(in: self.view)
        }
    }

    func hideNetworkActivity() {
        DispatchQueue.main.async {
            self.naHUD.dismiss()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "CreateNewAccount" {
            guard let registerVC = segue.destination as? RegisterView else { return }
            registerVC.presenter = presenter
        }
        if segue.identifier == "JumpConfirmation" {
            guard let confirmationVC = segue.destination as? ConfirmationView else { return }
            confirmationVC.presenter = presenter
            return
        }
        if segue.identifier == "EnterPhone" {
            guard let enterPhoneVC = segue.destination as? UpdatePhoneNumberView else { return }
            enterPhoneVC.presenter = presenter
            enterPhoneVC.isChanging = false
            return
        }
    }

    func showView(_ id: String, data _: [String: Any]?) {
        if canPerformSegue(withIdentifier: id) {
            performSegue(withIdentifier: id, sender: self)
        }
        return
    }

    func hideSplashView() {
        splashView.alpha = 0
        startSlideShow()
    }

    private var imageNum = 1

    private func startSlideShow() {
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in

            if self.imageNum < 7 {
                self.imageNum += 1
            } else {
                self.imageNum = 1
            }

            self.splashImageView.image = UIImage(named: "splash_\(self.imageNum)")
        }
    }

    @objc private func doneButtonPressed() {
        view.endEditing(true)
    }
}
