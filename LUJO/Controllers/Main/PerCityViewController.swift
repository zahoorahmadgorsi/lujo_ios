//
//  PerCityViewController.swift
//  LUJO
//
//  Created by hafsa lodhi on 24/01/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//


import UIKit
import JGProgressHUD
import Crashlytics
import AVFoundation

class PerCityViewController: UIViewController {
    
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "PerCityViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate(category: EventCategory, dataSource: PerCityObjects? = nil, city: DiningCity? = nil) -> PerCityViewController {
        let viewController = UIStoryboard.main.instantiate(identifier) as! PerCityViewController
        viewController.category = category
        viewController.dataSource = dataSource
        viewController.city = city
        return viewController
    }
    
    //MARK:- Globals
    
    private(set) var category: EventCategory!
    private var city: DiningCity?
    
    @IBOutlet var collectionView: UICollectionView!
    private var dataSource: PerCityObjects!
    
    private let naHUD = JGProgressHUD(style: .dark)
    
    private var currentLayout: LiftLayout?
    
    @IBOutlet weak var btnFilter: UIButton!
    @IBOutlet weak var collFilters: UICollectionView!
    private var filtersDataSource: [Product]!
    @IBOutlet weak var svPerCity: UIStackView!
    @IBOutlet var homeTopRatedSlider: HomeSlider!
    private var homeObjects: PerCityObjects?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem?.title = ""
