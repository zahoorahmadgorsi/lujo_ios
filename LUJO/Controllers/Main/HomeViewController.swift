//
//  HomeViewController.swift
//  LUJO
//
//  Created by Iker Kristian on 8/28/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import JGProgressHUD
import Crashlytics
import CoreLocation
import Intercom
import Kingfisher

enum HomeElementType: Int {
    case events, experiences
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
        
    //Zahoor Started 20200822
    var animationInterval:TimeInterval = 4
    var totalAnimationOnScreen:Int = 4
    //Zahoor finished
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        naHUD.textLabel.text = "Loading Information"
        featured.overlay = true
        featured.delegate = self
        locationEventSlider.delegate = self
        homeEventSlider.delegate = self
        homeExperienceSlider.delegate = self
        
        setupNavigationBar()
        updateUI()
        setupTapGesturesForEventsAndExperiences()
        
        let searchBarButton = UIButton(type: .system)
        searchBarButton.setImage(UIImage(named: "Search Icon White"), for: .normal)
        searchBarButton.setTitle("  SEARCH", for: .normal)
        searchBarButton.addTarget(self, action: #selector(searchBarButton_onClick(_:)), for: .touchUpInside)
        searchBarButton.titleLabel?.font = UIFont.systemFont(ofSize: 11)
        searchBarButton.sizeToFit()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchBarButton)
        
        locationEventContainerView.isHidden = true
        locationContainerView.isHidden = true
        noNearbyEventsContainerView.isHidden = true
        
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
        
