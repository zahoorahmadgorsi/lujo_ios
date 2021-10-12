//
//  HomeViewController.swift
//  LUJO
//
//  Created by Iker Kristian on 8/28/19.
//  Copyright © 2019 Baroque Access. All rights reserved.


import UIKit
import JGProgressHUD
import Crashlytics
import CoreLocation
import Kingfisher
import Mixpanel
import TwilioChatClient

enum HomeElementType: Int {
    case events, experiences
}

enum AnimationType {
    case featured
    case slider
    case specialEvent
    
    var isFeatured: Bool {
        return self == .featured
    }
}

struct AirportSuggestion {
    var origin: Airport?
    var destination: Airport
}

class HomeViewController: UIViewController, CLLocationManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "HomeViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate() -> HomeViewController {
        return UIStoryboard.main.instantiate(identifier)
    }
    
    //MARK:- Globals
    
    private var homeObjects: HomeObjects?
    private var locationEvents:[Product] = []
    
    private let naHUD = JGProgressHUD(style: .dark)
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var dimView: UIView!
    @IBOutlet weak var membershipView: UIView!
    
    @IBOutlet var splashView: UIView!
    @IBOutlet var welcomeLabel: UILabel!
    
    @IBOutlet weak var locationContainerView: UIView!
    @IBOutlet weak var noNearbyEventsContainerView: UIView!
    
    @IBOutlet weak var locationEventContainerView: UIView!
    @IBOutlet weak var locationEventTitleLabel: UILabel!
    @IBOutlet weak var locationEventSlider: HomeSlider!
    //See all buttons for all products
    @IBOutlet weak var locationEventViewSeeAll: UIView!
    @IBOutlet weak var topRatedViewSeeAll: UIView!
    @IBOutlet weak var giftViewSeeAll: UIView!
    @IBOutlet weak var villaViewSeeAll: UIView!
    @IBOutlet weak var eventViewSeeAll: UIView!
    @IBOutlet weak var yachtViewSeeAll: UIView!
    @IBOutlet weak var experienceViewSeeAll: UIView!
    
    @IBOutlet var homeRecentSlider: HomeSlider!
    @IBOutlet var homeTopRatedSlider: HomeSlider!
    @IBOutlet var homeGiftsSlider: HomeSlider!
    @IBOutlet var homeVillasSlider: HomeSlider!
    @IBOutlet var homeYachtsSlider: HomeSlider!
    @IBOutlet var homeEventSlider: HomeSlider!
    @IBOutlet var homeExperienceSlider: HomeSlider!
    
    
    @IBOutlet var specialEventContainer1: UIView!
    @IBOutlet var specialEventView1: HomeSpecialEventSummary!
    @IBOutlet var specialEventContainer2: UIView!
    @IBOutlet var specialEventView2: HomeSpecialEventSummary!
    
    @IBOutlet var featured: ImageCarousel!
    @IBOutlet var currentImageNum: UILabel!
    @IBOutlet var allImagesNum: UILabel!
    
    @IBOutlet weak var aviationCollectionView: UICollectionView! {
        didSet {
            aviationCollectionView.register(UINib(nibName: MainScreenAviationCell.identifier, bundle: nil),
                                            forCellWithReuseIdentifier: MainScreenAviationCell.identifier)
        }
    }
    
    @IBOutlet weak var currentAviationIndexLabel: UILabel!
    @IBOutlet weak var maxAviationIndexLabel: UILabel!
    private(set) var aviationDataSource: [AirportSuggestion] = []
    var profileButton: UIButton!
    private var canSendRequest: Bool = true
    
    /// Refresh control view. Used to display network activity when user pull scroll view down
    /// view to fetch new data.
    private lazy var refreshControl: UIRefreshControl = {
        // Create refresh control and link it with scroll view.
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: UIControl.Event.valueChanged)
        self.scrollView.refreshControl = refreshControl
        return refreshControl
    }()
    /// Preload data object that can store some data fetched earlier so we can instantly present
    /// this data without needing to fetch it again from the server. Default is nil.
    private var preloadData: HomeObjects? { return PreloadDataManager.HomeScreen.scrollViewData }
    static let animationInterval:TimeInterval = 3
    // B2 - 5
    var selectedCell: HomeSliderCell?
    var selectedFeaturedCell: ImageCarouselCell?
    var selectedSpecialEventCell: HomeSpecialEventSummary?
    
    var selectedCellImageViewSnapshot: UIView? //it’s a view that has a current rendered appearance of a view. Think of it as you would take a screenshot of your screen, but it will be one single view without any subviews.
    // B2 - 15
    var sliderToDetailAnimator: HomeSliderAnimator?
    var featuredToDetailAnimator: HomeFeaturedAnimator?
    var specialEventAnimator: SpecialEventAnimator?
    
    private var animationtype: AnimationType = .slider  //by default slider to detail animation would be called
    var timer = Timer()
//    var isPaused = true
    var pgrFullView: UIPanGestureRecognizer?    //to handle swipe left and right
    @IBOutlet weak var viewCallToAction: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ChatManager.sharedChatManager.delegate = self
