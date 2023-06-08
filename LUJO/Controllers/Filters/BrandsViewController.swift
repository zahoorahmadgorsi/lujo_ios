//
//  BrandsViewController.swift
//  LUJO
//
//  Created by Zahoor Gorsi on 23/02/2023.
//  Copyright © 2023 Baroque Access. All rights reserved.
//

import UIKit
import JGProgressHUD
import FirebaseCrashlytics

protocol BrandsSelectionProtocol{
    func passBackPickedItems(currentFilterType:GiftFilterType,pickedItems: [Taxonomy])
}

enum GiftFilterType : String{
    case brands, categories, colors
}

class BrandsViewController: UIViewController {
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "BrandsViewController" }
    private let naHUD = JGProgressHUD(style: .dark)
    var items = [Taxonomy]()
    var searchedItems = [Taxonomy]()
    var currentFilterType:GiftFilterType = .brands
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var collectionViewParent: UIView!
    
    var itemWidth:Int = 125
    var itemHeight:Int = 36
    var itemMargin:Int = 8
    
    var searching = false
    
    private(set) lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshConversations), for: .valueChanged)
        return control
    }()
    
    /// Init method that will init and return view controller.
    class func instantiate(currentFilterType:GiftFilterType,
                           alreadyPickedItems: [Taxonomy]? = [],
                           delegate:BrandsSelectionProtocol) -> BrandsViewController {
        let viewController = UIStoryboard.filters.instantiate(identifier) as! BrandsViewController
//        return UIStoryboard.filters.instantiate(identifier)
        viewController.currentFilterType = currentFilterType
        //viewController.alreadyPickedItems = alreadyPickedItems ?? []
        viewController.pickedItems = alreadyPickedItems ?? []
        viewController.delegate = delegate
        return viewController
    }

    let tagsCell = AirportCollViewCell()
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let contentView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        contentView.dataSource = self
        contentView.delegate = self
        contentView.register(UINib(nibName: tagsCell.identifier, bundle: nil), forCellWithReuseIdentifier: tagsCell.identifier)
        contentView.backgroundColor = .clear
        contentView.showsHorizontalScrollIndicator = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
//    var alreadyPickedItems: [Taxonomy] = [] // items which user has picked previously when filter was applied
    var pickedItems: [Taxonomy] = [] {
        didSet {
            collectionView.reloadData()
//            var _pickedItemsViewHeight = 0.0
//            let _textFieldHeight = self.txtName.isHidden == true ? 0 : self.txtName.frame.height
////            if self.scrollDirection == .horizontal {    //all selected items are being shown in one row
//                _pickedItemsViewHeight = pickedItems.count > 0 ? Double(self.itemHeight + 24) : 16  //24 and 16 are margins
////            }else if self.scrollDirection == .vertical {    //all selected items are being shown in one row
////                _pickedItemsViewHeight = pickedItems.count > 0 ? Double((pickedItems.count * (self.itemHeight + self.itemMargin) )) : 0.0
////            }
////            //setting the view height to dynamic
//            self.fullViewHeight.constant =  self.titleView.frame.height + _textFieldHeight + _pickedItemsViewHeight
////            print("title Height: \(self.titleView.frame.height)", "text Field Height: \(_textFieldHeight)")
////            print("picked Items View Height: \(_pickedItemsViewHeight)","view full Height: \(self.fullViewHeight.constant)"  )
//            self.collectionView.layoutIfNeeded()
        }
    }
    var delegate:BrandsSelectionProtocol?
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        self.view.addViewBorder(borderColor: UIColor.clear.cgColor, borderWidth: 1.0, borderCornerRadius: 24.0)
        self.tblView.dataSource = self;
        self.tblView.delegate = self;
        self.tblView.refreshControl = refreshControl
        
        if currentFilterType == .brands{
            self.title = "Brands"
        }else if currentFilterType == .categories{
            self.title = "Categories"
        }else if currentFilterType == .colors{
            self.title = "Colors"
        }
        
//        createRightBarButtons()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear All", style: .plain, target: self, action: #selector(clearAllTapped))
        
        collectionViewParent.addSubview(collectionView)
        setupLayout()
