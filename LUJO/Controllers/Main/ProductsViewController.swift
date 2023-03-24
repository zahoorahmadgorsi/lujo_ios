//
//  EventsViewController.swift
//  LUJO
//
//  Created by Iker Kristian on 8/28/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import JGProgressHUD
import FirebaseCrashlytics
import AVFoundation

enum ProductCategory: String {
    case event = "Events"
    case experience = "Experiences"
    case villa = "Villas"
    case gift = "Gifts"
    case yacht = "Yachts"
    case recent = "Recenlty Viewed"
    case topRated = "Top Rated"
}

class ProductsViewController: UIViewController {
    
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "ProductsViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate(category: ProductCategory,
                           subCategory: ProductCategory? = nil,
                           dataSource: [Product] = [],
                           city: Cities? = nil,
                           applyFilters: AppliedFilters? = nil) -> ProductsViewController {
        let viewController = UIStoryboard.main.instantiate(identifier) as! ProductsViewController
        viewController.category = category
        viewController.subCategory = subCategory
        viewController.dataSource = dataSource
        viewController.city = city
        viewController.applyFilters =  applyFilters
        return viewController
    }
    
    //MARK:- Globals
    
    private(set) var category: ProductCategory!
    private(set) var subCategory: ProductCategory! //e.g. toprated event
    
    private var city: Cities?
    
    @IBOutlet var collectionView: UICollectionView!
    private var dataSource: [Product]!
    
    private let naHUD = JGProgressHUD(style: .dark)
    
    private var currentLayout: LiftLayout?
    private var subCategoryType = ""
    
    // B2 - 5
    var selectedCell: HomeSliderCell?
    var selectedCellImageViewSnapshot: UIView? //it’s a view that has a current rendered appearance of a view. Think of it as you would take a screenshot of your screen, but it will be one single view without any subviews.
    // B2 - 15
    var eventsAnimator: EventsAnimator?
    
    /// Refresh control view. Used to display network activity when user pull scroll view down
    /// view to fetch new data.
    private lazy var refreshControl: UIRefreshControl = {
        // Create refresh control and link it with scroll view.
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: UIControl.Event.valueChanged)
        self.collectionView.refreshControl = refreshControl
        return refreshControl
    }()
    
    //Filters
    var applyFilters: AppliedFilters?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem?.title = ""
        currentLayout = collectionView.collectionViewLayout as? LiftLayout
        switch category! {
            case .event:
                currentLayout?.setCustomCellHeight(194)
//                currentLayout?.setCustomCellHeight(400)
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
        
        switch category {
            case .event: fallthrough
            case .experience:
                //Loading the preferences related to dining only very first time
                if !UserDefaults.standard.bool(forKey: "isEventPreferencesAlreadyShown")  {
                    let viewController = PrefCollectionsViewController.instantiate(prefType: .events, prefInformationType: .eventCategory)
                    self.navigationController?.pushViewController(viewController, animated: true)
                    UserDefaults.standard.set(true, forKey: "isEventPreferencesAlreadyShown")
                }
            case .villa:
                //Loading the preferences related to dining only very first time
                if !UserDefaults.standard.bool(forKey: "isVillaPreferencesAlreadyShown")  {
                    let viewController = PrefCollectionsViewController.instantiate(prefType: .villas, prefInformationType: .villaDestinations)
                    self.navigationController?.pushViewController(viewController, animated: true)
                    UserDefaults.standard.set(true, forKey: "isVillaPreferencesAlreadyShown")
                }
            case .yacht:
                //Loading the preferences related to dining only very first time
                if !UserDefaults.standard.bool(forKey: "isYachtPreferencesAlreadyShown")  {
                    let viewController = PrefCollectionsViewController.instantiate(prefType: .yachts, prefInformationType: .yachtHaveCharteredBefore)
                    self.navigationController?.pushViewController(viewController, animated: true)
                    UserDefaults.standard.set(true, forKey: "isYachtPreferencesAlreadyShown")
                }
            case .gift:
                //Loading the preferences related to dining only very first time
                if !UserDefaults.standard.bool(forKey: "isGiftPreferencesAlreadyShown")  {
                    let viewController = PrefCollectionsViewController.instantiate(prefType: .gifts, prefInformationType: .giftHabbits)
                    self.navigationController?.pushViewController(viewController, animated: true)
                    UserDefaults.standard.set(true, forKey: "isGiftPreferencesAlreadyShown")
                }
            default:
                print("No preferences to load")
       
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if dataSource.isEmpty {
            getInformation(for: category, past: false, term: nil, cityId: city?.termId, latitude: city?.latitude, longitude:city?.longitude, filtersToApply: self.applyFilters)
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
    
    /// Refresh control target action that will trigger once user pull to refresh scroll view.
    @objc func refresh(_ sender: AnyObject) {
        // Force data fetch.
        getInformation(for: category, past: false, term: nil, cityId: nil, latitude: city?.latitude, longitude:city?.longitude, filtersToApply: self.applyFilters)
    }
    
    @IBAction func eventTypeChanged(_ sender: Any) {
        getInformation(for: category, past: false, term: nil, cityId: nil, latitude: nil, longitude:nil,filtersToApply: self.applyFilters)
    }
    
    @IBAction func searchBarButton_onClick(_ sender: Any) {
        navigationController?.pushViewController(SearchProductsViewController.instantiate(category, subCategory), animated: true)
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
            case .gift:
                subCategoryType = "gift"
            default:
                subCategoryType = ""    //bring all top rated
        }
        
        if dataSource.count > 0 {
            titleString = "\(dataSource[0].locations?.city?.name ?? "") \(category == ProductCategory.experience ? "experiances" : "events")"
        } else if let city = city , let name = city.name {
            //titleString = "\(city.name) \(category == ProductCategory.experience ? "experiances" : "events")"
            titleString = "\(name) \(category.rawValue)"    //dubai event
        }
        //sub category will exist e.g. toprated events (event is subcategory) if user is coming from percity view controller by clicking on see all button at top rated
        //if subcategory exists then append it with appending s (to make it plural)
        title = titleString + (subCategoryType.count > 0 ? " " + subCategoryType.capitalizingFirstLetter() + "s" : "")
//        print(title as Any)
//        naHUD.textLabel.text = "Loading " + category.rawValue
    }
    
    func showError(_ error: Error, _ errorTitle:String) {
        showErrorPopup(withTitle: errorTitle, error: error)
    }
    
    func showFeedback(_ message: String) {
        showInformationPopup(withTitle: "Information", message: message)
    }
    
    func showNetworkActivity() {
        // Safe guard to that won't display both loaders at same time.
        if !refreshControl.isRefreshing {
            naHUD.show(in: view)
        }
    }
    
    func hideNetworkActivity() {
        // Safe guard that will call dismiss only if HUD is shown on screen.
        if naHUD.isVisible {
            naHUD.dismiss()
        }
    }
    
    func update(listOf objects: [Product]) {
        dataSource = objects
//        print("Found \(dataSource.count) items")
        currentLayout?.clearCache()
        collectionView.reloadData()

    }
}

extension ProductsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeSliderCell.identifier, for: indexPath) as! HomeSliderCell
        
        let model = dataSource[indexPath.row]
        if let mediaLink = model.thumbnail?.mediaUrl, model.thumbnail?.mediaType == "image" {
            cell.primaryImage.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
        }else if let firstImageLink = model.getGalleryImagesURL().first {
            cell.primaryImage.downloadImageFrom(link: firstImageLink, contentMode: .scaleAspectFill)
        }
        cell.primaryImage.isHidden = false;
        cell.containerView.removeLayer(layerName: "videoPlayer") //removing video player if was added
        var avPlayer: AVPlayer!
        if( model.thumbnail?.mediaType == "video"){
            //Playing the video
            if let videoLink = URL(string: model.thumbnail?.mediaUrl ?? ""){
                cell.primaryImage.isHidden = true;

                avPlayer = AVPlayer(playerItem: AVPlayerItem(url: videoLink))
                let avPlayerLayer = AVPlayerLayer(player: avPlayer)
                avPlayerLayer.name = "videoPlayer"
                avPlayerLayer.frame = cell.containerView.bounds
                avPlayerLayer.videoGravity = .resizeAspectFill
                cell.containerView.layer.insertSublayer(avPlayerLayer, at: 0)
                avPlayer.play()
                avPlayer.isMuted = true // To mute the sound
                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem, queue: .main) { _ in
                    avPlayer?.seek(to: CMTime.zero)
                    avPlayer?.play()
                }
            }else
                if let mediaLink = model.thumbnail?.thumbnail {
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
        
        cell.name.text = model.name
        cell.primaryImageHeight.constant = 122
        
        if model.type == "event" {
            cell.dateContainerView.isHidden = false
            
            let startDateText = ProductDetailsViewController.convertDateFormate(date: model.startDate!)
            var startTimeText = ProductDetailsViewController.timeFormatter.string(from: model.startDate!)
            
            var endDateText = ""
            if let eventEndDate = model.endDate {
                endDateText = ProductDetailsViewController.convertDateFormate(date: eventEndDate)
            }
            
            if let timezone = model.timezone {
                startTimeText = "\(startTimeText) (\(timezone))"
            }
            
            cell.date.text = endDateText != "" ? "\(startDateText) - \(endDateText)" : "\(startDateText) \(startTimeText)"
        }else { //showing location if available
            //cell.dateContainerView.isHidden = true
            let locationText = model.getLocation()
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
        let viewController = ProductDetailsViewController.instantiate(product: event)
        // B2 - 6
        selectedCell = collectionView.cellForItem(at: indexPath) as? HomeSliderCell
        // B2 - 7
        selectedCellImageViewSnapshot = selectedCell?.primaryImage.snapshotView(afterScreenUpdates: false)
//        self.navigationController?.pushViewController(viewController, animated: true)
//        // B1 - 4
        //That is how you configure a present custom transition. But it is not how you configure a push custom transition.
        viewController.transitioningDelegate = self
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true)
    }
}

