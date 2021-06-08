//
//  FavouritesViewController.swift
//  LUJO
//
//  Created by Hafsa on 05/11/2020.
//  Copyright © 2020 Baroque Access. All rights reserved.
//

import UIKit
import JGProgressHUD

class WishListViewController: UIViewController, WishListViewProtocol{
    /// Class storyboard identifier.
    class var identifier: String { return "WishListViewController" }
    
    @IBOutlet weak var stackView: UIStackView!
    
    /// Init method that will init and return view controller.
    class func instantiate() -> WishListViewController {
        return UIStoryboard.main.instantiate(identifier)
    }
    //MARK:- Globals
    
    private var wishListInformations: WishListObjects?
    private let naHUD = JGProgressHUD(style: .dark)
    @IBOutlet var scrollView: UIScrollView!
//    var totalAnimationOnScreen:Int = 8
    
    // B2 - 5
    var selectedCell: FavouriteCell?
    var selectedCellImageViewSnapshot: UIView? //it’s a view that has a current rendered appearance of a view. Think of it as you would take a screenshot of your screen, but it will be one single view without any subviews.
    // B2 - 15
    var wishListAnimator: WishListSliderAnimator?
    var wishListDiningAnimator: WishListDiningAnimator?
    
    /// Refresh control view. Used to display network activity when user pull scroll view down
    /// view to fetch new data.
    private lazy var refreshControl: UIRefreshControl = {
        // Create refresh control and link it with scroll view.
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: UIControl.Event.valueChanged)
        self.scrollView.refreshControl = refreshControl
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //data is loading in viewWillAppear
        //if data is already loaded then re-load silently
//        let isAlreadyLoaded:Bool = (wishListInformations == nil) ? false : true
        getWishListInformation(showActivity: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //refetch data IF ANd ONLY IF no data is there else back animation will not work properly
        if (wishListInformations == nil){
            getWishListInformation(showActivity: true)
        }
        startPauseAnimation(isPausing: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        startPauseAnimation(isPausing: true)
    }
    
    //when user will navigate away from the current controller, we are stopping all animation
    @objc func startPauseAnimation( isPausing : Bool) {
//        for view in self.stackView.subviews {
//            if view is WishListView{
//                (view as! WishListView).startPauseAnimation(isPausing: isPausing)
//            }
//        }
    }
    
    /// Refresh control target action that will trigger once user pull to refresh scroll view.
    @objc func refresh(_ sender: AnyObject) {
        // Force data fetch.
        getWishListInformation(showActivity: false)
    }
    
    func getWishListInformation(showActivity: Bool) {
        if showActivity {
            self.showNetworkActivity()
        }
        getWishListInformation() {information, error in
            self.hideNetworkActivity()
            
            if let error = error {
                self.showError(error)
                return
            }
            
            if let informations = information {
                self.update(informations)
            } else {
                let error = BackendError.parsing(reason: "Could not obtain wish list information")
                self.showError(error)
            }
        }
    }
    
    func update(_ information: WishListObjects?) {
        guard information != nil else {
            return
        }
        
        wishListInformations = information
        updateContent()

            // -------------------------------------------------------------------------------------
            // Refresh control and data caching.

            // Stop refresh control animation and allow scroll to sieze back refresh control space by
            // scrolling up.
            refreshControl.endRefreshing()

            // Store data for later use inside preload reference.
            //PreloadDataManager.DiningScreen.scrollViewData = information
            // -------------------------------------------------------------------------------------
    }
    
    func updateContent() {
        for view in self.stackView.subviews {
            view.removeFromSuperview()
        }
        //*******
        // EVENTS
        //*******
        var count = (wishListInformations?.events?.count ?? 0)
        if count > 0 , let items = wishListInformations?.events{
            let wishListView = WishListView()
            wishListView.delegate = self
            wishListView.itemType = .event
            wishListView.imgTitle.image = UIImage(named: "Event Icon White")
            wishListView.lblTitle.text = "Event"
            //preparing data of collection view
            var itemsList = [Favourite]()
            for item in items{
                itemsList.append( Favourite(id: item.id
                    , name: item.name
                    , description: item.description
                    , primaryMedia:item.primaryMedia
                    , location: item.location
                    , isFavourite: item.isFavourite))
            }
            wishListView.itemsList = itemsList
            stackView.addArrangedSubview(wishListView)
            
            //applying constraints on wishListView
            setupWishListLayout(wishListView: wishListView)
        }
        //***********
        // EXPERIENCE
        //***********
        count = (wishListInformations?.experiences?.count ?? 0)
        if count > 0 , let items = wishListInformations?.experiences{
            let wishListView: WishListView = {
                let tv = WishListView()
                tv.translatesAutoresizingMaskIntoConstraints = false
                return tv
            }()
            
            wishListView.delegate = self
            wishListView.itemType = .experience
            wishListView.imgTitle.image = UIImage(named: "Experience Icon White")
            wishListView.lblTitle.text = "Experience"
            //preparing data of collection view
            var itemsList = [Favourite]()
            for item in items{
                itemsList.append( Favourite(id: item.id
                    , name: item.name
                    , description: item.description
                    , primaryMedia:item.primaryMedia
                    , location: item.location
                    , isFavourite: item.isFavourite))
            }
            wishListView.itemsList = itemsList
            stackView.addArrangedSubview(wishListView)
            //applying constraints on wishListView
            setupWishListLayout(wishListView: wishListView)
        }
        //**************
        // Special Event
        //**************
        count = (wishListInformations?.specialEvents?.count ?? 0)
        if count > 0 , let items = wishListInformations?.specialEvents{
            let wishListView: WishListView = {
                let tv = WishListView()
                tv.translatesAutoresizingMaskIntoConstraints = false
                return tv
            }()
            
            wishListView.delegate = self
            wishListView.itemType = .specialEvent
            wishListView.imgTitle.image = UIImage(named: "Event Icon White")
            wishListView.lblTitle.text = "Special Event"
            //preparing data of collection view
            var itemsList = [Favourite]()
            for item in items{
                itemsList.append( Favourite(id: item.id
                    , name: item.name
                    , description: item.description
                    , primaryMedia:item.primaryMedia
                    , location: item.location
                    , isFavourite: item.isFavourite))
            }
            wishListView.itemsList = itemsList
            stackView.addArrangedSubview(wishListView)
            //applying constraints on wishListView
            setupWishListLayout(wishListView: wishListView)
        }
        //******************
        // Restaurant/Dining
        //******************
        count = (wishListInformations?.restaurants?.count ?? 0)
        if count > 0 , let items = wishListInformations?.restaurants{
            let wishListView: WishListView = {
                let tv = WishListView()
                tv.translatesAutoresizingMaskIntoConstraints = false
                return tv
            }()
            
            wishListView.delegate = self
            wishListView.itemType = .restaurant
            wishListView.imgTitle.image = UIImage(named: "dining grey icon")
            wishListView.lblTitle.text = "Dining"
            //preparing data of collection view
            var itemsList = [Favourite]()
            for item in items{
                itemsList.append( Favourite(id: item.id
                    , name: item.name
                    , description: item.description
                    , primaryMedia:item.primaryMedia
                    , location: item.location
                    , isFavourite: item.isFavourite))
            }
            wishListView.itemsList = itemsList
            stackView.addArrangedSubview(wishListView)
            //applying constraints on wishListView
            setupWishListLayout(wishListView: wishListView)
        }
        //******************
        // Hotel
        //******************
        count = (wishListInformations?.hotels?.count ?? 0)
        if count > 0 , let items = wishListInformations?.hotels{
            let wishListView: WishListView = {
                let tv = WishListView()
                tv.translatesAutoresizingMaskIntoConstraints = false
                return tv
            }()
            
            wishListView.delegate = self
            wishListView.itemType = .hotel
            wishListView.imgTitle.image = UIImage(named: "travel grey icon")
            wishListView.lblTitle.text = "Hotel"
            //preparing data of collection view
            var itemsList = [Favourite]()
            for item in items{
                itemsList.append( Favourite(id: item.id
                    , name: item.name
                    , description: item.description
                    , primaryMedia:item.primaryMedia
                    , location: item.location
                    , isFavourite: item.isFavourite))
            }
            wishListView.itemsList = itemsList
            stackView.addArrangedSubview(wishListView)
            //applying constraints on wishListView
            setupWishListLayout(wishListView: wishListView)
        }
        //******************
        // Villa
        //******************
        count = (wishListInformations?.villas?.count ?? 0)
        if count > 0 , let items = wishListInformations?.villas{
            let wishListView: WishListView = {
                let tv = WishListView()
                tv.translatesAutoresizingMaskIntoConstraints = false
                return tv
            }()
            
            wishListView.delegate = self
            wishListView.itemType = .villa
            wishListView.imgTitle.image = UIImage(named: "villa grey icon")
            wishListView.lblTitle.text = "Villa"
            //preparing data of collection view
            var itemsList = [Favourite]()
            for item in items{
                itemsList.append( Favourite(id: item.id
                    , name: item.name
                    , description: item.description
                    , primaryMedia:item.primaryMedia
                    , location: item.location
                    , isFavourite: item.isFavourite))
            }
            wishListView.itemsList = itemsList
            stackView.addArrangedSubview(wishListView)
            //applying constraints on wishListView
            setupWishListLayout(wishListView: wishListView)
        }
        //******************
        // Yacht
        //******************
        count = (wishListInformations?.yachts?.count ?? 0)
        if count > 0 , let items = wishListInformations?.yachts{
            let wishListView: WishListView = {
                let tv = WishListView()
                tv.translatesAutoresizingMaskIntoConstraints = false
                return tv
            }()
            
            wishListView.delegate = self
            wishListView.itemType = .yacht
            wishListView.imgTitle.image = UIImage(named: "yacht grey icon")
            wishListView.lblTitle.text = "Yacht"
            //preparing data of collection view
            var itemsList = [Favourite]()
            for item in items{
                itemsList.append( Favourite(id: item.id
                    , name: item.name
                    , description: item.description
                    , primaryMedia:item.primaryMedia
                    , location: item.location
                    , isFavourite: item.isFavourite))
            }
            wishListView.itemsList = itemsList
            stackView.addArrangedSubview(wishListView)
            //applying constraints on wishListView
            setupWishListLayout(wishListView: wishListView)
        }
        //******************
        // Gifts
        //******************
        count = (wishListInformations?.gifts?.count ?? 0)
        if count > 0 , let items = wishListInformations?.gifts{
            let wishListView: WishListView = {
                let tv = WishListView()
                tv.translatesAutoresizingMaskIntoConstraints = false
                return tv
            }()
            
            wishListView.delegate = self
            wishListView.itemType = .gift
            wishListView.imgTitle.image = UIImage(named: "gift grey icon")
            wishListView.lblTitle.text = "Gifts"
            //preparing data of collection view
            var itemsList = [Favourite]()
            for item in items{
                itemsList.append( Favourite(id: item.id
                    , name: item.name
                    , description: item.description
                    , primaryMedia:item.primaryMedia
                    , location: item.location
                    , isFavourite: item.isFavourite))
            }
            wishListView.itemsList = itemsList
            stackView.addArrangedSubview(wishListView)
            //applying constraints on wishListView
            setupWishListLayout(wishListView: wishListView)
        }
    }
    
    
    func setupWishListLayout(wishListView:WishListView){
        wishListView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
        wishListView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
        //top isnt required as in stack view it doesnt matter
        //wishListView.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 100).isActive = true
        wishListView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        //if height is 200 and marging is 15 then total height is 230
        //let itemHeight = CollectionSize.itemHeight.rawValue + CollectionSize.itemMargin.rawValue*2+64   // 64 is height of "see all" control
//        var itemHeight = wishListView.collectionView.collectionViewLayout.collectionViewContentSize.height
//        print(itemHeight)
        let itemHeight = CollectionSize.itemHeight.rawValue + CollectionSize.itemMargin.rawValue*2+64 // 64 is height of "see all" control
//        print(itemHeight)
        wishListView.heightAnchor.constraint(equalToConstant: CGFloat(itemHeight)).isActive = true
        //Starting the animation
//        wishListView.startPauseAnimation(isPausing: false)
    }
    
    func getWishListInformation(completion: @escaping (WishListObjects?, Error?) -> Void) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            completion(nil, LoginError.errorLogin(description: "User does not exist or is not verified"))
            return
        }
        