//        loadFromUserDefaults()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        
        if (self.items.count == 0){
            self.getItems(showActivity: true)   //activity indicator is required to stop user from interacting with the grid
        }else{
            self.tblView.reloadData()
            self.getItems(showActivity: false)    //silently loading the items.
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @objc func clearAllTapped() {
        //setting is selected to false to all items
        items.indices.forEach {
            items[$0].isSelected = false
        }
        //emptying picked items
        self.pickedItems = []
        delegate?.passBackPickedItems(currentFilterType: self.currentFilterType,
                                     pickedItems: self.pickedItems)
        //reloading table view and collection view
        self.tblView.reloadData()
        self.collectionView.reloadData()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate(
            [collectionView.topAnchor.constraint(equalTo: collectionViewParent.topAnchor),
             collectionView.bottomAnchor.constraint(equalTo: collectionViewParent.bottomAnchor),
             collectionView.leadingAnchor.constraint(equalTo: collectionViewParent.leadingAnchor),
             collectionView.trailingAnchor.constraint(equalTo: collectionViewParent.trailingAnchor)]
        )
    }
    
    private func setupSearchBar(){
        self.searchBar.delegate = self
        //Change the color of the glass icon
        let glassIconView = self.searchBar.searchTextField.leftView as! UIImageView
        glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
        glassIconView.tintColor = UIColor.rgMid
//        Change the color of the text field inside the search bar:
        let searchTextField = self.searchBar.searchTextField
        searchTextField.textColor = UIColor.white
//        searchTextField.clearButtonMode = .never
//        Hide or show the Cancel button on the right side of search bar:
//        self.searchBar.showsCancelButton = true
    }
    
    //this method creates the cross and edit button, on tap of this button, UIViewcontroller is closed
//    private func createRightBarButtons(){
//        let imgCross    = UIImage(named: "cross")!
//        let btnCross   = UIBarButtonItem(image: imgCross,  style: .plain, target: self, action: #selector(imgCrossTapped(_:)))
//        navigationItem.rightBarButtonItems = [btnCross]   //order is first and second (right to left)
//    }
//    
//    @objc func imgCrossTapped(_ sender: Any) {
//        if self.isModal{    //almost from all over the application
//            self.dismiss(animated: true, completion:{
//                self.presentationController?.delegate?.presentationControllerDidDismiss?(self.presentationController!)
//            })
//        }else if let navController = self.navigationController { //from the preferences screen
//            navController.popViewController(animated: true)
//        }
//    }
    
    @objc func refreshConversations() {
        self.refreshControl.beginRefreshing()
        getItems(showActivity: false)
    }
    
    func getItems(showActivity: Bool) {
        if showActivity {
            self.showNetworkActivity()
        }
        getItems() {information, error in
            self.refreshControl.endRefreshing()
            self.hideNetworkActivity()
            
            if let error = error {
                self.showError(error)
                return
            }
            
            if let items = information {
                self.items = items

                
                self.tblView.reloadData()
            } else {
                if error?._code == 403{
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.logoutUser()
                }else{
                    let error = BackendError.parsing(reason: "Could not obtain push notifications")
                    self.showError(error)
                }
            }
              //making it false at the last so that if its success or failure loading should become false
        }
    }
    
    func getItems(completion: @escaping ([Taxonomy]?, Error?) -> Void) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            completion(nil, LoginError.errorLogin(description: "User does not exist or is not verified"))
            return
        }
        
        if currentFilterType == .brands{
            GoLujoAPIManager().getBrands() { data, error in
                guard error == nil else {
                    Crashlytics.crashlytics().record(error: error!)
                    if error?._code == 403{
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.logoutUser()
                    }else{
                        let error = BackendError.parsing(reason: "Could not obtain the gift brands")
                        completion(nil, error)
                    }
                    return
                }
                completion(data, error)
            }
        }else if currentFilterType == .categories{
            GoLujoAPIManager().getCategories() { data, error in
                guard error == nil else {
                    Crashlytics.crashlytics().record(error: error!)
                    //unauthorized token, so forcefully signout the user
                    if error?._code == 403{
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.logoutUser()
                    }else{
                        let error = BackendError.parsing(reason: "Could not obtain the gift categories")
                        completion(nil, error)
                    }
                    return
                }
                completion(data, error)
            }
        }else if currentFilterType == .colors{
            GoLujoAPIManager().getColors() { data, error in
                guard error == nil else {
                    //unauthorized token, so forcefully signout the user
                    Crashlytics.crashlytics().record(error: error!)
                    if error?._code == 403{
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.logoutUser()
                    }else{
                        let error = BackendError.parsing(reason: "Could not obtain the gift colors")
                        completion(nil, error)
                    }
                    return
                }
                completion(data, error)
            }
        }
    }
    
    func showError(_ error: Error , isInformation:Bool = false) {
        if (isInformation){
            showErrorPopup(withTitle: "Information", error: error)
        }else{
            showErrorPopup(withTitle: "Gift Filter Error", error: error)
        }
        
    }
    
    func showNetworkActivity() {
        // Safe guard to that won't display both loaders at same time.
        if !refreshControl.isRefreshing {
            naHUD.show(in: view)
        }
    }
    
    func hideNetworkActivity() {
        // Safe guard that will call dismiss only if HUD is shown on screen.
        if naHUD.isVisible {
            naHUD.dismiss()
        }
    }
    
    
    @IBAction func btnApplyTapped(_ sender: Any) {
        print("btnApplyTapped")
        delegate?.passBackPickedItems(currentFilterType: self.currentFilterType, pickedItems: self.pickedItems)
        navigationController?.popViewController(animated: true)
    }
}

