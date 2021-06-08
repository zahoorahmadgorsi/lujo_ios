//
//  MyPreferencesViewController.swift
//  LUJO
//
//  Created by iMac on 06/05/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import UIKit
import JGProgressHUD

class PrefImagesCollViewController: UIViewController {
    
    //MARK: - 🎲 - Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "PrefImagesCollViewController" }
    
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
        contentView.register(UINib(nibName: PrefImageCollViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: PrefImageCollViewCell.identifier)
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
    //to check if any selection has been changed or not, so that we can change the bottom button text to next from skip
    var previouslySelectedItems:[String] = []
    
    private let naHUD = JGProgressHUD(style: .dark)
    var prefType: PrefType!
    var prefInformationType : PrefInformationType!
    var userPreferences: Preferences?
    var preferencesMasterData: PrefMasterData!
    var cellWidth : Int = 84
    var cellHeight : Int = 114
    
    /// Init method that will init and return view controller.
    //class func instantiate(user: LujoUser) -> MyPreferencesViewController {
    class func instantiate(prefType: PrefType, prefInformationType : PrefInformationType) -> PrefImagesCollViewController {
        let viewController = UIStoryboard.preferences.instantiate(identifier) as! PrefImagesCollViewController
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
        
        txtPleaseSpecify.addTarget(self,
                             action: #selector(isSelectionChanged),
                             for: .editingChanged)
        
        switch prefType {
            case .travel:
                imgPreference.image = UIImage(named: "Find Hotel Icon")
                lblPrefLabel.text = "Travel"
                switch prefInformationType {
                case .travelDestinationType:
                    lblPrefQuestion.text = "Destination type preferences:"
//                    txtPleaseSpecify.text = self.userPreferences?.travel.event_category_id_other
                    txtPleaseSpecify.isHidden = true
                    previouslySelectedItems = self.userPreferences?.travel.travel_destination_type ?? []
                default:
                    print("default of travel")
                }
            default:
                print("Others")
        }
        getPrefMasterData()
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
    
    func getPrefMasterData() {
        //checking if the master data for preferences is cahced or not
        switch prefType {
        case .travel:
            switch prefInformationType {
            case .travelDestinationType:
//                if let cachedItems = preferencesMasterData.travelDestinationTypes , cachedItems.count > 0{  //if data is already cached or not
//                    self.itemsList = cachedItems
//                }
                let taxonomyObj1 = Taxonomy(termId:-1 , name: "Adventure")
                let taxonomyObj2 = Taxonomy(termId:-1 , name: "Ski")
                let taxonomyObj3 = Taxonomy(termId:-1 , name: "Beach")
                let taxonomyObj4 = Taxonomy(termId:-1 , name: "Nature")
                let taxonomyObj5 = Taxonomy(termId:-1 , name: "Urban")
                let taxonomyObj6 = Taxonomy(termId:-1 , name: "Wellness")
                var taxonomies = [Taxonomy]()
                taxonomies.append(taxonomyObj1)
                taxonomies.append(taxonomyObj2)
                taxonomies.append(taxonomyObj3)
                taxonomies.append(taxonomyObj4)
                taxonomies.append(taxonomyObj5)
                taxonomies.append(taxonomyObj6)
                self.itemsList = taxonomies
            default:
                print("default of travel")
            }
        default:
            print("Others")
        }
        
        if (self.itemsList.count == 0){
            self.showNetworkActivity()  //if no data is cached then fetch openly else silently
        }
        getPrefMasterData() {taxonomies, error in
            self.hideNetworkActivity()
            if let error = error {
                self.showError(error)
                return
            }
            if let informations = taxonomies {
                if informations.count > 0{  //it will contain zero in case of hard coded values
                    self.itemsList = informations
                }
                
            } else {
                let error = BackendError.parsing(reason: "Could not obtain Preferences information")
                self.showError(error)
            }
        }
    }

    func getPrefMasterData(completion: @escaping ([Taxonomy]?, Error?) -> Void) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            completion(nil, LoginError.errorLogin(description: "User does not exist or is not verified"))
            return
        }

        switch prefType {
        case .travel:
            switch prefInformationType {
            case .travelDestinationType:
                print("Not required for hard coded data")
                completion(self.itemsList, nil)
//                GoLujoAPIManager().getTravelDestinationType(token) { taxonomies, error in
//                    guard error == nil else {
//                        Crashlytics.sharedInstance().recordError(error!)
//                        let error = BackendError.parsing(reason: "Could not obtain travel information")
//                        completion(nil, error)
//                        return
//                    }
//                    //caching master data into userdefaults
//                    if taxonomies?.count ?? 0 > 0{
//                        self.preferencesMasterData.travelDestinationTypes = taxonomies
//                        LujoSetup().store(preferencesMasterData: self.preferencesMasterData)
//                    }
//                    completion(taxonomies, error)
//                }
            default:
                print("default of travel")
            }
        default:
            print("Others")
        }
    }
    
