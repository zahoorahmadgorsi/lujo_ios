//
//  SearchEventsViewController.swift
//  LUJO
//
//  Created by Iker Kristian on 8/28/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import JGProgressHUD
import IQKeyboardManagerSwift
import FirebaseCrashlytics
import AVFoundation
import Mixpanel

class SearchProductsViewController: UIViewController {
    
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "SearchProductsViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate(_ category: ProductCategory, _ subCategory: ProductCategory?) -> SearchProductsViewController {
        let viewController = UIStoryboard.main.instantiate(identifier) as! SearchProductsViewController
        viewController.category = category  //is there any chance that i
        viewController.subCategory = subCategory
        return viewController
    }
    
    //MARK:- Globals
    
    private(set) var category: ProductCategory!
    private(set) var subCategory: ProductCategory? //e.g. toprated event
    
    @IBOutlet var collectionView: UICollectionView!
    private var dataSource: [Product] = []
    
    private let naHUD = JGProgressHUD(style: .dark)
    
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var clearButton: UIButton!
    private var currentLayout: LiftLayout?
    
    // B2 - 5
    var selectedCell: HomeSliderCell?
    var selectedCellImageViewSnapshot: UIView? //it’s a view that has a current rendered appearance of a view. Think of it as you would take a screenshot of your screen, but it will be one single view without any subviews.
    // B2 - 15
    var searchAnimator: SearchAnimator?
    //for paginations
    var pageNumber = 1
    let pageSize = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentLayout = collectionView.collectionViewLayout as? LiftLayout
        switch category! {
            case .event:
                currentLayout?.setCustomCellHeight(194)
                title = "Search events"
            case .experience:
                currentLayout?.setCustomCellHeight(170)
                title = "Search experiences"
            case .villa:
                currentLayout?.setCustomCellHeight(170)
                title = "Search properties"
            case .gift:
                currentLayout?.setCustomCellHeight(170)
                title = "Search gifts"
            case .yacht:
                currentLayout?.setCustomCellHeight(170)
                title = "Search yachts"
            case .topRated:
                currentLayout?.setCustomCellHeight(170)
                var str = "Search top rated"
                if let subCat = subCategory{
                    str += " " + subCat.rawValue.lowercased()
                }
                title = str + " (+15 rank)"
            case .recent:
                currentLayout?.setCustomCellHeight(170)
                title = "Search recenlty viewed"
        }
        
        collectionView.register(UINib(nibName: HomeSliderCell.identifier, bundle: nil), forCellWithReuseIdentifier: HomeSliderCell.identifier)
        
        searchTextField.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        activateKeyboardManager()
    }
    
    @IBAction func clearButton_onClick(_ sender: Any) {
        searchTextField.text = ""
        searchTextField.becomeFirstResponder()
        dataSource = []
        currentLayout?.clearCache()
        collectionView.reloadData()
    }
    
    func update(listOf objects: [Product]) {
        if dataSource.isEmpty{
            dataSource = objects
            DispatchQueue.main.async(execute: collectionView.reloadData)
        }else {  //paging is being applied
            if objects.count > 0{
                for item in objects{
                    dataSource.append(item)
                }
            }else{
                return  //stop it from executing collectionView.reloadData
            }
        }
        //        print("Found \(dataSource.count) items")
        currentLayout?.clearCache()
        DispatchQueue.main.async(execute: collectionView.reloadData)

    }
    
    func showError(_ error: Error, _ errorTitle:String) {
        showErrorPopup(withTitle: errorTitle, error: error)
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
}

extension SearchProductsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
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
        viewController.transitioningDelegate = self //That is how you configure a present custom transition. But it is not how you configure a push custom transition.
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print(indexPath.row,collectionView.numberOfItems(inSection: indexPath.section))
        if indexPath.row == collectionView.numberOfItems(inSection: indexPath.section) / 2  {   //if half data has been loaded then load rest silently
            print("load next set")
            self.pageNumber += 1
//            self.pageSize += self.pageSize
            self.getInformation(for: category, past: false, term: self.searchTextField.text, page: self.pageNumber, perPage: self.pageSize, isSilentFetch: true)
        }
    }
}

extension SearchProductsViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text?.count ?? 0 > 1 {
            textField.resignFirstResponder()
            self.getInformation(for: category, past: false, term: textField.text, page: self.pageNumber, perPage: self.pageSize)
            return true
        }
        
        showInformationPopup(withTitle: "Info", message: "Please, enter minimum 2 characters for search.")
        return false
    }
    
}

extension SearchProductsViewController {
    
    func getInformation(for category: ProductCategory, past: Bool, term: String?, page: Int, perPage: Int, isSilentFetch: Bool = false) {
        if !isSilentFetch{
            showNetworkActivity()
        }
        getList(for: category, past: past, term: term, page:page, perPage: perPage) { items, error in
            self.hideNetworkActivity()
            if let error = error {
                self.showError(error, category.rawValue)
            }
            self.update(listOf: items)  //incase of error items would have []
        }
    }
    
