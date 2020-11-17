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

        // Do any additional setup after loading the view.
        getWishListInformation(showActivity: true)
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
        }
        //***********
        // EXPERIENCE
        //***********
        count = (wishListInformations?.experiences?.count ?? 0)
        if count > 0 , let items = wishListInformations?.experiences{
//            let wishListView = WishListView()
            var wishListView: WishListView = {
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
            wishListView.itemType = .experience
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
            wishListView.itemType = .experience
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
            wishListView.itemType = .experience
            wishListView.imgTitle.image = UIImage(named: "Dining Icon White")
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
        count = (wishListInformations?.hotels?.count ?? 0)
        if count > 0 , let items = wishListInformations?.hotels{
//            let wishListView = WishListView()
            let wishListView: WishListView = {
                let tv = WishListView()
                tv.translatesAutoresizingMaskIntoConstraints = false
                return tv
            }()
            
            wishListView.delegate = self
            wishListView.itemType = .experience
            wishListView.imgTitle.image = UIImage(named: "Dining Icon White")
            wishListView.lblTitle.text = "Villa"
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
            wishListView.itemType = .experience
            wishListView.imgTitle.image = UIImage(named: "Dining Icon White")
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
    
    func didTappedOnItem() {
        print("didTappedOnItem")
    }
    
    func didTappedOnHeartAt(){
        print("didTappedOnHeartAt")
    }

}

//extension WishListViewController: DidSelectWishListItemProtocol {
//
//    func didTappedOnHeartAt(index: Int, sender: WishListView) {
//        print("HomeViewController.didTappedOnHeartAt")
//        var item: EventsExperiences!
//        switch sender {
//            case homeEventSlider:
//                item = homeObjects?.events[index]
//            case homeExperienceSlider:
//                item = homeObjects?.experiences[index]
//            case locationEventSlider:
//                item = locationEventSlider.itemsList[index]
//            default: return
//        }
//
//        //setting the favourite
//        self.showNetworkActivity()
//        setUnSetFavourites(id: item.id ,isUnSetFavourite: item.isFavourite ?? false) {information, error in
//            self.hideNetworkActivity()
//
//            if let error = error {
//                self.showError(error)
//                return
//            }
//
//            if let informations = information {
//                switch sender {
//                case self.homeEventSlider:
//                    var locationEvents = self.locationEventSlider.itemsList //events in locationEventSlider
//                    var homeEvents = self.homeEventSlider.itemsList     //events in homeEventSlider
//
//                    //Event updated in homeEventList , might also be present in locationlist
//                    //Get the element and its offset
//                    if let item = locationEvents.enumerated().first(where: {$0.element.id == homeEvents[index].id}) {
//                        print("HomeEventIndex:\(index) , : LocationEventIndex:\(item.offset) ")
//                        locationEvents[item.offset].isFavourite = !(locationEvents[item.offset].isFavourite ?? false)  //update location events list as well
//                        self.locationEventSlider.itemsList = locationEvents //re-assigning as it will automatically reload the collection
//                    }
//                    homeEvents[index].isFavourite = !(homeEvents[index].isFavourite ?? false)
//                    sender.itemsList = homeEvents   //re-assigning as it will automatically reload the collection
//                case self.homeExperienceSlider:
//                    var homeExperiences = self.homeExperienceSlider.itemsList //events in locationEventSlider
//                    homeExperiences[index].isFavourite = !(homeExperiences[index].isFavourite ?? false)
//                    sender.itemsList = homeExperiences   //re-assigning as it will automatically reload the collection
//                case self.locationEventSlider:
//                    var locationEvents = self.locationEventSlider.itemsList //events in locationEventSlider
//                    var homeEvents = self.homeEventSlider.itemsList     //events in homeEventSlider
//
//                    //Event updated in locationlist, might also be present in home event list,
//                    //Get the element and its offset
//                    if let item = homeEvents.enumerated().first(where: {$0.element.id == locationEvents[index].id}) {
//                        print("LocationEventIndex:\(index) , HomeEventIndex: \(item.offset) ")
//                        homeEvents[item.offset].isFavourite = !(homeEvents[item.offset].isFavourite ?? false)    //update home events list as well
//                        self.homeEventSlider.itemsList = homeEvents //re-assigning as it will automatically reload the collection
//                    }
//                    locationEvents[index].isFavourite = !(locationEvents[index].isFavourite ?? false)
//                    sender.itemsList = locationEvents   //re-assigning as it will automatically reload the collection
//                    // Store data for later use inside preload reference.
////                        PreloadDataManager.HomeScreen.scrollViewData = information
//                default: return
//                }
//                print("ItemID:\(item.id)" + ", ItemType:" + item.type  + ", ServerResponse:" + informations)
//            } else {
//                let error = BackendError.parsing(reason: "Could not obtain Dining information")
//                self.showError(error)
//            }
//        }
        
//    }
 
   
    
    
    
//    func didSelectItemAt(indexPath: IndexPath, sender: WishListView) {
//        print("HomeViewController.didSelectItemAt")
////        let event: EventsExperiences!
////
////        switch sender {
////            case homeEventSlider:
////                event = homeObjects?.events[indexPath.row]
////            case homeExperienceSlider:
////                event = homeObjects?.experiences[indexPath.row]
////            case locationEventSlider:
////                event = locationEventSlider.itemsList[indexPath.row]
////            default: return
////        }
////
////        let viewController = EventDetailsViewController.instantiate(event: event)
////        self.navigationController?.pushViewController(viewController, animated: true)
//    }
    
//}
