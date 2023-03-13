//
//  ProductDetailsViewController.swift
//  LUJO
//
//  Created by Iker Kristian on 8/28/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import JGProgressHUD
import Mixpanel
import FirebaseCrashlytics

class ProductDetailsViewController: UIViewController, GalleryViewProtocol {
    
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "ProductDetailsViewController" }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imgBack: UIImageView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var lblDescriptionHeight: NSLayoutConstraint!
    var isLabelAtMaxHeight = false
    
    @IBOutlet weak var viewReadMore: UIView!
    @IBOutlet weak var btnReadMore: UIButton!
    var descHeightToShowReadMore:CGFloat = 70.0
    /// Init method that will init and return view controller.
    class func instantiate(product: Product) -> ProductDetailsViewController {
        let viewController = UIStoryboard.main.instantiate(identifier) as! ProductDetailsViewController
        viewController.product = product
        return viewController
    }
    
    //MARK:- Globals
    
    private(set) var product: Product!
    
    @IBOutlet weak var ViewMainImage: UIView!
    @IBOutlet var mainImageView: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var locationContainerView: UIView!
    @IBOutlet var dateContainerView: UIView!
    @IBOutlet weak var calendarImage: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var requestButton: ActionButton!
    @IBOutlet var chatButton: UIButton!
    @IBOutlet weak var bottomLineViewHeight: NSLayoutConstraint!
    var isEventPast: Bool = false
    @IBOutlet weak var viewHeart: UIView!
    @IBOutlet weak var imgHeart: UIImageView!
    private let naHUD = JGProgressHUD(style: .dark)
    @IBOutlet weak var viewReadGallery: UIView!
    
    @IBOutlet weak var viewYachtLength: UIView!
    @IBOutlet weak var lblYachtLength: UILabel!
    
    @IBOutlet weak var viewYachtPassengers: UIView!
    @IBOutlet weak var lblYachtPassengers: UILabel!
    
    @IBOutlet weak var viewYachtCabins: UIView!
    @IBOutlet weak var lblYachtCabins: UILabel!
    
    @IBOutlet weak var viewBathrooms: UIView!
    @IBOutlet weak var lblBathrooms: UILabel!
    
    var scrollOffsetToShowNavigationBar :CGFloat = 280 //scrollview positiong
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "us_US")
        formatter.dateFormat = "MMM"
        return formatter
    }()
    
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "GMT")
        formatter.dateFormat = "HH:mm'h'"
        return formatter
    }()
    
    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter
    }()
    
    //dismissin on swiping down
    var pgrMainImage: UIPanGestureRecognizer?
    var pgrFullView: UIPanGestureRecognizer?
    var originalPosition: CGPoint?
    var currentPositionTouched: CGPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        bottomLineViewHeight.constant = UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20 ? 34 : 0
        //setting tapping event on viewheart
        //Add tap gesture on favourite
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedOnHeart(_:)))
        self.viewHeart.isUserInteractionEnabled = true      //can also be enabled from IB
        self.viewHeart.addGestureRecognizer(tapGestureRecognizer)
        //Add tap gesture on back button
        let tgrBack = UITapGestureRecognizer(target: self, action: #selector(tappedOnBack(_:)))
        self.imgBack.isUserInteractionEnabled = true        //can also be enabled from IB
        self.imgBack.addGestureRecognizer(tgrBack)
        //Add tap gesture on ReadMore button
        
        let tgrReadMore = UITapGestureRecognizer(target: self, action: #selector(btnSeeMoreTapped(_:)))
        self.viewReadMore.isUserInteractionEnabled = true   //can also be enabled from IB
        self.viewReadMore.addGestureRecognizer(tgrReadMore)
        
        //Addin swipe down pan gesture
        pgrMainImage = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        ViewMainImage.addGestureRecognizer(pgrMainImage!)   //applying pan gesture on main image
        
        pgrFullView  = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        self.view.addGestureRecognizer(pgrFullView!)        //applying pan gesture on full main view
        
        //zahoor uncomment below line after successfully testing with harshal... this is commented to test loading the product details via push notificatino
        if (product.name.count == 0 ){  //detail is going to open due to some push notification
            //showig animation
            let jeremyGif = UIImage.gifImageWithName("logo animation")
            let imageView = UIImageView(image: jeremyGif)
            imageView.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            view.addSubview(imageView)
            
//            self.showNetworkActivity()
            getProductDetails() {information, error in
//                self.hideNetworkActivity()
                imageView.removeFromSuperview()
                if let error = error {
                    self.showError(error, "Product Detail")
                    return
                }
                if let info = information {
                    self.product = info
                    self.setUpUi()
                } else {
                    let error = BackendError.parsing(reason: "Could not obtain product details")
                    self.showError(error, "Product Detail")
                }
            }
        }else{
            setUpUi()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activateKeyboardManager()
        print(product.id)
//        showInformationPopup(withTitle: "Only For Charmaine Diaz", message: "\n type: \(product.type) \n id:\(product.id)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func getProductDetails(completion: @escaping (Product?, Error?) -> Void) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            completion(nil, LoginError.errorLogin(description: "User does not exist or is not verified"))
            return
        }
        print("Product: \(product)")
        if (product.type == "event"){
            EEAPIManager().getEvents(past: false, term: nil, cityId: nil, productId: product.id) { list, error in
                guard error == nil else {
                    Crashlytics.crashlytics().record(error: error!)
                    let error = BackendError.parsing(reason: "Could not obtain Events information")
                    completion(nil, error)
                    return
                }
                completion(list[0], error)
            }
        }else if (product.type == "experience"){
            EEAPIManager().getExperiences( term: nil, cityId: nil, productId: product.id) { list, error in
                guard error == nil else {
                    Crashlytics.crashlytics().record(error: error!)
                    let error = BackendError.parsing(reason: "Experience could not be loaded")
                    completion(nil, error)
                    return
                }
                completion(list[0], error)
            }
        }else if (product.type == "villa"){
            EEAPIManager().getVillas(term: nil, cityId: nil, productId: product.id) { list, error in
                guard error == nil else {
                    Crashlytics.crashlytics().record(error: error!)
                    let error = BackendError.parsing(reason: "Villa could not be loaded")
                    completion(nil, error)
                    return
                }
                completion(list[0], error)
            }
        }else if (product.type == "gift"){
            EEAPIManager().getGoods( term: nil, giftCategoryId: nil, productId: product.id) { list, error in
                guard error == nil else {
                    Crashlytics.crashlytics().record(error: error!)
                    let error = BackendError.parsing(reason: "Gift could not be loaded")
                    completion(nil, error)
                    return
                }
                completion(list[0], error)
            }
        }else if (product.type == "yacht"){
            EEAPIManager().getYachts( term: nil, cityId: nil, productId: product.id) { list, error in
                guard error == nil else {
                    Crashlytics.crashlytics().record(error: error!)
                    let error = BackendError.parsing(reason: "Yacht could not be loaded")
                    completion(nil, error)
                    return
                }
                completion(list[0], error)
            }
        }else if (product.type == "restaurant"){
            EEAPIManager().getRestaurant( productId: product.id) { list, error in
                guard error == nil else {
                    Crashlytics.crashlytics().record(error: error!)
                    let error = BackendError.parsing(reason: "Restaurant could not be loaded")
                    completion(nil, error)
                    return
                }
                completion(list[0], error)
            }
        }
    }
    
    func setUpUi(){
        switch product.type {
            case "event":           fallthrough
            case "special-event":   setupEvents(product)
            case "gift":            fallthrough
            case "experience":      setupExperience(product)
            case "yacht":
                setupYacht(product)
//                getYachtGallery(product: product)
            case "villa":           setupVilla(product)
            default:
                setupEvents(product)//("It could be restaurant")
                break
        }
        //Setting up ReadMore
        if let font = descriptionTextView.font{
            let currentHeight = getTextViewHeight(text: descriptionTextView.text, width: descriptionTextView.bounds.width, font: font )
            print(currentHeight,descHeightToShowReadMore)
            if (currentHeight > descHeightToShowReadMore){
                viewReadMore.isHidden = false
                lblDescriptionHeight.constant = descHeightToShowReadMore
            }else{
                viewReadMore.isHidden = true  //no need to show readmore button
                lblDescriptionHeight.constant = currentHeight
            }
        }
        
        //setting up gallery
        setUpGallery(product)
        setRecentlyViewed()
    }
    
    
//    func getYachtGallery(product: Product){
//        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
//            LoginError.errorLogin(description: "User does not exist or is not verified")
//            return
//        }
//        
//        EEAPIManager().getYachtGallery(token, postId: product.id) { gallery, error in
//            guard error == nil else {
//                Crashlytics.crashlytics().record(error: error!)
//                _ = BackendError.parsing(reason: "Could not get yacht's gallery")
//                return
//            }
//            if (gallery.count > 0){
//                self.product.gallery = gallery
//                self.setUpGallery(self.product)
//            }
//        }
//    }
    
    @IBAction func requestBooking(_ sender: Any) {
        sendInitialInformation()
    }
    
    func didTappedOnImage(itemIndex: Int) {
        print("didTappedOnImage")
//        didTappedOnViewGallery(scrollToThisItem: itemIndex)
        let dataSource = product.getGalleryImagesURL()
        if dataSource.count > 0 {
            let viewController = GalleryViewControllerNEW.instantiate(dataSource: dataSource , scrollToItem: itemIndex)
            self.present(viewController, animated: true, completion: nil)
        } else {
            print("There are no images in the gallery, sorry!")
        }
    }
    
    @IBAction func viewGalleryButton_onClick(_ sender: UIButton) {
        didTappedOnViewGallery()
    }

    func didTappedOnViewGallery() {
        let dataSource = product.getGalleryImagesURL()
        if dataSource.isEmpty {
            print("There are no images in the gallery, sorry!")
//            showInformationPopup(withTitle: "Info", message: "There are no images in the gallery, sorry!")
        } else {
            let viewController = GalleryViewControllerNEW.instantiate(dataSource: dataSource )
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnSeeMoreTapped(_ sender: Any) {
        if isLabelAtMaxHeight {
            btnReadMore.setTitle("Read more", for: .normal)
            isLabelAtMaxHeight = false

            if let font = descriptionTextView.font{
                let currentHeight = getTextViewHeight(text: descriptionTextView.text, width: descriptionTextView.bounds.width, font: font )
//                    print(currentHeight,descHeightToShowReadMore)
                if (currentHeight > descHeightToShowReadMore){
                    lblDescriptionHeight.constant = descHeightToShowReadMore
                }else{
                    lblDescriptionHeight.constant = currentHeight
                }
            }
        }
        else {
            btnReadMore.setTitle("Read less", for: .normal)
            isLabelAtMaxHeight = true
            if let font = descriptionTextView.font{
                lblDescriptionHeight.constant = getTextViewHeight(text: descriptionTextView.text, width: descriptionTextView.bounds.width, font: font )
            }
        }
    }
    
    func getTextViewHeight(text: String, width: CGFloat, font: UIFont) -> CGFloat {
            let lbl = UITextView(frame: .zero)
            lbl.frame.size.width = width
            lbl.font = font
//            lbl.numberOfLines = 0
            lbl.text = text
            lbl.attributedText = convertToAttributedString(text)
            lbl.sizeToFit()
            return lbl.frame.height
        }
}

extension ProductDetailsViewController {
    
    fileprivate func setupEvents(_ product: Product) {
        if let mediaLink = product.thumbnail?.mediaUrl, product.thumbnail?.mediaType == "image" {
            mainImageView.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
        }
        else if let firstImageLink = product.getGalleryImagesURL().first {
            mainImageView.downloadImageFrom(link: firstImageLink, contentMode: .scaleAspectFill)
        }else{
            print("Image not found")
        }
        name.text = product.name
        self.title = name.text
        //checking favourite image red or white
        if (self.product.isFavourite ?? false){
            self.imgHeart.image = UIImage(named: "heart_red")
        }else{
            self.imgHeart.image = UIImage(named: "heart_white")
        }
        
        var locationText = product.address ?? ""  //in case of restaurant , it will have exact address
        locationText = locationText.count > 0 ? locationText + ", " + product.getLocation() : product.getLocation()
        locationLabel.text = locationText.uppercased()
        locationContainerView.isHidden = locationText.isEmpty
        
        var startDateText = ""
        var startTimeText = ""
        
        if let startDate = product.startDate {
            startDateText = ProductDetailsViewController.convertDateFormate(date: startDate)
            startTimeText = ProductDetailsViewController.timeFormatter.string(from: startDate)
        }
        
        var endDateText = ""
        if let eventEndDate = product.endDate {
            endDateText = ProductDetailsViewController.convertDateFormate(date: eventEndDate)
        }
        
        if let timezone = product.timezone {
            startTimeText = "\(startTimeText) (\(timezone))"
        }
        
        if product.startDate != nil {
            dateLabel.text = endDateText != "" ? "\(startDateText) - \(endDateText)" : "\(startDateText) \(startTimeText)"
        }
        //replacing date with cuisine
        if product.type == "restaurant" {
            var cuisineText = ""
            for cousine in product.cuisineCategory ?? [] {
                cuisineText = cuisineText.isEmpty ? "\(cousine.name)" : "\(cuisineText), \(cousine.name)"
            }
            dateLabel.text = cuisineText.uppercased()
            if (dateLabel.text?.count ?? 0 > 0){ //change calendar icon with cuisine icon
                calendarImage.image = UIImage(named:"Cuisine Icon Orange")
            }
        }
        
        dateContainerView.isHidden = ((dateLabel.text?.isEmpty) == nil)
        locationContainerView.isHidden = locationText.isEmpty
        //hiding yacht length, passenger and cabins views
        viewYachtLength.isHidden = true
        viewYachtPassengers.isHidden = true
        viewYachtCabins.isHidden = true
        viewBathrooms.isHidden = true
        
        descriptionTextView.attributedText = convertToAttributedString(product.description)
        
        chatButton.isEnabled = !isEventPast
        requestButton.isEnabled = !isEventPast
        if product.type == "special-event" {
            requestButton.setTitle("R E Q U E S T", for: .normal)
        }else if product.type == "restaurant" {
            requestButton.setTitle("REQUEST A RESERVATION", for: .normal)
        }
        
        if isEventPast {
            requestButton.setDisabled()
        }
    }
    
    fileprivate func setupExperience(_ product: Product) {
        if let mediaLink = product.thumbnail?.mediaUrl, product.thumbnail?.mediaType == "image" {
            mainImageView.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
        }
        else if let firstImageLink = product.getGalleryImagesURL().first {
            mainImageView.downloadImageFrom(link: firstImageLink, contentMode: .scaleAspectFill)
        }else{
            print("Image not found")
        }
        name.text = product.name
        self.title = name.text
        //checking favourite image red or white
        if (self.product.isFavourite ?? false){
            self.imgHeart.image = UIImage(named: "heart_red")
        }else{
            self.imgHeart.image = UIImage(named: "heart_white")
        }
        
        let locationText = product.getLocation()
        locationLabel.text = locationText.uppercased()
        locationContainerView.isHidden = locationText.isEmpty
        
        dateContainerView.isHidden = true
        //hiding yacht length, passenger and cabins views
        viewYachtLength.isHidden = true
        viewYachtPassengers.isHidden = true
        viewYachtCabins.isHidden = true
        viewBathrooms.isHidden = true
        
        descriptionTextView.attributedText = convertToAttributedString(product.description)
        requestButton.setTitle("R E Q U E S T", for: .normal)
    }
    
    fileprivate func setupVilla(_ product: Product) {
        if let mediaLink = product.thumbnail?.mediaUrl, product.thumbnail?.mediaType == "image" {
            mainImageView.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
        }
        else if let firstImageLink = product.getGalleryImagesURL().first {
            mainImageView.downloadImageFrom(link: firstImageLink, contentMode: .scaleAspectFill)
        }else{
            print("Image not found")
        }
        
        name.text = product.name
        self.title = name.text
        //checking favourite image red or white
        if (self.product.isFavourite ?? false){
            self.imgHeart.image = UIImage(named: "heart_red")
        }else{
            self.imgHeart.image = UIImage(named: "heart_white")
        }
        
        var locationText = ""
        if let cityName = product.locations?.city?.name {
            locationText = "\(cityName), "
        }
        locationText += product.locations?.country.name ?? ""
        locationLabel.text = locationText.uppercased()
        
        dateContainerView.isHidden = true
        //hiding yacht length, passenger and cabins views
        viewYachtLength.isHidden = true
//        viewYachtPassengers.isHidden = true
//        viewYachtCabins.isHidden = true
        
        //preparing summary data of collection view
        var itemsList =  [ProductDetail]()
        if let val = product.headline , val.count > 0{
            itemsList.append(ProductDetail(key: "Headline",value: val,isHighSeason: nil))
        }
        if let val = product.numberOfBedrooms, val > 0{
            itemsList.append(ProductDetail(key: "Number Of Bedrooms",value: String(val),isHighSeason: nil))
//            itemsList.append(ProductDetail(key: "No. Of Bedrooms",value: val,isHighSeason: nil))
            lblYachtCabins.text = String(val)
        }else{
            viewYachtCabins.isHidden = true
        }
        
        if let val = product.numberOfGuests, val.count > 0{
            itemsList.append(ProductDetail(key: "Number Of Guests",value: val,isHighSeason: nil))
//            itemsList.append(ProductDetail(key: "No. Of Guests",value: val,isHighSeason: nil))
            lblYachtPassengers.text = val
        }else{
            viewYachtPassengers.isHidden = true
        }
        if let val = product.numberOfBathrooms, val > 0{
            itemsList.append(ProductDetail(key: "Number Of Bathrooms",value: String(val),isHighSeason: nil))
//            itemsList.append(ProductDetail(key: "No. Of Bathrooms",value: val,isHighSeason: nil))
            lblBathrooms.text = String(val)
        }else{
            viewBathrooms.isHidden = true
        }
        
        
        if (itemsList.count > 0){
            
            let productDetailView: ProductDetailView = {
                let tv = ProductDetailView()
                tv.translatesAutoresizingMaskIntoConstraints = false
                return tv
            }()
            productDetailView.itemType = .summary
            productDetailView.lblTitle.text = productDetailView.itemType.rawValue
            productDetailView.itemsList = itemsList
            stackView.addArrangedSubview(productDetailView)
            //applying constraints on productDetailView
            setupProductDetailLayout(productDetailView: productDetailView)
        }
        //preparing price data of collection view
        
        itemsList =  [ProductDetail]()
        if let val = product.rentPricePerWeekHighSeason, val.count > 0{
            itemsList.append(ProductDetail(key: "Weekly Rent",value: "$" + val.withCommas() ,isHighSeason: true)) //High Season
//            itemsList.append(ProductDetail(key: "Weekly Rent",value: val,isHighSeason: true)) //High Season
        }
        if let val = product.rentPricePerWeekLowSeason, val.count > 0{
            itemsList.append(ProductDetail(key: "Weekly Rent",value: "$" + val.withCommas() ,isHighSeason: false)) // Low Season
//            itemsList.append(ProductDetail(key: "Weekly Rent",value:  val,isHighSeason: false)) // Low Season
        }
        if let val = product.salePrice , val.count > 0{
            itemsList.append(ProductDetail(key: "Sale Price",value: "$" + val.withCommas() ,isHighSeason: nil))
        }
        if (itemsList.count > 0){
            let productDetailView: ProductDetailView = {
                let tv = ProductDetailView()
                tv.translatesAutoresizingMaskIntoConstraints = false
                return tv
            }()
            //productDetailView.delegate = self
            productDetailView.itemType = .price
            productDetailView.lblTitle.text = productDetailView.itemType.rawValue
            productDetailView.itemsList = itemsList
            stackView.addArrangedSubview(productDetailView)
            //applying constraints on wishListView
            setupProductDetailLayout(productDetailView: productDetailView)
        }
        //preparing amenities data of collection view
        itemsList =  [ProductDetail]()
        var count = (product.villaAmenities?.count ?? 0)
        if count > 0 , let items = product.villaAmenities{
            for item in items{
                itemsList.append(ProductDetail(key: "name",value: item,isHighSeason: nil))
            }
        }
        //preparing facilites data of collection view
        count = (product.villaFacilities?.count ?? 0)
        if count > 0 , let items = product.villaFacilities{
            for item in items{
                itemsList.append(ProductDetail(key: "name",value: item.name,isHighSeason: nil))
            }
        }
        if (itemsList.count > 0){
            let productDetailView: ProductDetailView = {
                let tv = ProductDetailView()
                tv.translatesAutoresizingMaskIntoConstraints = false
                return tv
            }()
            //productDetailView.delegate = self
            productDetailView.itemType = .amenities
            productDetailView.lblTitle.text = productDetailView.itemType.rawValue
            productDetailView.itemsList = itemsList
            stackView.addArrangedSubview(productDetailView)
            //applying constraints on wishListView
            setupProductDetailLayout(productDetailView: productDetailView)
        }
        descriptionTextView.attributedText = convertToAttributedString(product.description)
        
        requestButton.setTitle("R E Q U E S T", for: .normal)
    }
    
    fileprivate func setupYacht(_ product: Product) {
        if let mediaLink = product.thumbnail?.mediaUrl, product.thumbnail?.mediaType == "image" {
            mainImageView.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
        }
        else if let firstImageLink = product.getGalleryImagesURL().first {
            mainImageView.downloadImageFrom(link: firstImageLink, contentMode: .scaleAspectFill)
        }else{
            print("Image not found")
        }
        
        name.text = product.name
        self.title = name.text
        //checking favourite image red or white
        if (self.product.isFavourite ?? false){
            self.imgHeart.image = UIImage(named: "heart_red")
        }else{
            self.imgHeart.image = UIImage(named: "heart_white")
        }
        let locationText = product.getLocation()
        locationLabel.text = locationText.uppercased()
        
        dateContainerView.isHidden = true
        viewBathrooms.isHidden = true
        
        //preparing summary data of collection view
        var itemsList =  [ProductDetail]()
//        if let val = product.headline , val.count > 0{
//            itemsList.append(ProductDetail(key: "Headline",value: val))
//        }

        if let val = product.guestsNumber, val.count > 0{
            itemsList.append(ProductDetail(key: "Number Of Guests",value: val,isHighSeason: nil))
//            itemsList.append(ProductDetail(key: "No. Of Guests",value: val,isHighSeason: nil))
            lblYachtPassengers.text = val
        }else{
            viewYachtPassengers.isHidden = true
        }
        if let val = product.cabinNumber, val.count > 0{
            itemsList.append(ProductDetail(key: "Number Of Cabins",value: val,isHighSeason: nil))
//            itemsList.append(ProductDetail(key: "No. Of Cabins",value: val,isHighSeason: nil))
            lblYachtCabins.text = val
        }else{
            viewYachtCabins.isHidden = true
        }
        
        if let val = product.crewNumber, val.count > 0{
            itemsList.append(ProductDetail(key: "Number Of Crews",value: val,isHighSeason: nil))
//            itemsList.append(ProductDetail(key: "No. Of Crews",value: val,isHighSeason: nil))
        }
        if let val = product.builderName, val.count > 0{
            itemsList.append(ProductDetail(key: "Builder Name",value: val,isHighSeason: nil))
        }
        if let val = product.interiorDesigner, val.count > 0{
            itemsList.append(ProductDetail(key: "Interior Designer",value: val,isHighSeason: nil))
        }
        if let val = product.exteriorDesigner , val.count > 0{
            itemsList.append(ProductDetail(key: "Exterior Designer",value: val,isHighSeason: nil))
        }
        if let val = product.buildYear, val > 0{
            itemsList.append(ProductDetail(key: "Build Year",value: String(val),isHighSeason: nil))
        }
        if let val = product.refitYear, val.count > 0{
            itemsList.append(ProductDetail(key: "Refit Year",value: val,isHighSeason: nil))
        }
        if let val = product.lengthM, val.count > 0{
            itemsList.append(ProductDetail(key: "Length (Meters)",value: val,isHighSeason: nil))
            lblYachtLength.text = val + "(m)"
        }else{
            viewYachtLength.isHidden = true
        }
        if let val = product.beamM, val.count > 0{
            itemsList.append(ProductDetail(key: "Beam",value: val,isHighSeason: nil))
        }
        if let val = product.draftM , val.count > 0{
            itemsList.append(ProductDetail(key: "Draft",value: val,isHighSeason: nil))
        }
        if let val = product.grossTonnage, val.count > 0{
            itemsList.append(ProductDetail(key: "Gross Tonnage",value: val,isHighSeason: nil))
        }
        if let val = product.cruisingSpeedKnot, val.count > 0{
            itemsList.append(ProductDetail(key: "Cruising Speed (Knots)",value: val,isHighSeason: nil))
//            itemsList.append(ProductDetail(key: "Cruising Speed",value: val,isHighSeason: nil))
        }
        if let val = product.topSpeedKnot, val.count > 0{
            itemsList.append(ProductDetail(key: "Top Speed (Knots)",value: val,isHighSeason: nil))
//            itemsList.append(ProductDetail(key: "Top Speed",value: val,isHighSeason: nil))
        }
        
        if (itemsList.count > 0){
            let productDetailView: ProductDetailView = {
                let tv = ProductDetailView()
                tv.translatesAutoresizingMaskIntoConstraints = false
                return tv
            }()
            productDetailView.itemType = .summary
            productDetailView.lblTitle.text = productDetailView.itemType.rawValue
            productDetailView.itemsList = itemsList
            stackView.addArrangedSubview(productDetailView)
            //applying constraints on productDetailView
            setupProductDetailLayout(productDetailView: productDetailView)
        }
        //preparing price data of collection view
        itemsList =  [ProductDetail]()
    
        if let val = product.charterPriceHighSeasonPerDay, val.amount.count > 0{
            itemsList.append(ProductDetail(key: "Daily Charter",value: (val.currencyType?.symbolLeft ?? "") + val.amount.withCommas() + (val.currencyType?.symbolRight ?? "") ,isHighSeason: true)) // high season
        }
        if let val = product.charterPriceHighSeasonPerWeek, val.amount.count > 0{
            itemsList.append(ProductDetail(key: "Weekly Charter",value: (val.currencyType?.symbolLeft ?? "") + val.amount.withCommas() + (val.currencyType?.symbolRight ?? "") ,isHighSeason: true)) // high season
        }
        
        if let val = product.charterPriceLowSeasonPerDay, val.amount.count > 0{
            itemsList.append(ProductDetail(key: "Daily Charter",value: (val.currencyType?.symbolLeft ?? "") + val.amount.withCommas() + (val.currencyType?.symbolRight ?? "") ,isHighSeason: false)) // low season
        }
        
        if let val = product.charterPriceLowSeasonPerWeek, val.amount.count > 0{
            itemsList.append(ProductDetail(key: "Weekly Charter",value: (val.currencyType?.symbolLeft ?? "") + val.amount.withCommas() + (val.currencyType?.symbolRight ?? "") ,isHighSeason: false)) //low season
        }
        if let val = product.salePrice , val.count > 0{
            itemsList.append(ProductDetail(key: "Sale Price",value: val.withCommas() ,isHighSeason: nil))
        }
        
        if (itemsList.count > 0){
            let productDetailView: ProductDetailView = {
                let tv = ProductDetailView()
                tv.translatesAutoresizingMaskIntoConstraints = false
                return tv
            }()
            //productDetailView.delegate = self
            productDetailView.itemType = .price
            productDetailView.lblTitle.text = productDetailView.itemType.rawValue
            productDetailView.itemsList = itemsList
            stackView.addArrangedSubview(productDetailView)
            //applying constraints on wishListView
            setupProductDetailLayout(productDetailView: productDetailView)
        }
        
        //preparing amenities (yachtExtras) data of collection view
        itemsList =  [ProductDetail]()
        let count = (product.yachtExtras?.count ?? 0)
        if count > 0 , let items = product.yachtExtras{
            itemsList =  [ProductDetail]()
            for item in items{
                itemsList.append(ProductDetail(key: "name",value: item.name,isHighSeason: nil))
            }
        }
        
        if (itemsList.count > 0){
            let productDetailView: ProductDetailView = {
                let tv = ProductDetailView()
                tv.translatesAutoresizingMaskIntoConstraints = false
                return tv
            }()
            //productDetailView.delegate = self
            productDetailView.itemType = .amenities
            productDetailView.lblTitle.text = productDetailView.itemType.rawValue
            productDetailView.itemsList = itemsList
            stackView.addArrangedSubview(productDetailView)
            //applying constraints on wishListView
            setupProductDetailLayout(productDetailView: productDetailView)
        }
        descriptionTextView.attributedText = convertToAttributedString(product.description)
        requestButton.setTitle("R E Q U E S T", for: .normal)
    }
    
    func setUpGallery(_ product: Product){
        //Setting up gallery
        switch product.gallery?.filter({$0.type == "image"}).count {
        case 0: print("No need to add any gallery")
        case 1:
            let galleryView = GalleryView1()
            galleryView.gallery = product.gallery
            galleryView.delegate = self
            stackView.addArrangedSubview(galleryView)
            //applying constraints on productDetailView
            setupGalleryLayout(galleryView: galleryView)
        case 2:
            let galleryView = GalleryView2()
            galleryView.gallery = product.gallery
            galleryView.delegate = self
            stackView.addArrangedSubview(galleryView)
            //applying constraints on galleryView
            setupGalleryLayout(galleryView: galleryView)
        case 3:
            let galleryView = GalleryView3()
            galleryView.gallery = product.gallery
            galleryView.delegate = self
            stackView.addArrangedSubview(galleryView)
            //applying constraints on galleryView
            setupGalleryLayout(galleryView: galleryView)
        default:
            print("4 or more")
            let galleryView = GalleryView4()
            galleryView.gallery = product.gallery
            galleryView.delegate = self
            stackView.addArrangedSubview(galleryView)
            //applying constraints on galleryView
            setupGalleryLayout(galleryView: galleryView)
        }
    }
    
    func setupProductDetailLayout(productDetailView:ProductDetailView){
        productDetailView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
        productDetailView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
        //top isnt required as in stack view it doesnt matter
        //wishListView.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 100).isActive = true
        productDetailView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
//        print(itemHeight)
        let collectionViewHeight = productDetailView.collectionView.collectionViewLayout.collectionViewContentSize.height
        let totalHeight = Int(collectionViewHeight/2) + (ProdCollSize.itemMargin.rawValue*2)+30 // 30 is height of "Title" control
//        print(totalHeight)
        productDetailView.heightAnchor.constraint(equalToConstant: CGFloat(totalHeight)).isActive = true
    }
    
    static func convertDateFormate(date: Date) -> String {
        let calendar = Calendar.current
        let anchorComponents = calendar.dateComponents([.day, .month, .year], from: date)
        
        let newDate = ProductDetailsViewController.dateFormatter.string(from: date)
        let dateDay = ProductDetailsViewController.numberFormatter.string(from: NSNumber(value: anchorComponents.day!))
        
        return dateDay! + " " + newDate
    }
    
    private func convertToAttributedString(_ text: String) -> NSAttributedString {
//        let range = NSRange(location: 0, length: text.count)
        let range = NSRange(location: 0, length: text.unicodeScalars.count) //unicodeScalars will count \n and \r as well.
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        let aString = NSMutableAttributedString(string: text)
        aString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 15, weight: .light), range: range)
        aString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: range)
        aString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: range)
        return aString
    }
    
    func setupGalleryLayout(galleryView:GalleryView1){
        galleryView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
        galleryView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
        //top isnt required as in stack view it doesnt matter
//        galleryView.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 0).isActive = true
        galleryView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        let totalHeight = 206
        galleryView.heightAnchor.constraint(equalToConstant: CGFloat(totalHeight)).isActive = true
    }
    
    func setupGalleryLayout(galleryView:GalleryView2){
        galleryView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
        galleryView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
        galleryView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        let totalHeight = 206
        galleryView.heightAnchor.constraint(equalToConstant: CGFloat(totalHeight)).isActive = true
    }
    
    func setupGalleryLayout(galleryView:GalleryView3){
        galleryView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
        galleryView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
        galleryView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        let totalHeight = 350
        galleryView.heightAnchor.constraint(equalToConstant: CGFloat(totalHeight)).isActive = true
    }
    
    func setupGalleryLayout(galleryView:GalleryView4){
        galleryView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
        galleryView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
        galleryView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        let totalHeight = 494
        galleryView.heightAnchor.constraint(equalToConstant: CGFloat(totalHeight)).isActive = true
    }
}

