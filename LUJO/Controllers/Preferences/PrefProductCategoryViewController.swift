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
    @IBOutlet weak var btnNextStep: UIButton!
    
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.vertical
        let contentView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        contentView.dataSource = self
        contentView.delegate = self
        contentView.register(UINib(nibName: ProdCategoryCollViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: ProdCategoryCollViewCell.identifier)
        contentView.backgroundColor = .clear
        contentView.showsHorizontalScrollIndicator = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    var itemsList: [BaroqueAviationCategory] = [] {
        didSet {
            collectionView.reloadData()
            collectionView.layoutIfNeeded() //forces the reload to happen immediately instead of on the next runloop cycle.
        }
    }
    //to check if any selection has been changed or not, so that we can change the bottom button text to next from skip
    var previouslySelectedItems:[String] = []
    
    private let naHUD = JGProgressHUD(style: .dark)
    var prefType: PrefType!
    var prefInformationType : PrefInformationType!
    var userPreferences: Preferences?
    var preferencesMasterData: PrefMasterData!
    
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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Skip all", style: .plain, target: self, action: #selector(skipTapped))
//        self.contentView.addViewBorder( borderColor: UIColor.white.cgColor, borderWith: 1.0,borderCornerRadius: 12.0)
        self.userPreferences = LujoSetup().getUserPreferences()  //get user preferences from the userdefaults
        self.preferencesMasterData = LujoSetup().getPreferencesMasterData() ?? PrefMasterData() //initialize if not found in the userdefaults
        
        self.collContainerView.addSubview(collectionView)
        applyConstraints()
        
        switch prefType {
        case .aviation:
            imgPreference.image = UIImage(named: "aviation_icon")
            lblPrefLabel.text = "Aviation"
            switch prefInformationType {
            case .aviationAircraftCategory:
                lblPrefQuestion.text = "Preferred aircraft category?"
                if let array = self.userPreferences?.aviation.aviation_aircraft_category_id{
                    previouslySelectedItems = array
                }
                default:
                    print("Others")
            }
        case .yachts:
            imgPreference.image = UIImage(named: "Charter Yacht Icon")
            lblPrefLabel.text = "Yacht"
            switch prefInformationType {
            case .yachtPreferredLength:
                lblPrefQuestion.text = "Preferred length of yacht:"
                if let array = self.userPreferences?.yacht.yacht_length{
                    previouslySelectedItems = array
                }
                default:
                    print("Others")
            }
        default:
            print("Others")
        }
        getPrefCategoryMasterData()
        
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
    
    func getPrefCategoryMasterData() {
        //checking if the master data for preferences is cahced or not
        switch prefType {
        case .aviation:
            switch prefInformationType {
            case .aviationAircraftCategory:
                if let cachedItems = preferencesMasterData.aviationCategories , cachedItems.count > 0{  //if data is already cached or not
                    addSelectiveJets(jets: cachedItems)
                }
            default:
                print("aviationOtherInterests")
            }
        case .yachts:
            switch prefInformationType {
            case .yachtPreferredLength:
                if let cachedItems = preferencesMasterData.yachtLengths , cachedItems.count > 0{  //if data is already cached or not
                    addSelectiveJets(jets: cachedItems)
                }
            default:
                print("yachtOtherInterests")
            }
        default:
            print("main switch")
        }
        if (self.itemsList.count == 0){
            self.showNetworkActivity()
        }
        getPrefCategoryMasterData() {information, error in
            self.hideNetworkActivity()
            if let error = error {
                self.showError(error)
                return
            }
            if let jets = information {
                self.addSelectiveJets(jets:jets)
            } else {
                let error = BackendError.parsing(reason: "Could not obtain Preferences information")
                self.showError(error)
            }
        }
    }
    
    //Server is sending 11 jets while we are going to display only 6 with local stored image
    func addSelectiveJets(jets: [BaroqueAviationCategory]){
        self.itemsList.removeAll()
        switch prefType {
        case .aviation:
            switch prefInformationType {
            case .aviationAircraftCategory:
                //adding items in a order of small to high
                if let found = jets.first(where: {$0.name == "Super light jet"}) {  //6 "Super light jet"
                    self.itemsList.append(found)
                }
                if let found = jets.first(where: {$0.name == "Light jet"}) {    //4     "Light jet"
                    self.itemsList.append(found)
                }
                if let found = jets.first(where: {$0.name == "Super midsize jet"}) {    //7 "Super midsize jet"
                    self.itemsList.append(found)
                }
                if let found = jets.first(where: {$0.name == "Midsize jet"}) {  //11    "Midsize jet"
                    self.itemsList.append(found)
                }
                if let found = jets.first(where: {$0.name == "Heavy jet"}) {    //10    "Heavy jet"
                    self.itemsList.append(found)
                }
                if var found = jets.first(where: {$0.name == "Ultra long range"}) { //1 "Ultra long range"
                    found.name = "Bizliners"
                    self.itemsList.append(found)
                }
            default:
                print("aviationOtherInterests")
            }
        case .yachts:
            switch prefInformationType {
            case .yachtPreferredLength:
                //adding items in a order of small to high
                if let found = jets.first(where: {$0.name == "0-20 meters"}) {
                    self.itemsList.append(found)
                }
                if let found = jets.first(where: {$0.name == "21-40 meters"}) {
                    self.itemsList.append(found)
                }
                if let found = jets.first(where: {$0.name == "41-60 meters"}) {
                    self.itemsList.append(found)
                }
                if let found = jets.first(where: {$0.name == "60+ meters"}) {
                    self.itemsList.append(found)
                }
            default:
                print("yachtOtherInterests")
            }
        default:
            print("main switch")
        }
        
    }
    
    func getPrefCategoryMasterData(completion: @escaping ([BaroqueAviationCategory]?, Error?) -> Void) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            completion(nil, LoginError.errorLogin(description: "User does not exist or is not verified"))
            return
        }
        
        switch prefType {
            case .aviation:
            switch prefInformationType {
                case .aviationAircraftCategory:
                GoLujoAPIManager().getAviationCategories(token) { taxonomies, error in
                    guard error == nil else {
                        Crashlytics.sharedInstance().recordError(error!)
                        let error = BackendError.parsing(reason: "Could not obtain the Preferences information")
                        completion(nil, error)
                        return
                    }
                    //caching master data into userdefaults
                    if taxonomies?.count ?? 0 > 0{
                        self.preferencesMasterData.aviationCategories = taxonomies
                        LujoSetup().store(preferencesMasterData: self.preferencesMasterData)
                    }
                    completion(taxonomies, error)
                }
                default:
                print("aviationOtherInterests")
            }
        case .yachts:
        switch prefInformationType {
            case .yachtPreferredLength:
                let obj1 = BaroqueAviationCategory(id:-1 , name: "0-20 meters")
                let obj2 = BaroqueAviationCategory(id:-1 , name: "21-40 meters")
                let obj3 = BaroqueAviationCategory(id:-1 , name: "41-60 meters")
                let obj4 = BaroqueAviationCategory(id:-1 , name: "60+ meters")
                var array = [BaroqueAviationCategory]()
                array.append(obj1)
                array.append(obj2)
                array.append(obj3)
                array.append(obj4)
                completion(array, nil)
            default:
            print("yachtOtherInterests")
        }
        default:
            print("outer switch")
        }
    }
    
    //when user will click on the next button at the bottom
    @IBAction func btnNextTapped(_ sender: Any) {
        if (isSelectionChanged()){
            var selectedArray = [String]()
            
            switch self.prefType {
            case .aviation:
                switch self.prefInformationType {
                case .aviationAircraftCategory:
                    if let ids = userPreferences?.aviation.aviation_aircraft_category_id{
                        for id in ids {
                            selectedArray.append(id)
                        }
                    }
                default:
                    print("aviation default")
                }
            case .yachts:
                switch self.prefInformationType {
                case .yachtPreferredLength:
                    if let ids = userPreferences?.yacht.yacht_length{
                        for id in ids {
                            selectedArray.append(id)
                        }
                    }
                default:
                    print("yacht default")
                }
            default:
                print("outer switch")
            }
            //if selected array is zero then its mean all previous selection has been un selected
//            if (selectedArray.count > 0) {   //something is there, so convert array to comma sepeated string
                let commaSeparatedString = selectedArray.map{String($0)}.joined(separator: ",")
                setPreferences(commaSeparatedString: commaSeparatedString)
//            }else{
//    //            showCardAlertWith(title: "My Preferences", body: "Please select one option at least.")
//                navigateToNextVC()  //skipping this step
//            }
        }else{
            navigateToNextVC()
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
                if var userPreferences = self.userPreferences{
                    switch self.prefType {
                    case .aviation:
                        switch self.prefInformationType {
                            case .aviationAircraftCategory:
                                let arr = commaSeparatedString.components(separatedBy: ",")
                                userPreferences.aviation.aviation_aircraft_category_id = arr
                                LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                            default:
                                print("Not yet required")
                        }
                    case .yachts:
                        switch self.prefInformationType {
                            case .yachtPreferredLength:
                                let arr = commaSeparatedString.components(separatedBy: ",")
                                userPreferences.yacht.yacht_length = arr
                                LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                            default:
                                print("Not yet required")
                        }
                    default:
                        print("outer switch's default")
                    }
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
                case .aviationAircraftCategory:
                    GoLujoAPIManager().setAviationAircraftCategory(token: token,commaSeparatedString: commaSeparatedString) { contentString, error in
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
                    completion("Success", nil)
            }
        case .yachts:
            switch prefInformationType {
                case .yachtPreferredLength:
                    GoLujoAPIManager().setYachtLength(token: token,commaSeparatedString: commaSeparatedString) { contentString, error in
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
                    completion("Success", nil)
            }
        default:
            print("out switch")
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
        case .yachts:
            switch self.prefInformationType {
            case .yachtPreferredLength:
                let viewController = PrefCollectionsViewController.instantiate(prefType: .yachts, prefInformationType: .yachtType)
                self.navigationController?.pushViewController(viewController, animated: true)
            default:
                self.skipTapped()
            }
        default:
            print("outer switch")
        }
    }
    
    func compare(current:[String] , previous:[String] ) -> Bool{
        if (Set(previous ) == Set(current)){
//            btnNextStep.setTitle("S K I P", for: .normal)
            btnNextStep.setTitle("S A V E", for: .normal)
            return true
        }else{
            btnNextStep.setTitle("S A V E", for: .normal)
            return false
        }
    }
    
    //this method checks the value which were at the time of loading of this screen and current seletion. if loading time value has been changed then button text get changed
    @objc func isSelectionChanged() -> Bool{
        switch self.prefType {
        case .aviation:
            switch self.prefInformationType {
            case .aviationAircraftCategory:
                let current = self.userPreferences?.aviation.aviation_aircraft_category_id ?? []
                let previous = self.previouslySelectedItems
                return !compare(current: current , previous: previous)
            default:
                print("This will not call")
            }
        case .yachts:
            switch self.prefInformationType {
            case .yachtPreferredLength:
                let current = self.userPreferences?.yacht.yacht_length ?? []
                let previous = self.previouslySelectedItems
                return !compare(current: current , previous: previous)
            default:
                print("This will not call")
            }
        default:
            print("default of outer switch")
        }
        return true
    }
    
    //@objc func skipTapped(sender: UIBarButtonItem){
    @objc func skipTapped(){
        if let viewController = navigationController?.viewControllers.first(where: {$0 is PreferencesHomeViewController}) {
            //if user came from my preferences
            navigationController?.popToViewController(viewController, animated: true)
        }else if let viewController = navigationController?.viewControllers.first(where: {$0 is PerCityViewController}) {
            //if user came from per city view controler
            navigationController?.popToViewController(viewController, animated: true)
        }else if let viewController = navigationController?.viewControllers.first(where: {$0 is ProductsViewController}) {
            //if user came from Products view controler
            navigationController?.popToViewController(viewController, animated: true)
        }else if let viewController = navigationController?.viewControllers.first(where: {$0 is AviationViewController}) {
            //if user came from Aviation view controler
            navigationController?.popToViewController(viewController, animated: true)
        }else{
            //if user came from home screen
            self.navigationController?.popToRootViewController(animated: true)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProdCategoryCollViewCell.identifier, for: indexPath) as! ProdCategoryCollViewCell
        
        let model = itemsList[indexPath.row]
        cell.lblTitle.text = model.name
        cell.lblTitle.textColor = UIColor.white
        cell.imgProduct.image = UIImage(named:model.name)
        
        switch self.prefType {
        case .aviation:
            switch self.prefInformationType {
            case .aviationAircraftCategory:
                if let ids = userPreferences?.aviation.aviation_aircraft_category_id{
                    if (ids.contains(String(model.id))){
                        cell.lblTitle.textColor = UIColor.rgMid
                        cell.imgProduct.image = UIImage(named: model.name + " selected")
                    }
                }
            default:
                print("aviation default")
            }
        case .yachts:
            switch self.prefInformationType {
            case .yachtPreferredLength:
                if let ids = userPreferences?.yacht.yacht_length{
                    if (ids.contains(String(model.name))){
                        cell.lblTitle.textColor = UIColor.rgMid
                        cell.imgProduct.image = UIImage(named: model.name + " selected")
                    }
                }
            default:
                print("yacht default")
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
        let termId = String(itemsList[indexPath.row].id)
        let name = String(itemsList[indexPath.row].name)
        
        switch self.prefType {
        case .aviation:
            switch self.prefInformationType {
            case .aviationAircraftCategory:
                if var ids = userPreferences?.aviation.aviation_aircraft_category_id{
                    if ids.contains(termId){
                        //remove all occurances in case there is duplication i.e. dirty data
                        ids.removeAll{ value in return value == termId}
                        userPreferences?.aviation.aviation_aircraft_category_id = ids
                    }else{
                        userPreferences?.aviation.aviation_aircraft_category_id?.append(termId)
                    }
                }else{
                    userPreferences?.aviation.aviation_aircraft_category_id = []    //initializing first
                    userPreferences?.aviation.aviation_aircraft_category_id?.append(termId)
                }
                isSelectionChanged()
                self.collectionView.reloadItems(at: [indexPath])
            default:
                print("aviation default")
            }
        case .yachts:
            switch self.prefInformationType {
            case .yachtPreferredLength:
                if var ids = userPreferences?.yacht.yacht_length{
                    if ids.contains(name){
                        //remove all occurances in case there is duplication i.e. dirty data
                        ids.removeAll{ value in return value == name}
                        userPreferences?.yacht.yacht_length = ids
                    }else{
                        userPreferences?.yacht.yacht_length?.append(name)
                    }
                }else{
                    userPreferences?.yacht.yacht_length = []    //initializing first
                    userPreferences?.yacht.yacht_length?.append(name)
                }
                isSelectionChanged()
                self.collectionView.reloadItems(at: [indexPath])
            default:
                print("yacht default")
            }
        default:
            print("Others")
        }
    }
    
}

extension PrefProductCategoryViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = Int(collectionView.bounds.size.width)
        let height = PrefCollSize.itemCategoryHeight.rawValue + (5 * indexPath.row )
//        print(width,height)
        switch prefInformationType {
        default:
            return CGSize(width: width, height: height)
        }
        
        
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        switch prefInformationType {
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
        return CGFloat(PrefCollSize.itemCategoryVerticalMargin.rawValue)
    }
    
    
}

