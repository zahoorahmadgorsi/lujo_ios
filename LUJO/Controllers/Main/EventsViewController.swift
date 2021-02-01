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
import AVFoundation

enum EventCategory: String {
    case event = "Events"
    case experience = "Experiences"
    case villa = "Villas"
    case gift = "Gifts"
    case yacht = "Yachts"
    case recent = "Recenlty Viewed"
    case topRated = "Top Rated"
}

class EventsViewController: UIViewController {
    
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "EventsViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate(category: EventCategory, subCategory: EventCategory? = nil, dataSource: [Product] = [], city: DiningCity? = nil) -> EventsViewController {
        let viewController = UIStoryboard.main.instantiate(identifier) as! EventsViewController
        viewController.category = category
        viewController.subCategory = subCategory
        viewController.dataSource = dataSource
        viewController.city = city
        return viewController
    }
    
    //MARK:- Globals
    
    private(set) var category: EventCategory!
    private(set) var subCategory: EventCategory! //e.g. toprated event
    
    private var city: DiningCity?
    
    @IBOutlet var collectionView: UICollectionView!
    private var dataSource: [Product]!
    
    private let naHUD = JGProgressHUD(style: .dark)
    
    private var currentLayout: LiftLayout?
    private var subCategoryType = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem?.title = ""
        currentLayout = collectionView.collectionViewLayout as? LiftLayout
        switch category! {
            case .event:
                currentLayout?.setCustomCellHeight(194)
            case .experience:
                currentLayout?.setCustomCellHeight(170)
            case .villa:
                currentLayout?.setCustomCellHeight(170)
            case .gift:
                currentLayout?.setCustomCellHeight(170)
            case .yacht:
                currentLayout?.setCustomCellHeight(170)
            case .recent:
                currentLayout?.setCustomCellHeight(170)
            case .topRated:
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
        //Deciding the title
        switch subCategory {
            case .event:
                subCategoryType = "event"
            case .experience:
                subCategoryType = "experience"
            case .villa:
                subCategoryType = "villa"
            case .yacht:
                subCategoryType = "yacht"
            default:
                subCategoryType = ""
        }
        
        if dataSource.count > 0 {
            titleString = "\(dataSource[0].location?.first?.city?.name ?? "") \(category == EventCategory.experience ? "experiances" : "events")"
        } else if let city = city {
            titleString = "\(city.name) \(category == EventCategory.experience ? "experiances" : "events")"
        }
        //sub category will exist e.g. toprated events (event is subcategory) if user is coming from percity view controller by clicking on see all button at top rated
        //if subcategory exists then append it with appending s (to make it plural)
        title = titleString + (subCategoryType.count > 0 ? " " + subCategoryType.capitalizingFirstLetter() + "s" : "")
        print(title as Any)
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
    
    func update(listOf objects: [Product]) {
        dataSource = objects
//        print("Found \(dataSource.count) items")
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
        }else if let firstImageLink = model.getGalleryImagesURL().first {
            cell.primaryImage.downloadImageFrom(link: firstImageLink, contentMode: .scaleAspectFill)
        }
        //Zahoor started 20201026
        cell.primaryImage.isHidden = false;
        cell.containerView.removeLayer(layerName: "videoPlayer") //removing video player if was added
        var avPlayer: AVPlayer!
        if( model.primaryMedia?.type == "video"){
            //Playing the video
            if let videoLink = URL(string: model.primaryMedia?.mediaUrl ?? ""){
                cell.primaryImage.isHidden = true;

                avPlayer = AVPlayer(playerItem: AVPlayerItem(url: videoLink))
                let avPlayerLayer = AVPlayerLayer(player: avPlayer)
                avPlayerLayer.name = "videoPlayer"
                avPlayerLayer.frame = cell.containerView.bounds
                avPlayerLayer.videoGravity = .resizeAspectFill
                cell.containerView.layer.insertSublayer(avPlayerLayer, at: 0)
                avPlayer.play()
                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem, queue: .main) { _ in
                    avPlayer?.seek(to: CMTime.zero)
                    avPlayer?.play()
                }
            }else
                if let mediaLink = model.primaryMedia?.thumbnail {
                cell.primaryImage.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
            }
        }
        //checking favourite image red or white
        if (model.isFavourite ?? false){
            cell.imgHeart.image = UIImage(named: "heart_red")
        }else{
            cell.imgHeart.image = UIImage(named: "heart_white")
        }
        //Add tap gesture on favourite
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTappedOnHeartAt(_:)))
        cell.viewHeart.isUserInteractionEnabled = true   //can also be enabled from IB
        cell.viewHeart.tag = indexPath.row
        cell.viewHeart.addGestureRecognizer(tapGestureRecognizer)
        //Zahoor end
        
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
        }else { //showing location if available
            //cell.dateContainerView.isHidden = true
            var locationText = ""
            if let cityName = model.location?.first?.city?.name {
                locationText = "\(cityName), "
            }
            locationText += model.location?.first?.country.name ?? ""
            cell.date.text = locationText.uppercased()
            cell.dateContainerView.isHidden = locationText.isEmpty
            cell.imgDate.image = UIImage(named: "Location White")
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
    
    func getList(for category: EventCategory, past: Bool, term: String?, cityId: Int?, completion: @escaping ([Product], Error?) -> Void) {
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
                        let error = BackendError.parsing(reason: "Could not obtain home experience information")
                        completion([], error)
                        return
                    }
                    completion(list, error)
                }
            case .villa:
                EEAPIManager().getVillas(token, term: term, cityId: cityId) { list, error in
                    guard error == nil else {
                        Crashlytics.sharedInstance().recordError(error!)
                        let error = BackendError.parsing(reason: "Could not obtain home villas information")
                        completion([], error)
                        return
                    }
                    completion(list, error)
                }
            case .gift:
                EEAPIManager().getGoods(token, term: term, cityId: cityId) { list, error in
                    guard error == nil else {
                        Crashlytics.sharedInstance().recordError(error!)
                        let error = BackendError.parsing(reason: "Could not obtain home gifts information")
                        completion([], error)
                        return
                    }
                completion(list, error)
            }
            case .yacht:
                EEAPIManager().getYachts(token, term: term, cityId: cityId) { list, error in
                    guard error == nil else {
                        Crashlytics.sharedInstance().recordError(error!)
                        let error = BackendError.parsing(reason: "Could not obtain home yachts information")
                        completion([], error)
                        return
                    }
                completion(list, error)
            }
            case .topRated:
                //since type is not optional thats why sending hardcoded "event"
                EEAPIManager().getTopRated(token, type: subCategoryType) { list, error in
                    guard error == nil else {
                        Crashlytics.sharedInstance().recordError(error!)
                        let error = BackendError.parsing(reason: "Could not obtain home top rated items information")
                        completion([], error)
                        return
                    }
                completion(list, error)
            }
            case .recent:
                EEAPIManager().getRecents(token, limit: "30", type: "") { list, error in
                    guard error == nil else {
                        Crashlytics.sharedInstance().recordError(error!)
                        let error = BackendError.parsing(reason: "Could not obtain home recently viewed information")
                        completion([], error)
                        return
                    }
                completion(list, error)
            }
        }
    }
    
    @objc func didTappedOnHeartAt( _ sender:AnyObject) {
        var item: Product!
        if let index = sender.view?.tag{
            item = dataSource[index]
            
            //setting the favourite
            self.showNetworkActivity()
            setUnSetFavourites(id: item.id ,isUnSetFavourite: item.isFavourite ?? false) {information, error in
                self.hideNetworkActivity()
                
                if let error = error {
                    self.showError(error)
                    return
                }
                
                if let informations = information {
                    self.dataSource[index].isFavourite = !(self.dataSource[index].isFavourite ?? false)
                    self.update(listOf: self.dataSource) //just to reload the grid
                   
    //              PreloadDataManager.HomeScreen.scrollViewData = information
                    print("ItemID:\(item.id)" + ", ItemType:" + item.type  + ", ServerResponse:" + informations)
                } else {
                    let error = BackendError.parsing(reason: "Could not obtain tap on heart information")
                    self.showError(error)
                }
            }
        }
    }
    
    func setUnSetFavourites(id:Int, isUnSetFavourite: Bool ,completion: @escaping (String?, Error?) -> Void) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            completion(nil, LoginError.errorLogin(description: "User does not exist or is not verified"))
            return
        }
        
        GoLujoAPIManager().setUnSetFavourites(token: token,id: id, isUnSetFavourite: isUnSetFavourite) { strResponse, error in
            guard error == nil else {
                Crashlytics.sharedInstance().recordError(error!)
                let error = BackendError.parsing(reason: "Could not set/unset favorites")
                completion(nil, error)
                return
            }
            completion(strResponse, error)
        }
    }
}
