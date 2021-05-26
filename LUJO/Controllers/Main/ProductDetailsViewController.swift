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
import Intercom

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
       
        switch product.type {
            case "event":           fallthrough
            case "special-event":   setupEvents(product)
            case "gift":            fallthrough
            case "experience":      setupExperience(product)
            case "yacht":           setupYacht(product)
            case "villa":           setupVilla(product)
            default:
                setupEvents(product)//("It could be restaurant")
                break
        }
        //setting up gallery
        setUpGallery(product)
        
        scrollView.delegate = self
        if let font = descriptionTextView.font{
            let currentHeight = getTextViewHeight(text: descriptionTextView.text, width: descriptionTextView.bounds.width, font: font )
//            print(currentHeight,descHeightToShowReadMore)
                if (currentHeight > descHeightToShowReadMore){
                    viewReadMore.isHidden = false
                    lblDescriptionHeight.constant = descHeightToShowReadMore
                }else{
                    viewReadMore.isHidden = true  //no need to show readmore button
                    lblDescriptionHeight.constant = currentHeight
                }
        }
        
        
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
        pgrFullView  = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        ViewMainImage.addGestureRecognizer(pgrMainImage!)   //applying pan gesture on main image
        self.view.addGestureRecognizer(pgrFullView!)        //applying pan gesture on full main view
        setRecentlyViewed()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activateKeyboardManager()
        //No need to hide/unhide now as now wer are presenting/dismissing , before we were doing push/pop view controller
