//
//  PerCityViewController.swift
//  LUJO
//
//  Created by hafsa lodhi on 24/01/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//


import UIKit
import JGProgressHUD
import Crashlytics
import AVFoundation

class PerCityViewController: UIViewController {
    
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "PerCityViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate(category: ProductCategory, dataSource: PerCityObjects? = nil, city: DiningCity? = nil) -> PerCityViewController {
        let viewController = UIStoryboard.main.instantiate(identifier) as! PerCityViewController
        viewController.category = category
        viewController.dataSource = dataSource
        viewController.city = city
        return viewController
    }
    
    //MARK:- Globals
    @IBOutlet weak var viewSeeAll: UIView!
    private(set) var category: ProductCategory!
    private var city: DiningCity?
    
    @IBOutlet var collectionView: UICollectionView!
    private var dataSource: PerCityObjects!
    
    private let naHUD = JGProgressHUD(style: .dark)
    
    private var currentLayout: LiftLayout?
    
    @IBOutlet weak var btnFilter: UIButton!
    @IBOutlet weak var collFilters: UICollectionView!
    private var filtersDataSource: [Product]!
    @IBOutlet weak var svPerCity: UIStackView!
    @IBOutlet var homeTopRatedSlider: HomeSlider!
    private var homeObjects: PerCityObjects?
    // B2 - 5
    var selectedCell: HomeSliderCell?
    var selectedImageView: UIImageView?
    var selectedCellHeart: UIImageView?
    var selectedCellImageViewSnapshot: UIView? //it’s a view that has a current rendered appearance of a view. Think of it as you would take a screenshot of your screen, but it will be one single view without any subviews.
    var selectedCellHeartSnapshot: UIView?
    // B2 - 15
    var topRatedAnimator: PerCityTopRatedAnimator?
    var perCityViewAnimator: PerCityViewAnimator?
    
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
    private var animationtype: AnimationType = .slider  //by default top rated to detail animation would be called
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem?.title = ""
        homeTopRatedSlider.delegate = self
        updateContentUI()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(btnSeeAllTapped))
        viewSeeAll.isUserInteractionEnabled = true
        viewSeeAll.addGestureRecognizer(tapGesture)
        
        switch category {
            case .event: fallthrough
            case .experience:
                //Loading the preferences related to dining only very first time
                if !UserDefaults.standard.bool(forKey: "isEventPreferencesAlreadyShown")  {
                    let viewController = PrefCollectionsViewController.instantiate(prefType: .events, prefInformationType: .eventCategory)
                    self.navigationController?.pushViewController(viewController, animated: true)
                    UserDefaults.standard.set(true, forKey: "isEventPreferencesAlreadyShown")
                }
//            case .villa:
//                //Loading the preferences related to dining only very first time
//                if !UserDefaults.standard.bool(forKey: "isVillaPreferencesAlreadyShown")  {
//                    let viewController = PrefCollectionsViewController.instantiate(prefType: .dining, prefInformationType: .diningCuisines)
//                    self.navigationController?.pushViewController(viewController, animated: true)
//                    UserDefaults.standard.set(true, forKey: "isVillaPreferencesAlreadyShown")
//                }
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
        if homeObjects == nil { //home objects will be nill if loading it for the first time
            getInformation(for: category)
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
        getInformation(for: category)
    }
    
    @IBAction func searchBarButton_onClick(_ sender: Any) {
        navigationController?.pushViewController(SearchProductsViewController.instantiate(category: category), animated: true)
    }
    
    fileprivate func updateContentUI() {
        if dataSource != nil || city != nil {
            self.navigationItem.rightBarButtonItem = nil
        }
        let titleString = category.rawValue
        title = titleString
//        naHUD.textLabel.text = "Loading " + category.rawValue
    }
    
    func showError(_ error: Error) {
        showErrorPopup(withTitle: "Events Error", error: error)
    }
    
    func showFeedback(_ message: String) {
        showInformationPopup(withTitle: "Information", message: message)
    }
    
    func showNetworkActivity() {
        if !refreshControl.isRefreshing {
            naHUD.show(in: view)
        }
    }
    
    func hideNetworkActivity() {
        naHUD.dismiss()
    }
    
    /// Refresh control target action that will trigger once user pull to refresh scroll view.
    @objc func refresh(_ sender: AnyObject) {
        // Force data fetch.
        getInformation(for: category)
    }
    
    func update(listOf information: PerCityObjects?) {
        guard information != nil else {
            homeTopRatedSlider.itemsList = []
            return
        }
        homeObjects = information
        updateContent()
        // Stop refresh control animation and allow scroll to sieze back refresh control space by
        // scrolling up.
        refreshControl.endRefreshing()
    }
    
    fileprivate func updateContent() {
        homeTopRatedSlider.itemsList = homeObjects?.topRated ?? []
        updatePopularCities()
    }
    
    func updatePopularCities() {
        // if homeObjects?.citie is nill then check homeObjects?.categories because homeObjects?.categories will have values in case of gift
        for city in homeObjects?.cities ?? homeObjects?.categories ?? [] {    //if cities are nil then categories will have gifts data
//        for city in homeObjects?.cities ?? [] {
            switch city.itemsNum {
            case 0:
                print("No city to show")
            case 1:
                if let cityView = svPerCity.arrangedSubviews.first(where: { ($0 as? CityView1)?.city?.termId == city.termId && $0.tag != 999 }) {
                        cityView.removeFromSuperview() //remove if already added
                }
                let cityView = CityView1()
                cityView.city = city
                cityView.delegate = self
                svPerCity.addArrangedSubview(cityView)
            case 2:
                if let cityView = svPerCity.arrangedSubviews.first(where: { ($0 as? CityView2)?.city?.termId == city.termId && $0.tag != 999 }) {
                        cityView.removeFromSuperview() //remove if already added
                }
                let cityView = CityView2()
                cityView.city = city
                cityView.delegate = self
                svPerCity.addArrangedSubview(cityView)
            case 3:
                if let cityView = svPerCity.arrangedSubviews.first(where: { ($0 as? CityView3)?.city?.termId == city.termId && $0.tag != 999 }) {
                        cityView.removeFromSuperview() //remove if already added
                }
                let cityView = CityView3()
                cityView.city = city
                cityView.delegate = self
                svPerCity.addArrangedSubview(cityView)
            default:
                if let cityView = svPerCity.arrangedSubviews.first(where: { ($0 as? CityView4)?.city?.termId == city.termId && $0.tag != 999 }) {
                        cityView.removeFromSuperview() //remove if already added
                }
                let cityView = CityView4()
                cityView.city = city
                cityView.delegate = self
                svPerCity.addArrangedSubview(cityView)
            
                print("Default is 4 and above")
            }
        }
    }
    
//    @IBAction func seeAllTopRatedButton_onClick(_ sender: UIButton) {
    @objc func btnSeeAllTapped(_ sender: Any) {
        let viewController = ProductsViewController.instantiate(category: .topRated, subCategory: self.category)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension PerCityViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0 //return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeSliderCell.identifier, for: indexPath) as! HomeSliderCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
}

extension PerCityViewController: CityViewProtocol {
    func seeAllProductsForCity(city: Cities) {
        let viewController = ProductsViewController.instantiate(category: self.category, city:DiningCity(termId: city.termId ?? -1, name: city.name ?? "" , restaurantsNum: -1, restaurants: []))
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func didTappedOnProductAt(product: Product, itemIndex: Int) {
        let viewController = ProductDetailsViewController.instantiate(product: product)
        animationtype = .featured //tapped on city view
            // B2 - 6
            //Finding UIImageView of restaurant where user has tapped so that we can animate this image
            //finding current cityview from the stackview, user has tapped on 1 out of 2 restaurants of this city
        if let cities = homeObjects?.cities {
            //for (index,city) in cities.enumerated()  {
            outerLoop: for city in cities  {
                switch city.itemsNum {
                case 0: print("Ignore")
                case 1:
                    if let cityView = svPerCity.arrangedSubviews.first(where: { ($0 as? CityView1)?.city?.termId == city.termId && $0.tag != 999 }) {
                        if let tappedRestaurant = (cityView as? CityView1)?.city?.items?.enumerated().first(where: {$0.element.id == product.id}) {
//                            print(city.name as Any ,product.name,tappedRestaurant.offset)
                            if (tappedRestaurant.offset == 0){
                                selectedImageView = (cityView as? CityView1)?.product1ImageView
                                selectedCellHeart = (cityView as? CityView1)?.imgHeart1
                            }
                            break outerLoop //break the loop
                        }
                    }
                case 2:
                    if let cityView = svPerCity.arrangedSubviews.first(where: { ($0 as? CityView2)?.city?.termId == city.termId && $0.tag != 999 }) {
                        if let tappedRestaurant = (cityView as? CityView2)?.city?.items?.enumerated().first(where: {$0.element.id == product.id}) {
//                            print(city.name as Any ,product.name,tappedRestaurant.offset)
                            if (tappedRestaurant.offset == 0){
                                selectedImageView = (cityView as? CityView2)?.product1ImageView
                                selectedCellHeart = (cityView as? CityView2)?.imgHeart1
                            }else if (tappedRestaurant.offset == 1){
                                selectedImageView = (cityView as? CityView2)?.product2ImageView
                                selectedCellHeart = (cityView as? CityView2)?.imgHeart2
                            }
                            break outerLoop //break the loop
                        }
                    }
                case 3:
                    if let cityView = svPerCity.arrangedSubviews.first(where: { ($0 as? CityView3)?.city?.termId == city.termId && $0.tag != 999 }) {
                        if let tappedRestaurant = (cityView as? CityView3)?.city?.items?.enumerated().first(where: {$0.element.id == product.id}) {
//                            print(city.name as Any ,product.name,tappedRestaurant.offset)
                            if (tappedRestaurant.offset == 0){
                                selectedImageView = (cityView as? CityView3)?.product1ImageView
                                selectedCellHeart = (cityView as? CityView3)?.imgHeart1
                            }else if (tappedRestaurant.offset == 1){
                                selectedImageView = (cityView as? CityView3)?.product2ImageView
                                selectedCellHeart = (cityView as? CityView3)?.imgHeart2
                            }else if (tappedRestaurant.offset == 2){
                                selectedImageView = (cityView as? CityView3)?.product3ImageView
                                selectedCellHeart = (cityView as? CityView3)?.imgHeart3
                            }
                            break outerLoop //break the loop
                        }
                    }
                default:
                    if let cityView = svPerCity.arrangedSubviews.first(where: { ($0 as? CityView4)?.city?.termId == city.termId && $0.tag != 999 }) {
                        if let tappedRestaurant = (cityView as? CityView4)?.city?.items?.enumerated().first(where: {$0.element.id == product.id}) {
//                            print(city.name as Any ,product.name,tappedRestaurant.offset)
                            if (tappedRestaurant.offset == 0){
                                selectedImageView = (cityView as? CityView4)?.product1ImageView
                                selectedCellHeart = (cityView as? CityView4)?.imgHeart1
                            }else if (tappedRestaurant.offset == 1){
                                selectedImageView = (cityView as? CityView4)?.product2ImageView
                                selectedCellHeart = (cityView as? CityView4)?.imgHeart2
                            }else if (tappedRestaurant.offset == 2){
                                selectedImageView = (cityView as? CityView4)?.product3ImageView
                                selectedCellHeart = (cityView as? CityView4)?.imgHeart3
                            }else if (tappedRestaurant.offset == 3){
                                selectedImageView = (cityView as? CityView4)?.product4ImageView
                                selectedCellHeart = (cityView as? CityView4)?.imgHeart4
                            }
                            break outerLoop //break the loop
                        }
                    }
                }
            }
        }

        // B2 - 7
        selectedCellImageViewSnapshot = selectedImageView?.snapshotView(afterScreenUpdates: false)
        selectedCellHeartSnapshot = selectedCellHeart?.snapshotView(afterScreenUpdates: false)
//        // B1 - 4
        //That is how you configure a present custom transition. But it is not how you configure a push custom transition.
        viewController.transitioningDelegate = self
        viewController.modalPresentationStyle = .overFullScreen
        present(viewController, animated: true)
    }

    func didTappedOnHeartAt(city currentCity: Cities, itemIndex: Int) {
        if let cityIndex = homeObjects?.cities?.firstIndex(where: {$0.termId == currentCity.termId}) ?? homeObjects?.categories?.firstIndex(where: {$0.termId == currentCity.termId})
           , let product = homeObjects?.cities?[cityIndex].items?[itemIndex] ?? homeObjects?.categories?[cityIndex].items?[itemIndex]{
            //setting the favourite
            self.showNetworkActivity()
            setUnSetFavourites(id: product.id ,isUnSetFavourite: product.isFavourite ?? false) {information, error in
                self.hideNetworkActivity()

                if let error = error {
                    self.showError(error)
                    return
                }

                if let informations = information {
                    switch self.category{
                    case .gift:
                        let isFavourtie = self.homeObjects?.categories?[cityIndex].items?[itemIndex].isFavourite ?? false
                        self.homeObjects?.categories?[cityIndex].items?[itemIndex].isFavourite = !(isFavourtie)
                    default:
                        let isFavourtie = self.homeObjects?.cities?[cityIndex].items?[itemIndex].isFavourite ?? false
                        self.homeObjects?.cities?[cityIndex].items?[itemIndex].isFavourite = !(isFavourtie)
                    }
                    self.updatePopularCities() //just to reload the grid
                    print("ItemID:\(product.id)" + ", ItemType:" + product.type  + ", ServerResponse:" + informations)
                } else {
                    let error = BackendError.parsing(reason: "Could not obtain tap on heart information")
                    self.showError(error)
                }
            }
        }
    }
    
    
    func getInformation(for category: ProductCategory) {
        showNetworkActivity()
        getList(for: category) { items, error in
            self.hideNetworkActivity()
            if let error = error {
                self.showError(error)
            } else {
                self.update(listOf: items ?? nil)
            }
        }
    }
    
    func getList(for category: ProductCategory, completion: @escaping (PerCityObjects?, Error?) -> Void) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            completion(nil, LoginError.errorLogin(description: "User does not exist or is not verified"))
            return
        }
        var categoryType = ""
        switch category {
            case .event:
                categoryType = "event"
            case .experience:
                categoryType = "experience"
            case .villa:
                categoryType = "villa"
            case .yacht:
                categoryType = "yacht"
            case .gift:
                categoryType = "gift"
            default:
                categoryType = "event"
       
        }
        EEAPIManager().getPerCity(token, type: categoryType) { list, error in
            guard error == nil else {
                Crashlytics.sharedInstance().recordError(error!)
                let error = BackendError.parsing(reason: "Could not obtain per city objects information")
                completion(nil, error)
                return
            }
            completion(list, error)
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

extension PerCityViewController: DidSelectSliderItemProtocol {
    
    func didTappedOnHeartAt(index: Int, sender: HomeSlider) {
        var item: Product!
        switch sender {
            case homeTopRatedSlider:
                item = homeObjects?.topRated[index]
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
                case self.homeTopRatedSlider:
                    var items = self.homeTopRatedSlider.itemsList
                    items[index].isFavourite = !(items[index].isFavourite ?? false)
                    sender.itemsList = items   //re-assigning as it will automatically reload the collection
                
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
            case homeTopRatedSlider:
                product = homeObjects?.topRated[indexPath.row]
            default: return
        }
        
        let viewController = ProductDetailsViewController.instantiate(product: product)
//        self.navigationController?.pushViewController(viewController, animated: true)
        // B2 - 6
        selectedCell = sender.collectionView.cellForItem(at: indexPath) as? HomeSliderCell
        // B2 - 7
        selectedCellImageViewSnapshot = selectedCell?.primaryImage.snapshotView(afterScreenUpdates: false)
        viewController.transitioningDelegate = self
        viewController.modalPresentationStyle = .overFullScreen
        present(viewController, animated: true)
    }
    
}

// B1 - 1
extension PerCityViewController: UIViewControllerTransitioningDelegate {

    // B1 - 2
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        return nil
        // B2 - 16
//        We are preparing the properties to initialize an instance of Animator. If it fails, return nil to use default animation. Then assign it to the animator instance that we just created.
        guard let firstViewController = source as? PerCityViewController,
            let secondViewController = presented as? ProductDetailsViewController,
            let selectedCellImageViewSnapshot = selectedCellImageViewSnapshot
            else {
                return nil
            }
//        print(animationtype)
        if animationtype == .slider{    //top rated
            topRatedAnimator = PerCityTopRatedAnimator(type: .present, firstViewController: firstViewController, secondViewController: secondViewController, selectedCellImageViewSnapshot: selectedCellImageViewSnapshot)
            return topRatedAnimator
        }else if animationtype == .featured{    //city-view
            perCityViewAnimator = PerCityViewAnimator(type: .present, firstViewController: firstViewController, secondViewController: secondViewController, selectedCellImageViewSnapshot: selectedCellImageViewSnapshot)
            return perCityViewAnimator
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
        if animationtype == .slider{//top rated
            topRatedAnimator = PerCityTopRatedAnimator(type: .dismiss, firstViewController: self, secondViewController: secondViewController, selectedCellImageViewSnapshot: selectedCellImageViewSnapshot)
            return topRatedAnimator
        }else if animationtype == .featured{//city-view
            perCityViewAnimator = PerCityViewAnimator(type: .dismiss, firstViewController: self, secondViewController: secondViewController, selectedCellImageViewSnapshot: selectedCellImageViewSnapshot)
            return perCityViewAnimator
        }else {
            return nil
        }
    }
}

//extension PerCityViewController: UINavigationControllerDelegate{
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
