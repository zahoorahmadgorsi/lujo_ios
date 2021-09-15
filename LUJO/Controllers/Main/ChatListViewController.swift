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
    
    @IBOutlet weak var imgCross: UIImageView!
    @IBOutlet weak var tblView: UITableView!
    
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
//    var chatManager = ChatManager(channelName: "")
    var identity = "USER_IDENTITY"
    //MARK:- View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addViewBorder(borderColor: UIColor.clear.cgColor, borderWidth: 1.0, borderCornerRadius: 24.0)
        self.tblView.dataSource = self;
        self.tblView.delegate = self;
        self.tblView.refreshControl = refreshControl
        
        //tap gesture on cross button
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imgCrossTapped))
        imgCross.isUserInteractionEnabled = true
        imgCross.addGestureRecognizer(tapGesture)
        
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New", style: .done, target: self, action: #selector(addTapped))
    }
    
    @objc func imgCrossTapped(_ sender: Any) {
        self.dismiss(animated: true, completion:nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (self.channels.count == 0){
            self.getChatsList(showActivity: true)
        }else{
            self.getChatsList(showActivity: false)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    @objc func refreshConversations() {
        self.refreshControl.beginRefreshing()
        getChatsList(showActivity: false)
    }
    
    func getChatsList(showActivity: Bool) {
        if showActivity {
            self.showNetworkActivity()
        }
        ChatManager.sharedChatManager.getUserChannels() {channels in
            if showActivity {
                self.hideNetworkActivity()
            }
//            for channel in channels {
//                print("Twilio: Channel: \(channel.friendlyName)")
//            }
            //sorting channels by date.. most recetnly update comes at top
            self.channels = channels.sorted(by: { $0.dateUpdated ?? Date() > $1.dateUpdated ?? Date()})
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
        cell.lblChannelFriendlyName.text = model.friendlyName?.uppercased()
        cell.lblLastMessage.text = model.uniqueName
        
        if let dateFromServer = model.dateCreated{
            cell.lblCreatedAtDate.text = dateFromServer.whatsAppTimeFormat()
            cell.lblCreatedAtTime.text = ""
//            cell.lblCreatedAtDate.text = Date.dateToString(date:dateFromServer, format: "MMM dd,yyyy")
//            cell.lblCreatedAtTime.text = Date.dateToString(date:dateFromServer, format: "h:mm a")
        }

//        if let avatarLink = model.meta?.avatar {
//            cell.imgAvatar.downloadImageFrom(link: avatarLink, contentMode: .scaleAspectFill)
//        }
        
        self.tblView.separatorStyle = .singleLine
        self.tblView.separatorColor = .lightGray
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let model = self.items[indexPath.item]
        let channelDescriptor = self.channels[indexPath.item]
        let newViewController = BasicChatViewController()
        channelDescriptor.channel(completion:{ (result, channel) in
          if result.isSuccessful(){
            print("Twilio: Channel Status: \(String(describing: channel?.status))")
            if  let channel = channel{
                newViewController.channel = channel
            }
            self.navigationController?.pushViewController(newViewController, animated: true)
          }
        })
    }
}
