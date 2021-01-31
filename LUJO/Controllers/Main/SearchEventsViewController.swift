//
//  SearchEventsViewController.swift
//  LUJO
//
//  Created by Iker Kristian on 8/28/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import JGProgressHUD
import IQKeyboardManagerSwift
import Crashlytics
import AVFoundation

class SearchEventsViewController: UIViewController {
    
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "SearchEventsViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate(category: EventCategory) -> SearchEventsViewController {
        let viewController = UIStoryboard.main.instantiate(identifier) as! SearchEventsViewController
        viewController.category = category
        return viewController
    }
    
    //MARK:- Globals
    
    private(set) var category: EventCategory!
    
    @IBOutlet var collectionView: UICollectionView!
    private var dataSource: [Product] = []
    
    private let naHUD = JGProgressHUD(style: .dark)
    
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var clearButton: UIButton!
    private var currentLayout: LiftLayout?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentLayout = collectionView.collectionViewLayout as? LiftLayout
        switch category! {
            case .event:
                currentLayout?.setCustomCellHeight(194)
                title = "Search events"
            case .experience:
                currentLayout?.setCustomCellHeight(170)
                title = "Search experiences"
            case .villa:
                currentLayout?.setCustomCellHeight(170)
                title = "Search villas"
            case .gift:
                currentLayout?.setCustomCellHeight(170)
                title = "Search gifts"
            case .yacht:
                currentLayout?.setCustomCellHeight(170)
                title = "Search yachts"
            case .topRated:
                currentLayout?.setCustomCellHeight(170)
                title = "Search top rated"
            case .recent:
                currentLayout?.setCustomCellHeight(170)
                title = "Search recenlty viewed"
        }
        
        collectionView.register(UINib(nibName: HomeSliderCell.identifier, bundle: nil), forCellWithReuseIdentifier: HomeSliderCell.identifier)
        
        searchTextField.becomeFirstResponder()
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
    }
    
    func update(listOf objects: [Product]) {
        dataSource = objects
//        print("Found \(dataSource.count) items")
        currentLayout?.clearCache()
        collectionView.reloadData()
    }
    
    func showError(_ error: Error) {
        showErrorPopup(withTitle: "Events Error", error: error)
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
}

extension SearchEventsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeSliderCell.identifier, for: indexPath) as! HomeSliderCell
        
        let model = dataSource[indexPath.row]
        if let mediaLink = model.primaryMedia?.mediaUrl, model.primaryMedia?.type == "image" {
            cell.primaryImage.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
        }else if let firstImageLink = model.getGalleryImagesURL().first {
            cell.primaryImage.downloadImageFrom(link: firstImageLink, contentMode: .scaleAspectFill)
        }
        //Zahoor started 20201026
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
        //Zahoor end
        cell.name.text = model.name
        cell.primaryImageHeight.constant = 122
        
        if model.type == "event" {
            cell.dateContainerView.isHidden = false
            
            let startDateText = EventDetailsViewController.convertDateFormate(date: model.startDate!)
            var startTimeText = EventDetailsViewController.timeFormatter.string(from: model.startDate!)
            
            var endDateText = ""
            if let eventEndDate = model.endDate {
                endDateText = EventDetailsViewController.convertDateFormate(date: eventEndDate)
            }
            
            if let timezone = model.timezone {
                startTimeText = "\(startTimeText) (\(timezone))"
            }
            
            cell.date.text = endDateText != "" ? "\(startDateText) - \(endDateText)" : "\(startDateText) \(startTimeText)"
        } else {
            cell.dateContainerView.isHidden = true
        }
        
        if model.tags?.count ?? 0 > 0, let fistTag = model.tags?[0] {
            cell.tagContainerView.isHidden = false
            cell.tagLabel.text = fistTag.name.uppercased()
        } else {
            cell.tagContainerView.isHidden = true
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let event = dataSource[indexPath.row]
        let viewController = EventDetailsViewController.instantiate(event: event)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension SearchEventsViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text?.count ?? 0 > 1 {
            textField.resignFirstResponder()
            self.getInformation(for: category, past: false, term: textField.text)
            return true
        }
        
        showInformationPopup(withTitle: "Info", message: "Please, enter minimum 2 characters for search.")
        return false
    }
    
}

extension SearchEventsViewController {
    
    func getInformation(for category: EventCategory, past: Bool, term: String?) {
        showNetworkActivity()
        getList(for: category, past: past, term: term) { items, error in
            self.hideNetworkActivity()
            if let error = error {
                self.showError(error)
            } else {
                self.update(listOf: items)
            }
        }
    }
    
    func getList(for category: EventCategory, past: Bool, term: String?, completion: @escaping ([Product], Error?) -> Void) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            completion([], LoginError.errorLogin(description: "User does not exist or is not verified"))
            return
        }
        
        switch category {
            case .event:
                EEAPIManager().getEvents(token, past: past, term: term, cityId: nil) { list, error in
                    guard error == nil else {
                        Crashlytics.sharedInstance().recordError(error!)
                        let error = BackendError.parsing(reason: "Could not obtain home events information")
                        completion([], error)
                        return
                    }
                    
                    completion(list, error)
                }
            case .experience:
                EEAPIManager().getExperiences(token, term: term, cityId: nil) { list, error in
                    guard error == nil else {
                        Crashlytics.sharedInstance().recordError(error!)
                        let error = BackendError.parsing(reason: "Could not obtain home experiences information")
                        completion([], error)
                        return
                    }
                    completion(list, error)
                }
            case .villa:
                EEAPIManager().getVillas(token, term: term, cityId: nil) { list, error in
                    guard error == nil else {
                        Crashlytics.sharedInstance().recordError(error!)
                        let error = BackendError.parsing(reason: "Could not obtain home villas information")
                        completion([], error)
                        return
                    }
                    completion(list, error)
                }
            case .gift:
                EEAPIManager().getGoods(token, term: term, cityId: nil) { list, error in
                    guard error == nil else {
                        Crashlytics.sharedInstance().recordError(error!)
                        let error = BackendError.parsing(reason: "Could not obtain home gifts information")
                        completion([], error)
                        return
                    }
                    completion(list, error)
            }
            case .yacht:
                EEAPIManager().getYachts(token, term: term, cityId: nil) { list, error in
                    guard error == nil else {
                        Crashlytics.sharedInstance().recordError(error!)
                        let error = BackendError.parsing(reason: "Could not obtain home yachts information")
                        completion([], error)
                        return
                    }
                    completion(list, error)
            }
            case .topRated:
                EEAPIManager().getYachts(token, term: term, cityId: nil) { list, error in
                    guard error == nil else {
                        Crashlytics.sharedInstance().recordError(error!)
                        let error = BackendError.parsing(reason: "Could not obtain home top rated information")
                        completion([], error)
                        return
                    }
                    completion(list, error)
            }
            case .recent:
                EEAPIManager().getYachts(token, term: term, cityId: nil) { list, error in
                    guard error == nil else {
                        Crashlytics.sharedInstance().recordError(error!)
                        let error = BackendError.parsing(reason: "Could not obtain home recently viewed information")
                        completion([], error)
                        return
                    }
                    completion(list, error)
            }
                
        }
    }
    
    @objc func didTappedOnHeartAt( _ sender:AnyObject) {
        var item: Product!
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
                    self.update(listOf: self.dataSource) //just to reload the grid
                   
    //              PreloadDataManager.HomeScreen.scrollViewData = information
                    print("ItemID:\(item.id)" + ", ItemType:" + item.type  + ", ServerResponse:" + informations)
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
