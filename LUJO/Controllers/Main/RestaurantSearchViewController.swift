//
//  RestaurantSearchViewController.swift
//  LUJO
//
//  Created by Iker Kristian on 8/27/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import CoreLocation
import IQKeyboardManagerSwift
import JGProgressHUD
import Crashlytics
import AVFoundation
import Mixpanel

class RestaurantSearchViewController: UIViewController {
    
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "RestaurantSearchViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate(searchTerm: String? = nil, currentLocation: CLLocation? = nil) -> RestaurantSearchViewController {
        let viewController = UIStoryboard.main.instantiate(identifier) as! RestaurantSearchViewController
        viewController.searchTerm = searchTerm
        viewController.currentLocation = currentLocation
        return viewController
    }
    
    //MARK:- Globals
    
    private let naHUD = JGProgressHUD(style: .dark)

    private var diningInformations: DiningHomeObjects?
    
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var clearButton: UIButton!
    @IBOutlet var collectionView: UICollectionView!
    
    private var currentLayout: LiftLayout?
    private var dataSource: [Restaurant] = []
    
    @IBOutlet weak var noResultsContainerView: UIStackView!
    @IBOutlet weak var noResultsTitleLabel: UILabel!
    @IBOutlet weak var noResultsActionButton: UIButton!
    
    private var searchTerm: String?
    private var currentLocation: CLLocation?
    
    private var keyword: String = "" {
        didSet {
            // Hide results container view on set.
            noResultsContainerView.isHidden = true
            // Update strings on no results title and action button.
            noResultsTitleLabel.text = "We haven't found any results for '\(keyword)'."
            noResultsActionButton.setTitle("SEND A CUSTOM REQUEST FOR '\(keyword.uppercased())'", for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentLayout = collectionView.collectionViewLayout as? LiftLayout
        currentLayout?.setCustomCellHeight(196)
        collectionView.register(UINib(nibName: DiningViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: DiningViewCell.identifier)
        
        title = "Search dining spots"
        searchTextField.text = searchTerm
        if let term = searchTerm {
            searchRestaurants(term: term)
        } else {
            searchTextField.becomeFirstResponder()
        }
        
        // Set action button title label properties.
        noResultsActionButton.titleLabel?.numberOfLines = 0
        noResultsActionButton.titleLabel?.textAlignment = .center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        activateKeyboardManager()
    }
    
    @IBAction func clearButton_onClick(_ sender: Any) {
        searchTextField.text = ""
        searchTextField.becomeFirstResponder()
        dataSource = []
        currentLayout?.clearCache()
        collectionView.reloadData()
        noResultsContainerView.isHidden = true
    }
    
    @IBAction func actionButton_onClick(_ sender: UIButton) {
        startChatWithInitialMessage("Hi Concierge team, I could not find any restaurants when I typed '\(keyword)'. Can you assist?")
    }
    
    fileprivate func presentRestaurantDetailViewController(restaurant: Restaurant) {
        let viewController = RestaurantDetailViewController.instantiate(restaurant: restaurant)
        present(viewController, animated: true, completion: nil)
    }
    
    func update(_ information: DiningHomeObjects?) {
        guard information != nil else {
            return
        }
        
        diningInformations = information
        currentLayout?.clearCache()
        collectionView.reloadData()
    }
    
    func updateSearch(_ information: [Restaurant]?) {
        dataSource = information ?? []
        currentLayout?.clearCache()
        collectionView.reloadData()
        noResultsContainerView.isHidden = !dataSource.isEmpty
    }
    
    func showError(_ error: Error) {
        showErrorPopup(withTitle: "Events Error", error: error)
    }
    
    func showNetworkActivity() {
        naHUD.show(in: view)
    }
    
    func hideNetworkActivity() {
        naHUD.dismiss()
    }
}

extension RestaurantSearchViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiningViewCell.identifier, for: indexPath) as! DiningViewCell
        let model = dataSource[indexPath.row]
        if let mediaLink = model.primaryMedia?.mediaUrl, model.primaryMedia?.type == "image" {
            cell.primaryImage.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
        }
  
        cell.primaryImage.isHidden = false;
        cell.containerView.removeLayer(layerName: "videoPlayer") //removing video player if was added
        var avPlayer: AVPlayer!
        if( model.primaryMedia?.type == "video"){
            //Playing the video
            if let videoLink = URL(string: model.primaryMedia?.mediaUrl ?? ""){
                cell.primaryImage.isHidden = true;

                avPlayer = AVPlayer(playerItem: AVPlayerItem(url: videoLink))
                let avPlayerLayer = AVPlayerLayer(player: avPlayer)
                avPlayerLayer.name = "videoPlayer"
                avPlayerLayer.frame = cell.containerView.bounds
                avPlayerLayer.videoGravity = .resizeAspectFill
                cell.containerView.layer.insertSublayer(avPlayerLayer, at: 0)
                avPlayer.play()
                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem, queue: .main) { _ in
                    avPlayer?.seek(to: CMTime.zero)
                    avPlayer?.play()
                }
            }else
                if let mediaLink = model.primaryMedia?.thumbnail {
                cell.primaryImage.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
            }
        }
        //checking favourite image red or white
        if (model.isFavourite ?? false){
            cell.imgHeart.image = UIImage(named: "heart_red")
        }else{
            cell.imgHeart.image = UIImage(named: "heart_white")
        }
        //Add tap gesture on favourite
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTappedOnHeartAt(_:)))
        cell.viewHeart.isUserInteractionEnabled = true   //can also be enabled from IB
        cell.viewHeart.tag = indexPath.row
        cell.viewHeart.addGestureRecognizer(tapGestureRecognizer)
        
        cell.name.text = model.name
        
        if let city = model.location.first?.city {
            cell.locationContainerView.isHidden = false
            cell.location.text = city.name.uppercased()
        } else {
            cell.locationContainerView.isHidden = true
        }
        
        if let star = model.michelinStar?.first {
            cell.starImageContainerView.isHidden = false
            cell.starCountLabel.text = star.name.uppercased()
        } else {
            cell.starImageContainerView.isHidden = true
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presentRestaurantDetailViewController(restaurant: dataSource[indexPath.row])
    }
}

