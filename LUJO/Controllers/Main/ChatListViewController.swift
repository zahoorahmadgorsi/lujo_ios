//
//  ChatViewController.swift
//  LUJO
//
//  Created by Iker Kristian on 8/29/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import JGProgressHUD

class ChatListViewController: UIViewController {
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "ChatListViewController" }
    private let naHUD = JGProgressHUD(style: .dark)
    var items = [ChatHeader]()
    @IBOutlet weak var tblView: UITableView!
    let serverDateFormatter: DateFormatter = {
        let result = DateFormatter()
        result.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
        result.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone
        return result
    }()
    
    let localDateFormatter: DateFormatter = {
        let result = DateFormatter()
        result.dateStyle = .medium
        result.timeStyle = .medium
        return result
    }()
    
    private(set) lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshConversations), for: .valueChanged)
        return control
    }()
    
    /// Init method that will init and return view controller.
    class func instantiate() -> ChatListViewController {
        return UIStoryboard.main.instantiate(identifier)
    }
    

    
    //MARK:- View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblView.dataSource = self;
        self.tblView.delegate = self;
        self.tblView.refreshControl = refreshControl
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New", style: .done, target: self, action: #selector(addTapped))
        getChatsList(showActivity: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getChatsList(showActivity: false)
    }
    
    @objc func refreshConversations() {
        self.refreshControl.beginRefreshing()
        getChatsList(showActivity: false)
    }
    
    func getChatsList(showActivity: Bool) {
        if showActivity {
            self.showNetworkActivity()
        }
        getChats() {information, error in
            self.hideNetworkActivity()
            self.refreshControl.endRefreshing() //if refersh control is spinning
            
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
    
    func update(_ information: ConversationList?) {
        guard information != nil else {
            return
        }
        
        if let chats = information?.items{
            self.items = chats.reversed()
            self.tblView.reloadData()
        }
    }
    
    func getChats(completion: @escaping (ConversationList?, Error?) -> Void) {
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
        let newViewController = BasicChatViewController()
        newViewController.conversationId = ""
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
}

extension ChatListViewController: UITableViewDelegate, UITableViewDataSource{

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
        
//        let dateFromServer = model.createdAt
//        let dtDate = myDate.serverDateFormatter.date(from: dateFromServer)!
//        let strDate = myDate.localDateFormatter.string(from: dtDate)
//
//        print (dateFromServer)
//        print (dtDate.asDateAndTime())
//        print (strDate)
        
//        cell.lblCreatedAt.text = model.createdAt
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
        let newViewController = BasicChatViewController()
        newViewController.conversationId = model.conversationId
        self.navigationController?.pushViewController(newViewController, animated: true)
        
//        let model = self.items[indexPath.item]
//        newMessage(title: "Existing Converation", subTitle: "Please send a message to this conversation", placeHolder1: model.title, placeHolder2: "Enter the message", conversationId: model.conversationId,text: model.title)
    }
}
