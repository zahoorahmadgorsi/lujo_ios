//
//  MyPreferencesViewController.swift
//  LUJO
//
//  Created by iMac on 06/05/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import UIKit
import JGProgressHUD

class PrefProductCategoryViewController: UIViewController {
    
    //MARK: - 🎲 - Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "PrefProductCategoryViewController" }
    
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
    var userPreferences: Preferences?
    
    /// Init method that will init and return view controller.
    //class func instantiate(user: LujoUser) -> MyPreferencesViewController {
    class func instantiate(prefType: PrefType, prefInformationType : PrefInformationType) -> PrefProductCategoryViewController {
        let viewController = UIStoryboard.preferences.instantiate(identifier) as! PrefProductCategoryViewController
        viewController.prefType = prefType
        viewController.prefInformationType = prefInformationType
        return viewController
    }

    //MARK:- Globals
    
//    private(set) var user: LujoUser!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Skip for now", style: .plain, target: self, action: #selector(skipTapped))
        self.contentView.addViewBorder( borderColor: UIColor.white.cgColor, borderWith: 1.0,borderCornerRadius: 12.0)
        self.userPreferences = LujoSetup().getUserPreferences()  //get user preferences from the userdefaults
        
        self.collContainerView.addSubview(collectionView)
        applyConstraints()
        
        switch prefType {
            case .aviation:
                imgPreference.image = UIImage(named: "aviation_icon")
                lblPrefLabel.text = "Aviation"
                switch prefInformationType {
                case .aviationAircraftCategory:
                    lblPrefQuestion.text = "Preferred aircraft category?"
                    txtPleaseSpecify.isHidden = true
//                        btnNextStep.setTitle("D O N E", for: .normal)
                    default:
                        print("Others")
                }
            default:
                print("Others")
        }
        getPreferences()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = "Preferences"
        activateKeyboardManager()

        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationItem.title = ""
        self.tabBarController?.tabBar.isHidden = false
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
            case .aviation:
                switch prefInformationType {
                    case .aviationAircraftCategory:
                        GoLujoAPIManager().getAviationBeverages(token) { taxonomies, error in
                            guard error == nil else {
                                Crashlytics.sharedInstance().recordError(error!)
                                let error = BackendError.parsing(reason: "Could not obtain the Preferences information")
                                completion(nil, error)
                                return
                            }
                            completion(taxonomies, error)
                        }
                    default:
                        print("aviationOtherInterests")
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
    
    //when user will click on the next button at the bottom
    @IBAction func btnNextTapped(_ sender: Any) {
        var selectedArray = [String]()
        
        switch self.prefType {
        case .aviation:
            switch self.prefInformationType {
            case .aviationAircraftCategory:
                if let str = userPreferences?.aviation.aviation_chartered_before{
                    selectedArray.append(str)
                }
            default:
                print("aviation default")
            }
            default:
                print("Others")
        }
        
        if (selectedArray.count > 0 || txtPleaseSpecify.text?.count ?? 0 > 0) {   //something is there, so convert array to comma sepeated string
            let commaSeparatedString = selectedArray.map{String($0)}.joined(separator: ",")
            setPreferences(commaSeparatedString: commaSeparatedString)
        }else{
//            showCardAlertWith(title: "My Preferences", body: "Please select one option at least.")
            navigateToNextVC()  //skipping this step
        }
    }
    
    func setPreferences(commaSeparatedString:String) {
        self.showNetworkActivity()
        setPreferencesInformation(commaSeparatedString: commaSeparatedString) {information, error in
            self.hideNetworkActivity()
            if let error = error {
                self.showError(error)
                return
            }
            if let informations = information {
                if let userPreferences = self.userPreferences{
                    LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                }
                
                self.navigateToNextVC()
            } else {
                let error = BackendError.parsing(reason: "Could not set the Preferences")
                self.showError(error)
            }
        }
    }
    

    func setPreferencesInformation(commaSeparatedString:String, completion: @escaping (String?, Error?) -> Void) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            completion(nil, LoginError.errorLogin(description: "User does not exist or is not verified"))
            return
        }
        
