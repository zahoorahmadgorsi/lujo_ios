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
import TwilioConversationsClient
import Mixpanel
import CoreLocation

/// A base class for the example controllers
class ConversationViewController: MessagesViewController, MessagesDataSource {

    // MARK: - Public properties

    /// The `BasicAudioController` control the AVAudioPlayer state (play, pause, stop) and update audio cell UI accordingly.
//    lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)
    let displayPicture =  "https://www.golujo.com/_assets/media/icons/footer-logo.svg"
    lazy var messageList: [ChatMessage] = []
    var conversation: TCHConversation?
    private let naHUD = JGProgressHUD(style: .dark)
    let pageSize: UInt = 10
    
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

//  Important - this identity would be assigned by your app, for instance after a user logs in
    var identity = "USER_IDENTITY"
    var product:Product!
    var initialMessage:String?
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var lastReadMessageIndex:Int = -1
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        //Need to send LAT/LONG with each message to the server
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        }
        
        configureMessageCollectionView()
        configureMessageInputBar()
//        title = "LUJO"  //this name would be override with conversation friendly name
        overrideUserInterfaceStyle = .dark  //showing chat window in dark mode
        let searchBarButton = UIButton(type: .system)
        searchBarButton.setImage(UIImage(named: "cross"), for: .normal)
