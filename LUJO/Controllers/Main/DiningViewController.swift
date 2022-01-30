//
//  DiningViewController.swift
//  LUJO
//
//  Created by Iker Kristian on 8/27/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import FirebaseCrashlytics
import JGProgressHUD
import CoreLocation

class DiningViewController: UIViewController, CLLocationManagerDelegate, DiningCityProtocol {

    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "DiningViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate() -> DiningViewController {
        return UIStoryboard.main.instantiate(identifier)
    }
    
    //MARK:- Globals
    
    private var diningInformations: DiningHomeObjects?
    
    private let naHUD = JGProgressHUD(style: .dark)
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var dimView: UIView!
    @IBOutlet weak var membershipView: UIView!
    
    @IBOutlet weak var searchBarButton: UIBarButtonItem!
    @IBOutlet weak var myLocationCityView: DiningCityView!
    
    @IBOutlet weak var locationContainerView: UIView!
    @IBOutlet weak var noNearbyRestaurantsContainerView: UIView!
    
    @IBOutlet weak var categorySlider: DiningCategorySlider!
    
    @IBOutlet var featured: ImageCarousel!
    @IBOutlet var currentImageNum: UILabel!
    @IBOutlet var allImagesNum: UILabel!
    
    @IBOutlet var chiefContainerView: UIView!
    @IBOutlet var gradientView: UIView!
    @IBOutlet var chiefImageView: UIImageView!
    @IBOutlet var restaurantName: UILabel!
    @IBOutlet var starsContainerView: UIView!
    @IBOutlet var starsLabel: UILabel!
    @IBOutlet var chiefNameLabel: UILabel!
    
    var locationRestaurants: [Product] = []
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
    private var preloadData: DiningHomeObjects? { return PreloadDataManager.DiningScreen.scrollViewData }
    
    // B2 - 5
    var selectedCell: UIImageView?
    var selectedCellHeart: UIImageView?
    var selectedFeaturedCell: ImageCarouselCell?
    var selectedChef: UIImageView?
    var selectedCellImageViewSnapshot: UIView? //it’s a view that has a current rendered appearance of a view. Think of it as you would take a screenshot of your screen, but it will be one single view without any subviews.
    // B2 - 15
    var selectedCellHeartSnapshot: UIView?
    var sliderDiningToDetailAnimator: DiningSliderAnimator?
    var featuredDiningToDetailAnimator: DiningFeaturedAnimator?
//    var diningCheffAnimator: DiningCheffAnimator?B2
    private var animationtype: AnimationType = .slider  //by default slider to detail animation would be called
    var timer = Timer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        
        featured.overlay = true
        featured.delegate = self
        
        setupTapGesturesForRestaurants()
        
        categorySlider.delegate = self
        
        locationContainerView.isHidden = true
        noNearbyRestaurantsContainerView.isHidden = true
        myLocationCityView.isHidden = true
        
        getDiningInformation(showActivity: true)
        
        locationManager.delegate = self
        
        //Loading the preferences related to dining only very first time if and only if user is paid
