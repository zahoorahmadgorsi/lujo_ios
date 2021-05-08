//
//  MyPreferencesViewController.swift
//  LUJO
//
//  Created by iMac on 06/05/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import UIKit
import JGProgressHUD

enum PrefCollSize:Int{
//    case itemWidth = 275
    case itemHeight = 40
    case itemHorizontalMargin = 0
    case itemVerticalMargin = 24
}

enum PrefType:String{
    case gifts
    case aviation
    case dining
    case travel
    case villas
    case yachts
}

enum PrefInformationType:String{
    case giftHabbits
    case giftCategories
    case giftPreferences
}

class PrefCollectionsViewController: UIViewController {
    
    //MARK: - 🎲 - Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "PrefCollectionsViewController" }
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var imgPreference: UIImageView!
    @IBOutlet weak var lblPrefLabel: UILabel!
    @IBOutlet weak var lblPrefQuestion: UILabel!
    @IBOutlet weak var collContainerView: UIView!
    @IBOutlet weak var txtPleaseSpecify: UITextField!
    @IBOutlet weak var btnNextStep: UIButton!
    
    
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
    
    var itemsList: [Taxonomy] = [] {
        didSet {
            collectionView.reloadData()
            collectionView.layoutIfNeeded() //forces the reload to happen immediately instead of on the next runloop cycle.
        }
    }
    private let naHUD = JGProgressHUD(style: .dark)
    var prefType: PrefType!
    var prefInformationType : PrefInformationType!
    
    /// Init method that will init and return view controller.
    //class func instantiate(user: LujoUser) -> MyPreferencesViewController {
    class func instantiate(prefType: PrefType, prefInformationType : PrefInformationType) -> PrefCollectionsViewController {
        let viewController = UIStoryboard.preferences.instantiate(identifier) as! PrefCollectionsViewController
        viewController.prefType = prefType
        viewController.prefInformationType = prefInformationType
        return viewController
    }

    //MARK:- Globals
    
//    private(set) var user: LujoUser!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Skip", style: .plain, target: self, action: #selector(skipTapped))
        self.contentView.addViewBorder( borderColor: UIColor.white.cgColor, borderWith: 1.0,borderCornerRadius: 12.0)
        
        self.collContainerView.addSubview(collectionView)
        applyConstraints()