//        searchBarButton.setTitle("Cancel", for: .normal)
        searchBarButton.titleLabel?.font = UIFont.systemFont(ofSize: 11)
        searchBarButton.addTarget(self, action: #selector(imgCrossTapped(_:)), for: .touchUpInside)
        searchBarButton.sizeToFit()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchBarButton)
        
        identity = LujoSetup().getLujoUser()?.email ?? identity //current logged in user
        
        if let converse = self.conversation{  //loading messages of existing conversation
            //Using setter to assign conversation
            ConversationsManager.sharedConversationsManager.setConversation(conversation: converse)
            //getting last pageSize count message of this conversation
            ConversationsManager.sharedConversationsManager.getLastMessagesWithCount(converse, msgsCount: pageSize, completion: {messages in
                //Since last pageSize count messages are fetched so we can safely set All messsages to be read for current participant
                ConversationsManager.sharedConversationsManager.setAllMessagesRead(converse) { (result, count) in
    //                        print("Twilio: channel's UnConsumed messages count set to zero. Result:\(result.isSuccessful())" , "Count:\(count)")
                }
                //Getting last message read index of other participants
                self.lastReadMessageIndex = ConversationsManager.sharedConversationsManager.getOthersLastMessageRead()
                
                var tempMessages:[ChatMessage] = []
//              print(tchMessage.attributes()?.dictionary)
                let myGroup = DispatchGroup()
//                self.showNetworkActivity()
                for msg in messages {
                    myGroup.enter()
                    if msg.hasMedia(){
                        //this is an asynch call
                        self.getAndConvertTCHImageMessageToChatMessage(msg) { (chatImageMessage, isCached) in
                            tempMessages.append(chatImageMessage)
                            myGroup.leave()
                        }
                    }else if let message = self.convertTCHMessageToChatMessage(message: msg){   //its a synch call
                        tempMessages.append(message)
                        myGroup.leave()
                    }
                }
                myGroup.notify(queue: .main) {
                    print("Twilio: conversation viewDidLoad. Finished whole DispatchGroup.")
//                    self.hideNetworkActivity()
                    tempMessages = tempMessages.sorted(by: { $0.sentDate < $1.sentDate }) //due to asynch calls, messages might be out of order
                    self.messageList.insert(contentsOf: tempMessages, at: 0)
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem(animated: true)
                }
            })
        }else if let user = LujoSetup().getLujoUser(), user.id > 0 { //creating new conversation
            let dateTime = Date.dateToString(date: Date(),format: "yyyy-MM-dd-HH-mm-ss")
            //Creating channel if doesnt exist else joining
            let channelUniqueName = product.type + " " + user.firstName + " " + dateTime
            let channelFriendlyName = product.name

            var attribute = Utility.getAttributes(onlyRelatedToUser: false)
            attribute["type"] = product.type

            if (initialMessage == nil ){    //user is coming for some general inquiry thats why initial message is nil
                let chatMessage:ChatMessage = addDefaultMessage(type:product.type)
                self.messageList.append(chatMessage)
            }
            showNetworkActivity()
            ConversationsManager.sharedConversationsManager.createConversation(uniqueChannelName: channelUniqueName, friendlyName: channelFriendlyName, customAttribute: attribute, { channelResult, channel in
                    if let location = self.currentLocation { //updating location (if user has enabled) and other attributes
                        var attributes = Utility.getAttributes(onlyRelatedToUser: false)
                        attributes["device_latitude"] = String(location.coordinate.latitude)
                        attributes["device_longitude"] = String(location.coordinate.longitude)
                        attributes["type"] = self.product.type
                        ConversationsManager.sharedConversationsManager.updateConversationAttributes(customAttributes: attributes)
                    }
                self.hideNetworkActivity()
            })
        }
    }
    
    @objc func imgCrossTapped(_ sender: Any) {
        self.dismiss(animated: true, completion:{
            self.presentationController?.delegate?.presentationControllerDidDismiss?(self.presentationController!)
        })
    }
    
    func addDefaultMessage(type:String)->ChatMessage{
         //if default avatar isnt available then just display the app logo
        let chatUser:ChatUser = ChatUser(senderId:"0000" , displayName:"LUJO", avatar: displayPicture)
        var defaultMessage:String = "Please include all the important details such as "
        if (type == "event" || type == "experience" || type == "special-event"){
            defaultMessage += "number of guests, location, date, time, budget "
        }else
        if(type == "gift"){
            defaultMessage += "name, brand, color, model etc "
        }else if(type == "yacht"){
            defaultMessage += "yacht charter type, yacht name, yacht type & cruising speed, number of guests, number of cabins, number of crews, builder name & year, refit year, yacht length, style, region, preferred cuisines, embarkation date and disembarkation date etc "
        }else if(type == "villa"){
            defaultMessage += "villa location, amenities, number of guests, number of rooms and number of washrooms, check in date and check out date etc "
        }else if(type == "travel"){
            defaultMessage += "travel destinations, travel activities, hotel star ratings, hotel groups & styles, amenities,  airlines, cabin class, seating in the airplane, meals, any allergies? etc "
        }else if(type == "restaurant"){
            defaultMessage += "restaurant name, date and time, preferred cuisines, beverages & seatings, any allergies, dining preference, dining time etc "
        }else if(type == "aviation"){
            defaultMessage += "one way or round trip, destination city & airport, aircraft category, charter date & time, cuisines & beverages, smoking? etc "
        }else{
            defaultMessage += "number of guests, locations, date, time, budget "
        }
        defaultMessage +=  "and any other preferences we should note."
        let chatMessage:ChatMessage = ChatMessage(text: defaultMessage, user: chatUser, messageId: UUID().uuidString, date: Date(), messageIndex: 0)
        return chatMessage
    }

    // MARK: update
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func loadMoreMessages() {
        if let channel = self.conversation , messageList.count > 0{
            var lastMessageIndex = messageList[0].messageIndex?.intValue ?? 0  //get the index of very first message in UInt
            lastMessageIndex -= 1   //fetch one index less downward
            if (lastMessageIndex >= 0){
                ConversationsManager.sharedConversationsManager.getOldMessagesWithCount(channel,startingIndex: UInt(lastMessageIndex), msgsCount: pageSize, completion: {messages in
                    var tempMessages:[ChatMessage] = []
                    let myGroup = DispatchGroup()
                    for message in messages {
                        myGroup.enter()
                        if message.hasMedia(){
                            //this is an asynch call
                            self.getAndConvertTCHImageMessageToChatMessage(message) { (chatImageMessage, isCached) in
                                tempMessages.append(chatImageMessage)
                                myGroup.leave()
                            }
                        }else if let message = self.convertTCHMessageToChatMessage(message: message){ //its a synch call
                            tempMessages.append(message)
                            myGroup.leave()
                        }
                    }
                    myGroup.notify(queue: .main) {
                        print("Twilio: loadMoreMessages Finished whole DispatchGroup.")
                        tempMessages = tempMessages.sorted(by: { $0.sentDate < $1.sentDate }) //due to asynch calls, messages might be out of order
                        self.messageList.insert(contentsOf: tempMessages, at: 0)
                        self.messagesCollectionView.reloadDataAndKeepOffset()
                        self.refreshControlEndRefreshing()
                    }
                })
            }else{
                refreshControlEndRefreshing()
            }
        }else{
            refreshControlEndRefreshing()
        }
    }
    
    private func refreshControlEndRefreshing(){
        self.refreshControl.endRefreshing()
        //messagekit is already taking the collection view to the top,  but some times it fails. checking that failing moment
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
            if (self.messagesCollectionView.contentOffset != CGPoint.zero){
                UIView.animate(withDuration: 0.5, animations: {
                    self.messagesCollectionView.contentOffset = CGPoint.zero
                })
            }
            timer.invalidate()
        })

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
        
        //within this 1.5 second interval, content offset get change meaning messagekit is doing some thing i.e. scrolling to the last message
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true, block: { timer in
            if (self.messagesCollectionView.contentOffset == CGPoint.zero){
                UIView.animate(withDuration: 0.5, animations: {
                    self.messagesCollectionView.contentOffset = CGPoint.init(x: 0, y: -110)
                })
            }
            timer.invalidate()
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
                return nil  //no need to display message date as
            }
        }
        return NSAttributedString(string: message.sentDate.dateToDayWeekYear(), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
    }

    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if let currentMessage = messageList[safe:indexPath.section] , let currentMessageIndex =  currentMessage.messageIndex?.intValue{
            if currentMessageIndex > lastReadMessageIndex{
                return NSAttributedString(string: "Unread", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
            }
        }
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
//        messageInputBar.sendButton.isEnabled = false
        messageInputBar.isUserInteractionEnabled = false
//        }
    }
    
    func hideNetworkActivity() {
        // Safe guard that will call dismiss only if HUD is shown on screen.
        if naHUD.isVisible {
            naHUD.dismiss()
//            messageInputBar.sendButton.isEnabled = true
            messageInputBar.isUserInteractionEnabled = true
        }
    }
}

