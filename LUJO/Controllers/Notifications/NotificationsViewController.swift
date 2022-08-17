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
}

class NotificationsViewController:UIViewController{
    /// Class storyboard identifier.
    class var identifier: String { return "NotificationsViewController" }
    private let naHUD = JGProgressHUD(style: .dark)
    var PushNotifications = [PushNotification]()
    
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
    
    //MARK:- View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tblView.dataSource = self;
        self.tblView.delegate = self;
        self.tblView.refreshControl = refreshControl
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (self.PushNotifications.count == 0){
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
            self.hideNetworkActivity()
            
            if let error = error {
                self.showError(error)
                return
            }
            
            if let informations = information {
                self.PushNotifications =  informations
                self.tblView.reloadData()
            } else {
                let error = BackendError.parsing(reason: "Could not obtain wish list information")
                self.showError(error)
            }
        }
    }
    
    func getPushNotifications(completion: @escaping ([PushNotification]?, Error?) -> Void) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            completion(nil, LoginError.errorLogin(description: "User does not exist or is not verified"))
            return
        }
        
        GoLujoAPIManager().getPushNotifications() { data, error in
            guard error == nil else {
                Crashlytics.crashlytics().record(error: error!)
                let error = BackendError.parsing(reason: "Could not obtain the push notifications")
                completion(nil, error)
                return
            }
            completion(data, error)
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
}

extension NotificationsViewController: UITableViewDelegate, UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.PushNotifications.count == 0 {
            self.tblView.setEmptyMessage("No notification(s) are available")
        }else{
            self.tblView.restore()
        }
        return self.PushNotifications.count
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell") as! ChatCell
        let model = PushNotifications[indexPath.row]
        
        if let payload = model.payload{
            if payload.type == NotificationPayloadType.EVENT.rawValue
                || payload.type == NotificationPayloadType.EXPERIENCE.rawValue
                || payload.type == NotificationPayloadType.SPECIAL_EVENT.rawValue{
                
                cell.imgAvatar.image = UIImage(named:"Get Tickets Icon")
            }else if(payload.type == NotificationPayloadType.VILLA.rawValue){
                cell.imgAvatar.image = UIImage(named:"villa cta")
            }else if(payload.type == NotificationPayloadType.GIFT.rawValue){
                cell.imgAvatar.image = UIImage(named:"Purchase Goods Icon")
            }else if(payload.type == NotificationPayloadType.YACHT.rawValue){
                cell.imgAvatar.image = UIImage(named:"Charter Yacht Icon")
            }else if(payload.type == NotificationPayloadType.TRAVEL.rawValue){
                cell.imgAvatar.image = UIImage(named:"aviation_icon")
            }else if(payload.type == NotificationPayloadType.RESTAURANT.rawValue){
                cell.imgAvatar.image = UIImage(named:"Book Table Icon")
            }
        }
        
        var titleMessage = ""
        if let title = model.title{
            titleMessage = title
            if let subTitle = model.subTitle{
                titleMessage += " " + subTitle
            }
            cell.lblChannelFriendlyName.text = titleMessage
        }
        
        cell.lblLastMessage.text = model.message
        cell.lblCreatedAt.text =  Date.dateFromUTCString(string: model.createdAt)?.whatsAppTimeFormat()
        
        self.tblView.separatorStyle = .singleLine
        self.tblView.separatorColor = .lightGray
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var notification = self.PushNotifications[indexPath.item]
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            self.deleteIndexPath = indexPath
            let itemToDelete = self.PushNotifications[indexPath.row].message
            confirmDelete(name: itemToDelete ?? "*this notification*")
        }
    }
    
    func confirmDelete(name: String) {
        let alert = UIAlertController(title: "Delete \(name)", message: "Are you sure you want to permanently delete this notification?", preferredStyle: .actionSheet)

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: handleDeleteChannel)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: handleCancelChannel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        self.present(alert, animated: true, completion: nil)
   }
    
    func handleDeleteChannel(alertAction: UIAlertAction! ) -> Void {
        if let indexPath = self.deleteIndexPath {
            let notification = self.PushNotifications[indexPath.row]
//                self.showNetworkActivity()
                print (notification.message)
            
        }
    }
    
    func handleCancelChannel(alertAction: UIAlertAction! ) -> Void {
        deleteIndexPath = nil       //re setting the index
    }
}
