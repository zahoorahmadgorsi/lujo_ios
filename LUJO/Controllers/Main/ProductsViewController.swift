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
    class func instantiate(category: ProductCategory, subCategory: ProductCategory? = nil, dataSource: [Product] = [], city: DiningCity? = nil) -> ProductsViewController {
        let viewController = UIStoryboard.main.instantiate(identifier) as! ProductsViewController
        viewController.category = category
        viewController.subCategory = subCategory
        viewController.dataSource = dataSource
        viewController.city = city
        return viewController
    }
    
    //MARK:- Globals
    
    private(set) var category: ProductCategory!
    private(set) var subCategory: ProductCategory! //e.g. toprated event
    
    private var city: DiningCity?
    
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
    
    @IBAction func eventTypeChanged(_ sender: Any) {
        getInformation(for: category, past: false, term: nil, cityId: nil)
    }
    
    @IBAction func searchBarButton_onClick(_ sender: Any) {
        navigationController?.pushViewController(SearchProductsViewController.instantiate(category: category), animated: true)
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
                subCategoryType = ""    //bring all top rated
        }
        
        if dataSource.count > 0 {
            titleString = "\(dataSource[0].location?.first?.city?.name ?? "") \(category == ProductCategory.experience ? "experiances" : "events")"
        } else if let city = city {
            titleString = "\(city.name) \(category == ProductCategory.experience ? "experiances" : "events")"
        }
        //sub category will exist e.g. toprated events (event is subcategory) if user is coming from percity view controller by clicking on see all button at top rated
        //if subcategory exists then append it with appending s (to make it plural)
        title = titleString + (subCategoryType.count > 0 ? " " + subCategoryType.capitalizingFirstLetter() + "s" : "")
//        print(title as Any)
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

extension ProductsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
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
        let viewController = ProductDetailsViewController.instantiate(event: event)
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
    
    func getInformation(for category: ProductCategory, past: Bool, term: String?, cityId: Int?) {
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
    
    func getList(for category: ProductCategory, past: Bool, term: String?, cityId: Int?, completion: @escaping ([Product], Error?) -> Void) {
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
                //bring all types and dont filter on term
                EEAPIManager().getTopRated(token, type: nil, term: nil) { list, error in
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
//        }else if animationtype == .featured{
//            featuredToDetailAnimator = HomeFeaturedAnimator(type: .present, firstViewController: firstViewController, secondViewController: secondViewController, selectedCellImageViewSnapshot: selectedCellImageViewSnapshot)
//            return featuredToDetailAnimator
//        }else {
//            return nil
//        }
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
//        }else if animationtype == .featured{
//            featuredToDetailAnimator = HomeFeaturedAnimator(type: .dismiss, firstViewController: self, secondViewController: secondViewController, selectedCellImageViewSnapshot: selectedCellImageViewSnapshot)
//            return featuredToDetailAnimator
//        }else {
//            return nil
//        }
    }
}

//extension EventsViewController: UINavigationControllerDelegate{
//    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
//    {
//        switch operation {
//            case .push:
//                return animationController(forPresented: toVC , presenting: fromVC, source: fromVC)
//            case .pop:
//                return animationController(forDismissed: fromVC)
//            default:
//                return nil
//        }
//
//    }
//}
