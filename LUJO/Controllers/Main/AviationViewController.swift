//
//  AviationViewController.swift
//  LUJO
//
//  Created by Kristian Iker on 9/4/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import Mixpanel

enum OriginAirport {
    case departureAirport, returnAirport
}

enum AviationError: Error, Equatable {
    case general(description: String)
    
    var errorCode: Int {
        switch self {
        case .general:
            return 1
        }
    }
}

extension AviationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .general(description):
            return NSLocalizedString(description, comment: "")
        }
    }
}


class AviationViewController: UIViewController, LuggageSelectionViewDelegate, AviationSearchCriteriaDelegate, UIGestureRecognizerDelegate, CalendarViewDelegate, AirportSearchViewDelegate, UINavigationControllerDelegate, MultiLegDataSourceProtocol {
    
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "AviationViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate() -> AviationViewController {
        return UIStoryboard.main.instantiate(identifier)
    }
    
    //MARK:- Globals
    
    private var passengersNum: Int = 1

    @IBOutlet var searchOptionsContainer: UIView!
    @IBOutlet var selectionButtons: [UIButton]!
    
    private var departureDateTime: Date?
    private var returnDateTime: Date?
    
    private var searchWaitView: AviationSearchView!
    private var emptyResultsView: AviationEmptyResultsView!
    
    var originAirport: Airport?
    var destinationAirport: Airport?
    
    private let maxPASSENGERS: Int = 50
    
    var searchCriteriaDelegate: SearchCriteriaDelegate?
    private var currentSearch: AviationSearch?
    
    private var lastSearch: [Lift]?
    
    //MARK:- View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubviews()
        
        showSearchOptions(for: .oneWay)
        
        //Loading the preferences related to dining only very first time
        if !UserDefaults.standard.bool(forKey: "isAviationPreferencesAlreadyShown")  {
            let viewController = PrefCollectionsViewController.instantiate(prefType: .aviation, prefInformationType: .aviationHaveCharteredBefore)
            self.navigationController?.pushViewController(viewController, animated: true)
            UserDefaults.standard.set(true, forKey: "isAviationPreferencesAlreadyShown")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //navigationController?.setNavigationBarHidden(true, animated: false)
        activateKeyboardManager()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    //MARK:- User Interaction
    
    
    //MARK:- Utilities
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let airport = originAirport {
            self.select(airport, forOrigin: .departureAirport)
        }
        if let airport = destinationAirport {
            self.select(airport, forOrigin: .returnAirport)
        }
    }
    
    fileprivate func setupWaitingSearchVIew() {
        searchWaitView = AviationSearchView(frame: view.bounds)
        searchWaitView.translatesAutoresizingMaskIntoConstraints = false
        searchWaitView.isHidden = true
        
        view.addSubview(searchWaitView)
        
        view.addConstraint(NSLayoutConstraint(item: searchWaitView, attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: view, attribute: .leading,
                                              multiplier: 1, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: searchWaitView, attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: view, attribute: .trailing,
                                              multiplier: 1, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: searchWaitView, attribute: .top,
                                              relatedBy: .equal,
                                              toItem: view, attribute: .top,
                                              multiplier: 1, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: searchWaitView, attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: view, attribute: .bottom,
                                              multiplier: 1, constant: 0))
    }
    
    fileprivate func setupEmptyResultsVIew() {
        emptyResultsView = AviationEmptyResultsView(frame: view.bounds)
        emptyResultsView.translatesAutoresizingMaskIntoConstraints = false
        emptyResultsView.isHidden = true
        
        view.addSubview(emptyResultsView)
        
        view.addConstraint(NSLayoutConstraint(item: emptyResultsView, attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: view, attribute: .leading,
                                              multiplier: 1, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: emptyResultsView, attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: view, attribute: .trailing,
                                              multiplier: 1, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: emptyResultsView, attribute: .top,
                                              relatedBy: .equal,
                                              toItem: view, attribute: .top,
                                              multiplier: 1, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: emptyResultsView, attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: view, attribute: .bottom,
                                              multiplier: 1, constant: 0))
    }
    
    fileprivate func setupSubviews() {
        setupWaitingSearchVIew()
        setupEmptyResultsVIew()
    }
    
    // MARK: Aviation Representable Methods
    
    func showSearchOptions(for type: AviationTripType) {
        guard let subviews = Bundle.main.loadNibNamed("AviationSearchOptions",
                                                      owner: self,
                                                      options: nil) else {
                                                        fatalError("Nib file not found at Aviation Options")
        }
        // swiftlint:disable line_length
        switch type {
        case .oneWay, .roundTrip:
            guard let newView = subviews.first(where: { $0 is AviationSingleLegSearchOptionsView }), newView is SearchCriteriaDelegate else {
                fatalError("Nib file not found at Aviation Options")
            }
            //Zahoor change started
        
            //No need to reInitialized self.searchCriteriaDelegate in case of return trip
            if (self.searchCriteriaDelegate == nil ) ||
                ((searchCriteriaDelegate as? AviationMultiLegSearchOptionsView) != nil) {
                searchCriteriaDelegate = newView as? SearchCriteriaDelegate
            }
//            searchCriteriaDelegate = newView as? SearchCriteriaDelegate
            //zahoor change finished
        default:
            guard let newView = subviews.first(where: { $0 is AviationMultiLegSearchOptionsView }), newView is AviationMultiLegSearchOptionsView else {
                fatalError("Nib file not found at Aviation Options")
            }
            searchCriteriaDelegate = newView as? SearchCriteriaDelegate
        }
        // swiftlint:enable line_length
        searchCriteriaDelegate?.aviationSearchCriteriaDelegate = self
        searchCriteriaDelegate?.tripType = type
        
        guard let searchOptionsView = searchCriteriaDelegate as? UIView else {
            fatalError("Nib file not fount at Aviation Options")
        }
        searchOptionsView.heightAnchor.constraint(greaterThanOrEqualToConstant: 32).isActive = true
        
        searchOptionsContainer.subviews.forEach({ $0.removeFromSuperview() })
        searchOptionsView.translatesAutoresizingMaskIntoConstraints = false
        searchOptionsContainer.addSubview(searchOptionsView)
        self.searchCriteriaDelegate = searchOptionsView as? SearchCriteriaDelegate
        
        NSLayoutConstraint.activate(
            [searchOptionsView.topAnchor.constraint(equalTo: searchOptionsContainer.topAnchor),
             searchOptionsView.bottomAnchor.constraint(equalTo: searchOptionsContainer.bottomAnchor),
             searchOptionsView.leadingAnchor.constraint(equalTo: searchOptionsContainer.leadingAnchor),
             searchOptionsView.trailingAnchor.constraint(equalTo: searchOptionsContainer.trailingAnchor)]
        )
    }
    
    func tripDatesSelected(departure: Date, return returnDate: Date?) {
//        print(departure,returnDate as Any)
        searchCriteriaDelegate?.set(departure: departure, returnDate: returnDate)
    }
    
    func select(_ airport: Airport, forOrigin: OriginAirport) {
        if forOrigin == .returnAirport {
            destinationAirport = nil
        }
        searchCriteriaDelegate?.set(airport, for: forOrigin)
    }
    
    func showEmptyResult() {
        emptyResultsView.isHidden = false
    }
    
    func waitingAnimation(show: Bool) {
        DispatchQueue.main.async {
            self.searchWaitView.isHidden = !show
            
            if show {
                self.searchWaitView.addRotationAnimation()
                self.tabBarController?.tabBar.isHidden = true
            } else {
                self.tabBarController?.tabBar.isHidden = false
            }
        }
    }
    
    func show(lifts list: [Lift], filter: [Filter]) {
        let viewController = AviationResultsViewController.instantiate(lifts: list, filter: filter, searchCriteria: currentSearch)
        present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func selectionButton_onClick(_ sender: UIButton) {
        for button in selectionButtons {
            button.isSelected = button == sender
        }
        
        selectTripKind(AviationTripType.aviationTypeFromRawValue(value: sender.tag))
    }
    
    @IBAction func showUserProfile(_ sender: Any) {
//        #warning("Present PRROFILE")
    }
    
    func showFeedback(_ message: String) {
        showInformationPopup(withTitle: "Information", message: message)
    }
    
    
    func select(_ luggage: AviationLuggage) {
        searchCriteriaDelegate?.set(luggage: luggage)
    }
    
    func get(destination airport: OriginAirport) {
        let viewController = AviationAirportSelectionViewController.instantiate(destination: airport)
        viewController.delegate = self
        present(viewController, animated: true, completion: nil)
    }
    
    func getTripDates(from date: Date?, isReturnDate: Bool) {
        let viewController = CalendarViewController.instantiate(firstValidDate: date,    //this date must be injected as utc to local
                                                                oneWay: !isReturnDate,
                                                                customTitle: isReturnDate ? "Return date" : "Departure date")
        viewController.delegate = self
        present(viewController, animated: true, completion: nil)
    }
    
    func getLuggage(from luggage: AviationLuggage?) {
        let luggage = luggage ?? AviationLuggage(carryOn: 0, hold: 0, golfBag: 0, skis: 0, other: 0)
        let viewController = AviationLuggageSelectionViewController.instantiate(luggage: luggage)
        viewController.delegate = self
        present(viewController, animated: true, completion: nil)
    }
    
    func search(using criteria: AviationSearch) {
        currentSearch = criteria
        searchFlights(matching: criteria)
    }
    
    func showSearchFeedback(_ message: String) {
        showFeedback(message)
    }
    
    func showMultiLegDetailVC(selectedIndex: Int?, segments: [AviationSegment], addMore: Bool) {
        let viewController = MultiLegDetailViewControllerNEW.instantiate(segments: segments, at: selectedIndex, addMore: addMore)
        viewController.searchDelegate = self
        viewController.dataSourceDelegate = self
        present(viewController, animated: true, completion: nil)
    }
    
    func updateDataSource(newDataSource: [AviationSegment]) {
        (searchCriteriaDelegate as? AviationMultiLegSearchOptionsView)?.segments = newDataSource
    }
}

