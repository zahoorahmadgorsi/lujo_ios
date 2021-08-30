//
//  RestaurantListViewController.swift
//  LUJO
//
//  Created by Nemanja Djurisic on 10/6/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import JGProgressHUD
import Crashlytics
import AVFoundation

class RestaurantListViewController: UIViewController {
    
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "RestaurantListViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate(dataSource: [Product] = [], city: DiningCity? = nil) -> RestaurantListViewController {
        let viewController = UIStoryboard.main.instantiate(identifier) as! RestaurantListViewController
        viewController.dataSource = dataSource
        viewController.city = city
        return viewController
    }
    
    //MARK:- Globals
    
    @IBOutlet weak var collectionView: UICollectionView!
    private var dataSource: [Product]!
    private var city: DiningCity?
    
    private let naHUD = JGProgressHUD(style: .dark)
    private var currentLayout: LiftLayout?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        currentLayout = collectionView.collectionViewLayout as? LiftLayout
        currentLayout?.setCustomCellHeight(196)
        
        collectionView.register(UINib(nibName: DiningViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: DiningViewCell.identifier)
    
        updateContentUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if dataSource.isEmpty, let city = city {
            getInformation(for: city)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    fileprivate func updateContentUI() {
        title = dataSource.count > 0 ? "\(dataSource[0].location?.first?.city?.name ?? "") dining spots" : "\(city?.name ?? "") dining spots"
    }
    
    func showError(_ error: Error) {
        showErrorPopup(withTitle: "Error", error: error)
    }
    
    func showFeedback(_ message: String) {
        showInformationPopup(withTitle: "Information", message: message)
    }
    
    func showNetworkActivity() {
        naHUD.show(in: view)
    }
    
    func hideNetworkActivity() {
        naHUD.dismiss()
    }
    
    func update(listOf objects: [Product]) {
        dataSource = objects
//        print("Found \(dataSource.count) items")
        currentLayout?.clearCache()
        collectionView.reloadData()
    }
    
    func getInformation(for city: DiningCity) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            showFeedback("User does not exist or is not verified")
            return
        }
        
        showNetworkActivity()
        GoLujoAPIManager().search(token, term: nil, cityId: city.termId, currentLocation: nil) { restaurants, error in
            self.hideNetworkActivity()
            if let error = error {
                Crashlytics.sharedInstance().recordError(error)
                self.showError(error)
            } else {
                self.update(listOf: restaurants ?? [])
            }
        }
    }
}

extension RestaurantListViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiningViewCell.identifier, for: indexPath) as! DiningViewCell

        let model = dataSource[indexPath.row]
        if let mediaLink = model.primaryMedia?.mediaUrl, model.primaryMedia?.type == "image" {
            cell.primaryImage.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
        }

        cell.name.text = model.name

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
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTappedOnHeartAt(_:)))
        cell.viewHeart.isUserInteractionEnabled = true   //can also be enabled from IB
        cell.viewHeart.tag = indexPath.row
        cell.viewHeart.addGestureRecognizer(tapGestureRecognizer)

        
        if let city = model.location?.first?.city {
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
        let viewController = ProductDetailsViewController.instantiate(product: dataSource[indexPath.row])
        viewController.delegate = self
        present(viewController, animated: true, completion: nil)
    }
    
    @objc func didTappedOnHeartAt(_ sender:AnyObject) {
        var item: Product!
        let index:Int = sender.view.tag
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
                self.collectionView.reloadData()
                // Store data for later use inside preload reference.
//                        PreloadDataManager.HomeScreen.scrollViewData = information
                print("ItemID:\(item.id)" + ", ServerResponse:" + informations)
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
                let error = BackendError.parsing(reason: "Could not obtain Dining information")
                completion(nil, error)
                return
            }
            completion(strResponse, error)
        }
    }
}

extension RestaurantListViewController : ProductDetailDelegate{
    func tappedOnBookRequest(viewController:UIViewController) {
        // Initialize a navigation controller, with your view controller as its root
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true, completion: nil)
    }
}
