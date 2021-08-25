//
//  ChatViewController.swift
//  LUJO
//
//  Created by Iker Kristian on 8/29/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import JGProgressHUD
import TwilioChatClient

class ChatListViewController: UIViewController {
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "ChatListViewController" }
    private let naHUD = JGProgressHUD(style: .dark)
    //var items = [ChatHeader]()
    var channels = [TCHChannelDescriptor]()
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
    // Convenience class to manage interactions with Twilio Chat
    var chatManager = ChatManager()
    var identity = "USER_IDENTITY"
    
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
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        login()
//    }
//
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        chatManager.shutdown()
//    }
    
    func login() {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            LoginError.errorLogin(description: "User does not exist or is not verified")
            return
        }
        self.showNetworkActivity()
        chatManager.login(self.identity) { (success) in
            self.hideNetworkActivity()
            DispatchQueue.main.async {
                if success {
//                    self.navigationItem.prompt = "Logged in as \"\(self.identity)\""
                    print("Logged in as \"\(self.identity)\"")
                    //after logging in getting the list of subscribed channels
                    self.getChatsList(showActivity: true)
                } else {
//                    self.navigationItem.prompt = "Unable to login"
                    print("Unable to login")
                    let error = BackendError.parsing(reason: "Unable to login - check the token URL in ChatConstants.swift")
                    self.showError(error)
                }
            }
        }
    }
    
    @objc func refreshConversations() {
        self.refreshControl.beginRefreshing()
        getChatsList(showActivity: false)
    }
    
    func getChatsList(showActivity: Bool) {
//        if showActivity {
//            self.showNetworkActivity()
//        }
//        self.chatManager.getUserChannels() {channels in
//            for channel in channels {
//                print("Channel: \(channel.friendlyName)")
//            }
//            self.channels = channels
//            self.tblView.reloadData()
//        }
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
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
}

extension ChatListViewController: UITableViewDelegate, UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.channels.count == 0 {
            self.tblView.setEmptyMessage("No data is available")
        }else{
            self.tblView.setEmptyMessage("")
        }
        return channels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell") as! ChatCell
        let model = channels[indexPath.row]
        cell.tag = indexPath.row
        cell.lblAuthorName.text = model.createdBy
        cell.lblTitle.text = model.friendlyName
        
        if let dateFromServer = model.dateCreated{
            let strDate = myDate.localDateFormatter.string(from: dateFromServer)
//            print (dateFromServer)
//            print (strDate)
            cell.lblCreatedAt.text = strDate
        }

//        if let avatarLink = model.meta?.avatar {
//            cell.imgAvatar.downloadImageFrom(link: avatarLink, contentMode: .scaleAspectFill)
//        }
        
        self.tblView.separatorStyle = .singleLine
        self.tblView.separatorColor = .systemOrange
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let model = self.items[indexPath.item]
        let channelDescriptor = self.channels[indexPath.item]
        let newViewController = BasicChatViewController()
        channelDescriptor.channel(completion:{ (result, channel) in
          if result.isSuccessful(){
            print("Channel Status: \(String(describing: channel?.status))")
            if  let channel = channel{
                newViewController.channel = channel
            }
            self.navigationController?.pushViewController(newViewController, animated: true)
          }
        })
    }
}
