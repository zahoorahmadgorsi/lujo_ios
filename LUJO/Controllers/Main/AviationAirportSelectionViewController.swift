//
//  AviationAirportSelectionViewController.swift
//  LUJO
//
//  Created by Kristian Iker on 9/4/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit

protocol AirportSearchViewDelegate: class {
    func select(_ airport: Airport, forOrigin: OriginAirport)
}

class AviationAirportSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "AviationAirportSelectionViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate(destination: OriginAirport) -> AviationAirportSelectionViewController {
        let viewController = UIStoryboard.main.instantiate(identifier) as! AviationAirportSelectionViewController
        viewController.airportType = destination
        return viewController
    }
    
    //MARK:- Globals
    
    private(set) var airportType: OriginAirport!
    weak var delegate: AirportSearchViewDelegate?
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var searchText: DesignableUITextField!
    @IBOutlet var airportsTableView: UITableView!
    @IBOutlet var bottomHeightConstraint: NSLayoutConstraint!
    
    private var airportsList = [Airport]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = airportType == .departureAirport ? "Departure airport" : "Arrival airport"
        
        searchText.becomeFirstResponder()
        searchText.addTarget(self,
                             action: #selector(AviationAirportSelectionViewController.textFieldDidChange(_:)),
                             for: .editingChanged)
        airportsTableView.dataSource = self
        airportsTableView.delegate = self
        
        // Hide separators for empty cells
        airportsTableView.tableFooterView = UIView(frame: .zero)
        // Observe keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(AviationAirportSelectionViewController.keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AviationAirportSelectionViewController.keyboardWillHide),
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
            getAirportListMatching(searchText)
        }
    }
    
    // MARK: Aviation Representable Methods
    
    func showAirportsList(_ airports: [Airport]) {
        airportsList = airports
        DispatchQueue.main.async {
            self.airportsTableView.reloadData()
        }
    }
    
    // MARK: Table View Data Source Methods
    
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return airportsList.count
    }
    
    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable force_cast
        let cell = airportsTableView.dequeueReusableCell(withIdentifier: "searchAirportCell",
                                                         for: indexPath) as! AirportSearchCell
        let airportData = AirportCellData.from(airport: airportsList[indexPath.row])
        
        cell.faaIdentifier.text = airportData.iata
        cell.airportName.text = airportData.name
        cell.airportProvince.text = airportData.city.uppercased()
        if !airportData.city.isEmpty {
            cell.airportProvince.text?.append(" ,")
        }
        cell.airportProvince.text?.append(airportData.country.uppercased())
        
        cell.separatorView.backgroundColor = (indexPath.row + 1) == airportsList.count ? UIColor.clear : UIColor.actionButton
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.select(airportsList[indexPath.row], forOrigin: airportType!)
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

extension AviationAirportSelectionViewController {
    
    func getAirportListMatching(_ pattern: String) {
        AviationAPIManagerNEW.shared.authorisationToken = LujoSetup().getCurrentUser()?.token
        AviationAPIManagerNEW.shared.searchAirports(matching: pattern) { airports, error in
            self.showAirportsList(airports ?? [])
        }
    }
}