        switch prefType {
            case .gifts:
                imgPreference.image = UIImage(named: "Purchase Goods Icon")
                lblPrefLabel.text = "Gifts"
                switch prefInformationType {
                    case .giftHabbits:
                        lblPrefQuestion.text = "Tell us about your gift giving habits:"
                    case .giftCategories:
                        lblPrefQuestion.text = "Preferred gift items:"
                    case .giftPreferences:
                        lblPrefQuestion.text = "Item Preferences:"
                        btnNextStep.setTitle("D O N E", for: .normal)
                    default:
                        print("Others")
                }
            default:
                print("Others")
        }
        getPreferences()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = "My Preferences"
        activateKeyboardManager()

        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationItem.title = ""
        self.tabBarController?.tabBar.isHidden = false
    }
    
    //when user will click on the back button at the bottom
    @IBAction func btnNextTapped(_ sender: Any) {
        switch prefType {
            case .gifts:
                switch prefInformationType {
                    case .giftHabbits:
                        let viewController = PrefCollectionsViewController.instantiate(prefType: .gifts, prefInformationType: .giftCategories)
                        self.navigationController?.pushViewController(viewController, animated: true)
                    case .giftCategories:
                        let viewController = PrefCollectionsViewController.instantiate(prefType: .gifts, prefInformationType: .giftPreferences)
                        self.navigationController?.pushViewController(viewController, animated: true)
                    default:
                        skipTapped()
//                        if let viewController = navigationController?.viewControllers.first(where: {$0 is MyPreferencesViewController}) {
//                              navigationController?.popToViewController(viewController, animated: false)
//                        }
                }
            default:
                print("Others")
        }
        
        
    }
    
    //@objc func skipTapped(sender: UIBarButtonItem){
    @objc func skipTapped(){
        if let viewController = navigationController?.viewControllers.first(where: {$0 is MyPreferencesViewController}) {
              navigationController?.popToViewController(viewController, animated: true)
        }
        
    }
    
    private func applyConstraints() {
        collectionView.leadingAnchor.constraint(equalTo: self.collContainerView.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.collContainerView.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: self.collContainerView.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.collContainerView.bottomAnchor).isActive = true
//        self.collContainerView.heightAnchor.constraint(equalTo: collectionView.heightAnchor).isActive = true
        
    }
    
    func getPreferences() {
        self.showNetworkActivity()

        getPreferencesInformation() {information, error in
            self.hideNetworkActivity()
            
            if let error = error {
                self.showError(error)
                return
            }
            
            if let informations = information {
                self.itemsList = informations
            } else {
                let error = BackendError.parsing(reason: "Could not obtain Preferences information")
                self.showError(error)
            }
        }
    }
    
    func getPreferencesInformation(completion: @escaping ([Taxonomy]?, Error?) -> Void) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            completion(nil, LoginError.errorLogin(description: "User does not exist or is not verified"))
            return
        }
        
        switch prefType {
            case .gifts:
                switch prefInformationType {
                    case .giftHabbits:
                        GoLujoAPIManager().getGiftHabbits(token) { taxonomies, error in
                            guard error == nil else {
                                Crashlytics.sharedInstance().recordError(error!)
                                let error = BackendError.parsing(reason: "Could not obtain the Preferences information")
                                completion(nil, error)
                                return
                            }
                            completion(taxonomies, error)
                        }
                    case .giftCategories:
                        GoLujoAPIManager().getGiftCategories(token) { taxonomies, error in
                            guard error == nil else {
                                Crashlytics.sharedInstance().recordError(error!)
                                let error = BackendError.parsing(reason: "Could not obtain the Preferences information")
                                completion(nil, error)
                                return
                            }
                            completion(taxonomies, error)
                        }
                    default:
                        print("giftPreferences")
                        GoLujoAPIManager().getGiftPreferences(token) { taxonomies, error in
                            guard error == nil else {
                                Crashlytics.sharedInstance().recordError(error!)
                                let error = BackendError.parsing(reason: "Could not obtain the Preferences information")
                                completion(nil, error)
                                return
                            }
                            completion(taxonomies, error)
                        }
                }
            default:
                print("Others")
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
        showErrorPopup(withTitle: "Preferences Error", error: error)
    }
}

extension PrefCollectionsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PrefCollViewCell.identifier, for: indexPath) as! PrefCollViewCell
        
        let model = itemsList[indexPath.row]
        
        cell.lblTitle.text = model.name
        

        return cell
        // swiftlint:enable force_cast
    }
    
    
}



extension PrefCollectionsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("didSelectItemAt")
    }
    
}

extension PrefCollectionsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

//        return CGSize(width: PrefCollSize.itemWidth.rawValue, height: PrefCollSize.itemHeight.rawValue)
        let itemWidth = Int(self.collContainerView.frame.size.width) - (PrefCollSize.itemHorizontalMargin.rawValue * 2)
        return CGSize(width: itemWidth, height: PrefCollSize.itemHeight.rawValue)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: CGFloat(PrefCollSize.itemHorizontalMargin.rawValue), bottom: 0, right: CGFloat(PrefCollSize.itemHorizontalMargin.rawValue)) // .zero
//        let CellWidth = PrefCollSize.itemWidth.rawValue
//        let CellCount = itemsList.count
//        let CellSpacing = PrefCollSize.itemMargin.rawValue
//        let collectionViewWidth = self.collContainerView.frame.size.width
//
//        let totalCellWidth = CellWidth * CellCount
//        let totalSpacingWidth = CellSpacing * (CellCount - 1)
//
//        let leftInset = (collectionViewWidth - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
//        let rightInset = leftInset
//
//        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        //return 16
        return CGFloat(PrefCollSize.itemVerticalMargin.rawValue)
    }
    
    
}