extension ProductsViewController {
    
    func getInformation(for category: ProductCategory, past: Bool, term: String?, cityId: String?, latitude: Double?, longitude:Double?, filtersToApply:AppliedFilters? = nil) {
        showNetworkActivity()
        getList(for: category, past: past, term: term, cityId: cityId,latitude: latitude,longitude:longitude, filtersToApply:filtersToApply) { items, error in
            self.hideNetworkActivity()
            // Stop refresh control animation and allow scroll to sieze back refresh control space by scrolling up.
            self.refreshControl.endRefreshing()
            if let error = error {
                self.showError(error, category.rawValue)
            } else {
                self.update(listOf: items)
            }
        }
    }
    
    func getList(for category: ProductCategory, past: Bool, term: String?, cityId: String?, latitude: Double?, longitude:Double?, filtersToApply:AppliedFilters? = nil,
                 completion: @escaping ([Product], Error?) -> Void) {
//        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
//            completion([], LoginError.errorLogin(description: "User does not exist or is not verified"))
//            return
//        }
        
        switch category {
            case .event:
            EEAPIManager().getEvents( past: past, term: term, latitude: latitude, longitude: longitude, productId: nil,
                                      filtersToApply: filtersToApply) { list, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not obtain Events information")
                        completion([], error)
                        return
                    }
                    completion(list, error)
                }
            case .experience:
                EEAPIManager().getExperiences( term: term, latitude: latitude, longitude: longitude, productId: nil,
                                               filtersToApply: filtersToApply) { list, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not obtain experience information")
                        completion([], error)
                        return
                    }
                    completion(list, error)
                }
            case .yacht:
                EEAPIManager().getYachts( term: term, cityId: cityId, productId: nil,
                                          filtersToApply: filtersToApply) { list, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not obtain yachts information")
                        completion([], error)
                        return
                    }
                completion(list, error)
            }
            case .villa:
                EEAPIManager().getVillas(term: term, latitude: latitude, longitude: longitude, productId: nil,
                                         filtersToApply: filtersToApply) { list, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not obtain villas information")
                        completion([], error)
                        return
                    }
                    completion(list, error)
                }
            case .gift:
                //sending category_term_id in case of gifts in the paraeter cityid
                EEAPIManager().getGoods( term: term, giftCategoryId: cityId, productId: nil,
                                         filtersToApply: filtersToApply) { list, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not obtain gifts information")
                        completion([], error)
                        return
                    }
                completion(list, error)
            }

            case .topRated:
                EEAPIManager().getTopRated(type: self.subCategoryType, term: nil) { list, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not obtain top rated items information")
                        completion([], error)
                        return
                    }
                completion(list, error)
            }
            case .recent:
                EEAPIManager().getRecents( limit: "30", type: "") { list, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
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
            setUnSetFavourites(type: item.type, id: item.id ,isUnSetFavourite: item.isFavourite ?? false) {information, error in
                self.hideNetworkActivity()
                
                if let error = error {
                    self.showError(error, "Favorites")
                    return
                }
                
                if let informations = information {
                    self.dataSource[index].isFavourite = !(self.dataSource[index].isFavourite ?? false)
                    self.update(listOf: self.dataSource) //just to reload the grid
                   
    //              PreloadDataManager.HomeScreen.scrollViewData = information
                    print("ItemID:\(item.id)" + ", ItemType:" + item.type  + ", ServerResponse:" + informations)
                } else {
                    let error = BackendError.parsing(reason: "Could not obtain tap on heart information")
                    self.showError(error, "Favorites")
                }
            }
        }
    }
    
    func setUnSetFavourites(type:String,id:String, isUnSetFavourite: Bool ,completion: @escaping (String?, Error?) -> Void) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            completion(nil, LoginError.errorLogin(description: "User does not exist or is not verified"))
            return
        }
        
        GoLujoAPIManager().setUnSetFavourites(type,id, isUnSetFavourite) { strResponse, error in
            guard error == nil else {
                Crashlytics.crashlytics().record(error: error!)
                let error = BackendError.parsing(reason: "Could not set/unset favorites")
                completion(nil, error)
                return
            }
            completion(strResponse, error)
        }
    }
}