//        print(LujoSetup().getLujoUser()?.membershipPlan as Any , UserDefaults.standard.bool(forKey: "isDiningPreferencesAlreadyShown"))
        if LujoSetup().getLujoUser()?.membershipPlan != nil && !UserDefaults.standard.bool(forKey: "isDiningPreferencesAlreadyShown")  {
            let viewController = PrefCollectionsViewController.instantiate(prefType: .dining, prefInformationType: .diningCuisines)
            self.navigationController?.pushViewController(viewController, animated: true)
            UserDefaults.standard.set(true, forKey: "isDiningPreferencesAlreadyShown")
        }
    }
    
    @IBAction func noNearbyRestaurantsDismissButton_onClick(_ sender: Any) {
        noNearbyRestaurantsContainerView.removeFromSuperview()
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
        @unknown default:
            break
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
        self.navigationController?.pushViewController(MembershipViewControllerNEW.instantiate(userFullname: fullName, screenType: .buyMembership, paymentType: .dining), animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        updateUIforAuthorizationStatus(status)
    }
    
    func checkLocationAuthorizationStatus() {
        updateUIforAuthorizationStatus(CLLocationManager.authorizationStatus())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        activateKeyboardManager()
        
        dimView.isHidden = LujoSetup().getLujoUser()?.membershipPlan != nil
        membershipView.isHidden = LujoSetup().getLujoUser()?.membershipPlan != nil
        searchBarButton.isEnabled = LujoSetup().getLujoUser()?.membershipPlan != nil
        
        checkLocationAuthorizationStatus()
        startPauseAnimation(isPausing: false)    //will start animating at 0 seconds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        startPauseAnimation(isPausing: true)
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.barTintColor = UIColor(named: "Navigation Bar")
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.backBarButtonItem?.title = ""
    }
    
    private let locationManager = CLLocationManager()
    
    var isLocationEnabled: Bool {
        let status = CLLocationManager.authorizationStatus()
        return (status == .authorizedAlways || status == .authorizedWhenInUse)
    }
    
    
    private func updateUIforAuthorizationStatus(_ status: CLAuthorizationStatus) {
        locationContainerView.isHidden = isLocationEnabled
        if !myLocationCityView.isHidden, !isLocationEnabled {
            myLocationCityView.isHidden = true
            locationRestaurants = []
            updatePopularCities()
        }
        if !(noNearbyRestaurantsContainerView?.isHidden ?? true), !isLocationEnabled {
            noNearbyRestaurantsContainerView?.isHidden = true
        }
        if isLocationEnabled {
            locationManager.startUpdatingLocation()
        }
    }
    
    func update(_ information: DiningHomeObjects?) {
        guard information != nil else {
            return
        }
        
        diningInformations = information
        updateContent()

            // -------------------------------------------------------------------------------------
            // Refresh control and data caching.

            // Stop refresh control animation and allow scroll to sieze back refresh control space by
            // scrolling up.
            refreshControl.endRefreshing()

            // Store data for later use inside preload reference.
            PreloadDataManager.DiningScreen.scrollViewData = information
            // -------------------------------------------------------------------------------------
    }
    
    func updateMyRestaurants(_ restaurants: [Product]) {
//        print(restaurants)
        locationRestaurants = restaurants
        myLocationCityView.isHidden = restaurants.count == 0
        noNearbyRestaurantsContainerView?.isHidden = restaurants.count > 0
        if let termId = restaurants.first?.location?.first?.city?.termId, let name = restaurants.first?.location?.first?.city?.name {
            myLocationCityView.city = DiningCity(termId: termId, name: name, restaurantsNum: 2, restaurants: restaurants)
            myLocationCityView.delegate = self
            updatePopularCities()
        }
    }
    
    fileprivate func updateContent() {
        if let featuredImages = diningInformations?.getFeaturedImages() {
            featured.imageURLList = featuredImages
            featured.titleList = diningInformations!.getFeaturedNames()
            featured.starList = diningInformations!.getFeaturedStars()
            featured.locationList = diningInformations!.getFeaturedLocations()
            allImagesNum.text = "\(featuredImages.count)"
            currentImageNum.text = "1"
        }
        
        chiefContainerView.isHidden = diningInformations?.starChief == nil
        if let starChielf = diningInformations?.starChief {
            chiefNameLabel.text = starChielf.chiefName.uppercased()
            chiefImageView.downloadImageFrom(link: starChielf.chiefImage ?? "", contentMode: .scaleAspectFill)
            starsContainerView.isHidden = starChielf.chiefRestaurant.michelinStar?.first == nil
            starsLabel.text = starChielf.chiefRestaurant.michelinStar?.first?.name.uppercased()
            restaurantName.text = starChielf.chiefRestaurant.name
            
            let gradientColors = [UIColor.blackBackgorund.cgColor,
                                  UIColor(red: 13 / 255, green: 13 / 255, blue: 13 / 255, alpha: 0.01).cgColor]
            let gradient = CAGradientLayer(start: .bottomCenter, end: .topCenter, colors: gradientColors, type: .axial)
            gradient.frame = CGRect(x: 0, y: 2, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width * 0.75 * 0.35)
            gradientView.layer.addSublayer(gradient)
        }
        featured.restaurantsList = diningInformations?.slider ?? [] 
        categorySlider.itemsList = diningInformations?.cuisines ?? []
        
        updatePopularCities()
    }
    
    func updatePopularCities() {
        for city in diningInformations?.cities ?? [] {
            if let cityView = stackView.arrangedSubviews.first(where: { ($0 as? DiningCityView)?.city?.termId == city.termId && $0.tag != 999 }) {
                if city.termId == locationRestaurants.first?.location?.first?.city?.termId {
                    cityView.removeFromSuperview()
                }
            } else if !(city.termId == locationRestaurants.first?.location?.first?.city?.termId) {
                let cityView = DiningCityView()
                cityView.city = city
                cityView.delegate = self
                stackView.addArrangedSubview(cityView)
            }
        }
    }
    
    fileprivate func setupTapGesturesForRestaurants() {
        addTapRecognizer(to: chiefContainerView)
        addTapRecognizer(to: featured)
    }
    
    fileprivate func addTapRecognizer(to view: UIView) {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(showRestaurantDetail(_:)))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func showRestaurantDetail(_ sender: UITapGestureRecognizer) {
        if sender.view is ImageCarousel {
            guard let currentFeatured = featured.currentIndex else { return }
            guard let featuredItem = diningInformations?.slider?[currentFeatured] else { return }
            // B2 - 6
            let indexPath = IndexPath(row: featured.currentIndex ?? 0, section: 0)
            selectedFeaturedCell = featured.collectionView.cellForItem(at: indexPath) as? ImageCarouselCell
            animationtype = .featured   //execute feature to detail animation
            // B2 - 7
            selectedCellImageViewSnapshot = selectedFeaturedCell?.primaryImage.snapshotView(afterScreenUpdates: false)
            
            presentRestaurantDetailViewController(restaurant: featuredItem, presentationStyle: .overFullScreen)
        } else if sender.view == chiefContainerView {
            guard let restaurant = diningInformations?.starChief?.chiefRestaurant else { return } 
            
            // B2 - 6
//            selectedCell = (cityView as? DiningCityView)?.restaurant1ImageView
//            animationtype = .specialEvent   //chef
//            // B2 - 7
//            selectedCellImageViewSnapshot = chiefImageView.snapshotView(afterScreenUpdates: false)
            presentRestaurantDetailViewController(restaurant: restaurant, presentationStyle: .overFullScreen)
        }
    }
    
    fileprivate func presentRestaurantDetailViewController(restaurant: Product , presentationStyle : UIModalPresentationStyle) {
//        let viewController = RestaurantDetailViewController.instantiate(restaurant: restaurant)
        let viewController = ProductDetailsViewController.instantiate(product: restaurant)
        viewController.delegate = self
//        // B1 - 4
        //That is how you configure a present custom transition. But it is not how you configure a push custom transition.
        viewController.transitioningDelegate = self
        viewController.modalPresentationStyle = presentationStyle
        present(viewController, animated: true, completion: nil)
    }
    
    private var currentLocation: CLLocation? {
        didSet {
            if let location = currentLocation {
                getLocationPlaces(for: location)
            }
        }
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
            print("Latitude:\(Float(location.coordinate.latitude))" , "Longitude:\(Float(location.coordinate.longitude))")
            GoLujoAPIManager().geopoint(token: token, type: "restaurant", latitude: Float(location.coordinate.latitude), longitude: Float(location.coordinate.longitude), radius: 50) { information, error in
                self.canSendRequest = true
                
                if let error = error {
                    Crashlytics.crashlytics().record(error: error)
                    // NEED TO BE REPLACED WITH UI VIEW
                    self.myLocationCityView.isHidden = true
                    self.noNearbyRestaurantsContainerView?.isHidden = false
                    self.showError(BackendError.parsing(reason: "Could not obtain Nearby Places"))
                } else {
                    if let information = information {
                        // NEED TO BE REPLACED WITH UI VIEW
                        self.updateMyRestaurants(information)
                    } else {
                        // NEED TO BE REPLACED WITH UI VIEW
                        self.showFeedback("No nearby Places available")
                        self.myLocationCityView.isHidden = true
                        self.noNearbyRestaurantsContainerView?.isHidden = false

                    }
                }
            }
        }
    }
    
    func showFeedback(_ message: String) {
        showInformationPopup(withTitle: "Information", message: message)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
        self.currentLocation = locations.first
    }
    
    /// Refresh control target action that will trigger once user pull to refresh scroll view.
    @objc func refresh(_ sender: AnyObject) {
        // Force data fetch.
        getDiningInformation(showActivity: false)
    }
    
    func showError(_ error: Error) {
        showErrorPopup(withTitle: "Events Error", error: error)
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
    
    @IBAction func searchBarButton_onClick(_ sender: UIBarButtonItem) {
        let viewController = RestaurantSearchViewController.instantiate()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func startPauseAnimation(isPausing : Bool) {
//        if !isPausing{
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
//        } else {
//            timer.invalidate()
//        }
    }
    
    func setUnSetFavourites(id:Int, isUnSetFavourite: Bool ,completion: @escaping (String?, Error?) -> Void) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            completion(nil, LoginError.errorLogin(description: "User does not exist or is not verified"))
            return
        }
        
        GoLujoAPIManager().setUnSetFavourites(token: token,id: id, isUnSetFavourite: isUnSetFavourite) { strResponse, error in
            guard error == nil else {
                Crashlytics.crashlytics().record(error: error!)
                let error = BackendError.parsing(reason: "Could not obtain Dining information")
                completion(nil, error)
                return
            }
            completion(strResponse, error)
        }
    }
}