// Chat functionality
extension ProductDetailsViewController {

    func sendInitialInformation(initialMsg:String = "" ,_ salesForceRequest:SalesforceRequest? = nil) {//if initialMessage is empty then user is coming to fill the booking details of yacht,villa and restaurnat
        var initialMessage = initialMsg
//        print(product.type)
        if (product.type == "yacht" && initialMessage.count == 0){
            let viewController = YachtViewController.instantiate(product: product)
            self.present(viewController, animated: true, completion: nil)
        }else if (product.type == "villa" && initialMessage.count == 0){
            let viewController = VillaViewController.instantiate(product: product)
            self.present(viewController, animated: true, completion: nil)
        }else if(product.type == "restaurant" && initialMessage.count == 0){
            let viewController = RestaurantRequestReservationViewController.instantiate(restaurant: product)
            present(viewController, animated: true, completion: nil)
        }
        else{
            guard let userFirstName = LujoSetup().getLujoUser()?.firstName else { return }
            if LujoSetup().getLujoUser()?.membershipPlan != nil {
                guard let userFirstName = LujoSetup().getLujoUser()?.firstName else { return }
                if (initialMessage.count == 0){ //user is coming to book event, experience or gift else initial message would have something incase of yacht,villa and restaurant
                    initialMessage = """
                    Hi Concierge team,

                    I am interested in \(product.name), can you assist me?

                    \(userFirstName)
                    """
}
                //Checking if user is able to logged in to Twilio or not, if not then getClient will login
                if ConversationsManager.sharedConversationsManager.getClient() != nil
                {
                    //            print(initialMessage)
                    let viewController = AdvanceChatViewController()
                    
                    let salesForceRequest = SalesforceRequest(id: product.id , type: product.type, name: product.name, date: salesForceRequest?.dingingRequestDate, time: salesForceRequest?.dingingRequestTime, persons: salesForceRequest?.dingingRequestPersons)
                    viewController.salesforceRequest = salesForceRequest
                    viewController.initialMessage = initialMessage
                    let navController = UINavigationController(rootViewController:viewController)
                    if #available(iOS 13.0, *) {
                            let controller = navController.topViewController
    // Modal Dismiss iOS 13 onward
    //to call UIAdaptivePresentationControllerDelegate.presentationControllerDidDismiss at dismiss by pressing cross button
                        controller?.presentationController?.delegate = self
                    }

                    //to call UIAdaptivePresentationControllerDelegate.presentationControllerDidDismiss at dismiss by dragging
                    navController.presentationController?.delegate = self
                    UIApplication.topViewController()?.present(navController, animated: true, completion: nil)
                    //Zahoor end
                }else{
                    let error = BackendError.parsing(reason: "Chat option is not available, please try again later")
                    self.showError(error)
                    print("Twilio: Not logged in")
                }
                

            } else {
                showInformationPopup()
            }
        }
    }
    
    fileprivate func setRecentlyViewed() {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            self.showError(LoginError.errorLogin(description: "User does not exist or is not verified"), "Verification")
            return
        }
