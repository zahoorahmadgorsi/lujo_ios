//
//  NotificationsViewController.swift
//  LUJO
//
//  Created by Zahoor Gorsi on 15/08/2022.
//  Copyright © 2022 Baroque Access. All rights reserved.
//

import UIKit
import JGProgressHUD
import FirebaseCrashlytics

enum NotificationPayloadType: String{
    case GENERAL = "general"
    case RESTAURANT = "restaurant"
    case EVENT = "event"
    case SPECIAL_EVENT = "special_event"
    case GIFT =  "gift"
    case EXPERIENCE = "experience"
    case YACHT = "yacht"
    case VILLA = "villa"
    case TRAVEL = "travel"
    case RECENT = "recent"
}

class NotificationsViewController:UIViewController{
    /// Class storyboard identifier.
    class var identifier: String { return "NotificationsViewController" }
    private let naHUD = JGProgressHUD(style: .dark)
    var pushNotifications = [PushNotification]()
    var filteredPushNotifications = [PushNotification]()
    var isFiltering = false
    
    var selectedProduct:NotificationPayloadType = NotificationPayloadType.RECENT
    @IBOutlet weak var tblView: UITableView!
    
    private(set) lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshConversations), for: .valueChanged)
        return control
    }()
    
    /// Init method that will init and return view controller.
    class func instantiate() -> NotificationsViewController {
        return UIStoryboard.main.instantiate(identifier)
    }
    
    var deleteIndexPath: IndexPath? = nil //used while deleting at swipe left
    let limit:Int = 15      //page size
    var increasedLimit: Int = 0 // setting in viewdid load number of records on a page
    
    var isLoadingNextPage : Bool = false    //loading next page
    var filterPicker: ikDataPickerManger?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //MARK:- View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        increasedLimit = limit  //assinging it here becuase limit we can change any time from the declaration area
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(filterTapped))
        
        self.tblView.dataSource = self;
        self.tblView.delegate = self;
        self.tblView.estimatedRowHeight = 135   //to make dynamic height have to provide some height
        self.tblView.rowHeight = UITableView.automaticDimension
        //adding separator line
        self.tblView.separatorStyle = .singleLine
        self.tblView.separatorColor = .lightGray
        
        self.tblView.refreshControl = refreshControl
        // disallowing table view to hide behind tab bar (its working fine in device but emulator)