        GoLujoAPIManager().getFavourites(token) { favourites, error in
            guard error == nil else {
                Crashlytics.sharedInstance().recordError(error!)
                let error = BackendError.parsing(reason: "Could not obtain the wish list information")
                completion(nil, error)
                return
            }
            completion(favourites, error)
        }
    }
    
    func showError(_ error: Error) {
        showErrorPopup(withTitle: "WishList Error", error: error)
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
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

   func didTappedOnSeeAll(itemType:FavouriteType) {
        print(itemType)
    }
    
    func didTappedOnItem(indexPath: IndexPath, itemType:FavouriteType, sender: WishListView) {
//        print(indexPath)
        switch itemType {
            case .event:
                if let event = wishListInformations?.events?[indexPath.row]{
                    let viewController = ProductDetailsViewController.instantiate(product: event)
//                    self.navigationController?.pushViewController(viewController, animated: true)
                    viewController.transitioningDelegate = self
                    viewController.modalPresentationStyle = .overFullScreen
                    // B2 - 6
                    selectedCell = sender.collectionView.cellForItem(at: indexPath) as? FavouriteCell
                    // B2 - 7
                    selectedCellImageViewSnapshot = selectedCell?.primaryImage.snapshotView(afterScreenUpdates: false)

                    present(viewController, animated: true)
                }
            case .experience:
                if let event = wishListInformations?.experiences?[indexPath.row]{
                    let viewController = ProductDetailsViewController.instantiate(product: event)
//                    self.navigationController?.pushViewController(viewController, animated: true)
                    viewController.transitioningDelegate = self
                    viewController.modalPresentationStyle = .overFullScreen
                    // B2 - 6
                    selectedCell = sender.collectionView.cellForItem(at: indexPath) as? FavouriteCell
                    // B2 - 7
                    selectedCellImageViewSnapshot = selectedCell?.primaryImage.snapshotView(afterScreenUpdates: false)

                    present(viewController, animated: true)
                }
            case .specialEvent:
                if let event = wishListInformations?.specialEvents?[indexPath.row]{
                    let viewController = ProductDetailsViewController.instantiate(product: event)
//                    self.navigationController?.pushViewController(viewController, animated: true)
                    viewController.transitioningDelegate = self
                    viewController.modalPresentationStyle = .overFullScreen
                    // B2 - 6
                    selectedCell = sender.collectionView.cellForItem(at: indexPath) as? FavouriteCell
                    // B2 - 7
                    selectedCellImageViewSnapshot = selectedCell?.primaryImage.snapshotView(afterScreenUpdates: false)

                    present(viewController, animated: true)
                }
            case .restaurant:
                if let item = wishListInformations?.restaurants?[indexPath.row]{
                    let viewController = ProductDetailsViewController.instantiate(product: item)
    //                self.navigationController?.pushViewController(viewController, animated: true)
                    viewController.transitioningDelegate = self
                    viewController.modalPresentationStyle = .overFullScreen
                    // B2 - 6
                    selectedCell = sender.collectionView.cellForItem(at: indexPath) as? FavouriteCell
                    // B2 - 7
                    selectedCellImageViewSnapshot = selectedCell?.primaryImage.snapshotView(afterScreenUpdates: false)

                    present(viewController, animated: true, completion: nil)
                }
            case .villa:
                if let event = wishListInformations?.villas?[indexPath.row]{
                    let viewController = ProductDetailsViewController.instantiate(product: event)
//                    self.navigationController?.pushViewController(viewController, animated: true)
                    viewController.transitioningDelegate = self
                    viewController.modalPresentationStyle = .overFullScreen
                    // B2 - 6
                    selectedCell = sender.collectionView.cellForItem(at: indexPath) as? FavouriteCell
                    // B2 - 7
                    selectedCellImageViewSnapshot = selectedCell?.primaryImage.snapshotView(afterScreenUpdates: false)

                    present(viewController, animated: true)
                }
            case .yacht:
                if let event = wishListInformations?.yachts?[indexPath.row]{
                    let viewController = ProductDetailsViewController.instantiate(product: event)
//                    self.navigationController?.pushViewController(viewController, animated: true)
                    viewController.transitioningDelegate = self
                    viewController.modalPresentationStyle = .overFullScreen
                    // B2 - 6
                    selectedCell = sender.collectionView.cellForItem(at: indexPath) as? FavouriteCell
                    // B2 - 7
                    selectedCellImageViewSnapshot = selectedCell?.primaryImage.snapshotView(afterScreenUpdates: false)

                    present(viewController, animated: true)
                }
            case .gift:
                if let event = wishListInformations?.gifts?[indexPath.row]{
                    let viewController = ProductDetailsViewController.instantiate(product: event)
//                    self.navigationController?.pushViewController(viewController, animated: true)
                    viewController.transitioningDelegate = self
                    viewController.modalPresentationStyle = .overFullScreen
                    // B2 - 6
                    selectedCell = sender.collectionView.cellForItem(at: indexPath) as? FavouriteCell
                    // B2 - 7
                    selectedCellImageViewSnapshot = selectedCell?.primaryImage.snapshotView(afterScreenUpdates: false)

                    present(viewController, animated: true)
                }
            default:
                print("default")
        }
        
    }
    
    func didTappedOnHeartAt(index: Int,itemType:FavouriteType, sender: WishListView){
        var itemID: Int = 0
        var isFavourite:Bool = false
        switch itemType {
        case .event:
            //if let id = wishListInformations?.events?[index].product?.id,
            if let id = wishListInformations?.events?[index].id,
                let isFav = wishListInformations?.events?[index].isFavourite{
                    itemID = id
                    isFavourite = isFav
            }
        case .specialEvent:
            if let id = wishListInformations?.specialEvents?[index].id,
                let isFav = wishListInformations?.specialEvents?[index].isFavourite{
                    itemID = id
                    isFavourite = isFav
            }
        case .experience:
            if let id = wishListInformations?.experiences?[index].id,
                let isFav = wishListInformations?.experiences?[index].isFavourite{
                    itemID = id
                    isFavourite = isFav
            }
        case .restaurant:
            if let id = wishListInformations?.restaurants?[index].id,
                let isFav = wishListInformations?.restaurants?[index].isFavourite{
                    itemID = id
                    isFavourite = isFav
            }
        case .hotel:
            if let id = wishListInformations?.hotels?[index].id,
                let isFav = wishListInformations?.hotels?[index].isFavourite{
                    itemID = id
                    isFavourite = isFav
            }
        case .villa:
            if let id = wishListInformations?.villas?[index].id,
                let isFav = wishListInformations?.villas?[index].isFavourite{
                    itemID = id
                    isFavourite = isFav
            }
        case .gift:
            if let id = wishListInformations?.gifts?[index].id,
                let isFav = wishListInformations?.gifts?[index].isFavourite{
                    itemID = id
                    isFavourite = isFav
            }
        case .yacht:
            if let id = wishListInformations?.yachts?[index].id,
                let isFav = wishListInformations?.yachts?[index].isFavourite{
                    itemID = id
                    isFavourite = isFav
            }
        }
        //setting the favourite
        self.showNetworkActivity()
        setUnSetFavourites(id: itemID ,isUnSetFavourite: isFavourite ) {information, error in
            self.hideNetworkActivity()
            
            if let error = error {
                self.showError(error)
                return
            }
            
            if let informations = information {
                // data re-fetch.
//                self.getWishListInformation(showActivity: true)
                print("ItemID: \(itemID)" + ", ServerResponse: " + informations)
                //removing item from the list
                    switch itemType {
                    case .event:
                        self.wishListInformations?.events?.remove(at: index)
                    case .specialEvent:
                        self.wishListInformations?.specialEvents?.remove(at: index)
                    case .experience:
                        self.wishListInformations?.experiences?.remove(at: index)
                    case .restaurant:
                        self.wishListInformations?.restaurants?.remove(at: index)
                    case .hotel:
                        self.wishListInformations?.hotels?.remove(at: index)
                    case .villa:
                        self.wishListInformations?.villas?.remove(at: index)
                    case .gift:
                        self.wishListInformations?.gifts?.remove(at: index)
                    case .yacht:
                        self.wishListInformations?.yachts?.remove(at: index)
                }
                //reloading whole UI
                self.updateContent()
            } else {
                let error = BackendError.parsing(reason: "Could not obtain tap on heart information")
                self.showError(error)
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
                let error = BackendError.parsing(reason: "Could not obtain wish list information")
                completion(nil, error)
                return
            }
            completion(strResponse, error)
        }
    }
}

