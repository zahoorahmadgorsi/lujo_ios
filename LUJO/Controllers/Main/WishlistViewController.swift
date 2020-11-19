//
//  FavouritesViewController.swift
//  LUJO
//
//  Created by I MAC on 05/11/2020.
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
    var animationInterval:TimeInterval = 4
    var totalAnimationOnScreen:Int = 8
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //if data is already loaded then re-load silently
        let isAlreadyLoaded:Bool = (wishListInformations == nil) ? false : true
        getWishListInformation(showActivity: !isAlreadyLoaded)
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
                let error = BackendError.parsing(reason: "Could not obtain Dining information")
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
         let secondsToDelay:TimeInterval = self.animationInterval / Double(totalAnimationOnScreen) //animation delay between Featured,Events and Experience
//        removing all subview first then adding new
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
                itemsList.append( Favourite(id: item.eventsExperience?.id
                    , name: item.eventsExperience?.name
                    , description: item.eventsExperience?.description
                    , primaryMedia:item.eventsExperience?.primaryMedia
                    , location: item.eventsExperience?.location
                    , isFavourite: item.eventsExperience?.isFavourite))
            }
            wishListView.itemsList = itemsList
            stackView.addArrangedSubview(wishListView)
            //applying constraints on wishListView
            setupWishListLayout(wishListView: wishListView)
            //Animation
//            DispatchQueue.main.asyncAfter(deadline: .now() + (1*secondsToDelay) ) {
//                self.startAnimation(wishListView: wishListView)
//            }
        }
        //***********
        // EXPERIENCE
        //***********
        count = (wishListInformations?.experiences?.count ?? 0)
        if count > 0 , let items = wishListInformations?.experiences{
//            let wishListView = WishListView()
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
                itemsList.append( Favourite(id: item.eventsExperience?.id
                    , name: item.eventsExperience?.name
                    , description: item.eventsExperience?.description
                    , primaryMedia:item.eventsExperience?.primaryMedia
                    , location: item.eventsExperience?.location
                    , isFavourite: item.eventsExperience?.isFavourite))
            }
            wishListView.itemsList = itemsList
            stackView.addArrangedSubview(wishListView)
            //applying constraints on wishListView
            setupWishListLayout(wishListView: wishListView)
            //Animation
