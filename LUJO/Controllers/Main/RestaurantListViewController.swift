//
//  RestaurantListViewController.swift
//  LUJO
//
//  Created by Nemanja Djurisic on 10/6/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import JGProgressHUD
import FirebaseCrashlytics
import AVFoundation

class RestaurantListViewController: UIViewController {
    
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "RestaurantListViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate(dataSource: [Product] = [], city: Cities? = nil) -> RestaurantListViewController {
        let viewController = UIStoryboard.main.instantiate(identifier) as! RestaurantListViewController
        viewController.dataSource = dataSource
        viewController.city = city      //if coming from discover screen
        return viewController
    }
    
    //MARK:- Globals
    
    @IBOutlet weak var collectionView: UICollectionView!
    private var dataSource: [Product]!
    private var city: Cities?
    
    private let naHUD = JGProgressHUD(style: .dark)
    private var currentLayout: LiftLayout?
    //for paginations
    var pageNumber = 1
    var discoverSearchResponse: DiscoverSearchResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        currentLayout = collectionView.collectionViewLayout as? LiftLayout
        currentLayout?.setCustomCellHeight(180)
        
        collectionView.register(UINib(nibName: DiningViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: DiningViewCell.identifier)
    
        updateContentUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        if dataSource.isEmpty, let city = city {
        if let city = city {
            getInformation(showActivity: dataSource.isEmpty, for: city, page: self.pageNumber, perPage: Constants.pageSize)
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
//        title = dataSource.count > 0 ? "\(dataSource[0].locations?.city?.name ?? "") dining spots" : "\(city?.name ?? "") dining spots"
        title = "\(city?.name ?? "") dining spots"
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
    
//    func update(listOf objects: [Product]) {
//        dataSource = objects
////        print("Found \(dataSource.count) items")
//        currentLayout?.clearCache()
//        collectionView.reloadData()
//    }
    
    func update(listOf objects: [Product]) {
        if dataSource.isEmpty{
            dataSource = objects
            DispatchQueue.main.async(execute: collectionView.reloadData)
        }else {  //paging is being applied
            if objects.count > 0{
                for item in objects{
                    //if found then replace, this happens when grid is reloaded incase of set/usset favourite
                    if let row = self.dataSource.firstIndex(where: {$0.id == item.id}) {
                        dataSource[row] = item
                    }else{
                        dataSource.append(item)
                    }
                }
            }else{
                return  //stop it from executing collectionView.reloadData
            }
            
        }
        //        print("Found \(dataSource.count) items")
        currentLayout?.clearCache()
        DispatchQueue.main.async(execute: collectionView.reloadData)
    }
    
    
    func getInformation(showActivity: Bool, for city: Cities, page: Int, perPage: Int) {
        if (showActivity){
            showNetworkActivity()
        }
        DiningAPIManager().search(term: nil, cityId: city.termId == nil ? nil : [city.termId ?? ""], cuisineCategoryId: nil, page:page, perPage:perPage) { list, error in
            self.hideNetworkActivity()
            if let error = error {
                Crashlytics.crashlytics().record(error: error)
                self.showError(error)
            } else {
                self.discoverSearchResponse = list
                self.update(listOf: list?.docs ?? [])
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
        if let mediaLink = model.thumbnail?.mediaUrl, model.thumbnail?.mediaType == "image" {
            cell.primaryImage.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
        }

        cell.name.text = model.name

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
                if let mediaLink = model.thumbnail?.videoThumbnail {
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

        
        if let city = model.locations?.city {
            cell.locationContainerView.isHidden = false
            cell.location.text = city.name.uppercased()
        } else {
            cell.locationContainerView.isHidden = true
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewController = ProductDetailsViewController.instantiate(product: dataSource[indexPath.row])
        present(viewController, animated: true, completion: nil)
    }
    
    @objc func didTappedOnHeartAt(_ sender:AnyObject) {
        var item: Product!
        let index:Int = sender.view.tag
        item = dataSource[index]
        
        //setting the favourite
        self.showNetworkActivity()
        setUnSetFavourites(type: item.type,id: item.id ,isUnSetFavourite: item.isFavourite ?? false) {information, error in
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
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print(indexPath.row,collectionView.numberOfItems(inSection: indexPath.section))
        print("Total Docs: \(self.city?.itemsNum)", "Loaded Docs: \((Constants.pageSize * (self.pageNumber)))")
        if indexPath.row == collectionView.numberOfItems(inSection: indexPath.section) / 2,
           let totalDocs = self.city?.itemsNum, totalDocs > (Constants.pageSize * (self.pageNumber)),
           let _city = self.city {   //if half data has been loaded then load rest silently
            print("load next set")
            self.pageNumber += 1
            getInformation(showActivity: dataSource.isEmpty, for: _city, page: self.pageNumber, perPage: Constants.pageSize)
        }
    }
    
    func setUnSetFavourites(type:String, id:String, isUnSetFavourite: Bool ,completion: @escaping (String?, Error?) -> Void) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            completion(nil, LoginError.errorLogin(description: "User does not exist or is not verified"))
            return
        }
        
        GoLujoAPIManager().setUnSetFavourites(type,id, isUnSetFavourite) { strResponse, error in
            guard error == nil else {
                Crashlytics.crashlytics().record(error: error!)
                //unauthorized token, so forcefully signout the user
                if error?._code == 403{
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.logoutUser()
                }else{
                    let error = BackendError.parsing(reason: "Could not update favorites information at dining")
                    completion(nil, error)
                }
                return
            }
            completion(strResponse, error)
        }
    }
}
