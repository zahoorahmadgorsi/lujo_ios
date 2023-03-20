//
//  PerCityViewController.swift
//  LUJO
//
//  Created by hafsa lodhi on 24/01/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//


import UIKit
import JGProgressHUD
import FirebaseCrashlytics
import AVFoundation
import Mixpanel

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
    
    @IBOutlet weak var collContainerView: UIView!
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        let contentView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        contentView.dataSource = self
        contentView.delegate = self
        contentView.register(UINib(nibName: PrefCollViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: PrefCollViewCell.identifier)
        contentView.backgroundColor = .clear
        contentView.showsHorizontalScrollIndicator = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    private var dataSource: PerCityObjects!
    
    private let naHUD = JGProgressHUD(style: .dark)
    
    private var currentLayout: LiftLayout?
    
    @IBOutlet weak var btnFilter: UIButton!
    private var filtersDataSource: [Product]!
    @IBOutlet weak var svPerCity: UIStackView!
    @IBOutlet weak var svFilters: UIStackView!
    @IBOutlet var homeTopRatedSlider: HomeSlider!
    private var homeObjects: PerCityObjects?
    private var filters:[Filters]?
    var quickFilters: [Taxonomy] = [] {
        didSet {
            collectionView.reloadData()
            collectionView.layoutIfNeeded() //forces the reload to happen immediately instead of on the next runloop cycle.
        }
    }
    
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
    
    //MARK:-  Filters
    
    
    var firstFilter:String = ""         //name
    var secondFilter: [Taxonomy] = []   //yacht Charter
    var thirdFilter: String = ""        //yacht Guests
    var fourthFilter: Taxonomy?         //yacht Length in Feet
    var fifthFilter: Taxonomy?          //yacht Length in Meters
    var sixthFilter: [Taxonomy] = []    //yacht Type
    var seventhFilter: String = ""      //yacht Built After
    var eighthFilter: Taxonomy?         //yacht tags
    var ninthFilter: [Taxonomy] = []    //Interested in charter or sale
    var tenthFilter: Taxonomy?          //Region
    var eleventhFilter: String = ""     //min price
    var twelvethFilter: String = ""     //max price
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem?.title = ""
        homeTopRatedSlider.delegate = self
        updateContentUI()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(btnSeeAllTapped))
        viewSeeAll.isUserInteractionEnabled = true
        viewSeeAll.addGestureRecognizer(tapGesture)
        
        self.collContainerView.addSubview(collectionView)
        applyConstraints()
        
        switch category {
            case .event: fallthrough
            case .experience:
                self.svFilters.isHidden = false
                //Loading the preferences related to events and experience only very first time
                if !UserDefaults.standard.bool(forKey: "isEventPreferencesAlreadyShown")  {
                    let viewController = PrefCollectionsViewController.instantiate(prefType: .events, prefInformationType: .eventCategory)
                    self.navigationController?.pushViewController(viewController, animated: true)
                    UserDefaults.standard.set(true, forKey: "isEventPreferencesAlreadyShown")
                }
            case .villa:
                self.svFilters.isHidden = false
                //Loading the preferences related to villa only very first time
                if !UserDefaults.standard.bool(forKey: "isVillaPreferencesAlreadyShown")  {
                    let airportCollViewCell = AirportCollViewCell()
                    let viewController = PreferredDestinationaViewController.instantiate(prefType: .villas, prefInformationType: .villaDestinations, cell: airportCollViewCell)
                    self.navigationController?.pushViewController(viewController, animated: true)
                    UserDefaults.standard.set(true, forKey: "isVillaPreferencesAlreadyShown")
                }
            case .yacht:
                self.svFilters.isHidden = false
                //Loading the preferences related to yacht only very first time
                if !UserDefaults.standard.bool(forKey: "isYachtPreferencesAlreadyShown")  {
                    let viewController = PrefCollectionsViewController.instantiate(prefType: .yachts, prefInformationType: .yachtHaveCharteredBefore)
                    self.navigationController?.pushViewController(viewController, animated: true)
                    UserDefaults.standard.set(true, forKey: "isYachtPreferencesAlreadyShown")
                }
            case .gift:
                self.svFilters.isHidden = false
                //Loading the preferences related to gift only very first time
                if !UserDefaults.standard.bool(forKey: "isGiftPreferencesAlreadyShown")  {
                    let viewController = PrefCollectionsViewController.instantiate(prefType: .gifts, prefInformationType: .giftHabbits)
                    self.navigationController?.pushViewController(viewController, animated: true)
                    UserDefaults.standard.set(true, forKey: "isGiftPreferencesAlreadyShown")
                }
            default:
                print("No preferences to load")
       
        }
        //get the quick filters (hiding it for now as shuja API isnt returning right results)
        getFilters()
    }
    
    //this method is mainly used when user is coming back from filters screen after picking some filters, this function first clears all quick filters selction, and then checks if user has picked some filter which also exists in quick filter then its highlighting that quick filter, then sorts the quick filters on the bases of selection and then fetches the data on the bases of filters
    override func viewDidAppear(_ animated: Bool) {
        clearQuickFilterSelection()     //first clearing all selection
        //highlight the quick filter if filter selection matches with quick
//        if secondFilter.count > 0 {     //yacht Charter
//            selectQuickFilter(secondFilter[0])    //only one value per filter can be selected from filter screen so this array will always contain 1 value here
//        }
//        //yacht Length in Feet
//        if let filter = fourthFilter{
//            selectQuickFilter(filter)
//        }
//        //yacht Length in Meters
//        if let filter = fifthFilter{
//            selectQuickFilter(filter)
//        }
//        //yacht Type
//        if sixthFilter.count > 0 {     //yacht Charter
//            selectQuickFilter(sixthFilter[0])    //only one value per filter can be selected from filter screen so this array will always contain 1 value here
//        }
//        //yacht tags
//        if let filter = eighthFilter{
//            selectQuickFilter(filter)
//        }
//        //Interested in charter or sale
//        if ninthFilter.count > 0 {     //yacht Charter
//            selectQuickFilter(ninthFilter[0])    //only one value per filter can be selected from filter screen so this array will always contain 1 value here
//        }
//
//        //Region
//        if let filter = tenthFilter{
//            selectQuickFilter(filter)
//        }
    
        quickFilters.sort { ($0.isSelected ?? false) && !($1.isSelected ?? false) }
        collectionView.reloadData()
        collectionView.scrollToTop()
        
        getInformation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    private func selectQuickFilter(_ filter:Taxonomy){
        if let row = self.quickFilters.firstIndex(where: {$0.termId == filter.termId}) {
            self.quickFilters[row].isSelected = true
        }
    }
    
    private func clearQuickFilterSelection(){
        for i in 0..<quickFilters.count {
            quickFilters[i].isSelected = false
        }
    }
    
    private func getFilters(){
        //loading the filters
        if !self.svFilters.isHidden{    //if filters stackView is not hidden then fetch filters
            self.getFilters(for: category) { (filters, filterError) in
//                self.hideNetworkActivity()    //it will hide the percity loader as well
                if let error = filterError {
                    self.showError(error, "Filters")
                } else {
                    self.filters = filters
                    //                self.quickFilters = filters?.quickFilters ?? []
                }
            }
        }
    }
    
    private func applyConstraints() {
        collectionView.leadingAnchor.constraint(equalTo: self.collContainerView.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.collContainerView.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: self.collContainerView.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.collContainerView.bottomAnchor).isActive = true
//        self.collContainerView.heightAnchor.constraint(equalTo: collectionView.heightAnchor).isActive = true
    }
    
    @IBAction func eventTypeChanged(_ sender: Any) {
        getInformation()
    }
    
    @IBAction func searchBarButton_onClick(_ sender: Any) {
        navigationController?.pushViewController(SearchProductsViewController.instantiate(category, nil), animated: true)
    }
    
    fileprivate func updateContentUI() {
        if dataSource != nil || city != nil {
            self.navigationItem.rightBarButtonItem = nil
        }
        let titleString = category.rawValue
        title = titleString == "Villas" ? "Properties" : titleString
//        naHUD.textLabel.text = "Loading " + category.rawValue
    }
    
    func showError(_ error: Error, _ errorTitle:String) {
        showErrorPopup(withTitle: errorTitle, error: error)
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
        getInformation()
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
        if let cities = homeObjects?.cities ?? homeObjects?.categories{
            //user might have applied the filters so remove pre filter applied views
            for view in svPerCity.arrangedSubviews{
                if view is CityView1 || view is CityView2 || view is CityView3 || view is CityView4{
                    view.removeFromSuperview()
                }
            }
            for city in cities {    //if cities are nil then categories will have gifts data
    //        for city in homeObjects?.cities ?? [] {
                //switch city.itemsNum {
                switch city.items?.count{
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
    }
    
//    @IBAction func seeAllTopRatedButton_onClick(_ sender: UIButton) {
    @objc func btnSeeAllTapped(_ sender: Any) {
        let viewController = ProductsViewController.instantiate(category: .topRated, subCategory: self.category)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func viewFilterTapped(_ sender: Any) {
        if let filters = self.filters{
            let viewController = FiltersViewController.instantiate(filters: filters, category:self.category)
//            viewController.delegate = self
            self.navigationController?.pushViewController(viewController, animated: false)
        }else{
            let error = BackendError.parsing(reason: "No filters are available")
            self.showError(error, "Filter")
        }
    }
    

}

extension PerCityViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return filters?.quickFilters?.count ?? 0
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PrefCollViewCell.identifier, for: indexPath) as! PrefCollViewCell
        
        let model = quickFilters[indexPath.row]
        cell.lblTitle.text = model.name
        cell.lblTitle.textColor = UIColor.white
        
        if model.isSelected ?? false{
            cell.containerView.addViewBorder( borderColor: UIColor.rgMid.cgColor, borderWidth: 1.0, borderCornerRadius: 6.0)
        }else{
            cell.containerView.addViewBorder( borderColor: UIColor.white.cgColor, borderWidth: 1.0, borderCornerRadius: 6.0)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.quickFilters[indexPath.row].isSelected = !(self.quickFilters[indexPath.row].isSelected ?? false)
        self.collectionView.reloadItems(at: [indexPath])    //only refresh current selection
//        quickFilters.sort { ($0.isSelected ?? false) && !($1.isSelected ?? false) }     //taking selected quick filters to top
//        collectionView.scrollToTop()    //take the scroll to the top
        
        //assign quick filter value to noral filter and then load the data
        let filter = self.quickFilters[indexPath.row]
        
//        if let filter.filterParameter = secondFilter{     //yacht Charter
//        if filter.filterParameter == "charter_term_id" {     //yacht Charter
//            if filter.isSelected ?? false {     //if is selected is true then append
//                secondFilter.append( filter)
//            }else { //if is selected is false then remove if exists
//                if let idx = secondFilter.firstIndex(where: { $0.termId == filter.termId }) {
//                    secondFilter.remove(at: idx)
//                }
//            }
//        }
//        //yacht Length in Feet (not used in quick filters)
//        if filter.filterParameter == "" {
//            fourthFilter = filter
//        }
//        //yacht Length in Meters  (not used in quick filters)
//        if filter.filterParameter == "" {
//            fifthFilter = filter
//        }
        //yacht Type (motor/sail)
//        if filter.filterParameter == "type_term_id" {
//            if filter.isSelected ?? false {     //if is selected is true then append
//                sixthFilter.append( filter)
//            }else { //if is selected is false then remove if exists
//                if let idx = sixthFilter.firstIndex(where: { $0.termId == filter.termId }) {
//                    sixthFilter.remove(at: idx)
//                }
//            }
//        }
//        //yacht tags (not used in quick filters)
//        if filter.filterParameter == "" {
//            eighthFilter = filter
//        }
//        //Interested in charter or sale
//        if filter.filterParameter == "yacht_status" {
//            if filter.isSelected ?? false {     //if is selected is true then append
//                ninthFilter.append( filter)
//            }else { //if is selected is false then remove if exists
//                if let idx = ninthFilter.firstIndex(where: { $0.termId == filter.termId }) {
//                    ninthFilter.remove(at: idx)
//                }
//            }
//        }
//        //Region
//        if filter.filterParameter == "region" {
//            if filter.isSelected ?? false {
//                tenthFilter = filter
//            }else{
//                tenthFilter = nil
//            }
//        }
    

        getInformation()    //applying the quick filter
        
    }
    
}

extension PerCityViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = Int(collectionView.bounds.size.width)
        let cellWidth = width / 3  - PrefCollSize.itemMargin.rawValue / 3    //to show 3 items at a time
            return CGSize(width: cellWidth, height: PrefCollSize.itemHeight.rawValue)
    }
}