extension DiningViewController: ImageCarouselDelegate {
    func didTappedOnHeartAt(index: Int, sender: ImageCarousel) {
        var item: Product!
        item = featured.restaurantsList[index]
        
        //setting the favourite
        self.showNetworkActivity()
        setUnSetFavourites(id: item.id ,isUnSetFavourite: item.isFavourite ?? false) {information, error in
            self.hideNetworkActivity()
            
            if let error = error {
                self.showError(error)
                return
            }
            
            if let informations = information {
                var restaurants = self.featured.restaurantsList
                restaurants[index].isFavourite = !(restaurants[index].isFavourite ?? false)
                sender.restaurantsList = restaurants
                // Store data for later use inside preload reference.
//                        PreloadDataManager.HomeScreen.scrollViewData = information
                print("ItemID:\(item.id)" + ", ServerResponse:" + informations)
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

extension DiningViewController: DidSelectCategotyItemProtocol {
    func didSelectSliderItemAt(indexPath: IndexPath, sender: DiningCategorySlider) {
        let categoryName = categorySlider.itemsList[indexPath.row].name
        let viewController = RestaurantSearchViewController.instantiate(searchTerm: categoryName, currentLocation: currentLocation)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension DiningViewController {
    
    func getDiningInformation(showActivity: Bool) {
        if showActivity {
            self.showNetworkActivity()
        }
        getDiningInformation() {information, error in
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
    
    func getDiningInformation(completion: @escaping (DiningHomeObjects?, Error?) -> Void) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            completion(nil, LoginError.errorLogin(description: "User does not exist or is not verified"))
            return
        }
        
        GoLujoAPIManager().home(token) { restaurants, error in
            guard error == nil else {
                Crashlytics.crashlytics().record(error: error!)
                let error = BackendError.parsing(reason: "Could not obtain Dining information")
                completion(nil, error)
                return
            }
            completion(restaurants, error)
        }
    }
    
    func seeAllRestaurantsForCity(city: DiningCity, view: DiningCityView) {
        if view == myLocationCityView {
            navigationController?.pushViewController(RestaurantListViewController.instantiate(dataSource: locationRestaurants), animated: true)
        } else {
            navigationController?.pushViewController(RestaurantListViewController.instantiate(dataSource: [], city: city), animated: true)
        }
    }
    
    func didTappedOnRestaurantAt(index: Int,restaurant: Product) {
        animationtype = .slider //call slider to detail animation
        // B2 - 6
        //Finding UIImageView of restaurant where user has tapped so that we can animate this image
        //finding current cityview from the stackview, user has tapped on 1 out of 2 restaurants of this city
        if let cityView = self.stackView.arrangedSubviews.first(where: { ($0 as? DiningCityView)?.city?.termId ==  restaurant.location?.first?.city?.termId && $0.tag != 999 }) ?? self.myLocationCityView{//(also checking my current location)
            //Finding restaurant which user has just tapped
            if let tappedRestaurant = (cityView as? DiningCityView)?.city?.restaurants.enumerated().first(where: {$0.element.id == restaurant.id}) {
                if (tappedRestaurant.offset == 0){
                    selectedCell = (cityView as? DiningCityView)?.restaurant1ImageView
                    selectedCellHeart = (cityView as? DiningCityView)?.imgHeart1
                }else if (tappedRestaurant.offset == 1){
                    selectedCell = (cityView as? DiningCityView)?.restaurant2ImageView
                    selectedCellHeart = (cityView as? DiningCityView)?.imgHeart2
                }
            }
        }
        // B2 - 7
        selectedCellImageViewSnapshot = selectedCell?.snapshotView(afterScreenUpdates: false)
        selectedCellHeartSnapshot = selectedCellHeart?.snapshotView(afterScreenUpdates: false)
        presentRestaurantDetailViewController(restaurant: restaurant, presentationStyle: .overFullScreen)
    }
    
    
    func didTappedOnHeartAt(index: Int, sender: Product) {
//        print("index:\(index)" + "Restaurant:\(sender.name)")
//
        //setting the favourite
        self.showNetworkActivity()
        setUnSetFavourites(id: sender.id ,isUnSetFavourite: sender.isFavourite ?? false) {information, error in
            self.hideNetworkActivity()

            if let error = error {
                self.showError(error)
                return
            }

            if let informations = information {
                //**************************************************
                //all restaurants on this page other then myLocation
                //**************************************************
                if let allCitiesAtDining = self.diningInformations?.cities{
                    for i in 0..<allCitiesAtDining.count {  //looping all cities on dining page
                        //Finding restaurant which user has just favourited/unfavourited
                        if let itemRestaurant = allCitiesAtDining[i].restaurants.enumerated().first(where: {$0.element.id == sender.id}) {
                            //Just got the city by value else we can also use long like like self.diningInformations?.cities[i]
                            if let city = self.diningInformations?.cities[i]{
                                //toggling the isFavourite value
                                self.diningInformations?.cities[i].restaurants[itemRestaurant.offset].isFavourite = !(itemRestaurant.element.isFavourite ?? false)
                                //finding current cityview from the stackview, to remove and then again adding updated by red/white heart
                                if let cityView = self.stackView.arrangedSubviews.first(where: { ($0 as? DiningCityView)?.city?.termId == city.termId && $0.tag != 999 }) {
                                    if let termId = sender.location?.first?.city?.termId, let name = sender.location?.first?.city?.name {
                                        (cityView as? DiningCityView)?.city = DiningCity(termId: termId, name: name, restaurantsNum: 2, restaurants: (self.diningInformations?.cities[i].restaurants)! )
                                    }
                                }
                            }
                        }
                    }
                }
                //*****************************
                //all restaurants on myLocation
                //*****************************
                //Finding restaurant which user has just favourited/unfavourited
                if let itemRestaurant = self.locationRestaurants.enumerated().first(where: {$0.element.id == sender.id}) {
                    //toggling the isFavourite value
                    self.locationRestaurants[itemRestaurant.offset].isFavourite = !(itemRestaurant.element.isFavourite ?? false)
                    if let termId = sender.location?.first?.city?.termId, let name = sender.location?.first?.city?.name {
                        self.myLocationCityView.city = DiningCity(termId: termId, name: name, restaurantsNum: 2, restaurants: self.locationRestaurants)
                    }
                }
//                print(" ServerResponse:" + informations)
            } else {
                let error = BackendError.parsing(reason: "Could not obtain tap on heart information")
                self.showError(error)
            }
        }
    }
    
}


// B1 - 1
extension DiningViewController: UIViewControllerTransitioningDelegate {

    // B1 - 2
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        return nil
        // B2 - 16
//        We are preparing the properties to initialize an instance of Animator. If it fails, return nil to use default animation. Then assign it to the animator instance that we just created.
        guard let firstViewController = source as? DiningViewController,
            let secondViewController = presented as? ProductDetailsViewController,
            let selectedCellImageViewSnapshot = selectedCellImageViewSnapshot
            else {
                return nil
            }
//        print(animationtype)
        if animationtype == .slider{
            sliderDiningToDetailAnimator = DiningSliderAnimator(type: .present, firstViewController: firstViewController, secondViewController: secondViewController, selectedCellImageViewSnapshot: selectedCellImageViewSnapshot)
            return sliderDiningToDetailAnimator
        }else
        if animationtype == .featured{
            featuredDiningToDetailAnimator = DiningFeaturedAnimator(type: .present, firstViewController: firstViewController, secondViewController: secondViewController, selectedCellImageViewSnapshot: selectedCellImageViewSnapshot)
            return featuredDiningToDetailAnimator
        }
//        else if animationtype == .specialEvent{
//            diningCheffAnimator = DiningCheffAnimator(type: .present, firstViewController: firstViewController, secondViewController: secondViewController, selectedCellImageViewSnapshot: selectedCellImageViewSnapshot)
//            return diningCheffAnimator
//        }
        else {
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
            sliderDiningToDetailAnimator = DiningSliderAnimator(type: .dismiss, firstViewController: self, secondViewController: secondViewController, selectedCellImageViewSnapshot: selectedCellImageViewSnapshot)
            return sliderDiningToDetailAnimator
        }else if animationtype == .featured{
            featuredDiningToDetailAnimator = DiningFeaturedAnimator(type: .dismiss, firstViewController: self, secondViewController: secondViewController, selectedCellImageViewSnapshot: selectedCellImageViewSnapshot)
            return featuredDiningToDetailAnimator
        }
//        else if animationtype == .specialEvent{
//            diningCheffAnimator = DiningCheffAnimator(type: .dismiss, firstViewController: self, secondViewController: secondViewController, selectedCellImageViewSnapshot: selectedCellImageViewSnapshot)
//            return diningCheffAnimator
//        }
        else{
            return nil
        }
    }
}

extension DiningViewController : ProductDetailDelegate{
    func tappedOnBookRequest(viewController:UIViewController) {
        // Initialize a navigation controller, with your view controller as its root
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true, completion: nil)
    }
}