// B1 - 1
extension WishListViewController: UIViewControllerTransitioningDelegate {

    // B1 - 2
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        return nil
        // B2 - 16
//        We are preparing the properties to initialize an instance of Animator. If it fails, return nil to use default animation. Then assign it to the animator instance that we just created.
        if (presented is ProductDetailsViewController){
            guard let firstViewController = source as? WishListViewController,
                let secondViewController = presented as? ProductDetailsViewController,
                let selectedCellImageViewSnapshot = selectedCellImageViewSnapshot
                else {
                    return nil
                }
            wishListAnimator = WishListSliderAnimator(type: .present, firstViewController: firstViewController, secondViewController: secondViewController, selectedCellImageViewSnapshot: selectedCellImageViewSnapshot)
            return wishListAnimator
        }
        else if (presented is ProductDetailsViewController){
            guard let firstViewController = source as? WishListViewController,
                let secondViewController = presented as? ProductDetailsViewController,
                let selectedCellImageViewSnapshot = selectedCellImageViewSnapshot
                else {
                    return nil
                }
            wishListDiningAnimator = WishListDiningAnimator(type: .present, firstViewController: firstViewController, secondViewController: secondViewController, selectedCellImageViewSnapshot: selectedCellImageViewSnapshot)
            return wishListDiningAnimator
        }else{
            return nil
        }

    }

    // B1 - 3
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        return nil
        // B2 - 17
//        We are preparing the properties to initialize an instance of Animator. If it fails, return nil to use default animation. Then assign it to the animator instance that we just created.
        if (dismissed is ProductDetailsViewController){
            guard let secondViewController = dismissed as? ProductDetailsViewController,
                let selectedCellImageViewSnapshot = selectedCellImageViewSnapshot
                else {
                    return nil
                }
                wishListAnimator = WishListSliderAnimator(type: .dismiss, firstViewController: self, secondViewController: secondViewController, selectedCellImageViewSnapshot: selectedCellImageViewSnapshot)
                return wishListAnimator
        }
        else if (dismissed is ProductDetailsViewController){
            guard let secondViewController = dismissed as? ProductDetailsViewController,
                let selectedCellImageViewSnapshot = selectedCellImageViewSnapshot
                else {
                    return nil
                }
            wishListDiningAnimator = WishListDiningAnimator(type: .dismiss, firstViewController: self, secondViewController: secondViewController, selectedCellImageViewSnapshot: selectedCellImageViewSnapshot)
            return wishListDiningAnimator
        }else{
            return nil
        }
    }
}

//extension WishlistViewController: UINavigationControllerDelegate{
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
