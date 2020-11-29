//
//  EventDetailsViewController.swift
//  LUJO
//
//  Created by Iker Kristian on 8/28/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit

class EventDetailsViewController: UIViewController {
    
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "EventDetailsViewController" }
    @IBOutlet weak var stackView: UIStackView!
    
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
            case "yacht":           setupExperience(product)
            default: break
        }
        bottomLineViewHeight.constant = UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20 ? 34 : 0
        //zahoor
        setRecentlyViewed()
            
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
            itemsList.append(ProductDetail(key: "Headline",value: val))
        }
        if let val = product.numberOfBedrooms, val.count > 0{
            itemsList.append(ProductDetail(key: "Number Of Bedrooms",value: val))
        }
        if let val = product.numberOfGuests, val.count > 0{
            itemsList.append(ProductDetail(key: "Number Of Guests",value: val))

        }
        if let val = product.numberOfBathrooms, val.count > 0{
            itemsList.append(ProductDetail(key: "Number Of Bathrooms",value: val))
        }
        if let val = product.rentPricePerWeekLowSeason, val.count > 0{
            itemsList.append(ProductDetail(key: "Low Season Weekly Rent",value: val))
        }
        if let val = product.rentPricePerWeekHighSeason, val.count > 0{
            itemsList.append(ProductDetail(key: "High Season Weekly Rent",value: val))
        }
        
        if (itemsList.count > 0){
            let productDetailView: ProductDetailView = {
                let tv = ProductDetailView()
                tv.translatesAutoresizingMaskIntoConstraints = false
                return tv
            }()
            //productDetailView.delegate = self
            productDetailView.itemType = .summary
            productDetailView.lblTitle.text = productDetailView.itemType.rawValue
            productDetailView.itemsList = itemsList
            stackView.addArrangedSubview(productDetailView)
            //applying constraints on wishListView
            setupProductDetailLayout(productDetailView: productDetailView)
        }
        //preparing price data of collection view
        itemsList =  [ProductDetail]()
        if let val = product.price , val > 0.0{
            itemsList.append(ProductDetail(key: "Price",value: String(val)))
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
        var count = (product.villaAmenities?.count ?? 0)
        if count > 0 , let items = product.villaAmenities{
            itemsList =  [ProductDetail]()
            for item in items{
                itemsList.append(ProductDetail(key: "name",value: item.name))
            }
        }
        //preparing facilites data of collection view
        count = (product.villaFacilities?.count ?? 0)
        if count > 0 , let items = product.villaFacilities{
            for item in items{
                itemsList.append(ProductDetail(key: "name",value: item.name))
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
            self.present(YachtViewController.instantiate(event: product), animated: true, completion: nil)
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
    //Zahoor finished
}
