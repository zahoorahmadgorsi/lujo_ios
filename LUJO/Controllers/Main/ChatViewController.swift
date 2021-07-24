//
//  ChatViewController.swift
//  LUJO
//
//  Created by Iker Kristian on 8/29/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import JGProgressHUD

class ChatViewController: UIViewController {
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "ChatViewController" }
    private let naHUD = JGProgressHUD(style: .dark)
    var items = [ChatHeader]()
    @IBOutlet weak var tblView: UITableView!
    
    /// Init method that will init and return view controller.
    class func instantiate() -> ChatViewController {
        return UIStoryboard.main.instantiate(identifier)
    }
    

    
    //MARK:- View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblView.dataSource = self;
        self.tblView.delegate = self;
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New", style: .done, target: self, action: #selector(addTapped))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getChatsList(showActivity: true)
    }
    
    func getChatsList(showActivity: Bool) {
        if showActivity {
            self.showNetworkActivity()
        }
        getChats() {information, error in
            self.hideNetworkActivity()
            
            if let error = error {
                self.showError(error)
                return
            }
            
            if let informations = information {
                self.update(informations)
            } else {
                let error = BackendError.parsing(reason: "Could not obtain chat list")
                self.showError(error)
            }
        }
    }
    
    func update(_ information: ChatList?) {
        guard information != nil else {
            return
        }
        
        if let chats = information?.items{
            self.items = chats
            self.tblView.reloadData()
        }
    }
    
    func getChats(completion: @escaping (ChatList?, Error?) -> Void) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            completion(nil, LoginError.errorLogin(description: "User does not exist or is not verified"))
            return
        }
        
        GoLujoAPIManager().getChats(token: token) { items, error in
            guard error == nil else {
                Crashlytics.sharedInstance().recordError(error!)
                let error = BackendError.parsing(reason: "Could not obtain the chat list")
                completion(nil, error)
                return
            }
            completion(items, error)
        }
    }
    
//    func sendMessage(showActivity: Bool) {
//        if showActivity {
//            self.showNetworkActivity()
//        }
//        sendMessage() {information, error in
//            self.hideNetworkActivity()
//
//            if let error = error {
//                self.showError(error)
//                return
//            }
//
//            if let informations = information {
//                self.update(informations)
//            } else {
//                let error = BackendError.parsing(reason: "Could not obtain chat list")
//                self.showError(error)
//            }
//        }
//    }

    
    func sendMessage(message:String,conversation_id:String,title:String,sales_force_id:String, completion: @escaping (String?, Error?) -> Void) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            completion(nil, LoginError.errorLogin(description: "User does not exist or is not verified"))
            return
        }
        
        GoLujoAPIManager().sendMessage( token: token,message: message,conversationId: conversation_id,title: title,sales_force_id: sales_force_id) { response, error in
            guard error == nil else {
                Crashlytics.sharedInstance().recordError(error!)
                let error = BackendError.parsing(reason: "Could not send the message")
                completion(nil, error)
                return
            }
            completion(response, error)
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
    @objc func addTapped(){
        newMessage(title: "New Converation", subTitle: "Please start a new conversation", placeHolder1: "Enter the conversation title", placeHolder2: "Enter the message", cancelTitle: "Cancel", saveTitle: "Send")
        
    }
    
    func newMessage(title:String, subTitle:String, placeHolder1:String, placeHolder2:String, cancelTitle:String, saveTitle:String, conversationId:String = "", text:String = ""){
        // create the actual alert controller view that will be the pop-up
        let alertController = UIAlertController(title: title, message: subTitle, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            // configure the properties of the text field
            textField.placeholder = placeHolder1
            textField.text = text
        }
        alertController.addTextField { (textField) in

            textField.placeholder = placeHolder2
        }
        // add the buttons/actions to the view controller
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: saveTitle, style: .default) { _ in
            // this code runs when the user hits the "save" button
            if let inputName = alertController.textFields![0].text,let conversationTitle = alertController.textFields![1].text{
                self.showNetworkActivity()
                self.sendMessage(message: inputName, conversation_id: conversationId,title: conversationTitle,sales_force_id: "", completion: {information, error in
                    self.hideNetworkActivity()

                    if let error = error {
                        self.showError(error)
                        return
                    }
                    self.getChatsList(showActivity: true)
                })
            }

        }

        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)

        present(alertController, animated: true, completion: nil)
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.items.count == 0 {
            self.tblView.setEmptyMessage("No data is available")
        }else{
            self.tblView.setEmptyMessage("")
        }
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell") as! ChatCell
        let model = items[indexPath.row]
        cell.tag = indexPath.row
        cell.lblAuthorName.text = model.authorName
        cell.lblTitle.text = model.title
        cell.lblCreatedAt.text = model.createdAt
        if let avatarLink = model.meta?.avatar {
            cell.imgAvatar.downloadImageFrom(link: avatarLink, contentMode: .scaleAspectFill)
        }
        
        self.tblView.separatorStyle = .singleLine
        self.tblView.separatorColor = .systemOrange
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.items[indexPath.item]
        newMessage(title: "Existing Converation", subTitle: "Please send a message to this conversation", placeHolder1: model.title, placeHolder2: "Enter the message", cancelTitle: "Cancel", saveTitle: "Send", conversationId: model.conversationId,text: model.title)
    }
}