//        naHUD.textLabel.text = "Loading Information"
        featured.overlay = true
        featured.delegate = self
        locationEventSlider.delegate = self
        
        homeRecentSlider.delegate = self
        homeTopRatedSlider.delegate = self
        homeGiftsSlider.delegate = self
        homeVillasSlider.delegate = self
        homeYachtsSlider.delegate = self
        
        homeEventSlider.delegate = self
        homeExperienceSlider.delegate = self
        
        setupNavigationBar()
        updateUI()
        setupTapGesturesForEventsAndExperiences()
        
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(showBadgeValue),
//                                               name: NSNotification.Name(rawValue: "showBadgeValue"),
//                                               object: nil)
        
        let imgSearch    = UIImage(named: "Search Icon White")!
        let imgCallToActions  = UIImage(named: "ctas")!
        let imgChat  = UIImage(named: "chatList")!
        let btnSearch   = UIBarButtonItem(image: imgSearch,  style: .plain, target: self, action: #selector(searchBarButton_onClick(_:)))
        let btnCallToAction = UIBarButtonItem(image: imgCallToActions,  style: .plain, target: self, action: #selector(btnCallToActionTapped(_:)))
        let btnChat = UIBarButtonItem(image: imgChat,  style: .plain, target: self, action: #selector(btnChatTapped(_:)))
        navigationItem.rightBarButtonItems = [btnChat,btnCallToAction, btnSearch]   //order is first second and third

        
        locationEventContainerView.isHidden = true
        locationContainerView.isHidden = true
        noNearbyEventsContainerView.isHidden = true
        
        //tap gesture on location based event's see all
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(btnLocationEventsSeeAllTapped))
        locationEventViewSeeAll.isUserInteractionEnabled = true
        locationEventViewSeeAll.addGestureRecognizer(tapGesture)
        
        //tap gesture on toprated's see all
        let tgTopRated = UITapGestureRecognizer(target: self, action: #selector(btnTopRatedSeeAllTapped))
        topRatedViewSeeAll.isUserInteractionEnabled = true
        topRatedViewSeeAll.addGestureRecognizer(tgTopRated)
        //tap gesture on gift's see all
        let tgGift = UITapGestureRecognizer(target: self, action: #selector(btnGiftSeeAllTapped))
        giftViewSeeAll.isUserInteractionEnabled = true
        giftViewSeeAll.addGestureRecognizer(tgGift)
        //tap gesture on Villa's see all
        let tgVilla = UITapGestureRecognizer(target: self, action: #selector(btnVillaSeeAllTapped))
        villaViewSeeAll.isUserInteractionEnabled = true
        villaViewSeeAll.addGestureRecognizer(tgVilla)
        //tap gesture on event's see all
        let tgEvent = UITapGestureRecognizer(target: self, action: #selector(btnEventSeeAllTapped))
        eventViewSeeAll.isUserInteractionEnabled = true
        eventViewSeeAll.addGestureRecognizer(tgEvent)
        //tap gesture on yacht's see all
        let tgYacht = UITapGestureRecognizer(target: self, action: #selector(btnYachtSeeAllTapped))
        yachtViewSeeAll.isUserInteractionEnabled = true
        yachtViewSeeAll.addGestureRecognizer(tgYacht)
        //tap gesture on Expereience's see all
        let tgExperience = UITapGestureRecognizer(target: self, action: #selector(btnExperienceSeeAllTapped))
        experienceViewSeeAll.isUserInteractionEnabled = true
        experienceViewSeeAll.addGestureRecognizer(tgExperience)
        
        // -------------------------------------------------------------------------------------
        // Check is there preload data stored for instant use, or we need to fetch data from the
        // server.
        if let preloadData = preloadData {
            update(preloadData)
        } else {
            if LujoSetup().getCurrentUser()?.tokenExpiration ?? Date().timeIntervalSince1970 < Date().addingTimeInterval(5 * 24 * 60 * 60).timeIntervalSince1970 {
                GoLujoAPIManager.shared.refreashToken { success in
                    DispatchQueue.main.async {
                        if success {
                            self.loadUserProfile()
                        }
                    }
                }
            } else {
                self.loadUserProfile()
            }
        }
        // -------------------------------------------------------------------------------------

        // Fetch aviation data source.
        fetchAviationDataSource()
        
        locationManager.delegate = self
        
        //handling swipe left and right gestures
        pgrFullView  = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        self.view.addGestureRecognizer(pgrFullView!)        //applying pan gesture on full main view
        //register this method into notification centre as when preferences are loaded from preferencesHomeViewController on this method would be called
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(getAllUserPreferences),
                                               name: Notification.Name(rawValue: "getAllUserPreferences"),
                                               object: nil)
        getAllUserPreferences() //fetching all user preferenes from the server
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        activateKeyboardManager()
        
        if let imageView = self.navigationItem.leftBarButtonItem?.customView as? UIImageView {
            if
                let avatarURLString = LujoSetup().getLujoUser()?.avatar,
                let url = URL(string: avatarURLString)
            {
                print("URL:\(url)")
                imageView.kf.setImage(with: url, placeholder: UIImage(named: "User Anonimous Image"), completionHandler: { result in
                    switch result {
                    case .success(_):
                        break
                    case .failure(_):
                        DispatchQueue.main.async {
                            imageView.image = UIImage(named: "User Anonimous Image")
                            imageView.tintColor = UIColor.gray
                        }
                    }
                })
            } else {
                imageView.image = UIImage(named: "User Anonimous Image")
                imageView.tintColor = UIColor.gray
            }
        }
        
        if !UserDefaults.standard.bool(forKey: "showWelcome") {
            dimView.isHidden = LujoSetup().getLujoUser()?.membershipPlan?.target == "all"
            membershipView.isHidden = LujoSetup().getLujoUser()?.membershipPlan?.target == "all"
            navigationItem.rightBarButtonItem?.isEnabled = LujoSetup().getLujoUser()?.membershipPlan?.target == "all"
        }
        
        // Check for location permission.
        checkLocationAuthorizationStatus()
        
        startPauseAnimation(isPausing: false)    //will start animating at 0 seconds
    }
    

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        startPauseAnimation(isPausing: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showBadgeValue()
    }

    //this method will fetch all user preferences from the server
    @objc func getAllUserPreferences() {
        self.showNetworkActivity()
        fetchAllUserPreferences() {information, error in
//            self.hideNetworkActivity()
            if self.naHUD.isVisible {
                self.naHUD.dismiss()
            }
            if let error = error {
                self.showError(error)
                return
            }
            if let userPreferences = information {
                LujoSetup().store(userPreferences: userPreferences)
            } else {
                let error = BackendError.parsing(reason: "Could not fetch the user preferences")
                self.showError(error)
            }
        }
    }
    
    func fetchAllUserPreferences(completion: @escaping (Preferences?, Error?) -> Void) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            completion(nil, LoginError.errorLogin(description: "User does not exist or is not verified"))
            return
        }
        GoLujoAPIManager().getAllPreferences(token) { Preferences, error in
            guard error == nil else {
                Crashlytics.sharedInstance().recordError(error!)
                let error = BackendError.parsing(reason: "Could not fetch user preferences")
                completion(nil, error)
                return
            }
            completion(Preferences, error)
        }
        
        
    }
    
    var isLocationEnabled: Bool {
        let status = CLLocationManager.authorizationStatus()
        return (status == .authorizedAlways || status == .authorizedWhenInUse)
    }
    
    
    private let locationManager = CLLocationManager()
    
    @IBAction func noNearbyEventsDismissButton_onClick(_ sender: Any) {
        noNearbyEventsContainerView.removeFromSuperview()
    }
    
    func checkLocationAuthorizationStatus() {
        updateUIforAuthorizationStatus(CLLocationManager.authorizationStatus())
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.barTintColor = UIColor(named: "Navigation Bar")
        navigationController?.navigationBar.isTranslucent = false
        
        // Create right bar button
        let profileImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 18
        profileImageView.layer.masksToBounds = true
        profileImageView.isUserInteractionEnabled = true
        profileImageView.clipsToBounds = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(fetchAndPresentUserAccount)))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
        self.navigationItem.leftBarButtonItem?.customView?.heightAnchor.constraint(equalToConstant: 36).isActive = true
        self.navigationItem.leftBarButtonItem?.customView?.widthAnchor.constraint(equalToConstant: 36).isActive = true
    }
    
    @IBAction func enableLocationButton_onClick(_ sender: Any) {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            updateUIforAuthorizationStatus(status)
        case .restricted: fallthrough
        case .denied:
            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    @IBAction func buyMembershipButton_onClick(_ sender: Any) {
        var fullName = ""
        if let firstName = LujoSetup().getLujoUser()?.firstName {
            fullName += "\(firstName) "
        }
        if let lastName = LujoSetup().getLujoUser()?.lastName {
            fullName += "\(lastName)"
        }
        self.navigationController?.pushViewController(MembershipViewControllerNEW.instantiate(userFullname: fullName, screenType: LujoSetup().getLujoUser()?.membershipPlan?.target == "dining" ? .upgradeMembership : .buyMembership, paymentType: .all), animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        updateUIforAuthorizationStatus(status)
    }
    
    private func updateUIforAuthorizationStatus(_ status: CLAuthorizationStatus) {
        locationContainerView.isHidden = isLocationEnabled
        if !locationEventContainerView.isHidden, !isLocationEnabled {
            locationEventContainerView.isHidden = true
        }
        if !(noNearbyEventsContainerView?.isHidden ?? true), !isLocationEnabled {
            noNearbyEventsContainerView?.isHidden = true
        }
        if isLocationEnabled {
            locationManager.startUpdatingLocation()
        }
    }
    
    func updateEventsByGeoLocation(_ events: [Product]) {
//        print(events)
        locationEvents = events
        locationEventContainerView.isHidden = events.count == 0
        locationEventSlider.itemsList = Array(events.prefix(5))
        noNearbyEventsContainerView?.isHidden = events.count > 0
        locationEventTitleLabel.text = "Upcoming in \(events.first?.location?.first?.city?.name ?? "your city")"
    }
    
    func update(_ information: HomeObjects?) {
        
        guard information != nil else {
            
            featured.imageURLList = [""]
            featured.itemsList = []
//            featuredPager.numberOfPages = 1
//            featuredPager.currentPage = 0
            homeRecentSlider.itemsList = []
            homeTopRatedSlider.itemsList = []
            homeGiftsSlider.itemsList = []
            homeVillasSlider.itemsList = []
            homeYachtsSlider.itemsList = []
            
            homeEventSlider.itemsList = []
            homeExperienceSlider.itemsList = []
            specialEventView1.updateInformation(with: nil)
            specialEventView2.updateInformation(with: nil)
            return
        }
        homeObjects = information
        updateContent()
        
        // Update location content
//        if isLocationEnabled {
//            noNearbyEventsContainerView.isHidden = false
//        }
        
        // -------------------------------------------------------------------------------------
        // Refresh control and data caching.
        
        // Stop refresh control animation and allow scroll to sieze back refresh control space by scrolling up.
        refreshControl.endRefreshing()
        
        // Store data for later use inside preload reference.
        PreloadDataManager.HomeScreen.scrollViewData = information
        // -------------------------------------------------------------------------------------
    }
    
    func showError(_ error: Error) {
        showErrorPopup(withTitle: "Events Error", error: error)
    }
    
    func showFeedback(_ message: String) {
        showInformationPopup(withTitle: "Information", message: message)
    }
    
    /// Refresh control target action that will trigger once user pull to refresh scroll view.
    @objc func refresh(_ sender: AnyObject) {
        // Force data fetch.
        getHomeInformation()
    }
    
    @IBAction func searchBarButton_onClick(_ sender: Any) {
        Mixpanel.mainInstance().track(event: "GlobalSearchButtonTappedAtHome")
        self.navigationController?.pushViewController(GlobalSearchViewController.instantiate(), animated: true)
    }

    @IBAction func btnCallToActionTapped(_ sender: Any) {
        Mixpanel.mainInstance().track(event: "btnCallToActionTappedAtHome")
//        print("btnCallToActionTapped")
        if (self.viewCallToAction.isHidden){
            scrollView.scrollToTop()    //because now call to action uiview would become visible to scroll to the top transitionCrossDissolve
    //        viewCallToAction.isHidden = !(viewCallToAction.isHidden)
        }
        UIView.transition(with: viewCallToAction, duration: 0.5, options: .curveEaseInOut, animations: {
            self.viewCallToAction.isHidden = !(self.viewCallToAction.isHidden)
        })
    }
    
    @IBAction func btnChatTapped(_ sender: Any) {
        Mixpanel.mainInstance().track(event: "btnChatTappedAtHome")
        let viewController = ChatListViewController.instantiate()
        let navViewController: UINavigationController = UINavigationController(rootViewController: viewController)
        if #available(iOS 13.0, *) {
            let controller = navViewController.topViewController
            // Modal Dismiss iOS 13 onward
            controller?.presentationController?.delegate = self
        }
        //incase user will do some messaging in AdvanceChatViewController and then dismiss it then chatlistviewcontroller should reflect last message body and time
        navViewController.presentationController?.delegate = self
        self.present(navViewController, animated: true, completion: nil)
    }
    
    @objc func btnLocationEventsSeeAllTapped(_ sender: Any) {
        let viewController = ProductsViewController.instantiate(category: .event, dataSource: locationEvents)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func btnTopRatedSeeAllTapped(_ sender: Any) {
        let viewController = ProductsViewController.instantiate(category: .topRated)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func btnGiftSeeAllTapped(_ sender: Any) {
        let viewController = ProductsViewController.instantiate(category: .gift)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func btnVillaSeeAllTapped(_ sender: Any) {
        let viewController = ProductsViewController.instantiate(category: .villa)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func btnEventSeeAllTapped(_ sender: Any) {
        let viewController = ProductsViewController.instantiate(category: .event)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func btnYachtSeeAllTapped(_ sender: Any) {
        let viewController = ProductsViewController.instantiate(category: .yacht)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func btnExperienceSeeAllTapped(_ sender: Any) {
        let viewController = ProductsViewController.instantiate(category: .experience)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func showEventDetail(_ sender: UITapGestureRecognizer) {
        let event: Product!
        
        switch sender.view {
            case is ImageCarousel:
                event = getCurrentEventInFeatured()
                // B2 - 6
                let indexPath = IndexPath(row: featured.currentIndex ?? 0, section: 0)
                selectedFeaturedCell = featured.collectionView.cellForItem(at: indexPath) as? ImageCarouselCell
                animationtype = .featured   //execute feature to detail animation
                // B2 - 7
                selectedCellImageViewSnapshot = selectedFeaturedCell?.primaryImage.snapshotView(afterScreenUpdates: false)
            case specialEventView1:
                event = homeObjects?.specialEvents[0]
                // B2 - 6
                animationtype = .specialEvent   //execute specialEvent to detail animation
                selectedSpecialEventCell = specialEventView1
                selectedCellImageViewSnapshot = selectedSpecialEventCell?.primaryImage.snapshotView(afterScreenUpdates: false)
            case specialEventView2:
                event = homeObjects?.specialEvents[1]
                // B2 - 6
                animationtype = .specialEvent   //execute specialEvent to detail animation
                selectedSpecialEventCell = specialEventView2
                selectedCellImageViewSnapshot = selectedSpecialEventCell?.primaryImage.snapshotView(afterScreenUpdates: false)
            default: return
        }
        if let event = event{
            let viewController = ProductDetailsViewController.instantiate(product: event)
    //        // B1 - 4
            //That is how you configure a present custom transition. But it is not how you configure a push custom transition.
            viewController.transitioningDelegate = self
            viewController.modalPresentationStyle = .overFullScreen
//            viewController.delegate = self
            
            present(viewController, animated: true)

    //        self.navigationController?.pushViewController(viewController, animated: true)
        }

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
        
        let initialLoad = UserDefaults.standard.bool(forKey: "showWelcome")
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        UserDefaults.standard.set(false, forKey: "showWelcome")
        tabBarController?.tabBar.isHidden = false
        splashView.isHidden = true
        if initialLoad {
            tabBarController?.selectedIndex = LujoSetup().getLujoUser()?.membershipPlan != nil ? LujoSetup().getLujoUser()?.membershipPlan?.target ?? "" == "all" ? 0 : 1 : 3
        }
    }
    
    fileprivate func updateUI() {
        if UserDefaults.standard.bool(forKey: "showWelcome") {
            
            tabBarController?.tabBar.isHidden = true
            welcomeLabel.text = "\(PreloadDataManager.UserEntryType.isOldUser ? "Welcome back" : "Welcome"),\n\(LujoSetup().getLujoUser()?.firstName ?? "") \(LujoSetup().getLujoUser()?.lastName ?? "")"
            PreloadDataManager.UserEntryType.isOldUser = true


            //********
            //MaxPanel
            //********
            // Ensure all future events sent from
            // the library will have the distinct_id -13793
            if let id = LujoSetup().getLujoUser()?.id{
                Mixpanel.mainInstance().identify(distinctId: String(id))
            }else{
                Mixpanel.mainInstance().identify(distinctId: "-13793")
            }
            if let phoneNumber = LujoSetup().getLujoUser()?.phoneNumber.readableNumber{
                // Sets user 13793's "$email" attribute to "jsmith@example.com"
                Mixpanel.mainInstance().people.set(properties: [ "$phone":phoneNumber])
            }
            if let firstname = LujoSetup().getLujoUser()?.firstName , let lastName = LujoSetup().getLujoUser()?.lastName {
                // Sets user 13793's "$email" attribute to "jsmith@example.com"
                Mixpanel.mainInstance().people.set(properties: [ "$name": firstname + " " + lastName])
            }
            
            navigationController?.setNavigationBarHidden(true, animated: false)
            splashView.isHidden = false
        }
    }
    
    fileprivate func addTapRecognizer(to view: UIView) {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(showEventDetail(_:)))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapRecognizer)
    }
    
    fileprivate func setupTapGesturesForEventsAndExperiences() {
        addTapRecognizer(to: specialEventView1)
        addTapRecognizer(to: specialEventView2)
        addTapRecognizer(to: featured)
        //Add tap gestures on heart images
        let tgrOnHeart1 = UITapGestureRecognizer(target: self, action: #selector(tappedOnHeart(_:)))
        specialEventView1.viewHeart.addGestureRecognizer(tgrOnHeart1)
        let tgrOnHeart2 = UITapGestureRecognizer(target: self, action: #selector(tappedOnHeart(_:)))
        specialEventView2.viewHeart.addGestureRecognizer(tgrOnHeart2)
        
    }
    
    @objc func tappedOnHeart(_ sender:UITapGestureRecognizer){
        var item: Product?
        var index: Int = 0
        
        if (sender.view == specialEventView1.viewHeart && homeObjects?.specialEvents.count ?? 0 >= 1){
            item = homeObjects?.specialEvents[0]
            index = 0
        }else if (sender.view == specialEventView2.viewHeart && homeObjects?.specialEvents.count ?? 0 >= 2){
            item = homeObjects?.specialEvents[1]
            index = 1
        }
        //setting the favourite
        if let item = item{
            self.showNetworkActivity()
            setUnSetFavourites(id: item.id ,isUnSetFavourite: item.isFavourite ?? false) {information, error in
                self.hideNetworkActivity()
                
                if let error = error {
                    self.showError(error)
                    return
                }
                
                if let informations = information {
                    self.homeObjects?.specialEvents[index].isFavourite = !(item.isFavourite ?? false)
                    if (index == 0){
                        self.specialEventView1.updateInformation(with: self.homeObjects?.specialEvents[index])
                    }else if (index == 1){
                        self.specialEventView2.updateInformation(with: self.homeObjects?.specialEvents[index])
                    }
                    print("ItemID:\(item.id)" + ", ItemType:" + item.type  + ", ServerResponse:" + informations)
                } else {
                    let error = BackendError.parsing(reason: "Could not obtain tap on heart information")
                    self.showError(error)
                }
            }
        }
    }
    
    fileprivate func updateContent() {
        
        if let featuredImages = homeObjects?.getFeaturedImages() {
            featured.imageURLList = featuredImages
            featured.titleList = homeObjects!.getFeaturedNames()
            featured.categoryList = homeObjects!.getFeaturedTypes()
            featured.tagsList = homeObjects!.getFeaturedTags()
            allImagesNum.text = "\(featuredImages.count)"
            currentImageNum.text = "1"
        }
        
        featured.itemsList = homeObjects?.slider ?? [] 
        homeRecentSlider.itemsList = homeObjects?.recent ?? []
        homeTopRatedSlider.itemsList = homeObjects?.topRated ?? []
        homeGiftsSlider.itemsList = homeObjects?.gifts ?? []
        homeVillasSlider.itemsList = homeObjects?.villas ?? []
        homeYachtsSlider.itemsList = homeObjects?.yachts ?? []
        
        homeEventSlider.itemsList = homeObjects?.events ?? []
        homeExperienceSlider.itemsList = homeObjects?.experiences ?? []
        
        if homeObjects?.specialEvents.count ?? 0 > 1 {
            specialEventView1.updateInformation(with: homeObjects?.specialEvents[0])
            specialEventView2.updateInformation(with: homeObjects?.specialEvents[1])
        } else if homeObjects?.specialEvents.count ?? 0 > 0 {
            specialEventView1.updateInformation(with: homeObjects?.specialEvents[0])
            specialEventView2.updateInformation(with: nil)
            specialEventContainer2.isHidden = true
        } else {
            specialEventView1.updateInformation(with: nil)
            specialEventContainer1.isHidden = true
            specialEventView2.updateInformation(with: nil)
            specialEventContainer2.isHidden = true
        }
    }
    
    func presentAccountViewController(_ user: LujoUser) {
        let viewController = AccountViewController.instantiate(user: user)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func fetchAviationDataSource() {
        // HARDCODED AIRPOTS
        let newYorkAirport = Airport(id: "aport-14267", name: "TETERBORO", city: "TETERBORO", country: Country(code: "US", name: "United States"), icao: "KTEB", iata: "TEB", faaId: "TEB", type: "airports")
        let parisAirport = Airport(id: "aport-3379", name: "CHARLES DE GAULLE", city: "PARIS", country: Country(code: "FR", name: "France"), icao: "LFPG", iata: "CDG", faaId: nil, type: "airports")
        let londonAirport = Airport(id: "aport-6400", name: "HEATHROW", city: "LONDON", country: Country(code: "GB", name: "United Kingdom"), icao: "EGLL", iata: "LHR", faaId: nil, type: "airports")
        let dubaiAirport = Airport(id: "aport-6310", name: "DUBAI INTL", city: "DUBAI", country: Country(code: "AE", name: "United Arab Emirates"), icao: "OMDB", iata: "DBX", faaId: nil, type: "airports")
        
        aviationDataSource = [
            AirportSuggestion(origin: nil, destination: newYorkAirport),
            AirportSuggestion(origin: nil, destination: parisAirport),
            AirportSuggestion(origin: nil, destination: londonAirport),
            AirportSuggestion(origin: nil, destination: dubaiAirport)
        ]
        
        maxAviationIndexLabel.text = String(aviationDataSource.count)
        
        aviationCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return aviationDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainScreenAviationCell.identifier, for: indexPath) as! MainScreenAviationCell
        let model = aviationDataSource[indexPath.row]
        cell.airportNameLabel.text = "Fly to \(model.destination.country.name)"
        cell.airportShortTitleLabel.text = model.destination.city
        cell.airportLongTitleLabel.text = model.destination.name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = aviationDataSource[indexPath.row]
        let navigationController = self.tabBarController!.viewControllers![3] as! UINavigationController
        let aviationViewController = navigationController.viewControllers[0] as! AviationViewController
        self.tabBarController?.selectedIndex = 3
        aviationViewController.destinationAirport = model.destination
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView == aviationCollectionView {
            let index = Int(scrollView.contentOffset.x / scrollView.frame.size.width) + 1
            currentAviationIndexLabel.text = String(index)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == aviationCollectionView {
            let index = Int(scrollView.contentOffset.x / scrollView.frame.size.width) + 1
            currentAviationIndexLabel.text = String(index)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width, height: 160)
    }
    
    private var currentLocation: CLLocation? {
        didSet {
            if let location = currentLocation {
                getLocationPlaces(for: location)
            }
        }
    }
    
    //when user will navigate away from the current controller, we are stopping all animation
    @objc func startPauseAnimation( isPausing : Bool) {
//        homeRecentSlider.startAnimation(isPausing: isPausing)
//        homeTopRatedSlider.startAnimation(isPausing: isPausing)
//        homeGiftsSlider.startAnimation(isPausing: isPausing)
//        homeVillasSlider.startAnimation(isPausing: isPausing)
//        homeYachtsSlider.startAnimation(isPausing: isPausing)
//        homeEventSlider.startAnimation(isPausing: isPausing)
//        homeExperienceSlider.startAnimation(isPausing: isPausing)
//        if !isPausing{
//            //Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { _ in
//            timer = Timer.scheduledTimer(withTimeInterval: HomeViewController.animationInterval, repeats: true, block: { _ in
//                if self.featured.titleList.count > 0 {
//                    if let index = Int(self.currentImageNum.text ?? "1") {
//                        if index == self.featured.titleList.count {
//                            self.featured.collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .left)
//                        } else {
//                            self.featured.collectionView.selectItem(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .left)
//                        }
//                    }
//                }
//            })
//
//        } else {
//            timer.invalidate()
//        }
    }
    
    /// Mark - Custom request actions
    @IBAction func findTableButton_onClick(_ sender: Any) {
//        self.present(TableViewController.instantiate(), animated: true, completion: nil)
        self.tabBarController?.selectedIndex = 1
    }
    
    @IBAction func getTicketsButton_onClick(_ sender: Any) {
        let viewController = PerCityViewController.instantiate(category: .event)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func purchaseGoodsButton_onClick(_ sender: Any) {
//        let viewController = ProductsViewController.instantiate(category: .gift)
        let viewController = PerCityViewController.instantiate(category: .gift)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func villaButton_onClick(_ sender: Any) {
        let viewController = PerCityViewController.instantiate(category: .villa)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func findAYachtButton_onClick(_ sender: Any) {
        //self.present(YachtViewController.instantiate(), animated: true, completion: nil)
        //let viewController = EventsViewController.instantiate(category: .yacht)
        let viewController = PerCityViewController.instantiate(category: .yacht)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func findAHotelButton_onClick(_ sender: Any) {
        //Loading the preferences related to dining only very first time
        if !UserDefaults.standard.bool(forKey: "isTravelPreferencesAlreadyShown")  {
            let viewController = TwoSliderPrefViewController.instantiate(prefType: .travel, prefInformationType: .travelFrequency)
            self.navigationController?.pushViewController(viewController, animated: true)
            UserDefaults.standard.set(true, forKey: "isTravelPreferencesAlreadyShown")
        }else{
            let viewController = HotelViewController.instantiate()
//            viewController.delegate = self
            self.present(viewController, animated: true, completion: nil)
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
    
    @objc func panGestureAction(_ panGesture: UIPanGestureRecognizer) {
        let minimumVelocityToHide: CGFloat = 1500
        let minimumScreenRatioToHide: CGFloat = 0.25
        let animationDuration: TimeInterval = 0.2
        
        func slideViewTo(_ x: CGFloat ,_ y: CGFloat) {
                self.view.frame.origin = CGPoint(x: x, y: y)
        }
        
        switch panGesture.state {
            //case .began, .changed:
            case .changed:
                // If pan started or is ongoing then slide the view to follow the finger
                let translation = panGesture.translation(in: view)
                if (panGesture.view == self.view ){
                    slideViewTo(translation.x,0)    //only swipe horizontal if its on main view
                }
            case .ended:
                // If pan ended, decide it we should close or reset the view based on the final position and the speed of the gesture
                let translation = panGesture.translation(in: view)
                let velocity = panGesture.velocity(in: view)
                let closing = (abs(translation.x) > self.view.frame.size.width * minimumScreenRatioToHide)  //checking on X position
                                || (velocity.x > minimumVelocityToHide) //checking on X velocity
                if closing {
                    if (translation.x > 0){ //swiped from left to right
                        UIView.animate(withDuration: animationDuration, animations: {
                            slideViewTo(0,0)
                        },completion: {_ in
                            self.fetchAndPresentUserAccount()  //open the profile screen
                        })
                        
                    }else{  //swiped from right to left
                        UIView.animate(withDuration: animationDuration, animations: {
                            slideViewTo(0,0)
                        },completion: {_ in
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "openChatWindow"), object: nil)
                        })
                    }
                }else{
                    UIView.animate(withDuration: animationDuration, animations: {
                        slideViewTo(0,0)
                    })
                }
            default:
                print(panGesture.state)
            }
      }
}

extension HomeViewController: ImageCarouselDelegate {
    func didTappedOnHeartAt(index: Int, sender: ImageCarousel) {
        var item: Product!
        item = featured.itemsList[index]
        
        //setting the favourite
        self.showNetworkActivity()
        setUnSetFavourites(id: item.id ,isUnSetFavourite: item.isFavourite ?? false) {information, error in
            self.hideNetworkActivity()
            
            if let error = error {
                self.showError(error)
                return
            }
            
            if let informations = information {
                var featuredExperiences = self.featured.itemsList //events in locationEventSlider
                featuredExperiences[index].isFavourite = !(featuredExperiences[index].isFavourite ?? false)
                sender.itemsList = featuredExperiences
                // Store data for later use inside preload reference.
//                        PreloadDataManager.HomeScreen.scrollViewData = information
                print("ItemID:\(item.id)" + ", ItemType:" + item.type  + ", ServerResponse:" + informations)
            } else {
                let error = BackendError.parsing(reason: "Could not obtain tap on heart information")
                self.showError(error)
            }
        }
    }
    
    
    func didMoveTo(position: Int) {
        currentImageNum.text = "\(position + 1)"
    }
    
}

extension HomeViewController: DidSelectSliderItemProtocol {
    
    func didTappedOnHeartAt(index: Int, sender: HomeSlider) {
        var item: Product!
        switch sender {
            case homeRecentSlider:
                item = homeObjects?.recent[index]
            case homeTopRatedSlider:
                item = homeObjects?.topRated[index]
            case homeGiftsSlider:
                item = homeObjects?.gifts[index]
            case homeVillasSlider:
                item = homeObjects?.villas[index]
            case homeYachtsSlider:
                item = homeObjects?.yachts[index]
            case homeEventSlider:
                item = homeObjects?.events[index]
            case homeExperienceSlider:
                item = homeObjects?.experiences[index]
            case locationEventSlider:
                item = locationEventSlider.itemsList[index]
            default: return
        }
        
        //setting the favourite
        self.showNetworkActivity()
        setUnSetFavourites(id: item.id ,isUnSetFavourite: item.isFavourite ?? false) {information, error in
            self.hideNetworkActivity()
            
            if let error = error {
                self.showError(error)
                return
            }
            
            if let informations = information {                
                switch sender {
                case self.homeRecentSlider:
                    var items = self.homeRecentSlider.itemsList
                    items[index].isFavourite = !(items[index].isFavourite ?? false)
                    self.homeObjects?.recent = items    // so that updated value can be loaded next time e.g. event detail
                    sender.itemsList = items   //re-assigning as it will automatically reload the collection
                case self.homeTopRatedSlider:
                    var items = self.homeTopRatedSlider.itemsList
                    items[index].isFavourite = !(items[index].isFavourite ?? false)
                    self.homeObjects?.topRated = items    // so that updated value can be loaded next time e.g. event detail
                    sender.itemsList = items   //re-assigning as it will automatically reload the collection
                case self.homeGiftsSlider:
                    var items = self.homeGiftsSlider.itemsList
                    items[index].isFavourite = !(items[index].isFavourite ?? false)
                    self.homeObjects?.gifts = items    // so that updated value can be loaded next time e.g. event detail
                    sender.itemsList = items   //re-assigning as it will automatically reload the collection
                case self.homeVillasSlider:
                    var items = self.homeVillasSlider.itemsList
                    items[index].isFavourite = !(items[index].isFavourite ?? false)
                    self.homeObjects?.villas = items    // so that updated value can be loaded next time e.g. event detail
                    sender.itemsList = items   //re-assigning as it will automatically reload the collection
                case self.homeYachtsSlider:
                    var items = self.homeYachtsSlider.itemsList
                    items[index].isFavourite = !(items[index].isFavourite ?? false)
                    self.homeObjects?.yachts = items    // so that updated value can be loaded next time e.g. event detail
                    sender.itemsList = items   //re-assigning as it will automatically reload the collection
                case self.homeEventSlider:
                    var locationEvents = self.locationEventSlider.itemsList //events in locationEventSlider
                    var homeEvents = self.homeEventSlider.itemsList     //events in homeEventSlider
                    
                    //Event updated in homeEventList , might also be present in locationlist
                    //Get the element and its offset
                    if let item = locationEvents.enumerated().first(where: {$0.element.id == homeEvents[index].id}) {
//                        print("HomeEventIndex:\(index) , : LocationEventIndex:\(item.offset) ")
                        locationEvents[item.offset].isFavourite = !(locationEvents[item.offset].isFavourite ?? false)  //update location events list as well
                        self.locationEventSlider.itemsList = locationEvents //re-assigning as it will automatically reload the collection
                    }
                    homeEvents[index].isFavourite = !(homeEvents[index].isFavourite ?? false)
                    self.homeObjects?.events = homeEvents    // so that updated value can be loaded next time e.g. event detail
                    sender.itemsList = homeEvents   //re-assigning as it will automatically reload the collection
                case self.homeExperienceSlider:
                    var homeExperiences = self.homeExperienceSlider.itemsList //events in locationEventSlider
                    homeExperiences[index].isFavourite = !(homeExperiences[index].isFavourite ?? false)
                    self.homeObjects?.experiences = homeExperiences    // so that updated value can be loaded next time e.g. event detail
                    sender.itemsList = homeExperiences   //re-assigning as it will automatically reload the collection
                case self.locationEventSlider:
                    var locationEvents = self.locationEventSlider.itemsList //events in locationEventSlider
                    var homeEvents = self.homeEventSlider.itemsList     //events in homeEventSlider
                    
                    //Event updated in locationlist, might also be present in home event list,
                    //Get the element and its offset
                    if let item = homeEvents.enumerated().first(where: {$0.element.id == locationEvents[index].id}) {
//                        print("LocationEventIndex:\(index) , HomeEventIndex: \(item.offset) ")
                        homeEvents[item.offset].isFavourite = !(homeEvents[item.offset].isFavourite ?? false)    //update home events list as well
                        self.homeEventSlider.itemsList = homeEvents //re-assigning as it will automatically reload the collection
                    }
                    locationEvents[index].isFavourite = !(locationEvents[index].isFavourite ?? false)
                    self.homeObjects?.events = locationEvents    // so that updated value can be loaded next time e.g. event detail
                    sender.itemsList = locationEvents   //re-assigning as it will automatically reload the collection
                    // Store data for later use inside preload reference.
//                        PreloadDataManager.HomeScreen.scrollViewData = information
                default: return
                }
                print("ItemID:\(item.id)" + ", ItemType:" + item.type  + ", ServerResponse:" + informations)
            } else {
                let error = BackendError.parsing(reason: "Could not obtain wishlist information")
                self.showError(error)
            }
        }
        
    }
 
    func didSelectSliderItemAt(indexPath: IndexPath, sender: HomeSlider) {
        let product: Product!
        
        switch sender {
            case homeRecentSlider:
                product = homeObjects?.recent[indexPath.row]
            case homeTopRatedSlider:
                product = homeObjects?.topRated[indexPath.row]
            case homeGiftsSlider:
                product = homeObjects?.gifts[indexPath.row]
            case homeVillasSlider:
                product = homeObjects?.villas[indexPath.row]
            case homeYachtsSlider:
                product = homeObjects?.yachts[indexPath.row]
            case homeEventSlider:
                product = homeObjects?.events[indexPath.row]
            case homeExperienceSlider:
                product = homeObjects?.experiences[indexPath.row]
            case locationEventSlider:
                product = locationEventSlider.itemsList[indexPath.row]
            default: return
        }
        animationtype = .slider //call slider to detail animation
        // B2 - 6
        selectedCell = sender.collectionView.cellForItem(at: indexPath) as? HomeSliderCell
        // B2 - 7
        selectedCellImageViewSnapshot = selectedCell?.primaryImage.snapshotView(afterScreenUpdates: false)

        let viewController = ProductDetailsViewController.instantiate(product: product)
        
        // B1 - 4
        viewController.transitioningDelegate = self //That is how you configure a present custom transition. But it is not how you configure a push custom transition.
        viewController.modalPresentationStyle = .overFullScreen
//        viewController.delegate = self

        present(viewController, animated: true)
    }
    
}

//extension HomeViewController : ProductDetailDelegate{
//    func presentChatViewController(viewController:UIViewController) {
//        // Initialize a navigation controller, with your view controller as its root
//        let navigationController = UINavigationController(rootViewController: viewController)
//        present(navigationController, animated: true, completion: nil)
//    }
//}

// Helper functions
extension HomeViewController {
    
    func getCurrentEventInFeatured() -> Product? {
        if let index = featured.currentIndex {
            return homeObjects?.slider[index]
        }
        return nil
    }
    
    func getLocationPlaces(for location: CLLocation) {
        if canSendRequest {
            canSendRequest = false
            guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
                self.showError(LoginError.errorLogin(description: "User does not exist or is not verified"))
                return
            }
            
            //25.2048,55.2708   //dubai lat, long
//            print("Latitude:\(Float(location.coordinate.latitude))" , "Longitude:\(Float(location.coordinate.longitude))")
            EEAPIManager().geopoint(token: token, type: "event", latitude: Float(location.coordinate.latitude), longitude: Float(location.coordinate.longitude), radius: 50) { information, error in
                self.canSendRequest = true
                
                if let error = error {
                    Crashlytics.sharedInstance().recordError(error)
                    // NEED TO BE REPLACED WITH UI VIEW
                    self.locationEventContainerView.isHidden = true
                    self.noNearbyEventsContainerView?.isHidden = false
                    self.showError(BackendError.parsing(reason: "Could not obtain Nearby Places"))
                } else {
                    if let information = information {
                        // NEED TO BE REPLACED WITH UI VIEW
                        self.updateEventsByGeoLocation(information)
                    } else {
                        // NEED TO BE REPLACED WITH UI VIEW
                        self.showFeedback("No nearby Places available")
                        self.locationEventContainerView.isHidden = true
                        self.noNearbyEventsContainerView?.isHidden = false
                        
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
        self.currentLocation = locations.first
    }
    
    func getHomeInformation() {
        if !UserDefaults.standard.bool(forKey: "showWelcome") {
            showNetworkActivity()
        }
        
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            self.showError(LoginError.errorLogin(description: "User does not exist or is not verified"))
            return
        }
        
        EEAPIManager().home(token) { information, error in
            self.hideNetworkActivity()
            
            if let error = error {
                Crashlytics.sharedInstance().recordError(error)
                self.showError(BackendError.parsing(reason: "Could not obtain Home Events information"))
            } else {
                if let information = information {
                    self.update(information)
                } else {
                    self.showFeedback("No events and experiences available")
                }
            }
        }
    }
    
    @objc func fetchAndPresentUserAccount() {
        showNetworkActivity()
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        getUserProfile { user, error in
            self.hideNetworkActivity()
            self.navigationItem.leftBarButtonItem?.isEnabled = true
            
            if let error = error {
                self.showError(error)
            } else {
                if let user = user {
                    self.presentAccountViewController(user)
                }
            }
        }
    }
    
    func loadUserProfile() {
        getUserProfile(completion: { _,_ in
            self.dimView.isHidden = LujoSetup().getLujoUser()?.membershipPlan?.target == "all"
            self.membershipView.isHidden = LujoSetup().getLujoUser()?.membershipPlan?.target == "all"
            self.navigationItem.rightBarButtonItem?.isEnabled = LujoSetup().getLujoUser()?.membershipPlan?.target == "all"
            self.getHomeInformation()
        })
    }
    
    func getUserProfile(completion: @escaping (LujoUser?, Error?) -> Void) {
        guard let currentUserToken = LujoSetup().getCurrentUser()?.token else {
            let error = LoginError.errorLogin(description: "No logged in user")
            completion(nil, error)
            return
        }
        
        GoLujoAPIManager().userProfile(for: currentUserToken) { user, error in
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard let user = user else {
                let error = LoginError.errorLogin(description: "Missing user information")
                completion(nil, error)
                return
            }
            
            LujoSetup().store(userInfo: user)
            completion(user, error)
        }
    }

    
    @objc func showBadgeValue() {
        ChatManager.sharedChatManager.getTotalUnConsumedMessagesCount(completion: { (count) in
            print("Twilio: Total UnConsumed messages count:\(count)")
            //setting the badge value
            let rightBarButtons = self.navigationItem.rightBarButtonItems
            let lastBarButton = rightBarButtons?.first
            lastBarButton?.setBadge(text: count == 0 ? "" : String(count))  //show empty string if count is zero
        })
    }
}

// B1 - 1
extension HomeViewController: UIViewControllerTransitioningDelegate {

    // B1 - 2
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        return nil
        // B2 - 16
//        We are preparing the properties to initialize an instance of Animator. If it fails, return nil to use default animation. Then assign it to the animator instance that we just created.
        guard let firstViewController = source as? HomeViewController,
            let secondViewController = presented as? ProductDetailsViewController,
            let selectedCellImageViewSnapshot = selectedCellImageViewSnapshot
            else {
                return nil
            }
//        print(animationtype)
        if animationtype == .slider{
            sliderToDetailAnimator = HomeSliderAnimator(type: .present, firstViewController: firstViewController, secondViewController: secondViewController, selectedCellImageViewSnapshot: selectedCellImageViewSnapshot)
            return sliderToDetailAnimator
        }else if animationtype == .featured{
            featuredToDetailAnimator = HomeFeaturedAnimator(type: .present, firstViewController: firstViewController, secondViewController: secondViewController, selectedCellImageViewSnapshot: selectedCellImageViewSnapshot)
            return featuredToDetailAnimator
        }else if animationtype == .specialEvent{
            specialEventAnimator = SpecialEventAnimator(type: .present, firstViewController: firstViewController, secondViewController: secondViewController, selectedCellImageViewSnapshot: selectedCellImageViewSnapshot)
            return specialEventAnimator
        }else {
            return nil
        }
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
        if animationtype == .slider{
            sliderToDetailAnimator = HomeSliderAnimator(type: .dismiss, firstViewController: self, secondViewController: secondViewController, selectedCellImageViewSnapshot: selectedCellImageViewSnapshot)
            return sliderToDetailAnimator
        }else if animationtype == .featured{
            featuredToDetailAnimator = HomeFeaturedAnimator(type: .dismiss, firstViewController: self, secondViewController: secondViewController, selectedCellImageViewSnapshot: selectedCellImageViewSnapshot)
            return featuredToDetailAnimator
        }else if animationtype == .specialEvent{
            specialEventAnimator = SpecialEventAnimator(type: .dismiss, firstViewController: self, secondViewController: secondViewController, selectedCellImageViewSnapshot: selectedCellImageViewSnapshot)
            return specialEventAnimator
        }else {
            return nil
        }
    }
}

extension HomeViewController: UIAdaptivePresentationControllerDelegate {
    // Only called when the sheet is dismissed by DRAGGING as well as when tapped on cross button.
    public func presentationControllerDidDismiss( _ presentationController: UIPresentationController) {
        if #available(iOS 13, *) {
            //Call viewWillAppear only in iOS 13
            //ChatManager.sharedChatManager.delegate = self.tabBarController as? ChatManagerDelegate
            ChatManager.sharedChatManager.delegate = self
        }
        showBadgeValue()
    }
}

extension HomeViewController:ChatManagerDelegate{
    func reloadMessages() {
        print("Twilio: reloadMessages")
    }

    func receivedNewMessage(message: TCHMessage, channel: TCHChannel) {
        showBadgeValue()
    }

    func channelJoined(channel: TCHChannel) {
        print("Twilio: channelJoined")
    }

}
