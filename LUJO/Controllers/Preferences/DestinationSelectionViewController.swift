//
//  DestinationSelectionViewController.swift
//  LUJO
//
//  Created by iMac on 23/05/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import UIKit
import FirebaseCrashlytics

protocol DestinationSearchViewDelegate: class {
    func select(_ destination: Taxonomy)
}

class DestinationSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "DestinationSelectionViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate(prefInformationType : PrefInformationType) -> DestinationSelectionViewController {
        let viewController = UIStoryboard.preferences.instantiate(identifier) as! DestinationSelectionViewController
        viewController.prefInformationType = prefInformationType
        return viewController
    }
    
    //MARK:- Globals
    weak var delegate: DestinationSearchViewDelegate?
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var searchText: DesignableUITextField!
    @IBOutlet var tblDestinations: UITableView!
    @IBOutlet var bottomHeightConstraint: NSLayoutConstraint!
    private var destinations = [Taxonomy]()
    var prefInformationType : PrefInformationType!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        switch(self.prefInformationType){
        case .aviationPreferredDestination: fallthrough
        case .travelDestinations:
            titleLabel.text = "Search Destinations"
        case .yachtPreferredRegions:
            titleLabel.text = "Search Regions"
        default:
            print("Never going to get executed")
        }
        
        searchText.becomeFirstResponder()
        searchText.addTarget(self,
                             action: #selector(textFieldDidChange(_:)),
                             for: .editingChanged)
        searchText.placeHolderColor = .placeholderText
        
        tblDestinations.dataSource = self
        tblDestinations.delegate = self
        
        // Hide separators for empty cells
        tblDestinations.tableFooterView = UIView(frame: .zero)
        // Observe keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(DestinationSelectionViewController.keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DestinationSelectionViewController.keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func cancelSelection(_: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let searchText = textField.text else {
            return
        }
        if searchText.count > 2 {
            getDestinationsMatching(searchText)
        }
    }
    
    // MARK: Aviation Representable Methods
    
    func showDestinationsList(_ destinations: [Taxonomy]) {
        self.destinations = destinations
        DispatchQueue.main.async {
            self.tblDestinations.reloadData()
        }
    }
    
    // MARK: Table View Data Source Methods
    
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return self.destinations.count
    }
    
    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable force_cast
        let cell = tblDestinations.dequeueReusableCell(withIdentifier: "destinationSearchCell",
                                                         for: indexPath) as! DestinationSearchCell
        let model = self.destinations[indexPath.row]
        cell.lblTermId.text = String(model.termId)
        //cell.lblDestinationName.text = model.name.uppercased()
        cell.lblDestinationName.text = model.name
        cell.separatorView.backgroundColor = (indexPath.row + 1) == self.destinations.count ? UIColor.clear : UIColor.actionButton
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.select(self.destinations[indexPath.row])
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Keyboad management
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardFrame = keyboardSize.cgRectValue
        bottomHeightConstraint.constant = keyboardFrame.height
    }
    
    @objc func keyboardWillHide(notification _: NSNotification) {
        bottomHeightConstraint.constant = 0
    }
    
    
}

extension DestinationSelectionViewController {
    
    func getDestinationsMatching(_ pattern: String) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            return
        }
        switch(self.prefInformationType){
        case .aviationPreferredDestination: fallthrough
        case .travelDestinations: fallthrough
        case .villaDestinations:
            GoLujoAPIManager().searchDestination(token: token, strToSearch: pattern) { taxonomies, error in
                guard error == nil else {
                    Crashlytics.crashlytics().record(error: error!)
                    let error = BackendError.parsing(reason: "Could not obtain preferred destinations")
                    self.showErrorPopup(withTitle: "Error", error: error)
                    return
                }
                self.showDestinationsList(taxonomies ?? [])
            }
        case .yachtPreferredRegions:
            GoLujoAPIManager().searchRegions(token: token, strToSearch: pattern) { taxonomies, error in
                guard error == nil else {
                    Crashlytics.crashlytics().record(error: error!)
                    let error = BackendError.parsing(reason: "Could not obtain preferred regions")
                    self.showErrorPopup(withTitle: "Error", error: error)
                    return
                }
                self.showDestinationsList(taxonomies ?? [])
            }
        default:
            print("Never going to get executed")
        }
    }
}