extension BrandsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidth, height: itemHeight)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(itemMargin)
//        return 0
    }
}

extension BrandsViewController: UITableViewDelegate, UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            if self.searchedItems.count == 0 {
                self.tblView.setEmptyMessage("No data is available having this title.")
            }else{
                self.tblView.restore()
            }
            return self.searchedItems.count
        } else {
            if self.items.count == 0 {
                self.tblView.setEmptyMessage("No data is available")
            }else{
                self.tblView.restore()
            }
            return self.items.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "brandsCell") as! BrandCell
        var model = items[indexPath.row]
        if searching {
            model = searchedItems[indexPath.row]
        }
        //if user has already picked this filter then show it as selected, set isSelected to true for all
        //if self.alreadyPickedItems.contains(where: ({$0.termId == model.termId})){
        if self.pickedItems.contains(where: ({$0.termId == model.termId})){
            model.isSelected = true
            if searching {
                searchedItems[indexPath.row].isSelected = true
            }else{
                items[indexPath.row].isSelected = true
            }
        }
        cell.lblTitle.text = model.name
        cell.imgView.image = model.isSelected == true ? UIImage(named: "filters_check") : UIImage(named: "filters_uncheck")

//        self.tblView.separatorStyle = .singleLine
//        self.tblView.separatorColor = .lightGray
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt")
        if searching {
            if self.searchedItems.count >= indexPath.row{
                self.searchedItems[indexPath.row].isSelected = !( self.searchedItems[indexPath.row].isSelected ?? false)
                self.pickedItems = self.searchedItems.filter({$0.isSelected == true})
                //if search mode is on then keep track of selected items in full set of items
                if let i = self.items.firstIndex(where: {$0.termId == self.searchedItems[indexPath.row].termId}){
                    self.items[i].isSelected = !( self.items[i].isSelected ?? false)
                }
            }
        }else{
            if self.items.count >= indexPath.row{
                self.items[indexPath.row].isSelected = !( self.items[indexPath.row].isSelected ?? false)
                //self.pickedItems = self.items.filter({$0.isSelected == true})
                if self.items[indexPath.row].isSelected ?? true{
                    self.pickedItems.append(self.items[indexPath.row])
                }else{
                    self.pickedItems.removeAll(where: ({$0.termId == self.items[indexPath.row].termId}))
                }
            }
        }
        
        self.collectionView.reloadData()
        self.tblView.reloadData()
        
    }
    

}

extension BrandsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedItems = items.filter {
            $0.name.range(of: searchText , options: .caseInsensitive) != nil
        }
        searching = searchText.count > 0 ? true : false
        self.tblView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        self.tblView.reloadData()
    }
}

extension BrandsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pickedItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if var cell = collectionView.dequeueReusableCell(withReuseIdentifier: tagsCell.identifier, for: indexPath) as? AirportCollViewCell{
//            cell.delegate = self
            let model = pickedItems[indexPath.row]
            cell.setTitle(title: model.name)
            
            return cell as! UICollectionViewCell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //when tapped on the cell it should be removed in case of tags, event category, villa lifestyle etc
        self.collectionView.deleteItems(at: [indexPath])
        let _temp = self.pickedItems[indexPath.row]
        self.pickedItems.remove(at: indexPath.row)
        
        //remove this item from full tableview as well
        if let i = self.items.firstIndex(where: {$0.termId == _temp.termId}){
            self.items[i].isSelected = false
        }
        //remove this item from searched tableview as well
        if let i = self.searchedItems.firstIndex(where: {$0.termId == _temp.termId}){
            self.searchedItems[i].isSelected = false
        }
        self.tblView.reloadData()
    }
}
