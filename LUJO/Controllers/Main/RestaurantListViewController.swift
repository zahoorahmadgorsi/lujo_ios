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

class RestaurantListViewController: UIViewController {
    
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "RestaurantListViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate(dataSource: [Restaurants] = [], city: DiningCity? = nil) -> RestaurantListViewController {
        let viewController = UIStoryboard.main.instantiate(identifier) as! RestaurantListViewController
        viewController.dataSource = dataSource
        viewController.city = city
        return viewController
    }
    
    //MARK:- Globals
    
    @IBOutlet weak var collectionView: UICollectionView!
    private var dataSource: [Restaurants]!
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
        title = dataSource.count > 0 ? "\(dataSource[0].location.first?.city?.name ?? "") dining spots" : "\(city?.name ?? "") dining spots"
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
    
    func update(listOf objects: [Restaurants]) {
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
        let viewController = RestaurantDetailViewController.instantiate(restaurant: dataSource[indexPath.row])
        present(viewController, animated: true, completion: nil)
    }

}
