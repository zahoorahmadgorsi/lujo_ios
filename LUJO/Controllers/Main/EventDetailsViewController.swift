//
//  EventDetailsViewController.swift
//  LUJO
//
//  Created by Iker Kristian on 8/28/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import JGProgressHUD

class EventDetailsViewController: UIViewController {
    
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "EventDetailsViewController" }
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var lblDescriptionHeight: NSLayoutConstraint!
    var isLabelAtMaxHeight = false
    
    @IBOutlet weak var viewReadMore: UIView!
    @IBOutlet weak var btnReadMore: UIButton!
    var descHeightToShowReadMore:CGFloat = 70.0
    /// Init method that will init and return view controller.
    class func instantiate(event: Product) -> EventDetailsViewController {
        let viewController = UIStoryboard.main.instantiate(identifier) as! EventDetailsViewController
        viewController.product = event
        return viewController
    }
    
    //MARK:- Globals
    
    private(set) var product: Product!
    
    @IBOutlet var mainImageView: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var dateLocationContainerView: UIView!
    @IBOutlet var dateContainerView: UIView!
    @IBOutlet var locationContainerView: UIView!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        switch product.type {
            case "event":           fallthrough
            case "special-event":   setupEvents(product)
            case "experience":      setupExperience(product)
            case "villa":           setupVilla(product)
            case "gift":            setupExperience(product)
            case "yacht":           setupYacht(product)
            default: break
        }
        
        if let font = descriptionTextView.font{
            let currentHeight = getTextViewHeight(text: descriptionTextView.text, width: descriptionTextView.bounds.width, font: font )
            print(currentHeight,descHeightToShowReadMore)
            if (product.type == "villa" || product.type == "yacht"){
                if (currentHeight > descHeightToShowReadMore){
                    viewReadMore.isHidden = false
                    lblDescriptionHeight.constant = descHeightToShowReadMore
                }else{
                    viewReadMore.isHidden = true
                    lblDescriptionHeight.constant = currentHeight
                }
            }else{
                lblDescriptionHeight.constant = currentHeight
                viewReadMore.isHidden = true
            }
        }
        
        
        bottomLineViewHeight.constant = UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20 ? 34 : 0
        //zahoor start
        //setting tapping event on viewheart
        //Add tap gesture on favourite
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedOnHeart(_:)))
        self.viewHeart.isUserInteractionEnabled = true   //can also be enabled from IB
        self.viewHeart.addGestureRecognizer(tapGestureRecognizer)
        
        setRecentlyViewed()
        //zahoor end
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activateKeyboardManager()
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func requestBooking(_ sender: Any) {
        sendInitialInformation()
    }
    
    @IBAction func viewGalleryButton_onClick(_ sender: UIButton) {
        presentGalleryViewControllerIfNeeded()
    }
    
    private func presentGalleryViewControllerIfNeeded() {
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
                    print(currentHeight,descHeightToShowReadMore)
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

extension EventDetailsViewController {
    
    fileprivate func setupEvents(_ event: Product) {
        // imagesList.imageURLList = event.allImages ?? []
        if let firstImageLink = event.getGalleryImagesURL().first {
            mainImageView.downloadImageFrom(link: firstImageLink, contentMode: .scaleAspectFill)
        }else{
            print("Image not found")
        }
        name.text = event.name

        //checking favourite image red or white
        if (self.product.isFavourite ?? false){
            self.imgHeart.image = UIImage(named: "heart_red")
        }else{
            self.imgHeart.image = UIImage(named: "heart_white")
        }
        
        var locationText = ""
        if let cityName = event.location?.first?.city?.name {
            locationText = "\(cityName), "
        }
        locationText += event.location?.first?.country.name ?? ""
        locationLabel.text = locationText.uppercased()
        locationContainerView.isHidden = locationText.isEmpty
        
        var startDateText = ""
        var startTimeText = ""
        
        if let startDate = event.startDate {
            startDateText = EventDetailsViewController.convertDateFormate(date: startDate)
            startTimeText = EventDetailsViewController.timeFormatter.string(from: startDate)
        }
        
        var endDateText = ""
        if let eventEndDate = event.endDate {
            endDateText = EventDetailsViewController.convertDateFormate(date: eventEndDate)
        }
        
        if let timezone = event.timezone {
            startTimeText = "\(startTimeText) (\(timezone))"
        }
        
        if event.startDate != nil {
            dateLabel.text = endDateText != "" ? "\(startDateText) - \(endDateText)" : "\(startDateText) \(startTimeText)"
        }
        
        dateContainerView.isHidden = event.startDate == nil
        dateLocationContainerView.isHidden = event.startDate == nil && locationText.isEmpty
        descriptionTextView.attributedText = convertToAttributedString(event.description)
        
        chatButton.isEnabled = !isEventPast
        requestButton.isEnabled = !isEventPast
        if event.type == "special-event" {
            requestButton.setTitle("R E Q U E S T", for: .normal)
        }
        
        if isEventPast {
            requestButton.setDisabled()
        }
    }
    
    fileprivate func setupExperience(_ experience: Product) {
        if let firstImageLink = experience.getGalleryImagesURL().first {
            mainImageView.downloadImageFrom(link: firstImageLink, contentMode: .scaleAspectFill)
        } else if let primaryImageLink = experience.primaryMedia?.mediaUrl{
            mainImageView.downloadImageFrom(link: primaryImageLink, contentMode: .scaleAspectFill)
        }
        
        name.text = experience.name

        
        var locationText = ""
        if let cityName = experience.location?.first?.city?.name {
            locationText = "\(cityName), "
        }
        locationText += experience.location?.first?.country.name ?? ""
        locationLabel.text = locationText.uppercased()
        
        dateContainerView.isHidden = true
        
        descriptionTextView.attributedText = convertToAttributedString(experience.description)
        requestButton.setTitle("R E Q U E S T", for: .normal)
    }
    
    fileprivate func setupVilla(_ product: Product) {
        if let firstImageLink = product.getGalleryImagesURL().first {
            mainImageView.downloadImageFrom(link: firstImageLink, contentMode: .scaleAspectFill)
        } else if let primaryImageLink = product.primaryMedia?.mediaUrl{
            mainImageView.downloadImageFrom(link: primaryImageLink, contentMode: .scaleAspectFill)
        }
        
        name.text = product.name

        
        var locationText = ""
        if let cityName = product.location?.first?.city?.name {
            locationText = "\(cityName), "
        }
        locationText += product.location?.first?.country.name ?? ""
        locationLabel.text = locationText.uppercased()
        
        dateContainerView.isHidden = true
        //preparing summary data of collection view
        var itemsList =  [ProductDetail]()
        if let val = product.headline , val.count > 0{
            itemsList.append(ProductDetail(key: "Headline",value: val,isHighSeason: nil))
        }
        if let val = product.numberOfBedrooms, val.count > 0{
            itemsList.append(ProductDetail(key: "Number Of Bedrooms",value: val,isHighSeason: nil))
        }
        if let val = product.numberOfGuests, val.count > 0{
            itemsList.append(ProductDetail(key: "Number Of Guests",value: val,isHighSeason: nil))

        }
        if let val = product.numberOfBathrooms, val.count > 0{
            itemsList.append(ProductDetail(key: "Number Of Bathrooms",value: val,isHighSeason: nil))
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
        if let val = product.rentPricePerWeekLowSeason, val.count > 0{
            itemsList.append(ProductDetail(key: "Weekly Rent",value: "$" + val,isHighSeason: false)) // Low Season
        }
        if let val = product.rentPricePerWeekHighSeason, val.count > 0{
            itemsList.append(ProductDetail(key: "Weekly Rent",value: "$" + val,isHighSeason: true)) //High Season
        }
        if let val = product.salePrice , val.count > 0{
            itemsList.append(ProductDetail(key: "Sale Price",value: "$" + val,isHighSeason: nil))
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
        if let firstImageLink = product.getGalleryImagesURL().first {
            mainImageView.downloadImageFrom(link: firstImageLink, contentMode: .scaleAspectFill)
        } else if let primaryImageLink = product.primaryMedia?.mediaUrl{
            mainImageView.downloadImageFrom(link: primaryImageLink, contentMode: .scaleAspectFill)
        }
        
        name.text = product.name
        
        var locationText = ""
        if let cityName = product.location?.first?.city?.name {
            locationText = "\(cityName), "
        }
        locationText += product.location?.first?.country.name ?? ""
        locationLabel.text = locationText.uppercased()
        
        dateContainerView.isHidden = true
        //preparing summary data of collection view
        var itemsList =  [ProductDetail]()
//        if let val = product.headline , val.count > 0{
//            itemsList.append(ProductDetail(key: "Headline",value: val))
//        }
        if let val = product.guestsNumber, val.count > 0{
            itemsList.append(ProductDetail(key: "Number Of Guests",value: val,isHighSeason: nil))
        }
        if let val = product.cabinNumber, val.count > 0{
            itemsList.append(ProductDetail(key: "Number Of Cabins",value: val,isHighSeason: nil))
        }
        if let val = product.crewNumber, val.count > 0{
            itemsList.append(ProductDetail(key: "Number Of Crews",value: val,isHighSeason: nil))
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
        }
        if let val = product.topSpeedKnot, val.count > 0{
            itemsList.append(ProductDetail(key: "Top Speed (Knots)",value: val,isHighSeason: nil))
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
        
        if let val = product.charterPriceLowSeasonPerWeek, val.count > 0{
            itemsList.append(ProductDetail(key: "Weekly Charter",value: "$" + val,isHighSeason: false)) //low season
        }
        if let val = product.charterPriceHighSeasonPerWeek, val.count > 0{
            itemsList.append(ProductDetail(key: "Weekly Charter",value: "$" + val,isHighSeason: true)) // high season
        }
        if let val = product.charterPriceLowSeasonPerDay, val.count > 0{
            itemsList.append(ProductDetail(key: "Daily Charter",value: "$" + val,isHighSeason: false)) // low season
        }
        if let val = product.charterPriceHighSeasonPerDay, val.count > 0{
            itemsList.append(ProductDetail(key: "Daily Charter",value: "$" + val,isHighSeason: true)) // high season
        }
        if let val = product.salePrice , val.count > 0{
            itemsList.append(ProductDetail(key: "Sale Price",value: "$" + val,isHighSeason: nil))
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
        var count = (product.yachtExtras?.count ?? 0)
        if count > 0 , let items = product.yachtExtras{
            itemsList =  [ProductDetail]()
            for item in items{
                itemsList.append(ProductDetail(key: "name",value: item.name,isHighSeason: nil))
            }
        }
//        //preparing facilites(yachtStatus) data of collection view
//        count = (product.yachtStatus?.count ?? 0)
//        if count > 0 , let items = product.yachtStatus{
//            for item in items{
//                itemsList.append(ProductDetail(key: "name",value: item.name))
//            }
//        }
//        //preparing facilites (yachtType) data of collection view
//        count = (product.yachtType?.count ?? 0)
//        if count > 0 , let items = product.yachtType{
//            for item in items{
//                itemsList.append(ProductDetail(key: "name",value: item.name))
//            }
//        }
        
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
    
    func setupProductDetailLayout(productDetailView:ProductDetailView){
        productDetailView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
        productDetailView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
        //top isnt required as in stack view it doesnt matter
        //wishListView.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 100).isActive = true
        productDetailView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
//        print(itemHeight)
        let collectionViewHeight = productDetailView.collectionView.collectionViewLayout.collectionViewContentSize.height
        let totalHeight = Int(collectionViewHeight/2) + (ProdCollSize.itemMargin.rawValue*2)+30 // 30 is height of "Title" control
        print(totalHeight)
        productDetailView.heightAnchor.constraint(equalToConstant: CGFloat(totalHeight)).isActive = true
    }
    
    static func convertDateFormate(date: Date) -> String {
        let calendar = Calendar.current
        let anchorComponents = calendar.dateComponents([.day, .month, .year], from: date)
        
        let newDate = EventDetailsViewController.dateFormatter.string(from: date)
        let dateDay = EventDetailsViewController.numberFormatter.string(from: NSNumber(value: anchorComponents.day!))
        
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
    
}

// Chat functionality
extension EventDetailsViewController {
    
    fileprivate func sendInitialInformation() {
        let isEqual = (product.type == "yacht")
        if !isEqual{
            guard let userFirstName = LujoSetup().getLujoUser()?.firstName else { return }
            
            EEAPIManager().sendRequestForSalesForce(itemId: product.id)
            
            let initialMessage = """
            Hi Concierge team,
            
            I am interested in \(product.name), can you assist me?
            
            \(userFirstName)
            """
            
            startChatWithInitialMessage(initialMessage)
        }else{  //yacht
            self.present(YachtViewController.instantiate(product: product), animated: true, completion: nil)
        }
        
    }
    
    //Zahoor Started
    fileprivate func setRecentlyViewed() {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            self.showError(LoginError.errorLogin(description: "User does not exist or is not verified"))
            return
        }
//        print(event.id)
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
                    
                    print("ItemID:\(self.product.id)" + ", ItemType:" + self.product.type  + ", ServerResponse:" + informations)
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
    
    
    //Zahoor finished
}