extension PerCityViewController: CityViewProtocol {
    func seeAllProductsForCity(city: Cities) {
        let viewController = ProductsViewController.instantiate(category: self.category, city:DiningCity(termId: city.termId ?? "asdf1234qwer", name: city.name ?? "" , restaurantsNum: -1, restaurants: []))
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
            setUnSetFavourites(type: product.type, id: product.id ,isUnSetFavourite: product.isFavourite ?? false) {information, error in
                self.hideNetworkActivity()

                if let error = error {
                    self.showError(error, "Favorites")
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
                    self.showError(error, "Favorites")
                }
            }
        }
    }
    
    func getInformation() {
        showNetworkActivity()
        getList(for: category) { items, error in
            self.hideNetworkActivity()
            if let error = error {
                self.showError(error,self.category.rawValue)
            } else {
                self.update(listOf: items ?? nil)
            }
        }
    }
    
    func getList(for category: ProductCategory, completion: @escaping (PerCityObjects?, Error?) -> Void) {
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
        
        var secondFilterTermId = "" , fourthFilterTermId = "", fifthFilterTermId = "", sixthFilterTermId = "", eighthFilterTermId = "", ninthFilterTermId = "", tenthFilterTermId = ""
        
//        var dictFilter = [String: String]() //used for mixpanle logging
//        if (firstFilter.count > 0){
//            dictFilter["Filter First (Name)"] = firstFilter
//        }
//        if secondFilter.count > 0{
//            let ids = secondFilter.map { $0.termId }
//            secondFilterTermId = (ids.map{String($0)}).joined(separator: ",")
//
//            let names = secondFilter.map{($0.name)}
//            dictFilter["Filter Second"] = names.joined(separator: ",")
//        }
//        if (thirdFilter.count > 0){
//            dictFilter["Filter Third"] = thirdFilter
//        }
//        if let filter = fourthFilter{
//            fourthFilterTermId = String(filter.termId)
//            dictFilter["Filter Fourth (Length In Feet)"] = filter.name
//        }
//        if let filter = fifthFilter{
//            fifthFilterTermId = String(filter.termId)
//            dictFilter["Filter Fifth (Length In Meters)"] = filter.name
//        }
//
//        if sixthFilter.count > 0{
//            let ids = sixthFilter.map { $0.termId }
//            sixthFilterTermId = (ids.map{String($0)}).joined(separator: ",")
//
//            let names = sixthFilter.map{($0.name)}
//            dictFilter["Filter Sixth"] = names.joined(separator: ",")
//        }
//
//        if (seventhFilter.count > 0){
//            dictFilter["Filter Seventh"] = seventhFilter
//        }
//        if let filter = eighthFilter{
//            eighthFilterTermId = String(filter.termId)
//            dictFilter["Filter Eighth"] = filter.name
//        }
//
//        if ninthFilter.count > 0{
//            let ids = ninthFilter.map { $0.termId }
//            ninthFilterTermId = (ids.map{String($0)}).joined(separator: ",")
//
//            let names = ninthFilter.map{($0.name)}
//            dictFilter["Ninth Sixth"] = names.joined(separator: ",")
//        }
//
//        if let filter = tenthFilter{
//            tenthFilterTermId = String(filter.termId)
//            dictFilter["Filter Tenth"] = filter.name
//        }
//        if (eleventhFilter.count > 0){
//            dictFilter["Filter Eleventh (Min Price)"] = eleventhFilter
//        }
//        if (twelvethFilter.count > 0){
//            dictFilter["Filter Twelveth (Max Price)"] = twelvethFilter
//        }
//        if (dictFilter.count > 0){
//            Mixpanel.mainInstance().track(event: "Filters Applied On \(category.rawValue)",
//                                          properties: dictFilter)
//        }
//
//
        EEAPIManager().getPerCity(type: categoryType
                                  , yachtName: firstFilter
                                  , yachtCharter: secondFilterTermId
                                  , yachtGuests: thirdFilter
                                  , yachtLengthFeet: fourthFilterTermId
                                  , yachtLengthMeters: fifthFilterTermId
                                  , yachtType: sixthFilterTermId
                                  , yachtBuiltAfter: seventhFilter
                                  , yachtTag: eighthFilterTermId
                                  , yachtStatus: ninthFilterTermId
                                  , region:  tenthFilterTermId
                                  , minPrice: eleventhFilter
                                  , maxPrice: twelvethFilter) { list, error in
            guard error == nil else {
                Crashlytics.crashlytics().record(error: error!)
                let error = BackendError.parsing(reason: category.rawValue + " could not be obtained" )
                completion(nil, error)
                return
            }
            completion(list, error)
        }
        
    }
    
    func getFilters(for category: ProductCategory, completion: @escaping ([Filters]?, Error?) -> Void) {

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
        EEAPIManager().getFilters(type: categoryType) { list, error in
            guard error == nil else {
                Crashlytics.crashlytics().record(error: error!)
                let error = BackendError.parsing(reason: "Could not obtain filters on per city")
                completion(nil, error)
                return
            }
            completion(list, error)
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
        setUnSetFavourites(type: item.type,id: item.id ,isUnSetFavourite: item.isFavourite ?? false) {information, error in
            self.hideNetworkActivity()
            
            if let error = error {
                self.showError(error, "Favorites")
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
                self.showError(error, "Favorites")
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

//extension PerCityViewController: FiltersVCProtocol{
//    func setCities(cities: [String]) {
//        self.cities = cities
//    }
    
//    func setFirstFilter(filter: String) {
//        self.firstFilter = filter
//    }
//
//    func setSecondFilter(filter: Taxonomy?) {
//        self.secondFilter = []  //from filter multiple selection isnt allowed
//        if let filt = filter{
//            self.secondFilter.append(filt)
//        }
//
//    }
//
//    func setThirdFilter(filter: String) {
//        self.thirdFilter = filter
//    }
//
//    func setFourthFilter(filter: Taxonomy?) {
//        self.fourthFilter = filter
//    }
//
//    func setFifthFilter(filter: Taxonomy?) {
//        self.fifthFilter = filter
//    }
//
//    func setSixthFilter(filter: Taxonomy?) {
//        self.sixthFilter = []  //from filter multiple selection isnt allowed
//        if let filt = filter{
//            self.sixthFilter.append(filt)
//        }
//    }
//
//    func setSeventhFilter(filter: String) {
//        self.seventhFilter = filter
//    }
//
//    func setEighthFilter(filter: Taxonomy?) {
//        self.eighthFilter = filter
//    }
//
//    func setNinthFilter(filter: Taxonomy?) {
//        self.ninthFilter = []  //from filter multiple selection isnt allowed
//        if let filt = filter{
//            self.ninthFilter.append(filt)
//        }
//    }
//
//    func setTenthFilter(filter: Taxonomy?) {
//        self.tenthFilter = filter
//    }
//
//    func setEleventhFilter(filter: String) {
//        self.eleventhFilter = filter
//    }
//
//    func setTwelvethFilter(filter: String) {
//        self.twelvethFilter = filter
//    }
//}
