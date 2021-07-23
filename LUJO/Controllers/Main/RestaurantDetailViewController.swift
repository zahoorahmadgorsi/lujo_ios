//
//  RestaurantDetailViewController.swift
//  LUJO
//
//  Created by Iker Kristian on 8/27/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import MapKit
import JGProgressHUD
import Mixpanel
import Mixpanel

class RestaurantDetailViewController: UIViewController {
    
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "RestaurantDetailViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate(restaurant: Product) -> ProductDetailsViewController {
        let viewController = UIStoryboard.main.instantiate(identifier) as! ProductDetailsViewController
//        viewController.restaurant = restaurant
        return viewController
    }
    
    //MARK:- Globals
    @IBOutlet var gradientView: UIView!
    @IBOutlet weak var ViewMainImage: UIView!
    @IBOutlet var mainImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var starsContainerView: UIView!
    @IBOutlet var starsLabel: UILabel!
    @IBOutlet var chiefContainerView: UIView!
    @IBOutlet var chiefName: UILabel!
    @IBOutlet var cousineLabel: UILabel!
    @IBOutlet var firstGalleryImageView: UIImageView!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var descriptionLabel: UITextView!
    @IBOutlet var iPhoneAspectRatioConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewHeart: UIView!
    @IBOutlet weak var imgHeart: UIImageView!
    private let naHUD = JGProgressHUD(style: .dark)
    
    @IBOutlet weak var btnBack: UIButton!
    var restaurant: Product!
    
    //dismissin on swiping down
    var panGestureRecognizer: UIPanGestureRecognizer?
    var originalPosition: CGPoint?
    var currentPositionTouched: CGPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRestaurant(restaurant)

        //Add tap gesture on favourite
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedOnHeart(_:)))
        self.viewHeart.isUserInteractionEnabled = true   //can also be enabled from IB
        self.viewHeart.addGestureRecognizer(tapGestureRecognizer)
        
        //Addin swipe down pan gesture
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        ViewMainImage.addGestureRecognizer(panGestureRecognizer!)
        
        setRecentlyViewed()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activateKeyboardManager()
    }
    
    @IBAction func tappedOnBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func viewGalleryButton_onClick(_ sender: Any) {
        //if !restaurant.getAllImagesURL().isEmpty {
        if !restaurant.getGalleryImagesURL().isEmpty {
            let viewController = GalleryViewControllerNEW.instantiate(dataSource: restaurant.getGalleryImagesURL())
            present(viewController, animated: true, completion: nil)
        } else {
            showInformationPopup(withTitle: "Info", message: "There are no images in the gallery, sorry!")
        }
    }
    
    @IBAction func viewOnMapButton_onClick(_ sender: Any) {
        
        guard
            let latitudeString = restaurant.latitude,
            let longitudeString = restaurant.longitude,
            let latitude = Double(latitudeString),
            let longitude = Double(longitudeString)
            else {
//                print("🛑 - Error: Missing latitude and logitude for Restaurants with id: \(restaurant.id) and name: \(restaurant.name)")
                return
        }
        
        // Check is there google maps application on the device.
        if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
            
            // Open google maps with provided place.
            let address = restaurant.address?.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
            UIApplication.shared.open(URL(string: "comgooglemaps://?q=\(address)&center=\(latitudeString),\(longitudeString)&zoom=14")!,
                                      options: [:],
                                      completionHandler: nil)
            
        } else if UIApplication.shared.canOpenURL(URL(string: "googlechromes://")!) {
            
            // Open google chrome and search google maps with provided place.
            let address = restaurant.address?.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
            UIApplication.shared.open(URL(string: "googlechromes://www.google.com/maps?q=\(address)&center=\(latitudeString),\(longitudeString)&zoom=14")!,
                                      options: [:],
                                      completionHandler: nil)
            
        } else {
            
            // Open apple maps with provided place.
            let regionDistance: CLLocationDistance = 1000
            let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
            let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = restaurant.name
            mapItem.openInMaps(launchOptions: options)
        }
    }
    
    @IBAction func requestButton_onClick(_ sender: UIButton) {
        let viewController = RestaurantRequestReservationViewController.instantiate(restaurant: restaurant)
        present(viewController, animated: true, completion: nil)
    }
    
    fileprivate func setupRestaurant(_ restaurant: Product) {
        
        iPhoneAspectRatioConstraint.isActive = UIDevice.current.userInterfaceIdiom == .phone
        
        if let mediaLink = restaurant.primaryMedia?.mediaUrl, restaurant.primaryMedia?.type == "image" {
            mainImageView.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
        }
        
        //if let firstImageLink = restaurant.getAllImagesURL().first {
        
        if let firstImageLink = restaurant.getGalleryImagesURL().first {
            firstGalleryImageView.downloadImageFrom(link: firstImageLink, contentMode: .scaleAspectFill)
        }
        nameLabel.text = restaurant.name
        //checking favourite image red or white
        if (self.restaurant.isFavourite ?? false){
            self.imgHeart.image = UIImage(named: "heart_red")
        }else{
            self.imgHeart.image = UIImage(named: "heart_white")
        }
        descriptionLabel.attributedText = convertToAttributedString(restaurant.description)
        
        starsContainerView.isHidden = restaurant.michelinStar?.first == nil
        starsLabel.text = restaurant.michelinStar?.first?.name.uppercased()
        
        chiefContainerView.isHidden = (restaurant.starChief == nil || restaurant.starChief?.isEmpty ?? true)
        chiefName.text = restaurant.starChief?.uppercased()
        
        var locationString = restaurant.address
        if let locaton = restaurant.location?.first {
            if let city = locaton.city {
                locationString = "\(locationString), \(city.name)"
            }
            
            locationString = "\(locationString), \(locaton.country.name)"
        }
        locationLabel.text = locationString
        
        var cousineText = ""
        for cousine in restaurant.cuisineCategory ?? [] {
            cousineText = cousineText.isEmpty ? "\(cousine.name)" : "\(cousineText), \(cousine.name)"
        }
        cousineLabel.text = cousineText.uppercased()
        
        let gradientColors = [UIColor.blackBackgorund.cgColor,
                              UIColor(red: 13 / 255, green: 13 / 255, blue: 13 / 255, alpha: 0.01).cgColor]
        let gradient = CAGradientLayer(start: .bottomCenter, end: .topCenter, colors: gradientColors, type: .axial)
        gradient.frame = CGRect(x: 0, y: 2, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width * (UIDevice.current.userInterfaceIdiom == .pad ? 0.575 : 0.8623) * 0.5)
        gradientView.layer.addSublayer(gradient)
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
    

    fileprivate func setRecentlyViewed() {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            self.showError(LoginError.errorLogin(description: "User does not exist or is not verified"))
            return
        }
//        print(event.id)
        Mixpanel.mainInstance().track(event: "RecentlyViewed",
                  properties: ["RecentlyViewed RestaurantId" : restaurant.id])
        RecentlyViewedAPIManager().setRecenltyViewed(token: token, id: restaurant.id){response, error in
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
        setUnSetFavourites(id: restaurant.id ,isUnSetFavourite: restaurant.isFavourite ?? false) {information, error in
            self.hideNetworkActivity()
            
            if let error = error {
                self.showError(error)
                return
            }
            
            if let informations = information {
                self.restaurant.isFavourite = !(self.restaurant.isFavourite ?? false)
                //checking favourite image red or white
                if (self.restaurant.isFavourite ?? false){
                    self.imgHeart.image = UIImage(named: "heart_red")
                }else{
                    self.imgHeart.image = UIImage(named: "heart_white")
                }
                
                print("ItemID:\(self.restaurant.id), ServerResponse:" + informations)
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
        let minimumScreenRatioToHide: CGFloat = 0.33
        let animationDuration: TimeInterval = 0.2
        
        func slideViewVerticallyTo(_ y: CGFloat) {
            self.view.frame.origin = CGPoint(x: 0, y: y)
        }
        
        switch panGesture.state {
            case .began, .changed:
                // If pan started or is ongoing then slide the view to follow the finger
                let translation = panGesture.translation(in: view)
                let y = max(0, translation.y)
                slideViewVerticallyTo(y)
            case .ended:
                // If pan ended, decide it we should close or reset the view based on the final position and the speed of the gesture
                let translation = panGesture.translation(in: view)
                let velocity = panGesture.velocity(in: view)
                let closing = (translation.y > self.view.frame.size.height * minimumScreenRatioToHide) ||
                              (velocity.y > minimumVelocityToHide)

                if closing {
                    self.tappedOnBack(panGesture)
                } else {
                    // If not closing, reset the view to the top
                    UIView.animate(withDuration: animationDuration, animations: {
                        slideViewVerticallyTo(0)
                    })
                }

            default:
                // If gesture state is undefined, reset the view to the top
                UIView.animate(withDuration: animationDuration, animations: {
                    slideViewVerticallyTo(0)
                })

            }
      }
    
}
