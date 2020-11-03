//
//  RestaurantDetailViewController.swift
//  LUJO
//
//  Created by Iker Kristian on 8/27/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import MapKit

class RestaurantDetailViewController: UIViewController {
    
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "RestaurantDetailViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate(restaurant: Restaurants) -> RestaurantDetailViewController {
        let viewController = UIStoryboard.main.instantiate(identifier) as! RestaurantDetailViewController
        viewController.restaurant = restaurant
        return viewController
    }
    
    //MARK:- Globals
    @IBOutlet var gradientView: UIView!
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
    
    var restaurant: Restaurants!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRestaurant(restaurant)
        //zahoor
        setRecentlyViewed()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activateKeyboardManager()
    }
    
    @IBAction func backButton_onClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func viewGalleryButton_onClick(_ sender: Any) {
        if !restaurant.getAllImagesURL().isEmpty {
            let viewController = GalleryViewControllerNEW.instantiate(dataSource: restaurant.getAllImagesURL())
            present(viewController, animated: true, completion: nil)
        } else {
            showInformationPopup(withTitle: "Info", message: "There are no images in the gallery, sorry!")
        }
    }
    
    @IBAction func viewOnMapButton_onClick(_ sender: Any) {
        
        guard
            let latitudeString = restaurant.latitude,
            let longitudeString = restaurant.longtitude,
            let latitude = Double(latitudeString),
            let longitude = Double(longitudeString)
            else {
                print("🛑 - Error: Missing latitude and logitude for Restaurants with id: \(restaurant.id) and name: \(restaurant.name)")
                return
        }
        
        // Check is there google maps application on the device.
        if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
            
            // Open google maps with provided place.
            let address = restaurant.address.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
            UIApplication.shared.open(URL(string: "comgooglemaps://?q=\(address)&center=\(latitudeString),\(longitudeString)&zoom=14")!,
                                      options: [:],
                                      completionHandler: nil)
            
        } else if UIApplication.shared.canOpenURL(URL(string: "googlechromes://")!) {
            
            // Open google chrome and search google maps with provided place.
            let address = restaurant.address.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
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
    
    fileprivate func setupRestaurant(_ restaurant: Restaurants) {
        
        iPhoneAspectRatioConstraint.isActive = UIDevice.current.userInterfaceIdiom == .phone
        
        if let mediaLink = restaurant.primaryMedia?.mediaUrl, restaurant.primaryMedia?.type == "image" {
            mainImageView.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
        }
        
        if let firstImageLink = restaurant.getAllImagesURL().first {
            firstGalleryImageView.downloadImageFrom(link: firstImageLink, contentMode: .scaleAspectFill)
        }
        nameLabel.text = restaurant.name
        
        descriptionLabel.attributedText = convertToAttributedString(restaurant.description)
        
        starsContainerView.isHidden = restaurant.michelinStar?.first == nil
        starsLabel.text = restaurant.michelinStar?.first?.name.uppercased()
        
        chiefContainerView.isHidden = (restaurant.starChief == nil || restaurant.starChief?.isEmpty ?? true)
        chiefName.text = restaurant.starChief?.uppercased()
        
        var locationString = restaurant.address
        if let locaton = restaurant.location.first {
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
    
    //Zahoor Started
    fileprivate func setRecentlyViewed() {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            self.showError(LoginError.errorLogin(description: "User does not exist or is not verified"))
            return
        }
//        print(event.id)
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
    //Zahoor finished
}