        startAnimation()    //will start animating at 0 seconds
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
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(HomeViewController.userProfileBarButton_onClick(_:))))
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
        
        // Stop refresh control animation and allow scroll to sieze back refresh control space by
        // scrolling up.
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
        self.navigationController?.pushViewController(GlobalSearchViewController.instantiate(), animated: true)
    }
    
    @IBAction func seeAllLocationEventsButton_onClick(_ sender: Any) {
        let viewController = EventsViewController.instantiate(category: .event, dataSource: locationEvents)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func seeAllEventsButton_onClick(_ sender: UIButton) {
        let viewController = EventsViewController.instantiate(category: .event)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func seeAllExperiencesButton_onClick(_ sender: UIButton) {
        let viewController = EventsViewController.instantiate(category: .experience)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func userProfileBarButton_onClick(_ sender: UIBarButtonItem) {
        fetchAndPresentUserAccount()
    }
    
    @objc func showEventDetail(_ sender: UITapGestureRecognizer) {
        let event: Product!
        
        switch sender.view {
        case is ImageCarousel:  event = getCurrentEventInFeatured()
        case specialEventView1: event = homeObjects?.specialEvents[0]
        case specialEventView2: event = homeObjects?.specialEvents[1]
        default: return
        }
        
        let viewController = EventDetailsViewController.instantiate(event: event)
        self.navigationController?.pushViewController(viewController, animated: true)
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
        //zahoor start
        //Add tap gestures on heart images
        let tgrOnHeart1 = UITapGestureRecognizer(target: self, action: #selector(tappedOnHeart(_:)))
        specialEventView1.imgHeart.addGestureRecognizer(tgrOnHeart1)
        let tgrOnHeart2 = UITapGestureRecognizer(target: self, action: #selector(tappedOnHeart(_:)))
        specialEventView2.imgHeart.addGestureRecognizer(tgrOnHeart2)
        
        //zahoor end
        
    }
    
    //Zahoor start
    @objc func tappedOnHeart(_ sender:UITapGestureRecognizer){
        var item: Product?
        var index: Int = 0
        
        if (sender.view == specialEventView1.imgHeart && homeObjects?.specialEvents.count ?? 0 >= 1){
            item = homeObjects?.specialEvents[0]
            index = 0
        }else if (sender.view == specialEventView2.imgHeart && homeObjects?.specialEvents.count ?? 0 >= 2){
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
//    @objc func tappedOnHeart2(_ sender:HomeSpecialEventSummary){
//        if (homeObjects?.specialEvents.count ?? 0 >= 2){
//            print(homeObjects?.specialEvents[1] as Any)
//        }
//    }
    //zahoor end
    
    fileprivate func updateContent() {
        
        if let featuredImages = homeObjects?.getFeaturedImages() {
            featured.imageURLList = featuredImages    
            featured.titleList = homeObjects!.getFeaturedNames()
            featured.categoryList = homeObjects!.getFeaturedTypes()
            featured.tagsList = homeObjects!.getFeaturedTags()
            allImagesNum.text = "\(featuredImages.count)"
            currentImageNum.text = "1"
        }
        
        featured.itemsList = homeObjects?.slider ?? [] //zahoor
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
    
    @objc func startAnimation() {
        //Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { _ in
        Timer.scheduledTimer(withTimeInterval: self.animationInterval, repeats: true, block: { _ in
            if self.featured.titleList.count > 0 {
                if let index = Int(self.currentImageNum.text ?? "1") {
                    if index == self.featured.titleList.count {
                        self.featured.carouselView.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .left)
                    } else {
                        self.featured.carouselView.selectItem(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .left)
                    }
                }
            }
        })
    }
    
    /// Mark - Custom request actions
    @IBAction func findTableButton_onClick(_ sender: Any) {
//        Zahoor started the change
//        self.present(TableViewController.instantiate(), animated: true, completion: nil)
        self.tabBarController?.selectedIndex = 1
//        Zahoor Finished the change
    }
    
    @IBAction func getTicketsButton_onClick(_ sender: Any) {
        let viewController = EventsViewController.instantiate(category: .event)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func purchaseGoodsButton_onClick(_ sender: Any) {
//        self.present(GoodsViewController.instantiate(), animated: true, completion: nil)
        let viewController = EventsViewController.instantiate(category: .good)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func villaButton_onClick(_ sender: Any) {
        let viewController = EventsViewController.instantiate(category: .villa)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func findAYachtButton_onClick(_ sender: Any) {
        //self.present(YachtViewController.instantiate(), animated: true, completion: nil)
        let viewController = EventsViewController.instantiate(category: .yacht)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func findAHotelButton_onClick(_ sender: Any) {
        self.present(HotelViewController.instantiate(), animated: true, completion: nil)
    }
    
    func setUnSetFavourites(id:Int, isUnSetFavourite: Bool ,completion: @escaping (String?, Error?) -> Void) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            completion(nil, LoginError.errorLogin(description: "User does not exist or is not verified"))
            return
        }
        
        GoLujoAPIManager().setUnSetFavourites(token: token,id: id, isUnSetFavourite: isUnSetFavourite) { strResponse, error in
            guard error == nil else {
                Crashlytics.sharedInstance().recordError(error!)
                let error = BackendError.parsing(reason: "Could not obtain favourites information")
                completion(nil, error)
                return
            }
            completion(strResponse, error)
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
                case self.homeEventSlider:
                    var locationEvents = self.locationEventSlider.itemsList //events in locationEventSlider
                    var homeEvents = self.homeEventSlider.itemsList     //events in homeEventSlider
                    
                    //Event updated in homeEventList , might also be present in locationlist
                    //Get the element and its offset
                    if let item = locationEvents.enumerated().first(where: {$0.element.id == homeEvents[index].id}) {
                        print("HomeEventIndex:\(index) , : LocationEventIndex:\(item.offset) ")
                        locationEvents[item.offset].isFavourite = !(locationEvents[item.offset].isFavourite ?? false)  //update location events list as well
                        self.locationEventSlider.itemsList = locationEvents //re-assigning as it will automatically reload the collection
                    }
                    homeEvents[index].isFavourite = !(homeEvents[index].isFavourite ?? false)
                    sender.itemsList = homeEvents   //re-assigning as it will automatically reload the collection
                case self.homeExperienceSlider:
                    var homeExperiences = self.homeExperienceSlider.itemsList //events in locationEventSlider
                    homeExperiences[index].isFavourite = !(homeExperiences[index].isFavourite ?? false)
                    sender.itemsList = homeExperiences   //re-assigning as it will automatically reload the collection
                case self.locationEventSlider:
                    var locationEvents = self.locationEventSlider.itemsList //events in locationEventSlider
                    var homeEvents = self.homeEventSlider.itemsList     //events in homeEventSlider
                    
                    //Event updated in locationlist, might also be present in home event list,
                    //Get the element and its offset
                    if let item = homeEvents.enumerated().first(where: {$0.element.id == locationEvents[index].id}) {
                        print("LocationEventIndex:\(index) , HomeEventIndex: \(item.offset) ")
                        homeEvents[item.offset].isFavourite = !(homeEvents[item.offset].isFavourite ?? false)    //update home events list as well
                        self.homeEventSlider.itemsList = homeEvents //re-assigning as it will automatically reload the collection
                    }
                    locationEvents[index].isFavourite = !(locationEvents[index].isFavourite ?? false)
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
        let event: Product!
        
        switch sender {
            case homeEventSlider:
                event = homeObjects?.events[indexPath.row]
            case homeExperienceSlider:
                event = homeObjects?.experiences[indexPath.row]
            case locationEventSlider:
                event = locationEventSlider.itemsList[indexPath.row]
            default: return
        }
        
        let viewController = EventDetailsViewController.instantiate(event: event)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}


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
            
            //37.939998626709
            //23.639999389648
            
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
    
    func fetchAndPresentUserAccount() {
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

}