//        self.navigationController?.setNavigationBarHidden(true, animated: true)
//        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //No need to hide/unhide now as now wer are presenting/dismissing , before we were doing push/pop view controller
//        self.navigationController?.setNavigationBarHidden(false, animated: true)
//        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func requestBooking(_ sender: Any) {
        sendInitialInformation()
    }
    
    func didTappedOnImage(itemIndex: Int) {
        print("didTappedOnImage")
    }
    
    @IBAction func viewGalleryButton_onClick(_ sender: UIButton) {
        didTappedOnViewGallery()
    }
    
    func didTappedOnViewGallery() {
        let dataSource = product.getGalleryImagesURL()
        if dataSource.isEmpty {
            showInformationPopup(withTitle: "Info", message: "There are no images in the gallery, sorry!")
        } else {
            let viewController = GalleryViewControllerNEW.instantiate(dataSource: dataSource)
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
        if let mediaLink = product.primaryMedia?.mediaUrl, product.primaryMedia?.type == "image" {
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
        if let cityName = product.location?.first?.city?.name {
            locationText += "\(cityName), "
        }
        locationText += product.location?.first?.country.name ?? ""
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
        if let mediaLink = product.primaryMedia?.mediaUrl, product.primaryMedia?.type == "image" {
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
        if let cityName = product.location?.first?.city?.name {
            locationText = "\(cityName), "
        }
        locationText += product.location?.first?.country.name ?? ""
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
        if let mediaLink = product.primaryMedia?.mediaUrl, product.primaryMedia?.type == "image" {
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
        if let cityName = product.location?.first?.city?.name {
            locationText = "\(cityName), "
        }
        locationText += product.location?.first?.country.name ?? ""
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
        if let val = product.numberOfBedrooms, val.count > 0{
            itemsList.append(ProductDetail(key: "Number Of Bedrooms",value: val,isHighSeason: nil))
//            itemsList.append(ProductDetail(key: "No. Of Bedrooms",value: val,isHighSeason: nil))
            lblYachtCabins.text = val
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
        if let val = product.numberOfBathrooms, val.count > 0{
            itemsList.append(ProductDetail(key: "Number Of Bathrooms",value: val,isHighSeason: nil))
//            itemsList.append(ProductDetail(key: "No. Of Bathrooms",value: val,isHighSeason: nil))
            lblBathrooms.text = val
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
                itemsList.append(ProductDetail(key: "name",value: item.name,isHighSeason: nil))
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
        if let mediaLink = product.primaryMedia?.mediaUrl, product.primaryMedia?.type == "image" {
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
        if let cityName = product.location?.first?.city?.name {
            locationText = "\(cityName), "
        }
        locationText += product.location?.first?.country.name ?? ""
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
        if let val = product.buildYear, val.count > 0{
            itemsList.append(ProductDetail(key: "Build Year",value: val,isHighSeason: nil))
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
    
        if let val = product.charterPriceHighSeasonPerDay, val.count > 0{
            itemsList.append(ProductDetail(key: "Daily Charter",value: "$" + val.withCommas() ,isHighSeason: true)) // high season
//            itemsList.append(ProductDetail(key: "Daily Charter",value:  val,isHighSeason: true)) // high season
        }
        if let val = product.charterPriceHighSeasonPerWeek, val.count > 0{
            itemsList.append(ProductDetail(key: "Weekly Charter",value: "$" + val.withCommas() ,isHighSeason: true)) // high season
//            itemsList.append(ProductDetail(key: "Weekly Charter",value: val,isHighSeason: true)) // high season
        }
        
        if let val = product.charterPriceLowSeasonPerDay, val.count > 0{
            itemsList.append(ProductDetail(key: "Daily Charter",value: "$" + val.withCommas() ,isHighSeason: false)) // low season
//            itemsList.append(ProductDetail(key: "Daily Charter",value: val,isHighSeason: false)) // low season
        }
        
        if let val = product.charterPriceLowSeasonPerWeek, val.count > 0{
            itemsList.append(ProductDetail(key: "Weekly Charter",value: "$" + val.withCommas() ,isHighSeason: false)) //low season
//            itemsList.append(ProductDetail(key: "Weekly Charter",value: val,isHighSeason: false)) //low season
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
        switch product.gallery?.count {
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
        let range = NSRange(location: 0, length: text.count)
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
    
    fileprivate func sendInitialInformation() {
        if (product.type == "yacht"){
            self.present(YachtViewController.instantiate(product: product), animated: true, completion: nil)
        }else if (product.type == "villa"){
            self.present(VillaViewController.instantiate(product: product), animated: true, completion: nil)
        }else if(product.type == "restaurant"){
            let viewController = RestaurantRequestReservationViewController.instantiate(restaurant: product)
            present(viewController, animated: true, completion: nil)
        }
        else{
            guard let userFirstName = LujoSetup().getLujoUser()?.firstName else { return }
            
            EEAPIManager().sendRequestForSalesForce(itemId: product.id){ customBookingResponse, error in
                guard error == nil else {
                    Crashlytics.sharedInstance().recordError(error!)
                    BackendError.parsing(reason: "Could not obtain the salesforce_id")
                    return
                }
                //https://developers.intercom.com/installing-intercom/docs/ios-configuration
                if let user = LujoSetup().getLujoUser(), user.id > 0 {
                    Intercom.logEvent(withName: "custom_request", metaData:[
                                        "sales_force_yacht_intent_id": customBookingResponse?.salesforceId ?? "NoSalesForceId"
                                        ,"user_id":user.id])
                }
            }
            
            Mixpanel.mainInstance().track(event: "Product Custom Request",
                                          properties: ["Product Name" : product.name
                                                       ,"Product Type" : product.type
                                                       ,"ProductId" : product.id])
            
            let initialMessage = """
            Hi Concierge team,
            
            I am interested in \(product.name), can you assist me?
            
            \(userFirstName)
            """
            
            startChatWithInitialMessage(initialMessage)
        }
        
    }
    
    fileprivate func setRecentlyViewed() {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            self.showError(LoginError.errorLogin(description: "User does not exist or is not verified"))
            return
        }
//        print(event.id)
        Mixpanel.mainInstance().track(event: "RecentlyViewed",
                  properties: ["RecentlyViewed ProductId" : product.id
                                ,"RecentlyViewed ProductType" : product.type])
        RecentlyViewedAPIManager().setRecenltyViewed(token: token, id: product.id){response, error in
            if let error = error{
                print(error.localizedDescription );
            }else{
                print(response ?? "Error setting recent value");
            }
        }
    }
    
    func showError(_ error: Error) {
        showErrorPopup(withTitle: "Recently Viewed Error", error: error)
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
        setUnSetFavourites(id: product.id ,isUnSetFavourite: product.isFavourite ?? false) {information, error in
            self.hideNetworkActivity()
            
            if let error = error {
                self.showError(error)
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
//        let statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        
        func slideViewTo(_ x: CGFloat ,_ y: CGFloat) {
                self.view.frame.origin = CGPoint(x: x, y: y)

        }
        
        switch panGesture.state {
            //case .began, .changed:
            case .changed:
                // If pan started or is ongoing then slide the view to follow the finger
                let translation = panGesture.translation(in: view)
                let x = max(0, translation.x)
                let y = max(0, translation.y)                           //it works but with status bar
                print(x,y)
                if (translation.x > 0){ //to disable swiping from right to left
                    if (panGesture.view == self.view ){
                        slideViewTo(translation.x,0)    //only swipe horizontal if its on main view
                    }else{
                        slideViewTo(translation.x,translation.y)    //swipe both horizontally and vertically if on main image
                    }
                }else{
                    print ("swiping from right to left")
                }
                
                
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