        switch prefType {
        case .aviation:
            switch prefInformationType {
                case .aviationHaveCharteredBefore:
                    GoLujoAPIManager().setAviationHaveCharteredBefore(token: token,commSepeartedString: commaSeparatedString) { contentString, error in
                        guard error == nil else {
                            Crashlytics.sharedInstance().recordError(error!)
                            let error = BackendError.parsing(reason: "Could not obtain the Preferences information")
                            completion(nil, error)
                            return
                        }
                        completion(contentString, error)
                    }
//                    completion("Success", nil)
                case .aviationInterestedIn:
                    GoLujoAPIManager().setAviationWantToPurchase(token: token,commSepeartedString: commaSeparatedString) { contentString, error in
                        guard error == nil else {
                            Crashlytics.sharedInstance().recordError(error!)
                            let error = BackendError.parsing(reason: "Could not obtain the Preferences information")
                            completion(nil, error)
                            return
                        }
                        completion(contentString, error)
                    }
                case .aviationPreferredCharter:
                    GoLujoAPIManager().setAviationPreferredCharter(token: token,commSepeartedString: commaSeparatedString) { contentString, error in
                        guard error == nil else {
                            Crashlytics.sharedInstance().recordError(error!)
                            let error = BackendError.parsing(reason: "Could not obtain the Preferences information")
                            completion(nil, error)
                            return
                        }
                        completion(contentString, error)
                    }
                case .aviationPreferredCuisine:
                    GoLujoAPIManager().setAviationPreferredCuisine(token: token,commSepeartedString: commaSeparatedString, typedPreference: txtPleaseSpecify.text ?? "") { contentString, error in
                        guard error == nil else {
                            Crashlytics.sharedInstance().recordError(error!)
                            let error = BackendError.parsing(reason: "Could not obtain the Preferences information")
                            completion(nil, error)
                            return
                        }
                        completion(contentString, error)
                    }

                case .aviationPreferredBevereges:
                    GoLujoAPIManager().setAviationPreferredBeverages(token: token,commSepeartedString: commaSeparatedString, typedPreference: txtPleaseSpecify.text ?? "") { contentString, error in
                        guard error == nil else {
                            Crashlytics.sharedInstance().recordError(error!)
                            let error = BackendError.parsing(reason: "Could not obtain the Preferences information")
                            completion(nil, error)
                            return
                        }
                        completion(contentString, error)
                    }
                default:
                    print("Not yet required")
//                    GoLujoAPIManager().setGiftPreferences(token: token,commSepeartedString: commaSeparatedString) { contentString, error in
//                        guard error == nil else {
//                            Crashlytics.sharedInstance().recordError(error!)
//                            let error = BackendError.parsing(reason: "Could not obtain the Preferences information")
//                            completion(nil, error)
//                            return
//                        }
//                        completion(contentString, error)
//                    }
                    completion("Success", nil)
            }
            default:
                print("Others")
        }
    }
    
    func navigateToNextVC(){
        switch self.prefType {
        case .aviation:
            switch self.prefInformationType {
            case .aviationAircraftCategory:
                let viewController = PrefCollectionsViewController.instantiate(prefType: .aviation, prefInformationType: .aviationPreferredCharter)
                self.navigationController?.pushViewController(viewController, animated: true)
            default:
                self.skipTapped()
            }
            default:
                print("Others")
        }
    }
    
    
    //@objc func skipTapped(sender: UIBarButtonItem){
    @objc func skipTapped(){
        if let viewController = navigationController?.viewControllers.first(where: {$0 is PreferencesHomeViewController}) {
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

extension PrefProductCategoryViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PrefCollViewCell.identifier, for: indexPath) as! PrefCollViewCell
        let model = itemsList[indexPath.row]
        cell.lblTitle.text = model.name
        
        switch self.prefType {
            case .gifts:
                switch self.prefInformationType {
                case .giftHabbits:
                    if let ids = userPreferences?.gift.gift_habit_id{
                        if (ids.contains(String(model.termId))){
                            cell.backgroundColor = UIColor.rgMid
                            cell.lblTitle.textColor = UIColor.white
                        }else{
                            cell.backgroundColor = UIColor.clear
                            cell.lblTitle.textColor = UIColor.rgMid
                        }
                    }
                case .giftCategories:
                    if let ids = userPreferences?.gift.gift_category_id{
                        if (ids.contains(String(model.termId))){
                            cell.backgroundColor = UIColor.rgMid
                            cell.lblTitle.textColor = UIColor.white
                        }else{
                            cell.backgroundColor = UIColor.clear
                            cell.lblTitle.textColor = UIColor.rgMid
                        }
                    }
                case .giftPreferences:
                    if let ids = userPreferences?.gift.gift_preferences_id{
                        if (ids.contains(String(model.termId))){
                            cell.backgroundColor = UIColor.rgMid
                            cell.lblTitle.textColor = UIColor.white
                        }else{
                            cell.backgroundColor = UIColor.clear
                            cell.lblTitle.textColor = UIColor.rgMid
                        }
                    }
                default:
                    print("gifts default")
                }
        case .aviation:
            switch self.prefInformationType {
            case .aviationHaveCharteredBefore:
                if let str = userPreferences?.aviation.aviation_chartered_before{
//                    if(str.caseInsensitiveCompare(model.name) == .orderedSame){
                    if(str.contains(model.name.lowercased()) ){
                        cell.backgroundColor = UIColor.rgMid
                        cell.lblTitle.textColor = UIColor.white
                    }else{
                        cell.backgroundColor = UIColor.clear
                        cell.lblTitle.textColor = UIColor.rgMid
                    }
                }
            case .aviationInterestedIn:
                if let str = userPreferences?.aviation.aviation_interested_in{
//                    if(str.caseInsensitiveCompare(model.name) == .orderedSame){
                    if(str.contains(model.name.lowercased()) ){
                        cell.backgroundColor = UIColor.rgMid
                        cell.lblTitle.textColor = UIColor.white
                    }else{
                        cell.backgroundColor = UIColor.clear
                        cell.lblTitle.textColor = UIColor.rgMid
                    }
                }
            case .aviationPreferredCharter:
                if let str = userPreferences?.aviation.aviation_preferred_charter_range{
                    if(model.name.lowercased().contains(str) ){ //model name is longer in length then the str i.e. Long Range and long respectively
                        cell.backgroundColor = UIColor.rgMid
                        cell.lblTitle.textColor = UIColor.white
                    }else{
                        cell.backgroundColor = UIColor.clear
                        cell.lblTitle.textColor = UIColor.rgMid
                    }
                }
            case .aviationPreferredCuisine:
                if let ids = userPreferences?.aviation.aviation_preferred_cuisine_id{
                    if (ids.contains(String(model.termId))){
                        cell.backgroundColor = UIColor.rgMid
                        cell.lblTitle.textColor = UIColor.white
                    }else{
                        cell.backgroundColor = UIColor.clear
                        cell.lblTitle.textColor = UIColor.rgMid
                    }
                }
            case .aviationPreferredBevereges:
                if let ids = userPreferences?.aviation.aviation_preferred_beverage_id{
                    if (ids.contains(String(model.termId))){
                        cell.backgroundColor = UIColor.rgMid
                        cell.lblTitle.textColor = UIColor.white
                    }else{
                        cell.backgroundColor = UIColor.clear
                        cell.lblTitle.textColor = UIColor.rgMid
                    }
                }
            default:
                print("aviation default")
            }
        default:
            print("Others")
        }

        return cell
        // swiftlint:enable force_cast
    }
}