//            DispatchQueue.main.asyncAfter(deadline: .now() + (1*secondsToDelay) ) {
//                self.startAnimation(wishListView: wishListView)
//            }
        }
        //**************
        // Special Event
        //**************
        count = (wishListInformations?.specialEvents?.count ?? 0)
        if count > 0 , let items = wishListInformations?.specialEvents{
//            let wishListView = WishListView()
            var wishListView: WishListView = {
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
                itemsList.append( Favourite(id: item.eventsExperience?.id
                    , name: item.eventsExperience?.name
                    , description: item.eventsExperience?.description
                    , primaryMedia:item.eventsExperience?.primaryMedia
                    , location: item.eventsExperience?.location
                    , isFavourite: item.eventsExperience?.isFavourite))
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
//            let wishListView = WishListView()
            let wishListView: WishListView = {
                let tv = WishListView()
                tv.translatesAutoresizingMaskIntoConstraints = false
                return tv
            }()
            
            wishListView.delegate = self
            wishListView.itemType = .restaurant
            wishListView.imgTitle.image = UIImage(named: "Dining Icon White")
            wishListView.lblTitle.text = "Dining"
            //preparing data of collection view
            var itemsList = [Favourite]()
            for item in items{
                itemsList.append( Favourite(id: item.restaurant?.id
                    , name: item.restaurant?.name
                    , description: item.restaurant?.description
                    , primaryMedia:item.restaurant?.primaryMedia
                    , location: item.restaurant?.location
                    , isFavourite: item.restaurant?.isFavourite))
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
//            let wishListView = WishListView()
            let wishListView: WishListView = {
                let tv = WishListView()
                tv.translatesAutoresizingMaskIntoConstraints = false
                return tv
            }()
            
            wishListView.delegate = self
            wishListView.itemType = .hotel
            wishListView.imgTitle.image = UIImage(named: "Hotel Icon")
            wishListView.lblTitle.text = "Hotel"
            //preparing data of collection view
            var itemsList = [Favourite]()
            for item in items{
                itemsList.append( Favourite(id: item.hotel?.id
                    , name: item.hotel?.name
                    , description: item.hotel?.description
                    , primaryMedia:item.hotel?.primaryMedia
                    , location: item.hotel?.location
                    , isFavourite: item.hotel?.isFavourite))
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
//            let wishListView = WishListView()
            let wishListView: WishListView = {
                let tv = WishListView()
                tv.translatesAutoresizingMaskIntoConstraints = false
                return tv
            }()
            
            wishListView.delegate = self
            wishListView.itemType = .villa
            wishListView.imgTitle.image = UIImage(named: "villa icon")
            wishListView.lblTitle.text = "Villa"
            //preparing data of collection view
            var itemsList = [Favourite]()
            for item in items{
                itemsList.append( Favourite(id: item.villa?.id
                    , name: item.villa?.name
                    , description: item.villa?.description
                    , primaryMedia:item.villa?.primaryMedia
                    , location: item.villa?.location
                    , isFavourite: item.villa?.isFavourite))
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
//            let wishListView = WishListView()
            let wishListView: WishListView = {
                let tv = WishListView()
                tv.translatesAutoresizingMaskIntoConstraints = false
                return tv
            }()
            
            wishListView.delegate = self
            wishListView.itemType = .yacht
            wishListView.imgTitle.image = UIImage(named: "Yacht Icon")
            wishListView.lblTitle.text = "Yacht"
            //preparing data of collection view
            var itemsList = [Favourite]()
            for item in items{
                itemsList.append( Favourite(id: item.yacht?.id
                    , name: item.yacht?.name
                    , description: item.yacht?.description
                    , primaryMedia:item.yacht?.primaryMedia
                    , location: item.yacht?.location
                    , isFavourite: item.yacht?.isFavourite))
            }
            wishListView.itemsList = itemsList
            stackView.addArrangedSubview(wishListView)
            //applying constraints on wishListView
            setupWishListLayout(wishListView: wishListView)
        }
        //******************
        // Gifts/Goods
        //******************
        count = (wishListInformations?.gifts?.count ?? 0)
        if count > 0 , let items = wishListInformations?.gifts{
//            let wishListView = WishListView()
            let wishListView: WishListView = {
                let tv = WishListView()
                tv.translatesAutoresizingMaskIntoConstraints = false
                return tv
            }()
            
            wishListView.delegate = self
            wishListView.itemType = .gift
            wishListView.imgTitle.image = UIImage(named: "Goods Icon")
            wishListView.lblTitle.text = "Goods"
            //preparing data of collection view
            var itemsList = [Favourite]()
            for item in items{
                itemsList.append( Favourite(id: item.gift?.id
                    , name: item.gift?.name
                    , description: item.gift?.description
                    , primaryMedia:item.gift?.primaryMedia
                    , location: item.gift?.location
                    , isFavourite: item.gift?.isFavourite))
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
        let itemHeight = CollectionSize.itemHeight.rawValue + CollectionSize.itemMargin.rawValue*2+64   // 64 is height of "see all" control
        wishListView.heightAnchor.constraint(equalToConstant: CGFloat(itemHeight)).isActive = true
    }
    
    func getWishListInformation(completion: @escaping (WishListObjects?, Error?) -> Void) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            completion(nil, LoginError.errorLogin(description: "User does not exist or is not verified"))
            return
        }
        
        GoLujoAPIManager().getFavourites(token) { favourites, error in
            guard error == nil else {
                Crashlytics.sharedInstance().recordError(error!)
                let error = BackendError.parsing(reason: "Could not obtain the information")
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
//        print("didTappedOnItem")
        switch itemType {
            case .event:
                if let event = wishListInformations?.events?[indexPath.row].eventsExperience{
                    let viewController = EventDetailsViewController.instantiate(event: event)
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
            case .experience:
            if let event = wishListInformations?.experiences?[indexPath.row].eventsExperience{
                let viewController = EventDetailsViewController.instantiate(event: event)
                self.navigationController?.pushViewController(viewController, animated: true)
            }
            case .specialEvent:
            if let event = wishListInformations?.specialEvents?[indexPath.row].eventsExperience{
                let viewController = EventDetailsViewController.instantiate(event: event)
                self.navigationController?.pushViewController(viewController, animated: true)
            }
            case .restaurant:
            if let item = wishListInformations?.restaurants?[indexPath.row].restaurant{
                let viewController = RestaurantDetailViewController.instantiate(restaurant: item)
//                self.navigationController?.pushViewController(viewController, animated: true)
                present(viewController, animated: true, completion: nil)
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
            if let id = wishListInformations?.events?[index].eventsExperience?.id,
                let isFav = wishListInformations?.events?[index].eventsExperience?.isFavourite{
                    itemID = id
                    isFavourite = isFav
            }
        case .specialEvent:
            if let id = wishListInformations?.specialEvents?[index].eventsExperience?.id,
                let isFav = wishListInformations?.specialEvents?[index].eventsExperience?.isFavourite{
                    itemID = id
                    isFavourite = isFav
            }
        case .experience:
            if let id = wishListInformations?.experiences?[index].eventsExperience?.id,
                let isFav = wishListInformations?.experiences?[index].eventsExperience?.isFavourite{
                    itemID = id
                    isFavourite = isFav
            }
        case .restaurant:
            if let id = wishListInformations?.restaurants?[index].restaurant?.id,
                let isFav = wishListInformations?.restaurants?[index].restaurant?.isFavourite{
                    itemID = id
                    isFavourite = isFav
            }
        case .hotel:
            if let id = wishListInformations?.hotels?[index].hotel?.id,
                let isFav = wishListInformations?.hotels?[index].hotel?.isFavourite{
                    itemID = id
                    isFavourite = isFav
            }
        case .villa:
            if let id = wishListInformations?.villas?[index].villa?.id,
                let isFav = wishListInformations?.villas?[index].villa?.isFavourite{
                    itemID = id
                    isFavourite = isFav
            }
        case .gift:
            if let id = wishListInformations?.gifts?[index].gift?.id,
                let isFav = wishListInformations?.gifts?[index].gift?.isFavourite{
                    itemID = id
                    isFavourite = isFav
            }
        case .yacht:
            if let id = wishListInformations?.yachts?[index].yacht?.id,
                let isFav = wishListInformations?.yachts?[index].yacht?.isFavourite{
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
                self.getWishListInformation(showActivity: false)
                print("ItemID:\(itemID)" + ", ServerResponse:" + informations)
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
                let error = BackendError.parsing(reason: "Could not obtain Dining information")
                completion(nil, error)
                return
            }
            completion(strResponse, error)
        }
    }
}