extension AviationViewController {
    
    func selectTripKind(_ kind: AviationTripType) {
        switch kind {
        case .oneWay:
            break
        case .roundTrip:
            break
        case .multiCity:
            break
        }
        
        showSearchOptions(for: kind)
    }
    
    func searchFlights(matching criteria: AviationSearch) {
        waitingAnimation(show: true)
        let cityFrom = criteria.data[0].startAirport.city
        let cityTo = criteria.data[0].endAirport.city
        let departureDateTime = criteria.data[0].dateTime.date + ":" + criteria.data[0].dateTime.time
        var arrivalDateTime : String = ""
        if let returnDate = criteria.data[0].returnDate?.date, let returnTime = criteria.data[0].returnDate?.time{
            arrivalDateTime = returnDate + ":" + returnTime
        }

        Mixpanel.mainInstance().track(event: "AviationSearch",
                                      properties: ["FlightFrom" : cityFrom
                                                   ,"FlightTo" : cityTo
                                                   ,"FlightDepartureDateTime" : departureDateTime
                                                   ,"FlightArrivalDateTime" : arrivalDateTime])
        
        AviationAPIManagerNEW.shared.authorisationToken = LujoSetup().getCurrentUser()?.token
        AviationAPIManagerNEW.shared.searchFlights(matching: criteria) { list, filter, error in
            
            guard error == nil else {
                self.waitingAnimation(show: false)
                self.showEmptyResult()
                return
            }
            
            guard let liftsList = list else {
                self.waitingAnimation(show: false)
                self.showEmptyResult()
                return
            }
            
            guard !liftsList.isEmpty else {
                self.waitingAnimation(show: false)
                self.showEmptyResult()
                return
            }
            
            var filters = [Filter(name: "No fuel stops", selected: true, count: 0)]
            
            if list?.first?.flightTime ?? 0 >= 300 {
                filters.append(Filter(name: "Heavy Jets", selected: true, count: 0))
            }
            
            AviationAPIManagerNEW.shared.filterFlights(matching: filters) { list, filter, error in
                self.waitingAnimation(show: false)
    
                guard error == nil else {
                    self.showEmptyResult()
                    return
                }
    
                guard let liftsList = list else {
                    self.showEmptyResult()
                    return
                }
    
                guard !liftsList.isEmpty else {
                    self.showEmptyResult()
                    return
                }
    
                self.show(lifts: liftsList, filter: filter)
            }
        }
    }
    
    func showError(error: Error) {
        showErrorPopup(withTitle: "Aviation Error", error: error)
    }
}