//        let adjustForTabbarInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: self.tabBarController!.tabBar.frame.height, right: 0)
//        self.tblView.contentInset = adjustForTabbarInsets
//        self.tblView.scrollIndicatorInsets = adjustForTabbarInsets
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        appDelegate.getUnReadPushNotificationsCount()
        
        if (self.pushNotifications.count == 0){
            self.getPushNotifications(showActivity: true)   //activity indicator is required to stop user from interacting with the grid
        }else{
            self.tblView.reloadData()
            self.getPushNotifications(showActivity: false)    //silently loading the notifications.
        }
    }
    
    @objc func refreshConversations() {
        self.refreshControl.beginRefreshing()
        getPushNotifications(showActivity: false)
    }
    
    func getPushNotifications(showActivity: Bool) {
        if showActivity {
            self.showNetworkActivity()
        }
        getPushNotifications() {information, error in
            self.refreshControl.endRefreshing()
            self.hideNetworkActivity()
            
            if let error = error {
                self.showError(error)
                return
            }
            
            if let items = information {
                if self.isFiltering{
                    self.filteredPushNotifications.removeAll()
                    for item in items{
                        if !self.filteredPushNotifications.contains(where: {$0.id == item.id}){
                            self.filteredPushNotifications.append(item)
                        }
                    }
                }else{
                    self.pushNotifications.removeAll()
                    for item in items{
                        self.pushNotifications.append(item)
                    }
                }
                
                self.tblView.reloadData()
            } else {
                let error = BackendError.parsing(reason: "Could not obtain push notifications")
                self.showError(error)
            }
              //making it false at the last so that if its success or failure loading should become false
        }
    }
    
    func getPushNotifications(completion: @escaping ([PushNotification]?, Error?) -> Void) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            completion(nil, LoginError.errorLogin(description: "User does not exist or is not verified"))
            return
        }
        
        GoLujoAPIManager().getPushNotifications( pageSize: self.increasedLimit , type: self.selectedProduct.rawValue) { data, error in
            guard error == nil else {
                Crashlytics.crashlytics().record(error: error!)
                //unauthorized token, so forcefully signout the user
                if error?._code == 403{
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.logoutUser()
                }else{
                    let error = BackendError.parsing(reason: "Could not obtain the push notifications")
                    completion(nil, error)
                }
                return
            }
            self.isLoadingNextPage = false
            completion(data, error)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print(scrollView.contentOffset.y,scrollView.frame.size.height)
//        print(scrollView.contentOffset.y+scrollView.frame.size.height,scrollView.contentSize.height)
        if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !isLoadingNextPage){
            //if user is filtering data but already pageSize filtered data is present
            // if user is reloading data but already pagesize data is present
            if ( (self.isFiltering && (self.filteredPushNotifications.count >= self.limit) )
                 || (!self.isFiltering && (self.pushNotifications.count >=  self.limit)  )){
                
                self.isLoadingNextPage = true
                //incrementing current page
                self.increasedLimit += self.limit    //resetting to page limit
                self.getPushNotifications(showActivity: true)
            }
            
        }
    }
    
    func showError(_ error: Error , isInformation:Bool = false) {
        if (isInformation){
            showErrorPopup(withTitle: "Information", error: error)
        }else{
            showErrorPopup(withTitle: "Error", error: error)
        }
        
    }
    
    func showNetworkActivity() {
        // Safe guard to that won't display both loaders at same time.
//        if !refreshControl.isRefreshing {
            naHUD.show(in: view)
//        }
    }
    
    func hideNetworkActivity() {
        // Safe guard that will call dismiss only if HUD is shown on screen.
        if naHUD.isVisible {
            naHUD.dismiss()
        }
    }
    
    @objc func filterTapped(sender: UIBarButtonItem) {
        if filterPicker == nil {
            let _filtersDataSource: [[String]] = [[
                                                    NotificationPayloadType.RESTAURANT.rawValue.capitalizingAllFirstLetters()
                                                    , NotificationPayloadType.GIFT.rawValue.capitalizingAllFirstLetters()
                                                    , NotificationPayloadType.VILLA.rawValue.capitalizingAllFirstLetters()
                                                    , NotificationPayloadType.EVENT.rawValue.capitalizingAllFirstLetters()
                                                    , NotificationPayloadType.YACHT.rawValue.capitalizingAllFirstLetters()
                                                    , NotificationPayloadType.TRAVEL.rawValue.capitalizingAllFirstLetters()
                                                    , NotificationPayloadType.EXPERIENCE.rawValue.capitalizingAllFirstLetters()
                                                   , "Special event"
                                                  ]]
            
            filterPicker = ikDataPickerManger.create(owner: self, sourceView: sender.customView, title: "Please select the product type", dataSource: _filtersDataSource,okTitle: "OK" , cancelTitle: "Cancel & Clear", callback: { [self] values in
                //default values which would over ride in next part of the function
//
                isFiltering = true
                self.selectedProduct = .RECENT
                
                if values.count > 0{
                    isFiltering = true
                    self.filteredPushNotifications.removeAll()
                    let selectedPickerItem = values[0].lowercased()
                    if selectedPickerItem == NotificationPayloadType.VILLA.rawValue.lowercased(){
                        //resetting to page limit
                        self.increasedLimit = self.increasedLimit > self.limit ? self.increasedLimit : self.limit
                        if self.selectedProduct != NotificationPayloadType.VILLA{ //slection is changing
                            self.selectedProduct = NotificationPayloadType.VILLA
                            self.navigationController?.navigationBar.topItem?.title = selectedPickerItem.capitalizingFirstLetter() + " Notifications"
                        }
                    }else if selectedPickerItem == "special event"{
                        if self.selectedProduct != NotificationPayloadType.SPECIAL_EVENT{ //slection is changing
                            self.selectedProduct = NotificationPayloadType.SPECIAL_EVENT
                            self.navigationController?.navigationBar.topItem?.title = selectedPickerItem.capitalizingFirstLetter() + " Notifications"
                        }
                        
                    }else if selectedPickerItem == NotificationPayloadType.EXPERIENCE.rawValue.lowercased(){
                        if self.selectedProduct != NotificationPayloadType.EXPERIENCE{ //slection is changing
                            self.selectedProduct = NotificationPayloadType.EXPERIENCE
                            self.navigationController?.navigationBar.topItem?.title = selectedPickerItem.capitalizingFirstLetter() + " Notifications"
                        }
                        
                    }else if selectedPickerItem == NotificationPayloadType.EVENT.rawValue.lowercased(){
                        if self.selectedProduct != NotificationPayloadType.EVENT{ //slection is changing
                            self.selectedProduct = NotificationPayloadType.EVENT
                            self.navigationController?.navigationBar.topItem?.title = selectedPickerItem.capitalizingFirstLetter() + " Notifications"
                        }
                        
                    }else if selectedPickerItem == NotificationPayloadType.GIFT.rawValue.lowercased(){
                        if self.selectedProduct != NotificationPayloadType.GIFT{ //slection is changing
                            self.selectedProduct = NotificationPayloadType.GIFT
                            self.navigationController?.navigationBar.topItem?.title = selectedPickerItem.capitalizingFirstLetter() + " Notifications"
                        }
                        
                    }else if selectedPickerItem == NotificationPayloadType.RESTAURANT.rawValue.lowercased(){
                        if self.selectedProduct != NotificationPayloadType.RESTAURANT{ //slection is changing
                            self.selectedProduct = NotificationPayloadType.RESTAURANT
                            self.navigationController?.navigationBar.topItem?.title = selectedPickerItem.capitalizingFirstLetter() + " Notifications"
                        }
                        
                    }else if selectedPickerItem == NotificationPayloadType.TRAVEL.rawValue.lowercased(){
                        if self.selectedProduct != NotificationPayloadType.TRAVEL{ //slection is changing
                            self.selectedProduct = NotificationPayloadType.TRAVEL
                            self.navigationController?.navigationBar.topItem?.title = selectedPickerItem.capitalizingFirstLetter() + " Notifications"
                        }
                        
                    }else if selectedPickerItem == NotificationPayloadType.YACHT.rawValue.lowercased(){
                        if self.selectedProduct != NotificationPayloadType.YACHT{ //slection is changing
                            self.selectedProduct = NotificationPayloadType.YACHT
                            self.navigationController?.navigationBar.topItem?.title = selectedPickerItem.capitalizingFirstLetter() + " Notifications"
                        }
                        
                    }else{
                        isFiltering = false
                        self.navigationController?.navigationBar.topItem?.title = "Notifications"
                        return
                    }
                    filteredPushNotifications = pushNotifications.filter({$0.payload?.type == self.selectedProduct.rawValue})
                    if filteredPushNotifications.count == 0{
                        getPushNotifications(showActivity: true)    //after applying local filter data wasnt found so fetching from server
                    }else{
                        self.tblView.reloadData()
                    }
                    
                }else{  //during filtering user has pressed the cancel button, so loading pre filtering data
                    isFiltering = false
                    self.navigationController?.navigationBar.topItem?.title = "Notifications"
                    self.tblView.reloadData()
                }
                
            })
        }
        filterPicker?.present()
    }
}