//        print(event.id)
        Mixpanel.mainInstance().track(event: "RecentlyViewed",
                  properties: ["RecentlyViewed ProductId" : product.id
                                ,"RecentlyViewed ProductType" : product.type])
        RecentlyViewedAPIManager().setRecenltyViewed(type: product.type, id: product.id){response, error in
            if let error = error{
                print(error.localizedDescription );
            }else{
                print(response ?? "Error setting recent value");
            }
        }
    }
    
    func showError(_ error: Error) {
        showErrorPopup(withTitle: "Error", error: error)
    }
    
    func showError(_ error: Error, _ errorTitle:String) {
        showErrorPopup(withTitle: errorTitle, error: error)
    }
    
    func showNetworkActivity() {
        naHUD.show(in: view)
    }
    
    func hideNetworkActivity() {
        naHUD.dismiss()
    }
    
    @objc func tappedOnBack(_ sender:AnyObject) {
//        self.navigationController?.popViewController(animated: true)
        dismiss(animated: true)
    }
    
    @objc func tappedOnHeart(_ sender:AnyObject) {
        //setting the favourite
        self.showNetworkActivity()
        setUnSetFavourites(type: product.type, id: product.id ,isUnSetFavourite: product.isFavourite ?? false) {information, error in
            self.hideNetworkActivity()
            
            if let error = error {
                self.showError(error, "Favorite")
                return
            }
            
            if let informations = information {
                self.product.isFavourite = !(self.product.isFavourite ?? false)
                //checking favourite image red or white
                if (self.product.isFavourite ?? false){
                    self.imgHeart.image = UIImage(named: "heart_red")
                }else{
                    self.imgHeart.image = UIImage(named: "heart_white")
                }
                
//                print("ItemID:\(self.product.id)" + ", ItemType:" + self.product.type  + ", ServerResponse:" + informations)
            } else {
                let error = BackendError.parsing(reason: "Could not obtain tap on heart information")
                self.showError(error, "Favorite")
            }
        }
    }
        
    func setUnSetFavourites(type:String,id:String, isUnSetFavourite: Bool ,completion: @escaping (String?, Error?) -> Void) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            completion(nil, LoginError.errorLogin(description: "User does not exist or is not verified"))
            return
        }
        
        GoLujoAPIManager().setUnSetFavourites(type, id, isUnSetFavourite) { strResponse, error in
            guard error == nil else {
                Crashlytics.crashlytics().record(error: error!)
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
//                let x = max(0, translation.x)
//                let y = max(0, translation.y)                           //it works but with status bar
//                print(x,y)
                if (translation.x > 0){ //to disable swiping from right to left
                    if (panGesture.view == self.view ){
                        slideViewTo(translation.x,0)    //only swipe horizontal if its on main view
                    }else{
                        slideViewTo(translation.x,translation.y)    //swipe both horizontally and vertically if on main image
                    }
                }
//            else{
//                    print ("swiping from right to left")
//                }
//                
                
                self.view.layer.cornerRadius = 12
            case .ended:
                // If pan ended, decide it we should close or reset the view based on the final position and the speed of the gesture
                let translation = panGesture.translation(in: view)
                let velocity = panGesture.velocity(in: view)
                let closing = (translation.y > self.view.frame.size.height * minimumScreenRatioToHide)  //checking on y position
                                || (velocity.y > minimumVelocityToHide)  //checking on y velocity
                                || (translation.x > self.view.frame.size.width * minimumScreenRatioToHide)  //checking on X position
                                || (velocity.x > minimumVelocityToHide) //checking on X velocity

                if closing {
                    self.tappedOnBack(panGesture)
                } else {
                    // If not closing, reset the view to the top
                    UIView.animate(withDuration: animationDuration, animations: {
                        slideViewTo(0,0)
                    })
                }
                self.view.layer.cornerRadius = 0
            default:
                print(panGesture.state)
            }
      }
}

