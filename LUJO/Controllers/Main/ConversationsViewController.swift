//
//  ChatViewController.swift
//  LUJO
//
//  Created by Iker Kristian and zahoor ahmad gorsi on 8/29/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import JGProgressHUD
import TwilioConversationsClient

class ConversationsViewController: UIViewController {
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "ChatListViewController" }
    private let naHUD = JGProgressHUD(style: .dark)
//    var conversations = [Conversation]()
    var conversations = [TCHConversation]()
    
    @IBOutlet weak var imgCross: UIImageView!
    @IBOutlet weak var tblView: UITableView!
    
    private(set) lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshConversations), for: .valueChanged)
        return control
    }()
    
    /// Init method that will init and return view controller.
    class func instantiate() -> ConversationsViewController {
        return UIStoryboard.main.instantiate(identifier)
    }
//    var identity = "USER_IDENTITY"
    var delegate:UIAdaptivePresentationControllerDelegate?
    var deleteIndexPath: IndexPath? = nil //used while deleting at swipe left
    
    //MARK:- View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addViewBorder(borderColor: UIColor.clear.cgColor, borderWidth: 1.0, borderCornerRadius: 24.0)
        self.tblView.dataSource = self;
        self.tblView.delegate = self;
        self.tblView.refreshControl = refreshControl
        
        self.title = "Conversations"
        
        let searchBarButton = UIButton(type: .system)
        searchBarButton.setImage(UIImage(named: "cross"), for: .normal)