extension NotificationsViewController: UITableViewDelegate, UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            if self.filteredPushNotifications.count == 0 {
                self.tblView.setEmptyMessage("No notification(s) are available for this filter.")
            }else{
                self.tblView.restore()
            }
            return self.filteredPushNotifications.count
        } else {
            if self.pushNotifications.count == 0 {
                self.tblView.setEmptyMessage("No notification(s) are available")
            }else{
                self.tblView.restore()
            }
            return self.pushNotifications.count
        }
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell") as! NotificationCell
        var model:PushNotification
        
        if isFiltering {
            model = filteredPushNotifications[indexPath.row]
        }else{
            model = pushNotifications[indexPath.row]
        }
        if let payload = model.payload{
            if payload.type == NotificationPayloadType.EVENT.rawValue
                || payload.type == NotificationPayloadType.EXPERIENCE.rawValue
                || payload.type == NotificationPayloadType.SPECIAL_EVENT.rawValue{
                
                cell.imgProduct.image = UIImage(named:"Get Tickets Icon")
            }else if(payload.type == NotificationPayloadType.VILLA.rawValue){
                cell.imgProduct.image = UIImage(named:"villa cta")
            }else if(payload.type == NotificationPayloadType.GIFT.rawValue){
                cell.imgProduct.image = UIImage(named:"Purchase Goods Icon")
            }else if(payload.type == NotificationPayloadType.YACHT.rawValue){
                cell.imgProduct.image = UIImage(named:"Charter Yacht Icon")
            }else if(payload.type == NotificationPayloadType.TRAVEL.rawValue){
                cell.imgProduct.image = UIImage(named:"aviation_icon")
            }else if(payload.type == NotificationPayloadType.RESTAURANT.rawValue){
                cell.imgProduct.image = UIImage(named:"Book Table Icon")
            }
        }
        
        if let title = model.title{
            cell.lblNotificationTitle.isHidden = false
            cell.lblNotificationTitle.text = title
        }else{
            cell.lblNotificationTitle.isHidden = true
        }
        
        if let subTitle = model.subTitle{
            cell.lblNotificationSubtitle.isHidden = false
            cell.lblNotificationSubtitle.text = subTitle
        }else{
            cell.lblNotificationSubtitle.isHidden = true
        }
        
        cell.lblNotificationBody.text = model.message
        cell.lblCreatedAt.text =  Date.dateFromUTCString(string: model.createdAt)?.whatsAppTimeFormat()
        if !model.isRead{    //if notification hasn't read yet then change the background
            cell.contentView.backgroundColor = .backGround
            print(model.id)
        }
        else{
            cell.contentView.backgroundColor = .clear
        }
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var notification = self.pushNotifications[indexPath.item]
        if isFiltering {
            notification = self.filteredPushNotifications[indexPath.item]
        }
        let notificationId = notification.id
        self.showNetworkActivity()
        GoLujoAPIManager().readPushNotifications(id: notificationId) { responseString, error in
            self.hideNetworkActivity()
            guard error == nil else {
                Crashlytics.crashlytics().record(error: error!)
                //unauthorized token, so forcefully signout the user
                if error?._code == 403{
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.logoutUser()
                }else{
                    let error = BackendError.parsing(reason: "Could not set read to the push notifications")
                    self.showError(error)
                }
                return
            }
//            print (responseString)
            if self.isFiltering{
                if let index = self.filteredPushNotifications.firstIndex(where: { $0.id == notificationId}) {
                    self.filteredPushNotifications[index].isRead = true
                }
            }else{
                if let index = self.pushNotifications.firstIndex(where: { $0.id == notificationId}) {
                    print(notificationId)
                    self.pushNotifications[index].isRead = true
                }
            }
            self.appDelegate.getUnReadPushNotificationsCount()   //user has read the notification now update the badge.
            self.tblView.reloadData()
        }
        if let productId = notification.payload?.id, let productType = notification.payload?.type{
//            print("Product Type: \(type) and ProductID: \(id)")
            var viewController = ProductDetailsViewController()
            let product = Product(id: productId, type: productType)
            viewController = ProductDetailsViewController.instantiate(product: product)
            viewController.modalPresentationStyle = .overFullScreen
            self.navigationController?.present(viewController, animated: true)
        }else{ //related to membership, if membership is expired or expiring then opening the membership page
            if notification.title?.contains("Membership") == true{
                if let user = LujoSetup().getLujoUser(), user.id.count > 0 {
                    let userFullname = "\(user.firstName) \(user.lastName)"
                    let hasMembership = Utility.isUserAMember()
                    var paymentType = MembershipType.none
                    
                    if let isContain = LujoSetup().getLujoUser()?.membershipPlan?.accessTo.contains(where: {$0.caseInsensitiveCompare("dining") == .orderedSame}), isContain == true{
                        paymentType = .dining
                    }else{
                        paymentType = .all
                    }

                    let viewController = MembershipViewControllerNEW.instantiate(userFullname: userFullname
                                                                                 , screenType: hasMembership ? .viewMembership : .buyMembership
                                                                                 , paymentType: paymentType)
                    let navController = UINavigationController(rootViewController: viewController)
                    self.present(navController, animated: true)
                }
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            self.deleteIndexPath = indexPath
            let itemToDelete = self.pushNotifications[indexPath.row].message
            confirmDelete(name: itemToDelete ?? "*this notification*")
        }
    }
    
    func confirmDelete(name: String) {
        let alert = UIAlertController(title: "Delete \(name)", message: "Are you sure you want to permanently delete this notification?", preferredStyle: .actionSheet)

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: handleDelete)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: handleDeleteCancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        self.present(alert, animated: true, completion: nil)
   }
    
    func handleDelete(alertAction: UIAlertAction! ) -> Void {
        if let indexPath = self.deleteIndexPath {
            let notification = self.pushNotifications[indexPath.row]
            self.showNetworkActivity()
            GoLujoAPIManager().deletePushNotifications(id: notification.id) { data, error in
                self.hideNetworkActivity()
                guard error == nil else {
                    Crashlytics.crashlytics().record(error: error!)
                    //unauthorized token, so forcefully signout the user
                    if error?._code == 403{
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.logoutUser()
                    }else{
                        let error = BackendError.parsing(reason: "Could not delete the push notifications")
                        self.showError(error)
                    }
                    return
                }
                print (notification.message)
                self.pushNotifications.remove(at: indexPath.row)
                // Note that indexPath is wrapped in an array:  [indexPath]
                self.tblView.deleteRows(at: [indexPath], with: .automatic)
                self.deleteIndexPath = nil
                //reload the count
                self.appDelegate.getUnReadPushNotificationsCount()   //user has read the notification now update the badge.
            }
            
        }
    }
    
    func handleDeleteCancel(alertAction: UIAlertAction! ) -> Void {
        deleteIndexPath = nil       //re setting the index
    }
}