////No need to hide/unhide now as now wer are presenting/dismissing , before we were doing push/pop view controller
extension ProductDetailsViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        hideUnhideNavigationBar(scrollView)
    }

    func hideUnhideNavigationBar(_ scrollView: UIScrollView){
        let hide = scrollView.contentOffset.y < self.scrollOffsetToShowNavigationBar
//        print(scrollView.contentOffset.y,hide)
        //hiding navigation bar if scroll off set is more then 280
//        self.navigationController?.setNavigationBarHidden(hide, animated: true)

    }
}

extension ProductDetailsViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func shouldBeRequiredToFail(by otherGestureRecognizer: UIGestureRecognizer) -> Bool{
        if (otherGestureRecognizer == pgrMainImage){
            return true
        }else{
            return false
        }
    }
}

extension ProductDetailsViewController: UIAdaptivePresentationControllerDelegate {
// Only called when the sheet is dismissed by DRAGGING as well as when tapped on cross button
    public func presentationControllerDidDismiss( _ presentationController: UIPresentationController) {
        if #available(iOS 13, *) {
            //Call viewWillAppear only in iOS 13
            //so that receivedNewMessage should stop calling on AdvanceChatViewController
            ConversationsManager.sharedConversationsManager.delegate = nil
            }
    }
}
