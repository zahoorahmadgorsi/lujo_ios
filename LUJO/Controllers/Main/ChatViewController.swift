/*
MIT License

Copyright (c) 2017-2020 MessageKit

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import UIKit
import MessageKit
import InputBarAccessoryView
import JGProgressHUD
import TwilioChatClient

/// A base class for the example controllers
class ChatViewController: MessagesViewController, MessagesDataSource {

    // MARK: - Public properties

    /// The `BasicAudioController` control the AVAudioPlayer state (play, pause, stop) and update audio cell UI accordingly.
//    lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)

    lazy var messageList: [ChatMessage] = []
    var channel = TCHChannel()
    private let naHUD = JGProgressHUD(style: .dark)
    
    private(set) lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
        return control
    }()

    // MARK: - Private properties

    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

//    // Important - this identity would be assigned by your app, for
//    // instance after a user logs in
    var identity = "USER_IDENTITY"
//    // Convenience class to manage interactions with Twilio Chat
//    var chatManager = ChatManager()
    var chatManager:ChatManager!
    var product:Product!
    var initialMessage:String?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMessageCollectionView()
        configureMessageInputBar()
        
//        if (channel != nil){  //user isnt coming to start a new conversation
//            getConversationDetails(showActivity: true)
//        }else{
////            if let user:ChatUser = self.systemUser() as? ChatUser  {
//                let displayPicture =  "https://www.golujo.com/_assets/media/icons/footer-logo.svg" //if default avatar isnt available then just display the app logo
//                let chatUser:ChatUser = ChatUser(senderId: "0000" , displayName:"LUJO", avatar: displayPicture)
//                let chatMessage:ChatMessage = ChatMessage(text: "How may we assist you today?", user: chatUser, messageId: UUID().uuidString, date: Date())
//                self.messageList.append(chatMessage)
//                self.messagesCollectionView.reloadData()
//                self.messagesCollectionView.scrollToLastItem(animated: true)
////            }
//        }
        title = "LUJO"
        
        chatManager.delegate = self
        if let user = LujoSetup().getLujoUser(), user.id > 0 {
            identity = user.email //+ " " + user.lastName
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        login()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        chatManager.shutdown()
    }

    // MARK: Login

    func login() {
        chatManager.login(self.identity) { (success) in
            DispatchQueue.main.async {
                if success {
//                    self.navigationItem.prompt = "Logged in as \"\(self.identity)\""
                    print("Logged in as \"\(self.identity)\"")
                } else {
//                    self.navigationItem.prompt = "Unable to login"
                    print("Unable to login")
                    let error = BackendError.parsing(reason: "Unable to login - check the token URL in ChatConstants.swift")
                    self.showError(error)
                }
            }
        }
    }
    
    func update(_ information: ConversationDetails?) {
        guard information != nil else {
            return
        }
        
        if let messages = information?.items{
            for item in messages{
                let displayPicture =  item.meta?.avatar ?? "https://www.golujo.com/_assets/media/icons/footer-logo.svg" //if default avatar isnt available then just display the app logo
                let chatUser:ChatUser = ChatUser(senderId:String(item.meta?.id ?? 0000) , displayName:item.author, avatar: displayPicture)
                let dateFromServer = item.createdAt.date
                let dtDate = myDate.serverDateFormatter.date(from: dateFromServer)!
                let chatMessage:ChatMessage = ChatMessage(text: item.body, user: chatUser, messageId: UUID().uuidString, date: dtDate)
                self.messageList.append(chatMessage)
            }
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem(animated: true)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func loadMoreMessages() {
//        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1) {
//            SampleData.shared.getMessages(count: 20) { messages in
//                DispatchQueue.main.async {
//                    self.messageList.insert(contentsOf: messages, at: 0)
//                    self.messagesCollectionView.reloadDataAndKeepOffset()
//                    self.refreshControl.endRefreshing()
//                }
//            }
//        }
    }
    
    func configureMessageCollectionView() {
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        
        scrollsToLastItemOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false

        showMessageTimestampOnSwipeLeft = true // default false
        
        messagesCollectionView.refreshControl = refreshControl
    }
    
    func configureMessageInputBar() {
        messageInputBar.delegate = self
        messageInputBar.inputTextView.text = self.initialMessage
        messageInputBar.inputTextView.tintColor = .rgMid
        messageInputBar.sendButton.setTitleColor(.rgMid, for: .normal)
        messageInputBar.sendButton.setTitleColor(
            UIColor.rgMid.withAlphaComponent(0.3),
            for: .highlighted
        )
    }
    
    // MARK: - Helpers
    
    func insertMessage(_ message: ChatMessage) {
        messageList.append(message)
        // Reload last section to update header/footer labels and insert a new one
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messageList.count - 1])
            if messageList.count >= 2 {
                messagesCollectionView.reloadSections([messageList.count - 2])
            }
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToLastItem(animated: true)
            }
        })
    }
    
    func isLastSectionVisible() -> Bool {
        guard !messageList.isEmpty else { return false }
        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }

    // MARK: - MessagesDataSource

    func currentSender() -> SenderType {
        if let currentUser = LujoSetup().getLujoUser(){
            let currentSender:ChatUser = ChatUser(senderId: String(currentUser.id), displayName: currentUser.firstName + " " + currentUser.lastName,avatar: currentUser.avatar)
            return currentSender
        }else{
            return systemUser()
        }
    }
    
    func systemUser() -> SenderType {
        let system = ChatUser(senderId: "000000", displayName: "LUJO")
        return system
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
        //adding time inside the text bubble
//        let item:MessageType = messageList[indexPath.section]
//        guard let time24hours = item.sentDate.asDateAndTime()["time"] else {
//            return messageList[indexPath.section]
//        }
//
//        let chatMessage:ChatMessage = ChatMessage(text: getTheMessageText(messageKind: item.kind) + "\n" + time24hours.time24To12(), user: item.sender as! ChatUser, messageId: item.messageId, date: item.sentDate)
//        return chatMessage
    }

    func getTheMessageText(messageKind: MessageKind) -> String {
        if case .text(let value) = messageKind {
            return value
        }
        return ""
    }
    
    //this function groups all messages under one date i.e. cellTopLabel will only be displayed once for each date
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if let firstItem = messageList[safe:indexPath.section - 1] , let secondItem = messageList[safe:indexPath.section]{
//            print(firstItem.sentDate.stripTime(),secondItem.sentDate.stripTime())
            if (firstItem.sentDate.stripTime() == secondItem.sentDate.stripTime()){
//                print("Dates are same")
                return nil  //no need to display message date as
            }
        }
        return NSAttributedString(string: message.sentDate.dateToDayWeekYear(), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
    }

    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(string: "Read", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
    }

    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }

    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if let time24hours = message.sentDate.asDateAndTime()["time"]{
            return NSAttributedString(string: time24hours.time24To12() , attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
        }else{
            return nil
        }
    }
    
    func textCell(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UICollectionViewCell? {
        return nil
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
}

// MARK: - MessageCellDelegate

extension ChatViewController: MessageCellDelegate {
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
    }
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        print("Image tapped")
    }
    
    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        print("Top cell label tapped")
    }
    
    func didTapCellBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom cell label tapped")
    }
    
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        print("Top message label tapped")
    }
    
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom label tapped")
    }

    func didStartAudio(in cell: AudioMessageCell) {
        print("Did start playing audio sound")
    }

    func didPauseAudio(in cell: AudioMessageCell) {
        print("Did pause audio sound")
    }

    func didStopAudio(in cell: AudioMessageCell) {
        print("Did stop audio sound")
    }

    func didTapAccessoryView(in cell: MessageCollectionViewCell) {
        print("Accessory view tapped")
    }

}

// MARK: - MessageLabelDelegate

extension ChatViewController: MessageLabelDelegate {
    func didSelectAddress(_ addressComponents: [String: String]) {
        print("Address Selected: \(addressComponents)")
    }
    
    func didSelectDate(_ date: Date) {
        print("Date Selected: \(date)")
    }
    
    func didSelectPhoneNumber(_ phoneNumber: String) {
        print("Phone Number Selected: \(phoneNumber)")
    }
    
    func didSelectURL(_ url: URL) {
        print("URL Selected: \(url)")
    }
    
    func didSelectTransitInformation(_ transitInformation: [String: String]) {
        print("TransitInformation Selected: \(transitInformation)")
    }

    func didSelectHashtag(_ hashtag: String) {
        print("Hashtag selected: \(hashtag)")
    }

    func didSelectMention(_ mention: String) {
        print("Mention selected: \(mention)")
    }

    func didSelectCustom(_ pattern: String, match: String?) {
        print("Custom data detector patter selected: \(pattern)")
    }
}

// MARK: - MessageInputBarDelegate

extension ChatViewController: InputBarAccessoryViewDelegate {

    @objc
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        processInputBar(messageInputBar)
    }

    func processInputBar(_ inputBar: InputBarAccessoryView) {
        // Here we can parse for which substrings were autocompleted
        let attributedText = inputBar.inputTextView.attributedText!
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.enumerateAttribute(.autocompleted, in: range, options: []) { (_, range, _) in
            let substring = attributedText.attributedSubstring(from: range)
            let context = substring.attribute(.autocompletedContext, at: 0, effectiveRange: nil)
            print("Autocompleted: `", substring, "` with context: ", context ?? [])
        }

        let components = inputBar.inputTextView.components
        inputBar.inputTextView.text = String()
        inputBar.invalidatePlugins()
        // Send button activity animation
        inputBar.sendButton.startAnimating()
        inputBar.inputTextView.placeholder = "Sending..."
        // Resign first responder for iPad split view
        inputBar.inputTextView.resignFirstResponder()
        
        for component in components {
            if let str = component as? String  {
                chatManager.sendMessage(str, completion: { (result, _) in
                    if result.isSuccessful() {
                        inputBar.sendButton.stopAnimating()
                        inputBar.inputTextView.placeholder = "Aa"
                        
//                        if let user:ChatUser = self.currentSender() as? ChatUser  {
//                            let message = ChatMessage(text: str, user: user, messageId: UUID().uuidString, date: Date())
//                            self.insertMessage(message)
//                            self.messagesCollectionView.scrollToLastItem(animated: true)
//                        }
                    } else {
//                        self.displayErrorMessage("Unable to send message")
                        let error = BackendError.parsing(reason: "Unable to send message")
                        self.showError(error)
                    }
                })
            }
        }
    }

    private func insertMessages(_ data: [Any]) {
        for component in data {
            if let str = component as? String, let user:ChatUser = self.currentSender() as? ChatUser  {
                let message = ChatMessage(text: str, user: user, messageId: UUID().uuidString, date: Date())
                insertMessage(message)
            }
//            else if let img = component as? UIImage {
//                let message = MockMessage(image: img, user: user, messageId: UUID().uuidString, date: Date())
//                insertMessage(message)
//            }
        }
    }
}

// MARK: QuickstartChatManagerDelegate
extension ChatViewController: ChatManagerDelegate {
    func reloadMessages() {
//        if (messageList.count == 1 ){
//            self.messagesCollectionView.reloadData()    // <-- This line will make UICollection crash if it has 0 items
//        }
        
    }

    // Scroll to bottom of table view for messages
    func receivedNewMessage(message: TCHMessage , channel: TCHChannel) {
        if (self.channel.sid == channel.sid){    //currently opened channel received the messages
            if (identity == message.member?.identity){ //its current users message
                if let user:ChatUser = self.currentSender() as? ChatUser  {
                    let msg = ChatMessage(text: message.body ?? "", user: user, messageId: message.sid ?? UUID().uuidString, date: message.dateCreatedAsDate ?? Date())
                    self.insertMessage(msg)
                    self.messagesCollectionView.scrollToLastItem(animated: true)
                }
            }else{
                let currentSender:ChatUser = ChatUser(senderId: message.member?.sid ?? "0000", displayName: message.member?.identity ?? "Default User")
                let msg = ChatMessage(text: message.body ?? "", user: currentSender, messageId: message.sid ?? UUID().uuidString, date: message.dateCreatedAsDate ?? Date())
                self.insertMessage(msg)
                self.messagesCollectionView.scrollToLastItem(animated: true)
            }
        }else{
            print("An other channel has received the message")
        }

    }
    
    func channelJoined(channel: TCHChannel){
        self.channel = channel
        self.showNetworkActivity()
        EEAPIManager().sendRequestForSalesForce(itemId: product.id, channelId: channel.sid ?? "NoChannel"){ customBookingResponse, error in
            self.hideNetworkActivity()
            guard error == nil else {
                Crashlytics.sharedInstance().recordError(error!)
                BackendError.parsing(reason: "Could not obtain the salesforce_id")
                return
            }
            print("After channel creation, joining, channelID is sent to salesforce successfully")
        }
    }
}