extension PrefProductCategoryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let termId = String(itemsList[indexPath.row].termId)
        switch self.prefType {
            case .gifts:
                switch self.prefInformationType {
                case .giftHabbits:
                    if let ids = userPreferences?.gift.gift_habit_id{
                        if let index = ids.firstIndex(of: termId) {
                            userPreferences?.gift.gift_habit_id?.remove(at: index)
                        }else{
                            userPreferences?.gift.gift_habit_id?.append(termId)
                        }
                    }
                case .giftCategories:
                    if let ids = userPreferences?.gift.gift_category_id{
                        if let index = ids.firstIndex(of: termId) {
                            userPreferences?.gift.gift_category_id?.remove(at: index)
                        }else{
                            userPreferences?.gift.gift_category_id?.append(termId)
                        }
                    }
                case .giftPreferences:
                    if let ids = userPreferences?.gift.gift_preferences_id{
                        if let index = ids.firstIndex(of: termId) {
                            userPreferences?.gift.gift_preferences_id?.remove(at: index)
                        }else{
                            userPreferences?.gift.gift_preferences_id?.append(termId)
                        }
                    }
                default:
                    print("gifts default")
                }
        case .aviation:
            switch self.prefInformationType {
            case .aviationHaveCharteredBefore:
                if (indexPath.row == 0){
                    userPreferences?.aviation.aviation_chartered_before = "yes"
                }else{
                    userPreferences?.aviation.aviation_chartered_before = "no"
                }
                self.collectionView.reloadData()
                return
            case .aviationInterestedIn:
                if (indexPath.row == 0){
                    userPreferences?.aviation.aviation_interested_in = "charter"
                }else{
                    userPreferences?.aviation.aviation_interested_in = "purchase"
                }
                self.collectionView.reloadData()
                return
            case .aviationPreferredCharter:
                if (indexPath.row == 0){
                    userPreferences?.aviation.aviation_preferred_charter_range = "short"
                }else{
                    userPreferences?.aviation.aviation_preferred_charter_range = "long"
                }
                self.collectionView.reloadData()
                return
            case .aviationPreferredCuisine:
                if let ids = userPreferences?.aviation.aviation_preferred_cuisine_id{
                    if let index = ids.firstIndex(of: termId) {
                        userPreferences?.aviation.aviation_preferred_cuisine_id?.remove(at: index)
                    }else{
                        userPreferences?.aviation.aviation_preferred_cuisine_id?.append(termId)
                    }
                }
            case .aviationPreferredBevereges:
                if let ids = userPreferences?.aviation.aviation_preferred_beverage_id{
                    if let index = ids.firstIndex(of: termId) {
                        userPreferences?.aviation.aviation_preferred_beverage_id?.remove(at: index)
                    }else{
                        userPreferences?.aviation.aviation_preferred_beverage_id?.append(termId)
                    }
                }
            default:
                print("aviation default")
            }
        default:
            print("Others")
        }
        self.collectionView.reloadItems(at: [indexPath])
    }
    
}

extension PrefProductCategoryViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch prefInformationType {
        case .giftHabbits:
            //width is same as collection container's view i.e. full width
            let itemWidth = Int(self.collContainerView.frame.size.width)
            return CGSize(width: itemWidth, height: PrefCollSize.itemHeight.rawValue)
        case .aviationHaveCharteredBefore:  fallthrough
        case .aviationInterestedIn:       fallthrough
        case .aviationPreferredCharter:
            //width is same as collection container's view i.e. full width
            return CGSize(width: PrefCollSize.aviationItemWidth.rawValue, height: PrefCollSize.itemHeight.rawValue)
        default:
            //width is half as collection container's view minus margin
            let itemWidth = Int(self.collContainerView.frame.size.width / 2)  - (PrefCollSize.itemHorizontalMargin.rawValue)
            return CGSize(width: itemWidth, height: PrefCollSize.itemHeight.rawValue)
        }
        
        
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        switch prefInformationType {
        case .aviationHaveCharteredBefore:  fallthrough
        case .aviationInterestedIn:       fallthrough
        case .aviationPreferredCharter:
            return UIEdgeInsets(top: CGFloat(PrefCollSize.itemVerticalMargin.rawValue), left: 0, bottom: 0, right: 0)
        default:
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
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