//        currentLayout = collectionView.collectionViewLayout as? LiftLayout
//        switch category! {
//            case .event:
//                currentLayout?.setCustomCellHeight(194)
//            case .experience:
//                currentLayout?.setCustomCellHeight(170)
//            case .villa:
//                currentLayout?.setCustomCellHeight(170)
//            case .gift:
//                currentLayout?.setCustomCellHeight(170)
//            case .yacht:
//                currentLayout?.setCustomCellHeight(170)
//            case .recent:
//                currentLayout?.setCustomCellHeight(170)
//            case .topRated:
//                currentLayout?.setCustomCellHeight(170)
//        }
//
//        collectionView.register(UINib(nibName: HomeSliderCell.identifier, bundle: nil), forCellWithReuseIdentifier: HomeSliderCell.identifier)
        
        homeTopRatedSlider.delegate = self
        
        updateContentUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if homeObjects == nil { //home objects will be nill if loading it for the first time
            getInformation(for: category)
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
    
    @IBAction func eventTypeChanged(_ sender: Any) {
        getInformation(for: category)
    }
    
    @IBAction func searchBarButton_onClick(_ sender: Any) {
        navigationController?.pushViewController(SearchEventsViewController.instantiate(category: category), animated: true)
    }
    
    fileprivate func updateContentUI() {
        if dataSource != nil || city != nil {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        var titleString = category.rawValue
        
//        if dataSource.count > 0 {
//            titleString = "\(dataSource[0].location?.first?.city?.name ?? "") \(category == EventCategory.experience ? "experiances" : "events")"
//        } else if let city = city {
//            titleString = "\(city.name) \(category == EventCategory.experience ? "experiances" : "events")"
//        }
        
        title = titleString
//        naHUD.textLabel.text = "Loading " + category.rawValue
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
    
    func update(listOf information: PerCityObjects?) {
        guard information != nil else {
            homeTopRatedSlider.itemsList = []
            return
        }
        homeObjects = information
        updateContent()
    }
    
    fileprivate func updateContent() {
        homeTopRatedSlider.itemsList = homeObjects?.topRated ?? []
        updatePopularCities()
    }
    
    func updatePopularCities() {
        for city in homeObjects?.cities ?? [] {
            switch city.itemsNum {
            case 0:
                print("No city to show")
            case 1:
                if let cityView = svPerCity.arrangedSubviews.first(where: { ($0 as? CityView1)?.city?.termID == city.termID && $0.tag != 999 }) {
                        cityView.removeFromSuperview() //remove if already added
                }
                let cityView = CityView1()
                cityView.city = city
                cityView.delegate = self
                svPerCity.addArrangedSubview(cityView)
            case 2:
                if let cityView = svPerCity.arrangedSubviews.first(where: { ($0 as? CityView2)?.city?.termID == city.termID && $0.tag != 999 }) {
                        cityView.removeFromSuperview() //remove if already added
                }
                let cityView = CityView2()
                cityView.city = city
                cityView.delegate = self
                svPerCity.addArrangedSubview(cityView)
            case 3:
                if let cityView = svPerCity.arrangedSubviews.first(where: { ($0 as? CityView3)?.city?.termID == city.termID && $0.tag != 999 }) {
                        cityView.removeFromSuperview() //remove if already added
                }
                let cityView = CityView3()
                cityView.city = city
                cityView.delegate = self
                svPerCity.addArrangedSubview(cityView)
            default:
                if let cityView = svPerCity.arrangedSubviews.first(where: { ($0 as? CityView4)?.city?.termID == city.termID && $0.tag != 999 }) {
                        cityView.removeFromSuperview() //remove if already added
                }
                let cityView = CityView4()
                cityView.city = city
                cityView.delegate = self
                svPerCity.addArrangedSubview(cityView)
            
                print("Default is 4 and above")
            }
        }
    }
    
    @IBAction func seeAllTopRatedButton_onClick(_ sender: UIButton) {
        let viewController = EventsViewController.instantiate(category: .topRated, subCategory: self.category)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension PerCityViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return dataSource.count
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeSliderCell.identifier, for: indexPath) as! HomeSliderCell
        
//        let model = dataSource[indexPath.row]
//        if let mediaLink = model.primaryMedia?.mediaUrl, model.primaryMedia?.type == "image" {
//            cell.primaryImage.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
//        }else if let firstImageLink = model.getGalleryImagesURL().first {
//            cell.primaryImage.downloadImageFrom(link: firstImageLink, contentMode: .scaleAspectFill)
//        }
//        //Zahoor started 20201026
//        cell.primaryImage.isHidden = false;
//        cell.containerView.removeLayer(layerName: "videoPlayer") //removing video player if was added
//        var avPlayer: AVPlayer!
//        if( model.primaryMedia?.type == "video"){
//            //Playing the video
//            if let videoLink = URL(string: model.primaryMedia?.mediaUrl ?? ""){
//                cell.primaryImage.isHidden = true;
//
//                avPlayer = AVPlayer(playerItem: AVPlayerItem(url: videoLink))
//                let avPlayerLayer = AVPlayerLayer(player: avPlayer)
//                avPlayerLayer.name = "videoPlayer"
//                avPlayerLayer.frame = cell.containerView.bounds
//                avPlayerLayer.videoGravity = .resizeAspectFill
//                cell.containerView.layer.insertSublayer(avPlayerLayer, at: 0)
//                avPlayer.play()
//                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem, queue: .main) { _ in
//                    avPlayer?.seek(to: CMTime.zero)
//                    avPlayer?.play()
//                }
//            }else
//                if let mediaLink = model.primaryMedia?.thumbnail {
//                cell.primaryImage.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
//            }
//        }
//        //checking favourite image red or white
//        if (model.isFavourite ?? false){
//            cell.imgHeart.image = UIImage(named: "heart_red")
//        }else{
//            cell.imgHeart.image = UIImage(named: "heart_white")
//        }
//        //Add tap gesture on favourite
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTappedOnHeartAt(_:)))
//        cell.viewHeart.isUserInteractionEnabled = true   //can also be enabled from IB
//        cell.viewHeart.tag = indexPath.row
//        cell.viewHeart.addGestureRecognizer(tapGestureRecognizer)
//        //Zahoor end
//
//        cell.name.text = model.name
//        cell.primaryImageHeight.constant = 122
//
//        if model.type == "event" {
//            cell.dateContainerView.isHidden = false
//
//            let startDateText = EventDetailsViewController.convertDateFormate(date: model.startDate!)
//            var startTimeText = EventDetailsViewController.timeFormatter.string(from: model.startDate!)
//
//            var endDateText = ""
//            if let eventEndDate = model.endDate {
//                endDateText = EventDetailsViewController.convertDateFormate(date: eventEndDate)
//            }
//
//            if let timezone = model.timezone {
//                startTimeText = "\(startTimeText) (\(timezone))"
//            }
//
//            cell.date.text = endDateText != "" ? "\(startDateText) - \(endDateText)" : "\(startDateText) \(startTimeText)"
//        }else { //showing location if available
//            //cell.dateContainerView.isHidden = true
//            var locationText = ""
//            if let cityName = model.location?.first?.city?.name {
//                locationText = "\(cityName), "
//            }
//            locationText += model.location?.first?.country.name ?? ""
//            cell.date.text = locationText.uppercased()
//            cell.dateContainerView.isHidden = locationText.isEmpty
//            cell.imgDate.image = UIImage(named: "Location White")
//        }
//
//        if model.tags?.count ?? 0 > 0, let fistTag = model.tags?[0] {
//            cell.tagContainerView.isHidden = false
//            cell.tagLabel.text = fistTag.name.uppercased()
//        } else {
//            cell.tagContainerView.isHidden = true
//        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let event = dataSource[indexPath.row]
//        let viewController = EventDetailsViewController.instantiate(event: event)
//        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}

extension PerCityViewController: CityViewProtocol {
    func seeAllProductsForCity(city: Cities) {
        print(city.name as Any)
    }
    
    func didTappedOnProductAt(product: Product) {
        let viewController = EventDetailsViewController.instantiate(event: product)
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    func didTappedOnHeartAt(city currentCity: Cities, itemIndex: Int) {
        if let cityIndex = homeObjects?.cities.firstIndex(where: {$0.termID == currentCity.termID}), let product = homeObjects?.cities[cityIndex].items?[itemIndex]{
            //setting the favourite
            self.showNetworkActivity()
            setUnSetFavourites(id: product.id ,isUnSetFavourite: product.isFavourite ?? false) {information, error in
                self.hideNetworkActivity()

                if let error = error {
                    self.showError(error)
                    return
                }

                if let informations = information {
                    let isFavourtie = self.homeObjects?.cities[cityIndex].items?[itemIndex].isFavourite ?? false
                    self.homeObjects?.cities[cityIndex].items?[itemIndex].isFavourite = !(isFavourtie)
                    self.updatePopularCities() //just to reload the grid

                    print("ItemID:\(product.id)" + ", ItemType:" + product.type  + ", ServerResponse:" + informations)
                } else {
                    let error = BackendError.parsing(reason: "Could not obtain tap on heart information")
                    self.showError(error)
                }
            }
        }
    }
    
    
    func getInformation(for category: EventCategory) {
        showNetworkActivity()
        getList(for: category) { items, error in
            self.hideNetworkActivity()
            if let error = error {
                self.showError(error)
            } else {
                self.update(listOf: items ?? nil)
            }
        }
    }
    
    func getList(for category: EventCategory, completion: @escaping (PerCityObjects?, Error?) -> Void) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            completion(nil, LoginError.errorLogin(description: "User does not exist or is not verified"))
            return
        }
        var categoryType = ""
        switch category {
            case .event:
                categoryType = "event"
            case .experience:
                categoryType = "experience"
            case .villa:
                categoryType = "villa"
            case .yacht:
                categoryType = "yacht"
            case .gift:
                categoryType = "gift"
            default:
                categoryType = "event"
       
        }
        EEAPIManager().getPerCity(token, type: categoryType) { list, error in
            guard error == nil else {
                Crashlytics.sharedInstance().recordError(error!)
                let error = BackendError.parsing(reason: "Could not obtain per city objects information")
                completion(nil, error)
                return
            }
            completion(list, error)
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

extension PerCityViewController: DidSelectSliderItemProtocol {
    
    func didTappedOnHeartAt(index: Int, sender: HomeSlider) {
        var item: Product!
        switch sender {
            case homeTopRatedSlider:
                item = homeObjects?.topRated[index]
            default: return
        }
        
        //setting the favourite
        self.showNetworkActivity()
        setUnSetFavourites(id: item.id ,isUnSetFavourite: item.isFavourite ?? false) {information, error in
            self.hideNetworkActivity()
            
            if let error = error {
                self.showError(error)
                return
            }
            
            if let informations = information {
                switch sender {
                case self.homeTopRatedSlider:
                    var items = self.homeTopRatedSlider.itemsList
                    items[index].isFavourite = !(items[index].isFavourite ?? false)
                    sender.itemsList = items   //re-assigning as it will automatically reload the collection
                
                default: return
                }
                print("ItemID:\(item.id)" + ", ItemType:" + item.type  + ", ServerResponse:" + informations)
            } else {
                let error = BackendError.parsing(reason: "Could not obtain wishlist information")
                self.showError(error)
            }
        }
        
    }
 
   
    
    
    
    func didSelectSliderItemAt(indexPath: IndexPath, sender: HomeSlider) {
        let product: Product!
        
        switch sender {
            case homeTopRatedSlider:
                product = homeObjects?.topRated[indexPath.row]
            default: return
        }
        
        let viewController = EventDetailsViewController.instantiate(event: product)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}