// MARK: - MessageCellDelegate

extension ConversationViewController: MessageCellDelegate {
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

extension ConversationViewController: MessageLabelDelegate {
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

extension ConversationViewController: InputBarAccessoryViewDelegate {

    @objc
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        processInputBar(messageInputBar)
    }

    func processInputBar(_ inputBar: InputBarAccessoryView) {
        
        var attribute = Utility.getAttributes(onlyRelatedToUser: true) //sending user attributes with each message as well
        if let currentLoc = currentLocation{
            attribute["device_latitude"] = String(currentLoc.coordinate.latitude)
            attribute["device_longitude"] = String(currentLoc.coordinate.longitude)
        }
        
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
                ConversationsManager.sharedConversationsManager.sendMessage(str, attribute, completion: { (result, _) in
                    inputBar.sendButton.stopAnimating()
                    if result.isSuccessful {
                        inputBar.inputTextView.placeholder = "Aa"
                        inputBar.inputTextView.becomeFirstResponder()   //brining focus for next message type
                    } else {
//                        self.displayErrorMessage("Unable to send message")
                        let error = BackendError.parsing(reason: "Unable to send message")
                        self.showError(error)
                    }
                })
            }
        }
//        }

    }
    
    internal func convertTCHMessageToChatMessage(message: TCHMessage) -> ChatMessage? {
        
        if (identity == message.participant?.identity){ //its current user's message
            if let user:ChatUser = self.currentSender() as? ChatUser  {
                if let messageBody = message.body {
                    if messageBody.isHtml(){
                        let attributedString = messageBody.parseHTML()
                        let msg = ChatMessage(attributedText: attributedString, user: user, messageId: message.sid ?? UUID().uuidString, date: message.dateCreatedAsDate ?? Date(), messageIndex: message.index ?? 0)
                        return msg
                    }else{
                        let msg = ChatMessage(text: messageBody, user: user, messageId: message.sid ?? UUID().uuidString, date: message.dateCreatedAsDate ?? Date() , messageIndex: message.index ?? 0)
                        return msg
                    }
                }
            }
        }else{
            //let currentSender:ChatUser = ChatUser(senderId: message.participant?.sid ?? "000", displayName: message.author ?? "Author name")
            let currentSender:ChatUser = ChatUser(senderId: message.participant?.sid ?? "000", displayName: "Customer Support")
            if let messageBody = message.body {
                if messageBody.isHtml(){
                    let attributedString = messageBody.parseHTML()
                    let msg = ChatMessage(attributedText: attributedString, user: currentSender, messageId: message.sid ?? UUID().uuidString, date: message.dateCreatedAsDate ?? Date(), messageIndex: message.index ?? 0)
                    return msg
                }else{
                    let msg = ChatMessage(text: messageBody, user: currentSender, messageId: message.sid ?? UUID().uuidString, date: message.dateCreatedAsDate ?? Date(), messageIndex: message.index ?? 0)
                    return msg
                }
            }
            
        }
        return nil
    }
    
    internal func getAndConvertTCHImageMessageToChatMessage(_ message: TCHMessage
                                                           , completion: @escaping (ChatMessage , _ isCached:Bool) -> Void){
        
        if let sid = message.mediaSid{
//            print("Twilio: message.index:\(String(describing: message.index))")
            if let cachedImage = ConversationsManager.sharedCache.object(forKey: sid as NSString) {
                print("Twilio: Image from cache")
                if (identity == message.participant?.identity){ //its current user's message
                    if let chatUser:ChatUser = self.currentSender() as? ChatUser  {
                        let photoMessage = ChatMessage(image: cachedImage, user: chatUser, messageId: UUID().uuidString, date: message.dateCreatedAsDate ?? Date(), messageIndex: message.index ?? 0)
                        completion(photoMessage, true)
                    }
                }else{
//                    let chatUser:ChatUser = ChatUser(senderId: message.participant?.sid ?? "000", displayName: message.author ?? "Author name")
                    let chatUser:ChatUser = ChatUser(senderId: message.participant?.sid ?? "000", displayName: "Customer Support")
                    let photoMessage = ChatMessage(image: cachedImage, user: chatUser, messageId: UUID().uuidString, date: message.dateCreatedAsDate ?? Date(), messageIndex: message.index ?? 0)
                    completion(photoMessage, true)
                }
            }else{  //image not found in the cache
                message.getMediaContentTemporaryUrl { (result, mediaContentUrl) in
                    guard let mediaContentUrl = URL( string:mediaContentUrl ?? self.displayPicture) else {
                        return
                    }
                    // Use this url to download an image or other media
//                    print("Twilio: mediaContentUrl:\(mediaContentUrl)")
                    DispatchQueue.global().async {
                        if let data = try? Data( contentsOf:mediaContentUrl) , let loadedImage:UIImage = UIImage( data:data)
                        {
                            DispatchQueue.main.async {
                                ConversationsManager.sharedCache.setObject(loadedImage, forKey: sid as NSString) //putting image into the cache
                                if (self.identity == message.participant?.identity){ //its current user's message
                                    if let chatUser:ChatUser = self.currentSender() as? ChatUser  {
                                        let photoMessage = ChatMessage(image: loadedImage, user: chatUser, messageId: UUID().uuidString, date: message.dateCreatedAsDate ?? Date(), messageIndex: message.index ?? 0)
                                        completion(photoMessage, false)
                                    }
                                }else{
                                    let chatUser:ChatUser = ChatUser(senderId: message.participant?.sid ?? "000", displayName: message.author ?? "Author name")
                                    let photoMessage = ChatMessage(image: loadedImage, user: chatUser, messageId: UUID().uuidString, date: message.dateCreatedAsDate ?? Date(), messageIndex: message.index ?? 0)
                                    completion(photoMessage, false)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

extension ConversationViewController:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        self.currentLocation = locations.first
        //for printing
//        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
//        print("Twilio: location updated = \(locValue.latitude) \(locValue.longitude)")
    }
}
