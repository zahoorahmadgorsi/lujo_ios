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
    var conversations = [Conversation]()
    var searchedConversations = [Conversation]()
    
    @IBOutlet weak var imgCross: UIImageView!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var searching = false
    
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
        setupSearchBar()
        
        self.view.addViewBorder(borderColor: UIColor.clear.cgColor, borderWidth: 1.0, borderCornerRadius: 24.0)
        self.tblView.dataSource = self;
        self.tblView.delegate = self;
        self.tblView.refreshControl = refreshControl
//        self.tblView.isEditing = true
        
        self.title = "Conversations"
        
        createRightBarButtons()
        
        loadFromUserDefaults()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (self.conversations.count == 0){
            self.getConversations(showActivity: true)   //activity indicator is required to stop user from interacting with the grid
        }else{
            self.tblView.reloadData()
            self.getConversations(showActivity: false)    //silently loading the conversations.
        }
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
    private func createRightBarButtons(){
        let imgCross    = UIImage(named: "cross")!
        let btnCross   = UIBarButtonItem(image: imgCross,  style: .plain, target: self, action: #selector(imgCrossTapped(_:)))
        navigationItem.rightBarButtonItems = [btnCross]   //order is first and second (right to left)

    }
    
    @objc func imgCrossTapped(_ sender: Any) {
        if self.isModal{    //almost from all over the application
            self.dismiss(animated: true, completion:{
                self.presentationController?.delegate?.presentationControllerDidDismiss?(self.presentationController!)
            })
        }else if let navController = self.navigationController { //from the preferences screen
            navController.popViewController(animated: true)
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
            let myGroup = DispatchGroup()
            var tempConversations = [Conversation]()    //variable for this function only
            for conversation in conversations {
                myGroup.enter()
                //last message of the conversation as per design
                conversation.getLastMessages(withCount: 1) { (result, messages: [TCHMessage]?) in
                    let tempConversation:Conversation = Conversation(conversation)
                    if  let msgs = messages , msgs.count > 0{
                        tempConversation.tchMessage = msgs[0]
                        if let message = msgs[0].body , message.count > 0{
                            tempConversation.lastMessageBody = msgs[0].attachedMedia.count > 0 ? "PHOTO" : message  //if last message is media then show PHOTO
                        }
                    }
                    tempConversations.append(tempConversation)
                    myGroup.leave()
                }
            }
            myGroup.notify(queue: .main) {
                print("Twilio: getConversations Finished whole DispatchGroup.")
                if showActivity {
                    self.hideNetworkActivity()
                }else{
                    self.refreshControl.endRefreshing()
                }
                tempConversations = tempConversations.sorted(by: { ($0.tchConversation?.lastMessageDate ?? $0.tchConversation?.dateCreatedAsDate) ?? Date() > ($1.tchConversation?.lastMessageDate ?? $1.tchConversation?.dateCreatedAsDate) ?? Date()})
                //Storing into user defaults
                self.saveIntoUserDefaults(tempConversations: tempConversations)
                self.conversations = tempConversations  //assigning just loaded, sorted, cached conversation to self.conversations
                self.tblView.reloadData()
            }
        }
    }
    
    private func saveIntoUserDefaults(tempConversations : [Conversation]){
        do{
            let conversationsData = try NSKeyedArchiver.archivedData(withRootObject: tempConversations, requiringSecureCoding: false)
            UserDefaults.standard.set(conversationsData, forKey: "conversationsData")
        }catch {
            print(error.localizedDescription)
        }
    }

    private func loadFromUserDefaults(){
        guard let conversationsData = UserDefaults.standard.object(forKey: "conversationsData") as? NSData else {
            print("'conversationsData' not found in UserDefaults")
            return
        }
        do {
            guard let cachedConversations = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(conversationsData as Data) as? [Conversation] else { return }
            self.conversations = cachedConversations
        } catch {
            print(error.localizedDescription)
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
}

extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource{

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if searching {
        if self.searchedConversations.count == 0 {
            self.tblView.setEmptyMessage("No conversation is available having this title.")
        }else{
            self.tblView.restore()
        }
        return self.searchedConversations.count
    } else {
        if self.conversations.count == 0 {
            self.tblView.setEmptyMessage("No conversation(s) are available")
        }else{
            self.tblView.restore()
        }
        return self.conversations.count
    }
}

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell") as! ChatCell
        var model = conversations[indexPath.row]
        if searching {
            model = searchedConversations[indexPath.row]
        }
        
        if let type = model.tchConversation?.attributes()?.dictionary?["type"] as? String ?? model.type{    //model.type is cached value
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
        if let friendlyName = model.tchConversation?.friendlyName ?? model.friendlyName{  //model.friendlyName contains cached value
            cell.lblChannelFriendlyName.text = friendlyName.uppercased()
        }
        
        //date of the conversation
        if let dateFromServer = model.tchConversation?.lastMessageDate ?? model.lastMessageDate{
            cell.lblCreatedAt.text = dateFromServer.whatsAppTimeFormat()
        }else if let dateFromServer = model.tchConversation?.dateCreatedAsDate ?? model.dateCreatedAsDate{  //this conversation has no last message hence showing the conversation created date
            cell.lblCreatedAt.text = dateFromServer.whatsAppTimeFormat()
        }
        if let message = model.tchMessage, message.attachedMedia.count > 0{
            cell.lblLastMessage.text = "PHOTO"
        }else if let message = model.tchMessage?.body ?? model.lastMessageBody{
            cell.lblLastMessage.text = message.isHtml() == true ? message.parseHTML().string : message
        }
        
        
        //number of un read messages of this conversation
        model.tchConversation?.getUnreadMessagesCount { (result, unReadMsgsCount: NSNumber?) in
            if result.isSuccessful ,let count = unReadMsgsCount, count.intValue > 0, cell.tag == indexPath.row{
                cell.lblUnConsumedMessagesCount.text = count.stringValue
                cell.viewUnConsumedMessagesCount.addViewBorder(borderColor: UIColor.rgMid.cgColor, borderWidth: 1.0, borderCornerRadius: cell.viewUnConsumedMessagesCount.frame.height/2)
            }
        }
        self.tblView.separatorStyle = .singleLine
        self.tblView.separatorColor = .lightGray
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.conversations.count >= indexPath.row{
            var conversation = self.conversations[indexPath.item].tchConversation
            if searching {
                conversation = self.searchedConversations[indexPath.item].tchConversation
            }
            if let convers = conversation{
                let viewController = AdvanceChatViewController()
                viewController.conversation = convers
                let navViewController: UINavigationController = UINavigationController(rootViewController: viewController)
                if #available(iOS 13.0, *) {
                    let controller = navViewController.topViewController
                    // Modal Dismiss iOS 13 onward
                    controller?.presentationController?.delegate = self
                }
                //incase user will do some messaging in AdvanceChatViewController and then dismiss it then chatlistviewcontroller should reflect last message body and time
                navViewController.presentationController?.delegate = self
                self.present(navViewController, animated: true, completion: nil)
                // Close keyboard when you select cell
                self.searchBar.searchTextField.endEditing(true)
            }else{
                let error = BackendError.parsing(reason: "Could not load this conversation")
                self.showError(error)
                print("Twilio: Not logged in")
            }
        }else{
            print("Conversation not found at index:\(indexPath.row)")
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            self.deleteIndexPath = indexPath
            let itemToDelete = self.conversations[indexPath.row].tchConversation?.friendlyName
            confirmDelete(name: itemToDelete ?? "*this conversation*")
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
            if let conversation = self.conversations[indexPath.row].tchConversation{
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
            }else{
                print("Twilio: Conversations are not loaded yet")
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
    
//    func conversationUpdated(conversation: TCHConversation, updated: TCHConversationUpdate) {}
    
    func reloadMessages() {
        print("Twilio: reloadMessages")
    }

    func receivedNewMessage(message: TCHMessage, conversation: TCHConversation) {
        self.getConversations(showActivity: false)    //New message is recived on chatlistViewController time to update the last message body, time and unconsumed index
    }
    
    func channelJoined(channel: TCHConversation) {
        print("Twilio: channelJoined")
    }
    
    //if index is visible then reload that cell with text "Typing..."
    // incase of multithreading this code might fail
    func typingOn(_ conversation: TCHConversation, _ participant: TCHParticipant, isTyping:Bool){
//        if let friendlyName = conversation.friendlyName, let identity = participant.identity{
//            print("Twilio: typingOn : \(friendlyName) by \(identity) is \(isTyping)")
//        }
    }
}

extension ConversationsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedConversations = conversations.filter {
            $0.friendlyName?.range(of: searchText , options: .caseInsensitive) != nil
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
