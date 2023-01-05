//
//  AviationResultsViewController.swift
//  LUJO
//
//  Created by Kristian Iker on 9/4/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import JGProgressHUD

class AviationResultsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "AviationResultsViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate(lifts: [Lift], filter: [Filter], searchCriteria: AviationSearch?) -> AviationResultsViewController {
        let viewController = UIStoryboard.main.instantiate(identifier) as! AviationResultsViewController
        viewController.lifts = lifts
        viewController.filter = filter
        viewController.searchCriteria = searchCriteria
        return viewController
    }
    
    //MARK:- Globals
    
    private(set) var lifts: [Lift]!
    private(set) var filter: [Filter]!
    private(set) var searchCriteria: AviationSearch? // Optional
    
    private var lastSearch: [Lift]?

    private let naHUD = JGProgressHUD(style: .dark)
    @IBOutlet var topBar: UIView!
    private var emptyResultsView: AviationEmptyResultsView!
    
    @IBOutlet var liftsCollection: UICollectionView!
    
    private var profileImage: UIImage?
    
    var selectedLift: Lift?
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter
    }()
    
    override func viewDidLoad() {
//        naHUD.textLabel.text = "Searching ..."
        guard let layout = liftsCollection.collectionViewLayout as? LiftLayout else { return }
        layout.setCustomCellHeight(244)
        setupEmptyResultsVIew()
    }
    
    func updateUser(image: UIImage?) {
        profileImage = image
    }
    
    func showNetworkActivity() {
        naHUD.show(in: view)
    }
    
    func hideNetworkActivity() {
        naHUD.dismiss()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lifts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = liftsCollection.dequeueReusableCell(withReuseIdentifier: "liftResultCell",
                                                       for: indexPath) as! LiftCollectionViewCell
        
        let aircraft = lifts[indexPath.row].aircraft
        
        var memberPrice = "$0.0"
        if let price = formatter.string(from: aircraft.memberPrice as NSNumber) {
            memberPrice = price
        }
        
        var nonMemberPrice = "$0.0"
        if let price = formatter.string(from: aircraft.nonMemberPrice as NSNumber) {
            nonMemberPrice = price
        }
        cell.displayContent(image: aircraft.images.first ?? "",
                            name: aircraft.name,
                            seats: aircraft.seats,
                            luggage: aircraft.luggageCapacity,
                            memberPrice: memberPrice,
                            nonMemberPrice: nonMemberPrice)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let liftDetails = LiftDetailViewController()
        liftDetails.lift = lifts[indexPath.row]
        if let segments = searchCriteria?.data {
            liftDetails.segments = segments
        }
        liftDetails.delegate = self
        present(liftDetails, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        selectedLift = lifts[indexPath.row]
    }
    
    func show(lifts list: [Lift], filter: [Filter]) {
        self.filter = filter
        lifts = list
     
        let toAdd = list.filter { !lifts.contains($0) }.map { IndexPath(item: list.firstIndex(of: $0)!, section: 0) }
        let toDel = lifts.filter { !list.contains($0) }.map { IndexPath(item: lifts.firstIndex(of: $0)!, section: 0) }
               
//        showNetworkActivity()
        liftsCollection.performBatchUpdates({
            liftsCollection.deleteItems(at: toDel)
            liftsCollection.insertItems(at: toAdd)
        }, completion: { _ in
            self.liftsCollection.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
//            self.hideNetworkActivity()
        })
    }
    
    @IBAction func filtersBarButton_onClick(_ sender: Any) {
        let viewController = AviationResultsFilterViewController.instantiate(filter: filter)
        present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func unwindToResultsView(segue: UIStoryboardSegue) {
        // Placeholder for unwind segue
        guard let layout = liftsCollection.collectionViewLayout as? LiftLayout else { return }
        layout.clearCache()
    }
    
    fileprivate func setupEmptyResultsVIew() {
        emptyResultsView = AviationEmptyResultsView(frame: view.bounds)
        emptyResultsView.translatesAutoresizingMaskIntoConstraints = false
        emptyResultsView.isHidden = true
        
        view.addSubview(emptyResultsView)
        
        view.addConstraint(NSLayoutConstraint(item: emptyResultsView, attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: view, attribute: .leading,
                                              multiplier: 1, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: emptyResultsView, attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: view, attribute: .trailing,
                                              multiplier: 1, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: emptyResultsView, attribute: .top,
                                              relatedBy: .equal,
                                              toItem: topBar, attribute: .bottom,
                                              multiplier: 1, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: emptyResultsView, attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: view, attribute: .bottom,
                                              multiplier: 1, constant: 0))
    }
    
    func waitingAnimation(show: Bool) {
        DispatchQueue.main.async {
//            self.searchWaitView.isHidden = !show
//
//            if show {
//                self.searchWaitView.addRotationAnimation()
//            }
        }
    }
    
    func showEmptyResult() {
        emptyResultsView.isHidden = false
    }
    
    @IBAction func backButton_onClick(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension AviationResultsViewController: LiftDetailDelegate {
    
    func finished(payment: PaymentResult, for aircraft: String, method: Int, completion: @escaping (Error?) -> Void) {
        inform(result: payment, for: aircraft, with: method, completion: completion)
    }
    
    func performAction(for result: String) {
        //no more used as booking was on 4th index which has been replaced with wishlist
//        var viewController: UIViewController? = self
//        while !(viewController is MainTabBarController) {
//            let presenter = viewController?.presentingViewController
//            viewController?.dismiss(animated: false, completion: nil)
//            viewController = presenter
//        }
        
//        self.dismiss(animated: true, completion: {
//            (viewController as? MainTabBarController)?.selectedIndex = 4    //it has been given to wishlist zahoor
//        })
        
        self.view.window?.rootViewController?.dismiss(animated: true, completion: {
            if let top = UIApplication.topViewController(){
                if let topNav = top.navigationController{
                    let viewController = BookingsViewController.instantiate()
                    viewController.selectedItemIndex = 1
                    topNav.pushViewController(viewController, animated: true)
                }
            }
        })
    }

}

extension AviationResultsViewController {
    
    func inform(result: PaymentResult, for aircraft: String, with method: Int, completion: @escaping (Error?) -> Void) {
        save(result, for: aircraft, with: method) { error in
            completion(error)
        }
    }
    
    func save(_ payment: PaymentResult, for aircraft: String, with method: Int, completion: @escaping (Error?) -> Void) {
        guard let currentUser = LujoSetup().getLujoUser() else { return }
        
        let paymentInfo = PaymentInformation(customerId: currentUser.id,
                                             token: payment.token!,
                                             profileId: payment.sessionId ?? "",
                                             aircraftId: aircraft,
                                             retref: payment.reference,
                                             acctId: payment.acctid!,
                                             paymentMethod: method)
        
        AviationAPIManagerNEW.shared.authorisationToken = LujoSetup().getCurrentUser()?.token
        AviationAPIManagerNEW.shared.authorizePayment(for: paymentInfo) { error in
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    func filterFlights(matching criteria: [Filter]) {
//        waitingAnimation(show: true)//app is crashing due to animation
        
        AviationAPIManagerNEW.shared.filterFlights(matching: criteria) { list, filter, error in
//            self.waitingAnimation(show: false)
            
            guard error == nil else {
                self.showEmptyResult()
                return
            }
            
            guard let liftsList = list else {
                self.showEmptyResult()
                return
            }
            
            guard !liftsList.isEmpty else {
                self.showEmptyResult()
                return
            }
            
            self.show(lifts: liftsList, filter: filter)
        }
    }
    
}
