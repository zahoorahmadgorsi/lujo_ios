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
//    var channelDescriptors = [TCHChannelDescriptor]()
    var conversations = [Conversation]()
    
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
    var identity = "USER_IDENTITY"
    var delegate:UIAdaptivePresentationControllerDelegate?
    
    //MARK:- View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ChatManager.sharedChatManager.delegate = self
        
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
        
        //loading cached conversations list
        do {
            if let decoded  = UserDefaults.standard.object(forKey: "sorted_conversations") as? Data{
                conversations = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(decoded) as? [Conversation] ?? [Conversation]()
                self.tblView.reloadData()
            }
        } catch {
            print(error)
        }
        
        if (self.conversations.count == 0){
            self.getChatsList(showActivity: true)
        }else{
            self.getChatsList(showActivity: false)
        }
    }
    
    @objc func refreshConversations() {
        self.refreshControl.beginRefreshing()
        getChatsList(showActivity: false)
    }
    
    func getChatsList(showActivity: Bool) {
        if showActivity {
            self.showNetworkActivity()
        }
        ChatManager.sharedChatManager.getUserChannelDescriptors() {channelDescriptors in
            if showActivity {
                self.hideNetworkActivity()
            }else{
                self.refreshControl.endRefreshing()
            }
            var count = 0   //to trace if all descriptor's channel last message body and time has been fetched or not
//            self.channelDescriptors.removeAll()
//            self.conversations.removeAll()
            var tempConversations = [Conversation]()

            for channelDescriptor in channelDescriptors {
//                self.channelDescriptors.append(channelDescriptor)
                if let attributes = channelDescriptor.attributes()?.dictionary , let type = attributes["type"] as? String{
                    let item:Conversation = Conversation(channelDescriptor,channelDescriptor.sid, type,channelDescriptor.friendlyName , channelDescriptor.unconsumedMessagesCount(),"" , Date())
                    item.lastMessageDateTime = channelDescriptor.dateCreated
                    //self.conversations.append(item)
                    tempConversations.append(item)
                }
                ChatManager.sharedChatManager.getChannelFromDescriptor(channelDescriptor: channelDescriptor){(result,channel)  in
                    if (result){
                        channel.messages?.message(withIndex: channel.lastMessageIndex ?? 0, completion: { (result, message) in
                            count += 1
                            if let msg = message{
                                if let fooOffset = tempConversations.firstIndex(where: {$0.sid == channelDescriptor.sid}) {
                                    tempConversations[fooOffset].lastMessageBody = msg.body
                                    if let utcTime = msg.dateCreated{
                                        let date = Date.dateFromUTC(utcTimeString: utcTime)
//                                        print("utc: \(utcTime), date: \(String(describing: date))")
                                        tempConversations[fooOffset].lastMessageDateTime =  date
                                    }
                                }
                            }
                            //if all channels last message's body and time has been fetched then reload the whole grid
//                            print("Count:\(count)" , "channelDescriptors count: \(channelDescriptors.count)")
                            if (count == channelDescriptors.count){
                                self.storeConversations(tempConversations)
                            }
                        })
                    }else{//some error while fetching the channel from descriptor now just load the tableview
                        //sorting channelDescriptor by date.. most recetnly update comes at top
                        self.storeConversations(tempConversations)
                    }
                }
            }
            
        }
    }
    
    func storeConversations(_ tempConversations:[Conversation]){
        do {
            //self.conversations = self.conversations.sorted(by: { $0.lastMessageDateTime ?? Date() > $1.lastMessageDateTime ?? Date()})
            let conversations = tempConversations.sorted(by: { $0.lastMessageDateTime ?? Date() > $1.lastMessageDateTime ?? Date()})
            let encodedData = try NSKeyedArchiver.archivedData(withRootObject: conversations, requiringSecureCoding: false)
            UserDefaults.standard.set(encodedData, forKey: "sorted_conversations")
            self.tblView.reloadData()
            self.conversations = conversations
            
        } catch {
            print(error)
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
        if self.conversations.count == 0 {
            self.tblView.setEmptyMessage("No conversation(s) are available")
        }else{
            self.tblView.restore()
        }
        return conversations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell") as! ChatCell
        let model = conversations[indexPath.row]
        //if let attributes = model.channelDescriptor.attributes()?.dictionary , let type = attributes["type"] as? String{
        if let type = model.type {
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
        cell.lblLastMessage.text = model.lastMessageBody
        if let dateFromServer = model.lastMessageDateTime{
            cell.lblCreatedAt.text = dateFromServer.whatsAppTimeFormat()
        }
        if model.unConsumedMessagesCount.intValue > 0{
            cell.lblUnConsumedMessagesCount.text = model.unConsumedMessagesCount.stringValue
            cell.viewUnConsumedMessagesCount.addViewBorder(borderColor: UIColor.rgMid.cgColor, borderWidth: 1.0, borderCornerRadius: cell.viewUnConsumedMessagesCount.frame.height/2)
        }else{
            cell.lblUnConsumedMessagesCount.text = ""
            cell.viewUnConsumedMessagesCount.addViewBorder(borderColor: UIColor.clear.cgColor, borderWidth: 1.0, borderCornerRadius: cell.viewUnConsumedMessagesCount.frame.height/2)
        }

        
        self.tblView.separatorStyle = .singleLine
        self.tblView.separatorColor = .lightGray
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let model = self.items[indexPath.item]
        //let channelDescriptor = self.channelDescriptors[indexPath.item]
        if let channelDescriptor = self.conversations[indexPath.item].channelDescriptor{
            let viewController = BasicChatViewController()
            channelDescriptor.channel(completion:{ (result, channel) in
              if result.isSuccessful(){
                print("Twilio: Channel didSelectRowAt Status: \(String(describing: channel?.status))")
                if  let channel = channel{
                    viewController.channel = channel
                }

                let navViewController: UINavigationController = UINavigationController(rootViewController: viewController)
                if #available(iOS 13.0, *) {
                    let controller = navViewController.topViewController
                    // Modal Dismiss iOS 13 onward
                    controller?.presentationController?.delegate = self
                }
                //incase user will do some messaging in basicchatviewcontroller and then dismiss it then chatlistviewcontroller should reflect last message body and time
                navViewController.presentationController?.delegate = self
                self.present(navViewController, animated: true, completion: nil)
              }
            })
        }
        
    }
}

extension ChatListViewController: UIAdaptivePresentationControllerDelegate {
    // Only called when the sheet is dismissed by DRAGGING as well as when tapped on cross button
    public func presentationControllerDidDismiss( _ presentationController: UIPresentationController) {
        if #available(iOS 13, *) {
            //Call viewWillAppear only in iOS 13
            viewWillAppear(true)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "showBadgeValue"), object: nil)
        }
    }
}

extension ChatListViewController: ChatManagerDelegate {
    func reloadMessages() {
        print("Twilio: reloadMessages")
    }
    
    func receivedNewMessage(message: TCHMessage, channel: TCHChannel) {
        self.viewDidAppear(true)    //it will update the last message body, time and consumed index
    }
    
    func channelJoined(channel: TCHChannel) {
        print("Twilio: channelJoined")
    }
    
    
}
