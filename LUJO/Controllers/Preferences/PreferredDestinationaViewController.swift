//
//  MyPreferencesViewController.swift
//  LUJO
//
//  Created by iMac on 06/05/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import UIKit
import JGProgressHUD

class PreferredDestinationaViewController: UIViewController, UITextFieldDelegate, DestinationSearchViewDelegate,AirportSearchViewDelegate  {
    //MARK: - 🎲 - Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "PreferredDestinationaViewController" }
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var imgPreference: UIImageView!
    @IBOutlet weak var lblPrefLabel: UILabel!
    @IBOutlet weak var lblPrefQuestion: UILabel!
    @IBOutlet weak var txtPreferredDestination: UITextField!
    @IBOutlet weak var collContainerView: UIView!
    var userPreferences: Preferences?
    @IBOutlet weak var btnNextStep: UIButton!
    
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.vertical
        let contentView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        contentView.dataSource = self
        contentView.delegate = self
        contentView.register(UINib(nibName: AirportCollViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: AirportCollViewCell.identifier)
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
    //to check if any selection has been changed or not, so that we can change the bottom button text to next from skip
    var previouslySelectedItems:[Taxonomy] = []
    
    /// Init method that will init and return view controller.
    //class func instantiate(user: LujoUser) -> MyPreferencesViewController {
    class func instantiate(prefType: PrefType, prefInformationType : PrefInformationType) -> PreferredDestinationaViewController {
        let viewController = UIStoryboard.preferences.instantiate(identifier) as! PreferredDestinationaViewController
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
        txtPreferredDestination.delegate = self //to make it uneditable
        self.collContainerView.addSubview(collectionView)
        applyConstraints()
        self.userPreferences = LujoSetup().getUserPreferences()  //get user preferences from the userdefaults
        
        switch prefType {
            case .aviation:
                imgPreference.image = UIImage(named: "aviation_icon")
                lblPrefLabel.text = "Aviation"
                switch prefInformationType {
                case .aviationPreferredDestination:
                    lblPrefQuestion.text = "What are your top preferred destinations?"
                    txtPreferredDestination.text = "Destination City, State or Country"
                    if let destinations = self.userPreferences?.aviation.aviation_preferred_destinations{
                        var taxonomies = [Taxonomy]()
                        for item in  destinations {
                            let taxonomy = Taxonomy(termId: Int(item) ?? -1 , name: item)
                            taxonomies.append(taxonomy)
                        }
                        previouslySelectedItems = taxonomies
                        self.itemsList = taxonomies
                    }
                case .aviationPreferredAirport:
                    lblPrefQuestion.text = "Which airport do you want to fly more often?"
                    txtPreferredDestination.text = "Destination Airport"
                    if let airports = self.userPreferences?.aviation.aviation_preferred_airports{
                        var taxonomies = [Taxonomy]()
                        for item in  airports {
                            let taxonomy = Taxonomy(termId: Int(item) ?? -1 , name: item)
                            taxonomies.append(taxonomy)
                        }
                        previouslySelectedItems = taxonomies
                        self.itemsList = taxonomies
                    }
//                        btnNextStep.setTitle("D O N E", for: .normal)
                    default:
                        print("Others")
                }
            default:
                print("Others")
        }
        
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
    
    //when user will click on the back button at the bottom
    @IBAction func btnNextTapped(_ sender: Any) {
        if (isSelectionChanged()){
            var selectedArray = [String]()
            for item in itemsList{
                //selectedArray.append(item.termId)   //taking all selected termdID into array
                selectedArray.append(item.name)   //taking all selected name into array
            }
            if (selectedArray.count > 0) {   //something is there, so convert array to comma sepeated string
                let commaSeparatedString = selectedArray.map{String($0)}.joined(separator: ",")
                setPreferences(commaSeparatedString: commaSeparatedString)
            }else{
                navigateToNextVC()  //skipping this step
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
                    switch self.prefType {
                    case .aviation:
                        switch self.prefInformationType {
                            case .aviationPreferredDestination:
                                let arr = commaSeparatedString.components(separatedBy: ",")
                                userPreferences.aviation.aviation_preferred_destinations = arr
                                LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                            case .aviationPreferredAirport:
                                let arr = commaSeparatedString.components(separatedBy: ",")
                                userPreferences.aviation.aviation_preferred_airports = arr  
                                LujoSetup().store(userPreferences: userPreferences)//saving user preferences into user defaults
                            default:
                                print("Not yet required")
                        }
                        default:
                            print("Others")
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
                case .aviationPreferredDestination:
                    GoLujoAPIManager().setAviationPreferredDestinations(token: token,commSepeartedString: commaSeparatedString) { contentString, error in
                        guard error == nil else {
                            Crashlytics.sharedInstance().recordError(error!)
                            let error = BackendError.parsing(reason: "Could not obtain the Preferences information")
                            completion(nil, error)
                            return
                        }
                        completion(contentString, error)
                    }
            case .aviationPreferredAirport:
                GoLujoAPIManager().setAviationPreferredAirports(token: token,commSepeartedString: commaSeparatedString) { contentString, error in
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
                print("Others")
        }
    }
    
    func navigateToNextVC(){
        switch self.prefType {
        case .aviation:
            switch self.prefInformationType {
            case .aviationPreferredDestination:
                let viewController = PreferredDestinationaViewController.instantiate(prefType: .aviation, prefInformationType: .aviationPreferredAirport)
                self.navigationController?.pushViewController(viewController, animated: true)
            case .aviationPreferredAirport:
                let viewController = PrefProductCategoryViewController.instantiate(prefType: .aviation, prefInformationType: .aviationAircraftCategory)
                self.navigationController?.pushViewController(viewController, animated: true)
            default:
                self.skipTapped()
            }
            default:
                print("Others")
        }
    }
    
    func compare(current:[String] , previous:[String] ) -> Bool{
        if (Set(previous ) == Set(current)){
            btnNextStep.setTitle("S K I P", for: .normal)
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
            case .aviationPreferredDestination: fallthrough
            case .aviationPreferredAirport:
                let current = self.itemsList.map{$0.name}
                let previous = self.previouslySelectedItems.map{$0.name}
                return !compare(current: current , previous: previous)
            default:
                print("This will not call")
            }
            default:
                print("Others")
        }
        return true
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
    
    //making preffered destination field uneditable
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txtPreferredDestination {

            switch self.prefType {
            case .aviation:
                switch self.prefInformationType {
                case .aviationPreferredDestination:
                    let viewController = DestinationSelectionViewController.instantiate()
                    viewController.delegate = self
                    present(viewController, animated: true, completion: nil)
                    return false
                case .aviationPreferredAirport:
                    let viewController = AviationAirportSelectionViewController.instantiate(destination: .returnAirport)
                    viewController.delegate = self
                    present(viewController, animated: true, completion: nil)
                    return false
                default:
                    self.skipTapped()
                }
                default:
                    print("Others")
            }
        }
        return true
    }
    
    //WHen user has selected some destination airpot
    func select(_ airport: Airport, forOrigin: OriginAirport) {
        let airportId = Int(airport.id.split(separator: "-")[1]) //BA is sending airport Id as a string in this format "id": "aport-26805"
        let taxonomy = Taxonomy(termId: airportId ?? -1 , name: airport.name)
        if !itemsList.contains(where: {$0.name == taxonomy.name}){//only add if already not added
            itemsList.append(taxonomy)
            self.collectionView.reloadData()
            isSelectionChanged()
        }else{
            print("Already exists")
        }
    }
    
    //WHen user has selected some destination airpot
    func select(_ destination: Taxonomy) {
//        print("Preferred Destination:\(destination.termId)")
        if !itemsList.contains(where: {$0.name == destination.name}){//only add if already not added
            itemsList.append(destination)
            self.collectionView.reloadData()
            isSelectionChanged()
        }else{
            print("Already exists")
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

extension PreferredDestinationaViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AirportCollViewCell.identifier, for: indexPath) as! AirportCollViewCell
        let model = itemsList[indexPath.row]
        cell.lblTitle.text = model.name

        return cell
        // swiftlint:enable force_cast
    }
    
    
}



extension PreferredDestinationaViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print(self.itemsList.count,indexPath.row)
        self.collectionView.deleteItems(at: [indexPath])
        self.itemsList.remove(at: indexPath.row)
        isSelectionChanged()
    }
}

extension PreferredDestinationaViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = Int(collectionView.bounds.size.width)
//        let itemWidth = Int(self.collContainerView.frame.size.width / 2)  - (PrefCollSize.itemMargin.rawValue)
//        return CGSize(width: itemWidth, height: PrefCollSize.itemHeight.rawValue)
        let itemWidth = Int(width / 2)  - PrefCollSize.itemMargin.rawValue / 2    //to keep horizontal and vertical margin same
        print(width , itemWidth)
        return CGSize(width: itemWidth, height: PrefCollSize.itemHeight.rawValue)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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
        return CGFloat(PrefCollSize.itemMargin.rawValue)
    }
    
    
}