    func getList(for category: ProductCategory, past: Bool, term: String?, page: Int, perPage: Int
                 , completion: @escaping ([Product], Error?) -> Void) {
        
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            completion([], LoginError.errorLogin(description: "User does not exist or is not verified"))
            return
        }
        
        switch category {
            case .event:
                Mixpanel.mainInstance().track(event: "EventSearched", properties: ["searchedText" : term ?? "EmptyString"])
            EEAPIManager().getEvents(past: past, term: term, latitude: nil, longitude: nil, productId: nil, page:page, perPage:perPage) { list, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not obtain events information")
                        completion([], error)
                        return
                    }
                    completion(list, error)
                }
            case .experience:
                Mixpanel.mainInstance().track(event: "ExperienceSearched",
                      properties: ["searchedText" : term ?? "EmptyString"])
                EEAPIManager().getExperiences(term: term, latitude: nil, longitude: nil, productId: nil, page:page, perPage:perPage) { list, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not obtain experiences information")
                        completion([], error)
                        return
                    }
                    completion(list, error)
                }
            case .villa:
                Mixpanel.mainInstance().track(event: "VillaSearched",
                      properties: ["searchedText" : term ?? "EmptyString"])
            EEAPIManager().getVillas(term: term, latitude: nil, longitude: nil, productId: nil, page:page, perPage:perPage) { list, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not obtain villas information")
                        completion([], error)
                        return
                    }
                    completion(list, error)
                }
            case .gift:
                Mixpanel.mainInstance().track(event: "GiftSearched",
                      properties: ["searchedText" : term ?? "EmptyString"])
                EEAPIManager().getGoods( term: term, giftCategoryId: nil, productId: nil, page:page, perPage:perPage) { list, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not obtain gifts information")
                        completion([], error)
                        return
                    }
                    completion(list, error)
            }
            case .yacht:
                Mixpanel.mainInstance().track(event: "YachtSearched",
                      properties: ["searchedText" : term ?? "EmptyString"])
                EEAPIManager().getYachts( term: term, cityId: nil, productId: nil, page:page, perPage:perPage) { list, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not obtain yachts information")
                        completion([], error)
                        return
                    }
                    completion(list, error)
            }
            case .topRated:
                Mixpanel.mainInstance().track(event: "TopRatedSearched",
                      properties: ["searchedText" : term ?? "EmptyString"])
                var subCatParam = ""
                switch subCategory {
                case .event:
                    subCatParam = "event"
                case .experience:
                    subCatParam = "experience"
                case .gift:
                    subCatParam = "gift"
                case .villa:
                    subCatParam = "villa"
                case .yacht:
                    subCatParam = "yacht"
                default:
                    subCatParam = subCategory?.rawValue.lowercased() ?? ""
                }
                EEAPIManager().getTopRated( type: subCatParam, term: term) { list, error in
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let error = BackendError.parsing(reason: "Could not obtain top rated information")
                        completion([], error)
                        return
                    }
                    completion(list, error)
            }
            case .recent:   //it will never be called
                EEAPIManager().getYachts( term: term, cityId: nil, productId: nil, page:page, perPage:perPage) { list, error in
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
                    self.showError(error, "Favorite")
                    return
                }
                
                if let informations = information {
                    self.dataSource[index].isFavourite = !(self.dataSource[index].isFavourite ?? false)
                    self.update(listOf: self.dataSource) //just to reload the grid
                   
    //              PreloadDataManager.HomeScreen.scrollViewData = information
                    print("ItemID:\(item.id)" + ", ItemType:" + item.type  + ", ServerResponse:" + informations)
                } else {
                    let error = BackendError.parsing(reason: "Could not obtain tap on heart information")
                    self.showError(error, "Favorite")
                }
            }
        }
    }
    
    func setUnSetFavourites(type:String, id:String, isUnSetFavourite: Bool ,completion: @escaping (String?, Error?) -> Void) {
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
extension SearchProductsViewController: UIViewControllerTransitioningDelegate {

    // B1 - 2
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        return nil
        // B2 - 16
//        We are preparing the properties to initialize an instance of Animator. If it fails, return nil to use default animation. Then assign it to the animator instance that we just created.
        guard let firstViewController = source as? SearchProductsViewController,
            let secondViewController = presented as? ProductDetailsViewController,
            let selectedCellImageViewSnapshot = selectedCellImageViewSnapshot
            else {
                return nil
            }
//        print(animationtype)
//        if animationtype == .slider{
            searchAnimator = SearchAnimator(type: .present, firstViewController: firstViewController, secondViewController: secondViewController, selectedCellImageViewSnapshot: selectedCellImageViewSnapshot)
            return searchAnimator
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
            searchAnimator = SearchAnimator(type: .dismiss, firstViewController: self, secondViewController: secondViewController, selectedCellImageViewSnapshot: selectedCellImageViewSnapshot)
            return searchAnimator

    }
}
