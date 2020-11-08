//
//  FavouritesViewController.swift
//  LUJO
//
//  Created by I MAC on 05/11/2020.
//  Copyright © 2020 Baroque Access. All rights reserved.
//

import UIKit
import JGProgressHUD

class WishListViewController: UIViewController {

    /// Class storyboard identifier.
    class var identifier: String { return "WishListViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate() -> WishListViewController {
        return UIStoryboard.main.instantiate(identifier)
    }
    //MARK:- Globals
    
    private var wishListInformations: WishListObjects?
    private let naHUD = JGProgressHUD(style: .dark)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getWishListInformation(showActivity: true)
    }
    
    /// Refresh control target action that will trigger once user pull to refresh scroll view.
    @objc func refresh(_ sender: AnyObject) {
        // Force data fetch.
        getWishListInformation(showActivity: false)
    }
    
    func getWishListInformation(showActivity: Bool) {
        if showActivity {
            self.showNetworkActivity()
        }
        getWishListInformation() {information, error in
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
    
    func update(_ information: WishListObjects?) {
        guard information != nil else {
            return
        }
        
        wishListInformations = information
        updateContent()

            // -------------------------------------------------------------------------------------
            // Refresh control and data caching.

            // Stop refresh control animation and allow scroll to sieze back refresh control space by
            // scrolling up.
            refreshControl.endRefreshing()

            // Store data for later use inside preload reference.
            //PreloadDataManager.DiningScreen.scrollViewData = information
            // -------------------------------------------------------------------------------------
    }
    
    fileprivate func updateContent() {
//        if let featuredImages = diningInformations?.getFeaturedImages() {
//            featured.imageURLList = featuredImages
//            featured.titleList = diningInformations!.getFeaturedNames()
//            featured.starList = diningInformations!.getFeaturedStars()
//            featured.locationList = diningInformations!.getFeaturedLocations()
//            allImagesNum.text = "\(featuredImages.count)"
//            currentImageNum.text = "1"
//        }
//
//        chiefContainerView.isHidden = diningInformations?.starChief == nil
//        if let starChielf = diningInformations?.starChief {
//            chiefNameLabel.text = starChielf.chiefName.uppercased()
//            chiefImageView.downloadImageFrom(link: starChielf.chiefImage ?? "", contentMode: .scaleAspectFill)
//            starsContainerView.isHidden = starChielf.chiefRestaurant.michelinStar?.first == nil
//            starsLabel.text = starChielf.chiefRestaurant.michelinStar?.first?.name.uppercased()
//            restaurantName.text = starChielf.chiefRestaurant.name
//
//            let gradientColors = [UIColor.blackBackgorund.cgColor,
//                                  UIColor(red: 13 / 255, green: 13 / 255, blue: 13 / 255, alpha: 0.01).cgColor]
//            let gradient = CAGradientLayer(start: .bottomCenter, end: .topCenter, colors: gradientColors, type: .axial)
//            gradient.frame = CGRect(x: 0, y: 2, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width * 0.75 * 0.35)
//            gradientView.layer.addSublayer(gradient)
//        }
//
//        categorySlider.itemsList = diningInformations?.cuisines ?? []
//
//        updatePopularCities()
    }
    
    func getWishListInformation(completion: @escaping (WishListObjects?, Error?) -> Void) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            completion(nil, LoginError.errorLogin(description: "User does not exist or is not verified"))
            return
        }
        
        GoLujoAPIManager().getFavourites(token) { favourites, error in
            guard error == nil else {
                Crashlytics.sharedInstance().recordError(error!)
                let error = BackendError.parsing(reason: "Could not obtain Dining information")
                completion(nil, error)
                return
            }
            completion(favourites, error)
        }
    }
    
    func showError(_ error: Error) {
        showErrorPopup(withTitle: "WishList Error", error: error)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    

}