    //when user will click on the next button at the bottom
    @IBAction func btnNextTapped(_ sender: Any) {
        if (isSelectionChanged()){
            let valueSpecified:Int? = Int(txtPleaseSpecify.text ?? "") // firstText is UITextField
//            print(valueSpecified as Any)
            if (valueSpecified != nil) { //!= nill mean value has been typecasted hence its a numeric value
                // number is not allowed but alphanumeric
                let error = PreferenceError.onlyAlphaNumeric(reason: "Please specify a valid value")
                self.showError(error)
                return
            }
            
            var selectedArray = [String]()
            
            switch self.prefType {
            case .travel:
                switch prefInformationType {
                case .travelDestinationType:
                    if let ids = userPreferences?.travel.travel_destination_type{
                        for id in ids {
                            if id.count > 0{ //to avoid empty string
                                selectedArray.append(id)
                            }
                        }
                    }
                default:
                    print("default of travel")
             }
            default:
                print("Default of main switch")
            }
            if (selectedArray.count > 0 || txtPleaseSpecify.text?.count ?? 0 > 0) {   //something is there, so convert array to comma sepeated string
                let commaSeparatedString = selectedArray.map{String($0)}.joined(separator: ",")
                setPreferences(commaSeparatedString: commaSeparatedString)
            }
            else{
                print("This line must not execute")
            }
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
                    let arr = commaSeparatedString.components(separatedBy: ",")
                    switch self.prefType {
                    case .travel:
                        switch self.prefInformationType {
                        case .travelDestinationType:
                            if arr.count > 0 && arr[0].count > 0{   //avoid empty string
                                userPreferences.travel.travel_destination_type = arr
                            }
//                            userPreferences.travel.event_category_id_other = self.txtPleaseSpecify.text
                            LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                        default:
                            print("default of travel")
                     }
                    default:
                        print("Default of main switch")
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
        case .travel:
            switch prefInformationType {
            case .travelDestinationType:
                GoLujoAPIManager().setTravelDestinationType(token: token,commaSeparatedString: commaSeparatedString) { contentString, error in
                    guard error == nil else {
                        Crashlytics.sharedInstance().recordError(error!)
                        let error = BackendError.parsing(reason: "Could not set the Preferences information")
                        completion(nil, error)
                        return
                    }
                    completion(contentString, error)
                }
                
//                GoLujoAPIManager().setEventLocation(token: token,commaSeparatedString: commaSeparatedString) { contentString, error in
//                    guard error == nil else {
//                        Crashlytics.sharedInstance().recordError(error!)
//                        let error = BackendError.parsing(reason: "Could not set the Preferences information")
//                        completion(nil, error)
//                        return
//                    }
//                    completion(contentString, error)
//                }
            default:
                print("default of travel")
            }
        default:
            print("Main switch default ")
        }
    }
    
    func navigateToNextVC(){
        switch self.prefType {
        case .travel:
            switch prefInformationType {
            case .travelDestinationType:
                let viewController = PrefImagesCollViewController.instantiate(prefType: .travel, prefInformationType: .travelHotelGroups)
                self.navigationController?.pushViewController(viewController, animated: true)
            default:
                print("default of travel")
        }
        default:
            print("default of main switch")
        }
    }
    
    //this method checks the value which were at the time of loading of this screen and current seletion. if loading time value has been changed then button text get changed
    @objc func isSelectionChanged() -> Bool{
        switch self.prefType {
        case .travel:
            switch prefInformationType {
            case .travelDestinationType:
                let current = self.userPreferences?.travel.travel_destination_type ?? []
                let previous = self.previouslySelectedItems
                return !compare(current: current , previous: previous)
                
//                let current = self.userPreferences?.event.event_category_id ?? []
//                let previous = self.previouslySelectedItems
//                let previouslyTypedStr = self.userPreferences?.event.event_category_id_other ?? ""
//                return !compare(current: current , previous: previous, previousTypedStr:previouslyTypedStr)
            default:
                print("default of travel")
        }
        default:
            print("default clause of main switch")
        }
        return true
    }
    
    func compare(current:String , previous:String) -> Bool{
        if previous == current{
            btnNextStep.setTitle("S K I P", for: .normal)
            return true
        }else{
            btnNextStep.setTitle("S A V E", for: .normal)
            return false
        }
    }
    
    func compare(current:[String] , previous:[String] , previousTypedStr:String? = nil) -> Bool{
        let currentTypedStr = self.txtPleaseSpecify.text
        if (Set(previous ) == Set(current) && (previousTypedStr ?? currentTypedStr == self.txtPleaseSpecify.text)){
            btnNextStep.setTitle("S K I P", for: .normal)
            return true
        }else{
            btnNextStep.setTitle("S A V E", for: .normal)
            return false
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

extension PrefImagesCollViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PrefImageCollViewCell.identifier, for: indexPath) as! PrefImageCollViewCell
        let model = itemsList[indexPath.row]
        cell.lblTitle.text = model.name
        
        
        switch self.prefType {
        case .travel:
            switch prefInformationType {
            case .travelDestinationType:
                cell.imgView.image = UIImage(named: model.name + " travel")
                if let ids = userPreferences?.travel.travel_destination_type{
                    if (ids.contains(model.name)){
                        cell.viewContent.addViewBorder( borderColor: UIColor.rgMid.cgColor, borderWith: 1.0, borderCornerRadius: 12.0)
                    }else{
                        cell.viewContent.addViewBorder( borderColor: UIColor.clear.cgColor, borderWith: 1.0, borderCornerRadius: 12.0)
                    }
                }

            default:
                print("default of travel")
         }
        default:
            print("default statement of main switch")
        }

        return cell
        // swiftlint:enable force_cast
    }
}

extension PrefImagesCollViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let termId = String(itemsList[indexPath.row].termId)
        let name = String(itemsList[indexPath.row].name)
        
        switch self.prefType {
        case .travel:
        switch prefInformationType {
        case .travelDestinationType:
            if var ids = userPreferences?.travel.travel_destination_type{
                if ids.contains(name){
                    //remove all occurances in case there is duplication i.e. dirty data
                    ids.removeAll{ value in return value == name}
                    userPreferences?.travel.travel_destination_type = ids
                }else{
                    userPreferences?.travel.travel_destination_type?.append(name)
                }
            }else{
                userPreferences?.travel.travel_destination_type = []    //initializing first
                userPreferences?.travel.travel_destination_type?.append(name)
            }
        default:
            print("default of travel")
        }
        default:
            print("default statement of main switch")
        }
        self.collectionView.reloadItems(at: [indexPath])    //only refresh current selection
        isSelectionChanged()
    }
}

extension PrefImagesCollViewController: UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: CGFloat(PrefCollSize.itemMargin.rawValue), left: CGFloat(PrefCollSize.itemMargin.rawValue), bottom: 0, right: CGFloat(PrefCollSize.itemMargin.rawValue))
    }
    
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

