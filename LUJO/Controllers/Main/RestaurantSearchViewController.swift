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
import FirebaseCrashlytics
import AVFoundation
import Mixpanel

class RestaurantSearchViewController: UIViewController {
    
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "RestaurantSearchViewController" }
    
    
    /// Init method that will init and return view controller.
    //class func instantiate(searchTerm: String? = nil, currentLocation: CLLocation? = nil) -> RestaurantSearchViewController {
    class func instantiate(cuisineCategory: Cuisine? = nil, currentLocation: CLLocation? = nil) -> RestaurantSearchViewController {
        let viewController = UIStoryboard.main.instantiate(identifier) as! RestaurantSearchViewController
//        viewController.searchTerm = searchTerm
        viewController.cuisineCategory = cuisineCategory
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
    private var dataSource: [Product] = []
    
    @IBOutlet weak var noResultsContainerView: UIStackView!
    @IBOutlet weak var noResultsTitleLabel: UILabel!
    @IBOutlet weak var noResultsActionButton: UIButton!
    
//    private var searchTerm: String?
    var cuisineCategory:Cuisine?
    private var currentLocation: CLLocation?
    //for paginations
    var pageNumber = 1
    var discoverSearchResponse: DiscoverSearchResponse?

    
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
//        searchTextField.text = searchTerm
//        if let term = searchTerm {
//            keyword = term
//            searchRestaurants(term: term, cityId: nil, currentLocation: nil)
//        }
        if let _cuisineCategory = self.cuisineCategory{
            title = "\(_cuisineCategory.name) Cuisine"
//            searchTextField.text = _cuisineCategory.name
            keyword = _cuisineCategory.name
            //search cuisine by category id
            searchRestaurants(term: nil, cityId: nil, cuisineCategoryId: _cuisineCategory.termId, page: self.pageNumber, perPage: Constants.pageSize)
        }else {
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
        guard let userFirstName = LujoSetup().getLujoUser()?.firstName else { return }
        let initialMessage = """
        Hi Concierge team,
        
        I could not find any restaurants when I typed '\(keyword)'. Can you assist?"
        
        \(userFirstName)
        """
        //Checking if user is able to logged in to Twilio or not, if not then getClient will login
        if ConversationsManager.sharedConversationsManager.getClient() != nil
        {
            let viewController = AdvanceChatViewController()
            viewController.salesforceRequest = SalesforceRequest(id: "-1asdf1234qwer" , type: "restaurant" , name: "Restaurant Searched", sfRequestType: .CUSTOM)
            viewController.initialMessage = initialMessage
            let navController = UINavigationController(rootViewController:viewController)
            UIApplication.topViewController()?.present(navController, animated: true, completion: nil)
        }else{
            let error = BackendError.parsing(reason: "Chat option is not available, please try again later")
            self.showError(error)
            print("Twilio: Not logged in")
        }
        
    }
    
    func showError(_ error: Error) {
        showErrorPopup(withTitle: "Error", error: error)
    }
    
    fileprivate func presentRestaurantDetailViewController(restaurant: Product) {
        let viewController = ProductDetailsViewController.instantiate(product: restaurant)
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
    
    func updateSearch(_ objects: [Product]?) {
//        dataSource = information ?? []
//        currentLayout?.clearCache()
//        collectionView.reloadData()
//        noResultsContainerView.isHidden = !dataSource.isEmpty
        
        //if both dataSource and objects are empty then refreshing grid is throwin exception
        //Terminating app due to uncaught exception 'CALayerInvalidGeometry', reason: 'CALayer position contains NaN
        if dataSource.isEmpty,  let _objects = objects, _objects.isEmpty {
            return
        }
        dataSource = objects ?? []
        DispatchQueue.main.async(execute: collectionView.reloadData)
                                 
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
        if let mediaLink = model.thumbnail?.mediaUrl, model.thumbnail?.mediaType == "image" {
            cell.primaryImage.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
        }
  
        cell.primaryImage.isHidden = false;
        cell.containerView.removeLayer(layerName: "videoPlayer") //removing video player if was added
        var avPlayer: AVPlayer!
        if( model.thumbnail?.mediaType == "video"){
            //Playing the video
            if let videoLink = URL(string: model.thumbnail?.mediaUrl ?? ""){
                cell.primaryImage.isHidden = true;

                avPlayer = AVPlayer(playerItem: AVPlayerItem(url: videoLink))
                let avPlayerLayer = AVPlayerLayer(player: avPlayer)
                avPlayerLayer.name = "videoPlayer"
                avPlayerLayer.frame = cell.containerView.bounds
                avPlayerLayer.videoGravity = .resizeAspectFill
                cell.containerView.layer.insertSublayer(avPlayerLayer, at: 0)
                avPlayer.play()
                avPlayer.isMuted = true // To mute the sound
                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem, queue: .main) { _ in
                    avPlayer?.seek(to: CMTime.zero)
                    avPlayer?.play()
                }
            }else
                if let mediaLink = model.thumbnail?.thumbnail {
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
        
        if let city = model.locations?.city {
            cell.locationContainerView.isHidden = false
            cell.location.text = city.name.uppercased()
        } else {
            cell.locationContainerView.isHidden = true
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print(indexPath.row,collectionView.numberOfItems(inSection: indexPath.section))
        print("totalDocs:\(discoverSearchResponse?.totalDocs)" , "Loaded docs: \((self.pageNumber) * Constants.pageSize)")
        if indexPath.row == collectionView.numberOfItems(inSection: indexPath.section) / 2 ,
           let totalDocs = discoverSearchResponse?.totalDocs, totalDocs > (Constants.pageSize * (self.pageNumber)){   //if half data has been loaded then load rest silently
            print("load next set")
            self.pageNumber += 1
            self.searchRestaurants(term: keyword
                                   ,cityId: nil
                                   ,cuisineCategoryId: self.cuisineCategory?.termId
                                   , page: self.pageNumber
                                   , perPage: Constants.pageSize)
        }
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
            self.pageNumber = 1     //when ever there is a change in text in searchtext then start searching from first page
            self.searchRestaurants(term: keyword,
                                   cityId: nil,
                                   cuisineCategoryId: self.cuisineCategory?.termId
                                   ,page: self.pageNumber
                                   ,perPage: Constants.pageSize)
            return true
        }
        
        showInformationPopup(withTitle: "Info", message: "Please, enter minimum 2 characters for search.")
        return false
    }
    
}

extension RestaurantSearchViewController {

    func searchRestaurants(term: String?, cityId: [String]?, cuisineCategoryId: String?, page: Int, perPage: Int) {
        self.showNetworkActivity()
        self.searchRestaurants(term: term,
                               cityId: cityId,
                               cuisineCategoryId: cuisineCategoryId
                               ,page: self.pageNumber
                               ,perPage: Constants.pageSize) { items, error in
            self.hideNetworkActivity()
            
            var _oldData = self.dataSource
            var _newData = items ?? []
            
            if let error = error {
                self.showError(error)
            }
            
            // if user is fetching next page data so append new data to old data
            if page > 1 {
                for item in _newData{
                    if !_oldData.contains(where: {$0.id == item.id}) {
                        _oldData.append(item)
                    }
                }
            }else{  //for first page newData is current data
                _oldData = _newData
            }
            
            self.updateSearch(_oldData)
        }
    }
    
    func searchRestaurants(term: String?, cityId: [String]?, cuisineCategoryId: String?, page: Int, perPage: Int, completion: @escaping ([Product]?, Error?) -> Void) {
        Mixpanel.mainInstance().track(event: "RestaurantSearched",
              properties: ["SearchedText" : term])
        
        DiningAPIManager().search(term: term,
                                  cityId: cityId,
                                  cuisineCategoryId: cuisineCategoryId
                                  ,page: page
                                  ,perPage: perPage) { list, error in
            guard error == nil else {
                Crashlytics.crashlytics().record(error: error!)
                //unauthorized token, so forcefully signout the user
                if error?._code == 403{
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.logoutUser()
                }else{
                    let error = BackendError.parsing(reason: "Could not search dining information")
                    completion(nil, error)
                }
                return
            }
            self.discoverSearchResponse = list
            completion(list?.docs ?? [], error)
        }
    }
    
    @objc func didTappedOnHeartAt( _ sender:AnyObject) {
        var item: Product!
        if let index = sender.view?.tag{
            item = dataSource[index]
            
            //setting the favourite
            self.showNetworkActivity()
            setUnSetFavourites(type: item.type, id: item.id ,isUnSetFavourite: item.isFavourite ?? false) {information, error in
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
    
    func setUnSetFavourites(type:String, id:String, isUnSetFavourite: Bool ,completion: @escaping (String?, Error?) -> Void) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            completion(nil, LoginError.errorLogin(description: "User does not exist or is not verified"))
            return
        }
        
        GoLujoAPIManager().setUnSetFavourites(type, id, isUnSetFavourite) { strResponse, error in
            guard error == nil else {
                Crashlytics.crashlytics().record(error: error!)
                //unauthorized token, so forcefully signout the user
                if error?._code == 403{
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.logoutUser()
                }else{
                    let error = BackendError.parsing(reason: "Could not set/unset favorites")
                    completion(nil, error)
                }
                return
            }
            completion(strResponse, error)
        }
    }
}