// B1 - 1
extension ProductsViewController: UIViewControllerTransitioningDelegate {

    // B1 - 2
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        return nil
        // B2 - 16
//        We are preparing the properties to initialize an instance of Animator. If it fails, return nil to use default animation. Then assign it to the animator instance that we just created.
        guard let firstViewController = source as? ProductsViewController,
            let secondViewController = presented as? ProductDetailsViewController,
            let selectedCellImageViewSnapshot = selectedCellImageViewSnapshot
            else {
                return nil
            }
//        print(animationtype)
//        if animationtype == .slider{
            eventsAnimator = EventsAnimator(type: .present, firstViewController: firstViewController, secondViewController: secondViewController, selectedCellImageViewSnapshot: selectedCellImageViewSnapshot)
            return eventsAnimator
    }

    // B1 - 3
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        return nil
        // B2 - 17
//        We are preparing the properties to initialize an instance of Animator. If it fails, return nil to use default animation. Then assign it to the animator instance that we just created.
        guard let secondViewController = dismissed as? ProductDetailsViewController,
            let selectedCellImageViewSnapshot = selectedCellImageViewSnapshot
            else {
                return nil
            }
//        if animationtype == .slider{
            eventsAnimator = EventsAnimator(type: .dismiss, firstViewController: self, secondViewController: secondViewController, selectedCellImageViewSnapshot: selectedCellImageViewSnapshot)
            return eventsAnimator
    }
}