//        searchBarButton.setTitle("Cancel", for: .normal)
        searchBarButton.titleLabel?.font = UIFont.systemFont(ofSize: 11)
        searchBarButton.addTarget(self, action: #selector(imgCrossTapped(_:)), for: .touchUpInside)
        searchBarButton.sizeToFit()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchBarButton)
    }
    
    @objc func imgCrossTapped(_ sender: Any) {
        self.dismiss(animated: true, completion:{
            self.presentationController?.delegate?.presentationControllerDidDismiss?(self.presentationController!)
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (self.conversations.count == 0){
            self.getConversations(showActivity: true)   //activity indicator is required to stop user from interacting with the grid
        }else{
            self.getConversations(showActivity: false)
        }
    }
    
    @objc func refreshConversations() {
        self.refreshControl.beginRefreshing()
        getConversations(showActivity: false)
    }
    
    func getConversations(showActivity: Bool) {
        //when chatViewController was opened from chatlistViewController and then get closed, then this method would be called from presentationControllerDidDismiss would set delegate to self again
        ConversationsManager.sharedConversationsManager.delegate = self
        if showActivity {
            self.showNetworkActivity()
        }
        
        ConversationsManager.sharedConversationsManager.getConversations{conversations in
            if showActivity {
                self.hideNetworkActivity()
            }else{
                self.refreshControl.endRefreshing()
            }
            self.conversations = conversations.sorted(by: { $0.lastMessageDate ?? Date() > $1.lastMessageDate ?? Date()})
            self.tblView.reloadData()
        }
    }
    
    func showError(_ error: Error , isInformation:Bool = false) {
        if (isInformation){
            showErrorPopup(withTitle: "Information", error: error)
        }else{
            showErrorPopup(withTitle: "Chat Error", error: error)
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
    
    @objc func addTapped(){
        let newViewController = AdvanceChatViewController()
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
}

extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.conversations.count == 0 {
            self.tblView.setEmptyMessage("No conversation(s) are available")
        }else{
            self.tblView.restore()
        }
//        print("twilio: conversations.count: \(self.conversations.count)")
        return self.conversations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell") as! ChatCell
//        print("indexPath.row: \(indexPath.row)")
        let model = conversations[indexPath.row]
//        print("Twilio: CoversationID: \(String(describing: model.sid))")
        if let attributes = model.attributes()?.dictionary , let type = attributes["type"] as? String{
            if type == "event" || type  == "experience" || type  == "special-event" {
                cell.imgAvatar.image = UIImage(named:"Get Tickets Icon")
            }else if type  == "villa"{
                cell.imgAvatar.image = UIImage(named:"villa cta")
            }else if type  == "gift"{
                cell.imgAvatar.image = UIImage(named:"Purchase Goods Icon")
            }else if type  == "yacht"{
                cell.imgAvatar.image = UIImage(named:"Charter Yacht Icon")
            }else if type  == "aviation"{
                cell.imgAvatar.image = UIImage(named:"aviation_icon")
            }else if type  == "restaurant"{
                cell.imgAvatar.image = UIImage(named:"Book Table Icon")
            }else if type  == "travel"{
                cell.imgAvatar.image = UIImage(named:"Find Hotel Icon")
            }else{
                cell.imgAvatar.image = UIImage(named:"Lujo Logo")
            }
        }else{
            cell.imgAvatar.image = UIImage(named:"Lujo Logo")
        }
        
        cell.tag = indexPath.row
        //Title of the conversation
        cell.lblChannelFriendlyName.text = model.friendlyName?.uppercased()
        //date of the conversation
        if let dateFromServer = model.lastMessageDate{
            cell.lblCreatedAt.text = dateFromServer.whatsAppTimeFormat()
        }else if let dateFromServer = model.dateCreatedAsDate{  //this channel has no last message hence showing the channel created date
            cell.lblCreatedAt.text = dateFromServer.whatsAppTimeFormat()
        }
        
        //last message of the conversation as per design
        model.getLastMessages(withCount: 1) { (result, messages: [TCHMessage]?) in
            
            if result.isSuccessful , let msgs = messages , msgs.count > 0{
                if msgs[0].hasMedia(){
                    cell.lblLastMessage.text = "PHOTO"
                }else{
                    if let messageBody = msgs[0].body {
                        if messageBody.isHtml(){
                            let attributedString = messageBody.parseHTML()
                            cell.lblLastMessage.text = attributedString.string
                        }else{
                            cell.lblLastMessage.text = msgs[0].body
                        }
                    }
                }
            }
        }
        //number of un read messages of this conversation
        model.getUnreadMessagesCount { (result, unReadMsgsCount: NSNumber?) in
            if result.isSuccessful ,let count = unReadMsgsCount{
                if count.intValue > 0{
                    cell.lblUnConsumedMessagesCount.text = count.stringValue
                    cell.viewUnConsumedMessagesCount.addViewBorder(borderColor: UIColor.rgMid.cgColor, borderWidth: 1.0, borderCornerRadius: cell.viewUnConsumedMessagesCount.frame.height/2)
                }else{
                    cell.lblUnConsumedMessagesCount.text = ""
                    cell.viewUnConsumedMessagesCount.addViewBorder(borderColor: UIColor.clear.cgColor, borderWidth: 1.0, borderCornerRadius: cell.viewUnConsumedMessagesCount.frame.height/2)
                }
            }
        }
        self.tblView.separatorStyle = .singleLine
        self.tblView.separatorColor = .lightGray
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversation = self.conversations[indexPath.item]
        let viewController = AdvanceChatViewController()
        viewController.channel = conversation
        let navViewController: UINavigationController = UINavigationController(rootViewController: viewController)
        if #available(iOS 13.0, *) {
            let controller = navViewController.topViewController
            // Modal Dismiss iOS 13 onward
            controller?.presentationController?.delegate = self
        }
        //incase user will do some messaging in AdvanceChatViewController and then dismiss it then chatlistviewcontroller should reflect last message body and time
        navViewController.presentationController?.delegate = self
        self.present(navViewController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            self.deleteIndexPath = indexPath
            let itemToDelete = self.conversations[indexPath.row].friendlyName
            confirmDelete(name: itemToDelete ?? "*this channel*")
        }
    }
    
    func confirmDelete(name: String) {
        let alert = UIAlertController(title: "Delete Conversation \(name)", message: "Are you sure you want to permanently delete this conversation?", preferredStyle: .actionSheet)

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: handleDeleteChannel)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: handleCancelChannel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        self.present(alert, animated: true, completion: nil)
   }
    
    func handleDeleteChannel(alertAction: UIAlertAction! ) -> Void {
        if let indexPath = self.deleteIndexPath {
            let conversation = self.conversations[indexPath.row]
            conversation.destroy { (result) in
                if (result.isSuccessful){
                    self.conversations.remove(at: indexPath.row)
                    // Note that indexPath is wrapped in an array:  [indexPath]
                    self.tblView.deleteRows(at: [indexPath], with: .automatic)
                    self.deleteIndexPath = nil
                }
                else{
                    AlertService.showAlert(style: .actionSheet, title: nil, message: "You can not delete this conversation")
                }
            }
        }
    }
    
    func handleCancelChannel(alertAction: UIAlertAction! ) -> Void {
        deleteIndexPath = nil       //re setting the index
    }
}

extension ConversationsViewController: UIAdaptivePresentationControllerDelegate {
    // Only called when the sheet is dismissed by DRAGGING as well as when tapped on cross button
    public func presentationControllerDidDismiss( _ presentationController: UIPresentationController) {
        if #available(iOS 13, *) {
            //Call viewWillAppear only in iOS 13
            self.getConversations(showActivity: false)    //chatViewController is closed time to update the last message body, time and unconsumed index
        }
    }
}

extension ConversationsViewController: ConversationsManagerDelegate {
    func reloadMessages() {
        print("Twilio: reloadMessages")
    }

    func receivedNewMessage(message: TCHMessage, channel: TCHConversation) {
        self.getConversations(showActivity: false)    //New message is recived on chatlistViewController time to update the last message body, time and unconsumed index
    }
    
    func channelJoined(channel: TCHConversation) {
        print("Twilio: channelJoined")
    }
    
    
    func typingOn(_ conversation: TCHConversation, _ participant: TCHParticipant, isTyping:Bool){
        print("Twilio: typingOn : \(String(describing: conversation.friendlyName)) by \(String(describing: participant.identity)) is \(isTyping)")
    }
}
