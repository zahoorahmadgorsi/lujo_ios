//
//  ReferralCodeViewController.swift
//  LUJO
//
//  Created by iMac on 25/04/2022.
//  Copyright © 2022 Baroque Access. All rights reserved.
//

import Foundation
import UIKit
import JGProgressHUD
import FirebaseCrashlytics

class GenerateReferralCodeViewController: UIViewController {
    
    /// Class storyboard identifier.
    class var identifier: String { return "GenerateReferralCodeViewController" }
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var collContainerView: UIView!
    @IBOutlet weak var btnGenerateCode: UIButton!
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.vertical
        let contentView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        contentView.dataSource = self
        contentView.delegate = self
        contentView.register(UINib(nibName: PrefCollViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: PrefCollViewCell.identifier)
        contentView.backgroundColor = .clear
        contentView.showsHorizontalScrollIndicator = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    var selectedItem: ReferralType?
    var itemsList: [ReferralType] = [] {
        didSet {
            collectionView.reloadData()
            collectionView.layoutIfNeeded() //forces the reload to happen immediately instead of on the next runloop cycle.
        }
    }
    
    private let naHUD = JGProgressHUD(style: .dark)
    var cellWidth : Int = 325
    
    /// Init method that will init and return view controller.
    //class func instantiate(user: LujoUser) -> MyPreferencesViewController {
    class func instantiate() -> GenerateReferralCodeViewController {
        let viewController = UIStoryboard.accountNEW.instantiate(identifier) as! GenerateReferralCodeViewController
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collContainerView.addSubview(collectionView)
        applyConstraints()
        
        getReferralTypes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = "Create Referral Codes"
        activateKeyboardManager()
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationItem.title = ""
        self.tabBarController?.tabBar.isHidden = false
    }
    
    private func applyConstraints() {
        collectionView.leadingAnchor.constraint(equalTo: self.collContainerView.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.collContainerView.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: self.collContainerView.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.collContainerView.bottomAnchor).isActive = true
//        self.collContainerView.heightAnchor.constraint(equalTo: collectionView.heightAnchor).isActive = true
    }
    
    func getReferralTypes() {
        if (self.itemsList.count == 0){
            self.showNetworkActivity()  //if no data is cached then fetch openly else silently
        }
        getReferralTypes() {referralCodes, error in
            self.hideNetworkActivity()
            if let error = error {
                self.showError(error)
                return
            }
            if let informations = referralCodes {
                if informations.count > 0{  //it will contain zero in case of hard coded values
                    self.itemsList = informations
                }
            } else {
                let error = BackendError.parsing(reason: "Could not obtain the list of referral options")
                self.showError(error)
            }
        }
    }
    
    func getReferralTypes(completion: @escaping ([ReferralType]?, Error?) -> Void) {
        GoLujoAPIManager().getReferralTypes() { referralCodes, error in
            guard error == nil else {
                Crashlytics.crashlytics().record(error: error!)
                let error = BackendError.parsing(reason: "Could not obtain the list of referral options")
                completion(nil, error)
                return
            }
            completion(referralCodes, error)
        }
    }
    
    
    @IBAction func generateCodeTapped(_ sender: Any) {
        if let selected = selectedItem{
            showNetworkActivity()
            GoLujoAPIManager().getReferralCodeAgainstType(selected.discountPercentageEnum) { ReferralCode, error in
                self.hideNetworkActivity()
                guard error == nil , let code = ReferralCode?.referralCode else {
                    Crashlytics.crashlytics().record(error: error!)
                    BackendError.parsing(reason: "Could not obtain the list of referral code")
                    return
                }
                let viewController = ShareReferralCodeViewController.instantiate(code, selected.title)
                self.navigationController?.pushViewController(viewController, animated: true)

            }
        }
    }
    
    func showNetworkActivity() {
        naHUD.show(in: view)
    }
    
    func hideNetworkActivity() {
        // Safe guard that will call dismiss only if HUD is shown on screen.
        if naHUD.isVisible {
            naHUD.dismiss()
        }
    }
    
    func showError(_ error: Error) {
        showErrorPopup(withTitle: "Referral Code Error", error: error)
    }
}

extension GenerateReferralCodeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PrefCollViewCell.identifier, for: indexPath) as! PrefCollViewCell
        let model = itemsList[indexPath.row]
        cell.lblTitle.text = model.title
        if let title = selectedItem?.title ,  model.title == title{
            cell.containerView.backgroundColor = UIColor.rgMid
            cell.lblTitle.textColor = UIColor.white
        }else{
            cell.containerView.backgroundColor = UIColor.clear
            cell.lblTitle.textColor = UIColor.rgMid
        }
        return cell
    }
}

extension GenerateReferralCodeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedItem = itemsList[indexPath.row]
        self.collectionView.reloadData()
    }
}

extension GenerateReferralCodeViewController: UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: PrefCollSize.itemHeight.rawValue)
    }

//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        insetForSectionAt section: Int) -> UIEdgeInsets {
//            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//    }
//
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        //return CGFloat(PrefCollSize.itemMargin.rawValue)    //horizonntal margin between cells
        return 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return CGFloat(PrefCollSize.itemMargin.rawValue)    //vertical margin between cells
    }
}
