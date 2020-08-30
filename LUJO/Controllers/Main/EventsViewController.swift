//
//  EventsViewController.swift
//  LUJO
//
//  Created by Iker Kristian on 8/28/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import JGProgressHUD
import Crashlytics

enum EventCategory: String {
    case event = "Events"
    case experience = "Experiences"
}

class EventsViewController: UIViewController {
    
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "EventsViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate(category: EventCategory, dataSource: [EventsExperiences] = [], city: DiningCity? = nil) -> EventsViewController {
        let viewController = UIStoryboard.main.instantiate(identifier) as! EventsViewController
        viewController.category = category
        viewController.dataSource = dataSource
        viewController.city = city
        return viewController
    }
    
    //MARK:- Globals
    
    private(set) var category: EventCategory!
    private var city: DiningCity?
    
    @IBOutlet var collectionView: UICollectionView!
    private var dataSource: [EventsExperiences]!
    
    private let naHUD = JGProgressHUD(style: .dark)
    
    private var currentLayout: LiftLayout?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem?.title = ""
        currentLayout = collectionView.collectionViewLayout as? LiftLayout
        switch category! {
        case .event:
            currentLayout?.setCustomCellHeight(194)
        case .experience:
            currentLayout?.setCustomCellHeight(170)
        }
        
        collectionView.register(UINib(nibName: HomeSliderCell.identifier, bundle: nil), forCellWithReuseIdentifier: HomeSliderCell.identifier)
        
        updateContentUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if dataSource.isEmpty {
            getInformation(for: category, past: false, term: nil, cityId: city?.termId)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        switch segue.identifier {
//        case "ShowDetail":
//            guard let detailVC = segue.destination as? EventExperienceDetailView else { return }
//            guard let cell = sender as? HomeEventCell else { return }
//            detailVC.information = cell.item
//            detailVC.isEventPast = eventsSegment.selectedSegmentIndex == 1
//        case "ShowSearchScreen":
//            guard let searchVC = segue.destination as? EventExperienceSearchView else { return }
//            searchVC.presenter = presenter
//            searchVC.elementType = elementType
//        default:
//            super.prepare(for: segue, sender: sender)
//        }
//    }
    
    @IBAction func eventTypeChanged(_ sender: Any) {
        getInformation(for: category, past: false, term: nil, cityId: nil)
    }
    
    @IBAction func searchBarButton_onClick(_ sender: Any) {
        navigationController?.pushViewController(SearchEventsViewController.instantiate(category: category), animated: true)
    }
    
    fileprivate func updateContentUI() {
        if dataSource.count > 0 || city != nil {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        var titleString = category.rawValue
        
        if dataSource.count > 0 {
            titleString = "\(dataSource[0].location.first?.city?.name ?? "") \(category == EventCategory.experience ? "experiances" : "events")"
        } else if let city = city {
            titleString = "\(city.name) \(category == EventCategory.experience ? "experiances" : "events")"
        }
        
        title = titleString
//        naHUD.textLabel.text = "Loading " + category.rawValue
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
    
    func update(listOf objects: [EventsExperiences]) {
        dataSource = objects
        print("Found \(dataSource.count) items")
        currentLayout?.clearCache()
        collectionView.reloadData()
    }
}

extension EventsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeSliderCell.identifier, for: indexPath) as! HomeSliderCell
        
        let model = dataSource[indexPath.row]
        if let mediaLink = model.primaryMedia?.mediaUrl, model.primaryMedia?.type == "image" {
            cell.primaryImage.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
        }
        
        cell.name.text = model.name
        cell.primaryImageHeight.constant = 122
        
        if model.type == "event" {
            cell.dateContainerView.isHidden = false
            
            let startDateText = EventDetailsViewController.convertDateFormate(date: model.startDate!)
            var startTimeText = EventDetailsViewController.timeFormatter.string(from: model.startDate!)
            
            var endDateText = ""
            if let eventEndDate = model.endDate {
                endDateText = EventDetailsViewController.convertDateFormate(date: eventEndDate)
            }
            
            if let timezone = model.timezone {
                startTimeText = "\(startTimeText) (\(timezone))"
            }
            
            cell.date.text = endDateText != "" ? "\(startDateText) - \(endDateText)" : "\(startDateText) \(startTimeText)"
        } else {
            cell.dateContainerView.isHidden = true
        }
        
        if model.tags?.count ?? 0 > 0, let fistTag = model.tags?[0] {
            cell.tagContainerView.isHidden = false
            cell.tagLabel.text = fistTag.name.uppercased()
        } else {
            cell.tagContainerView.isHidden = true
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let event = dataSource[indexPath.row]
        let viewController = EventDetailsViewController.instantiate(event: event)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension EventsViewController {
    
    func getInformation(for category: EventCategory, past: Bool, term: String?, cityId: Int?) {
        showNetworkActivity()
        getList(for: category, past: past, term: term, cityId: cityId) { items, error in
            self.hideNetworkActivity()
            if let error = error {
                self.showError(error)
            } else {
                self.update(listOf: items)
            }
        }
    }
    
    func getList(for category: EventCategory, past: Bool, term: String?, cityId: Int?, completion: @escaping ([EventsExperiences], Error?) -> Void) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            completion([], LoginError.errorLogin(description: "User does not exist or is not verified"))
            return
        }
        
        switch category {
        case .event:
            EEAPIManager().getEvents(token, past: past, term: term, cityId: cityId) { list, error in
                guard error == nil else {
                    Crashlytics.sharedInstance().recordError(error!)
                    let error = BackendError.parsing(reason: "Could not obtain Home Events information")
                    completion([], error)
                    return
                }
                
                completion(list, error)
            }
        case .experience:
            EEAPIManager().getExperiences(token, term: term, cityId: cityId) { list, error in
                guard error == nil else {
                    Crashlytics.sharedInstance().recordError(error!)
                    let error = BackendError.parsing(reason: "Could not obtain Home Events information")
                    completion([], error)
                    return
                }
                completion(list, error)
            }
        }
    }
}