extension RestaurantSearchViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        keyword = textField.text!
        if keyword.count > 1 {
            textField.resignFirstResponder()
            
            self.searchRestaurants(term: keyword)
            return true
        }
        
        showInformationPopup(withTitle: "Info", message: "Please, enter minimum 2 characters for search.")
        return false
    }
    
}

extension RestaurantSearchViewController {

    func searchRestaurants(term: String) {
        self.showNetworkActivity()
        self.searchRestaurants(term: term) { information, error in
            self.hideNetworkActivity()
            if let error = error {
                self.showError(error)
            }
            self.updateSearch(information)
        }
    }
    
    func searchRestaurants(term: String, completion: @escaping ([Restaurant]?, Error?) -> Void) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            completion(nil, LoginError.errorLogin(description: "User does not exist or is not verified"))
            return
        }
        
        Mixpanel.mainInstance().track(event: "RestaurantSearched",
              properties: ["SearchedText" : term])
        
        GoLujoAPIManager().search(token, term: term, cityId: nil, currentLocation: currentLocation) { restaurants, error in
            guard error == nil else {
                Crashlytics.sharedInstance().recordError(error!)
                let error = BackendError.parsing(reason: "Could not obtain Dining information")
                completion(nil, error)
                return
            }
            completion(restaurants, error)
        }
    }
    
    @objc func didTappedOnHeartAt( _ sender:AnyObject) {
        var item: Restaurant!
        if let index = sender.view?.tag{
            item = dataSource[index]
            
            //setting the favourite
            self.showNetworkActivity()
            setUnSetFavourites(id: item.id ,isUnSetFavourite: item.isFavourite ?? false) {information, error in
                self.hideNetworkActivity()
                
                if let error = error {
                    self.showError(error)
                    return
                }
                
                if let informations = information {
                    self.dataSource[index].isFavourite = !(self.dataSource[index].isFavourite ?? false)
                    self.updateSearch(self.dataSource) //just to reload the grid
                   
    //              PreloadDataManager.HomeScreen.scrollViewData = information
                    print("ItemID:\(item.id)"  + ", ServerResponse:" + informations)
                } else {
                    let error = BackendError.parsing(reason: "Could not obtain tap on heart information")
                    self.showError(error)
                }
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
}
