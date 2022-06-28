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
import MapKit
import MessageKit
import InputBarAccessoryView
import Kingfisher
import TwilioConversationsClient
import Mixpanel
import FirebaseCrashlytics

final class AdvanceChatViewController: ConversationViewController {
        
    let outgoingAvatarOverlap: CGFloat = 17.5
    var readConsumptionTimer = Timer()
    let readConsumptionTimerInterval:TimeInterval = 5
    
    override func viewDidLoad() {
        messagesCollectionView = MessagesCollectionView(frame: .zero, collectionViewLayout: CustomMessagesFlowLayout())
        messagesCollectionView.register(CustomCell.self)
        super.viewDidLoad()
        ConversationsManager.sharedConversationsManager.delegate = self
        
        updateTitleView(title: conversation?.friendlyName ?? "LUJO", subtitle: nil)    //extension 2 Online
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.readConsumptionTimer.invalidate()
    }
    
    override func configureMessageCollectionView() {
        super.configureMessageCollectionView()
        
//        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
//        layout?.sectionInset = UIEdgeInsets(top: 1, left: 8, bottom: 1, right: 8)
//
//        // Hide the outgoing avatar and adjust the label alignment to line up with the messages
//        layout?.setMessageOutgoingAvatarSize(.zero)
//        layout?.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)))
//        layout?.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)))
//
//        // Set outgoing avatar to overlap with the message bubble
//        layout?.setMessageIncomingMessageTopLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 18, bottom: outgoingAvatarOverlap, right: 0)))
//        layout?.setMessageIncomingAvatarSize(CGSize(width: 30, height: 30))
//        layout?.setMessageIncomingMessagePadding(UIEdgeInsets(top: -outgoingAvatarOverlap, left: -18, bottom: outgoingAvatarOverlap, right: 18))
//
//        layout?.setMessageIncomingAccessoryViewSize(CGSize(width: 30, height: 30))
//        layout?.setMessageIncomingAccessoryViewPadding(HorizontalEdgeInsets(left: 8, right: 0))
//        layout?.setMessageIncomingAccessoryViewPosition(.messageBottom)
//        layout?.setMessageOutgoingAccessoryViewSize(CGSize(width: 30, height: 30))
//        layout?.setMessageOutgoingAccessoryViewPadding(HorizontalEdgeInsets(left: 0, right: 8))

        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    
    override func configureMessageInputBar() {
//        super.configureMessageInputBar()
        
        messageInputBar = CameraInputBarAccessoryView()
        messageInputBar.delegate = self
//        messageInputBar.overrideUserInterfaceStyle = .dark  //zahoor showing advance chat window always in dark mode
        messageInputBar.inputTextView.tintColor = .rgMid
        messageInputBar.inputTextView.delegate = self // to show typingIndicator
        
        messageInputBar.sendButton.setTitleColor(.rgMid, for: .normal)
        messageInputBar.sendButton.setTitleColor(
            UIColor.rgMid.withAlphaComponent(0.3),
            for: .highlighted)
        
        
        messageInputBar.isTranslucent = true
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.inputTextView.text = self.initialMessage
        
        messageInputBar.inputTextView.tintColor = .rgMid
        //messageInputBar.inputTextView.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        messageInputBar.inputTextView.backgroundColor = .white
        messageInputBar.inputTextView.textColor = .black
        messageInputBar.inputTextView.placeholderTextColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 36)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 36)
        messageInputBar.inputTextView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
        messageInputBar.inputTextView.layer.borderWidth = 1.0
        messageInputBar.inputTextView.layer.cornerRadius = 16.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        configureInputBarItems()
    }

    private func configureInputBarItems() {
        messageInputBar.setRightStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.sendButton.imageView?.backgroundColor = UIColor(white: 0.85, alpha: 1)
        messageInputBar.sendButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        messageInputBar.sendButton.setSize(CGSize(width: 36, height: 36), animated: false)
        messageInputBar.sendButton.image = #imageLiteral(resourceName: "ic_up")
        messageInputBar.sendButton.title = nil
        messageInputBar.sendButton.imageView?.layer.cornerRadius = 16
//        let charCountButton = InputBarButtonItem()
//            .configure {
//                $0.title = "0/140"
//                $0.contentHorizontalAlignment = .right
//                $0.setTitleColor(UIColor.rgMid , for: .normal)//(UIColor(white: 0.6, alpha: 1), for: .normal)
//                $0.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: .bold)
//                $0.setSize(CGSize(width: 50, height: 25), animated: false)
//            }.onTextViewDidChange { (item, textView) in
//                item.title = "\(textView.text.count)/140"
//                let isOverLimit = textView.text.count > 140
//                item.inputBarAccessoryView?.shouldManageSendButtonEnabledState = !isOverLimit // Disable automated management when over limit
//                if isOverLimit {
//                    item.inputBarAccessoryView?.sendButton.isEnabled = false
//                }
//                let color = isOverLimit ? .red : UIColor(white: 0.6, alpha: 1)
//                item.setTitleColor(color, for: .normal)
//        }
//        let bottomItems = [.flexibleSpace, charCountButton]
        
        configureInputBarPadding()
        
//        messageInputBar.setStackViewItems(bottomItems, forStack: .bottom, animated: false)

        // This just adds some more flare
        messageInputBar.sendButton
            .onEnabled { item in
                UIView.animate(withDuration: 0.3, animations: {
                    item.imageView?.backgroundColor = .rgMid
                })
            }.onDisabled { item in
                UIView.animate(withDuration: 0.3, animations: {
                    item.imageView?.backgroundColor = UIColor(white: 0.85, alpha: 1)
                })
        }
        messageInputBar.sendButton.isEnabled = messageInputBar.inputTextView.text.count > 0 //if textview has some text then enabled it
    }
    
    /// The input bar will autosize based on the contained text, but we can add padding to adjust the height or width if necessary
    /// See the InputBar diagram here to visualize how each of these would take effect:
    /// https://raw.githubusercontent.com/MessageKit/MessageKit/master/Assets/InputBarAccessoryViewLayout.png
    private func configureInputBarPadding() {
    
        // Entire InputBar padding
        messageInputBar.padding.bottom = 8
        
        // or MiddleContentView padding
        messageInputBar.middleContentViewPadding.right = -38

        // or InputTextView padding
        messageInputBar.inputTextView.textContainerInset.bottom = 8
        
    }
    
    // MARK: - Helpers
    
//    func isTimeLabelVisible(at indexPath: IndexPath) -> Bool {
//        return indexPath.section % 3 == 0 && !isPreviousMessageSameSender(at: indexPath)
//    }
    
    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else { return false }
        return messageList[indexPath.section].user == messageList[indexPath.section - 1].user
    }
    
    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < messageList.count else { return false }
        return messageList[indexPath.section].user == messageList[indexPath.section + 1].user
    }
    
    func setTypingIndicatorViewHidden(_ isHidden: Bool, _ participant: TCHParticipant, performUpdates updates: (() -> Void)? = nil) {
//        var whoIsTyping = "Typing..."
//        if isHidden == false, let name = participant.identity{
//            whoIsTyping = name + " is typing..."
//        }
//        updateTitleView(title: conversation?.friendlyName ?? "LUJO", subtitle: isHidden ? "2 Online" : whoIsTyping)
        updateTitleView(title: conversation?.friendlyName ?? "LUJO", subtitle: isHidden ? "" : "Typing...") //2 Online
        setTypingIndicatorViewHidden(isHidden, animated: true, whilePerforming: updates) { [weak self] success in
            if success, self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToLastItem(animated: true)
            }
        }
    }
    
    
//    private func makeButton(named: String) -> InputBarButtonItem {
//        return InputBarButtonItem()
//            .configure {
//                $0.spacing = .fixed(10)
//                $0.image = UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
//                $0.setSize(CGSize(width: 25, height: 25), animated: false)
//                $0.tintColor = UIColor(white: 0.8, alpha: 1)
//            }.onSelected {
//                $0.tintColor = .rgMid
//            }.onDeselected {
//                $0.tintColor = UIColor(white: 0.8, alpha: 1)
//            }.onTouchUpInside {
//                print("Item Tapped")
//                let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//                let action = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//                actionSheet.addAction(action)
//                if let popoverPresentationController = actionSheet.popoverPresentationController {
//                    popoverPresentationController.sourceView = $0
//                    popoverPresentationController.sourceRect = $0.frame
//                }
//                self.navigationController?.present(actionSheet, animated: true, completion: nil)
//        }
//    }
    
    // MARK: - UICollectionViewDataSource
    
    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            fatalError("Ouch. nil data source for messages")
        }

        // Very important to check this when overriding `cellForItemAt`
        // Super method will handle returning the typing indicator cell
        guard !isSectionReservedForTypingIndicator(indexPath.section) else {
            return super.collectionView(collectionView, cellForItemAt: indexPath)
        }

        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        if case .custom = message.kind {
            let cell = messagesCollectionView.dequeueReusableCell(CustomCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        }
        return super.collectionView(collectionView, cellForItemAt: indexPath)
    }

    // MARK: - MessagesDataSource

//    override func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
//        if isTimeLabelVisible(at: indexPath) {
//            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
//        }
//        return nil
//    }
    
    override func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
//        if !isPreviousMessageSameSender(at: indexPath) {
//            let name = message.sender.displayName
//            return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
//        }
        return nil
    }

    //we are handling this method in the parent class
//    override func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
//
//        if !isNextMessageSameSender(at: indexPath) && isFromCurrentSender(message: message) {
//            return NSAttributedString(string: "Delivered", attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
//        }
//        return nil
//    }
}

// MARK: - MessagesDisplayDelegate

extension AdvanceChatViewController: MessagesDisplayDelegate {

    // MARK: - Text Messages

    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }

    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        switch detector {
        case .hashtag, .mention:
            if isFromCurrentSender(message: message) {
                return [.foregroundColor: UIColor.white]
            } else {
                return [.foregroundColor: UIColor.blue]
            }
        default: return MessageLabel.defaultAttributes
        }
    }

    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
    }

    // MARK: - All Messages
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .rgMid : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }

    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        var corners: UIRectCorner = []
        
        if isFromCurrentSender(message: message) {
            corners.formUnion(.topLeft)
            corners.formUnion(.bottomLeft)
            if !isPreviousMessageSameSender(at: indexPath) {
                corners.formUnion(.topRight)
            }
            if !isNextMessageSameSender(at: indexPath) {
                corners.formUnion(.bottomRight)
            }
        } else {
            corners.formUnion(.topRight)
            corners.formUnion(.bottomRight)
            if !isPreviousMessageSameSender(at: indexPath) {
                corners.formUnion(.topLeft)
            }
            if !isNextMessageSameSender(at: indexPath) {
                corners.formUnion(.bottomLeft)
            }
        }
        
        return .custom { view in
            let radius: CGFloat = 16
            let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            view.layer.mask = mask
        }
    }
    
//    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
//        let avatar = SampleData.shared.getAvatarFor(sender: message.sender)
//        avatarView.set(avatar: avatar)
//        avatarView.isHidden = isNextMessageSameSender(at: indexPath)
//        avatarView.layer.borderWidth = 2
//        avatarView.layer.borderColor = UIColor.rgMid.cgColor
//    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let chatUser = message.sender as? ChatUser
        if let avatarLink = chatUser?.avatar {
            avatarView.downloadImageFrom(link: avatarLink, contentMode: .scaleAspectFill)
        }
        
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            // set the vertical position of the Avatar for incoming messages so that the bottom of the Avatar
            // aligns with the bottom of the Message
            layout.setMessageIncomingAvatarPosition(.init(vertical: .messageBottom))

            // set the vertical position of the Avatar for outgoing messages so that the bottom of the Avatar
            // aligns with the `cellBottom`
            layout.setMessageOutgoingAvatarPosition(.init(vertical: .messageBottom))
        }
    }
    
    func configureAccessoryView(_ accessoryView: UIView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        // Cells are reused, so only add a button here once. For real use you would need to
        // ensure any subviews are removed if not needed
        accessoryView.subviews.forEach { $0.removeFromSuperview() }
        accessoryView.backgroundColor = .clear

        let shouldShow = Int.random(in: 0...10) == 0
        guard shouldShow else { return }

        let button = UIButton(type: .infoLight)
        button.tintColor = .rgMid
        accessoryView.addSubview(button)
        button.frame = accessoryView.bounds
        button.isUserInteractionEnabled = false // respond to accessoryView tap through `MessageCellDelegate`
        accessoryView.layer.cornerRadius = accessoryView.frame.height / 2
        accessoryView.backgroundColor = UIColor.rgMid.withAlphaComponent(0.3)
    }

    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if case MessageKind.photo(let media) = message.kind, let imageURL = media.url {
            imageView.kf.setImage(with: imageURL)
        } else {
            imageView.kf.cancelDownloadTask()
        }
    }
    
    // MARK: - Location Messages
    
    func annotationViewForLocation(message: MessageType, at indexPath: IndexPath, in messageCollectionView: MessagesCollectionView) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: nil, reuseIdentifier: nil)
        let pinImage = #imageLiteral(resourceName: "ic_map_marker")
        annotationView.image = pinImage
        annotationView.centerOffset = CGPoint(x: 0, y: -pinImage.size.height / 2)
        return annotationView
    }
    
    func animationBlockForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> ((UIImageView) -> Void)? {
        return { view in
            view.layer.transform = CATransform3DMakeScale(2, 2, 2)
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
                view.layer.transform = CATransform3DIdentity
            }, completion: nil)
        }
    }
    
    func snapshotOptionsForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LocationMessageSnapshotOptions {
        return LocationMessageSnapshotOptions(showsBuildings: true, showsPointsOfInterest: true, span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
    }

    // MARK: - Audio Messages

    func audioTintColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return self.isFromCurrentSender(message: message) ? .white : .rgMid
    }

//    func configureAudioCell(_ cell: AudioMessageCell, message: MessageType) {
//        audioController.configureAudioCell(cell, message: message) // this is needed especially when the cell is reconfigure while is playing sound
//    }
    
}

// MARK: - MessagesLayoutDelegate

extension AdvanceChatViewController: MessagesLayoutDelegate {
    //date under which all messages are grouped
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        if let firstItem = messageList[safe:indexPath.section - 1] , let secondItem = messageList[safe:indexPath.section]{
            if (firstItem.sentDate.stripTime() == secondItem.sentDate.stripTime()){ //if Dates are same
                return 0  //no need to allot height to display message date
            }
        }
        return 30
    }
    
    //display name
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
//        if isFromCurrentSender(message: message) {
//            return !isPreviousMessageSameSender(at: indexPath) ? 20 : 0
//        } else {
//            return !isPreviousMessageSameSender(at: indexPath) ? (20 + outgoingAvatarOverlap) : 0
//        }
        if let firstItem = messageList[safe:indexPath.section - 1] , let secondItem = messageList[safe:indexPath.section]{
//            print(firstItem.sender.displayName,secondItem.sender.displayName)
            if (firstItem.sender.displayName == secondItem.sender.displayName){ //if last message and this message sender are same
                return 0  //no need to allot height to display name
            }
        }
        return 20
    }

    //time
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
//        return (!isNextMessageSameSender(at: indexPath) && isFromCurrentSender(message: message)) ? 16 : 0
        return 16
    }
    
    // read
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isFromCurrentSender(message: message){
            return 17
        }else{
            return 0
        }
    }
}


extension AdvanceChatViewController: CameraInputBarAccessoryViewDelegate {

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith attachments: [AttachmentManager.Attachment]) {
        if let channel = self.conversation{
            let myGroup = DispatchGroup()
            self.showNetworkActivity()
            
            for item in attachments {
                if  case .image(let image) = item {
                    myGroup.enter()
                    var attribute = Utility.getAttributes(onlyRelatedToUser: true) //sending user attributes with each message as well
                    if let currentLoc = currentLocation{
                        attribute["device_latitude"] = String(currentLoc.coordinate.latitude)
                        attribute["device_longitude"] = String(currentLoc.coordinate.longitude)
                    }
                    ConversationsManager.sharedConversationsManager.sendMessageHavingImage(photo: image, channel, attribute) { (result, message) in
                        myGroup.leave()
                    }
                }
            }
            inputBar.invalidatePlugins()
            myGroup.notify(queue: .main) {
                print("Twilio: didPressSendButtonWith attachments Finished whole DispatchGroup.")
                self.hideNetworkActivity()
            }
        }
    }
    
    //This method checks that other user (not me) has read the message upto what point
    func checkConsumptionHorizon(){
        print("Twilio: checkConsumption Horizon")
        let messageIndex = ConversationsManager.sharedConversationsManager.getOthersLastMessageRead()
        if messageIndex > self.lastReadMessageIndex{
            self.lastReadMessageIndex = messageIndex
            //refresh the collectionview
            self.readConsumptionTimer.invalidate()
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem(animated: true)
        }
    }
}

extension AdvanceChatViewController: ConversationsManagerDelegate {
    

    func typingOn(_ conversation: TCHConversation, _ participant: TCHParticipant, isTyping:Bool){
        print("Twilio: typingOn : \(String(describing: conversation.friendlyName)) by \(String(describing: participant.identity)) is \(isTyping)")
        if(conversation.sid == self.conversation?.sid){
            self.setTypingIndicatorViewHidden(!isTyping , participant)
        }
    }
    
    
    func reloadMessages() {
    }
    
    internal func receivedNewMessage(message: TCHMessage
                                     , conversation: TCHConversation
                                     ){
        if let converse = self.conversation , converse.sid == conversation.sid{
            //if conversation chat window is opened and recieved a new message then set its Consumed messages to all
            ConversationsManager.sharedConversationsManager.setAllMessagesRead(conversation) { (result, count) in
                if let id = message.author, id == self.identity{ //if this message is from myself only then chek the reading receipt
                    self.readConsumptionTimer.invalidate()
                    self.readConsumptionTimer = Timer.scheduledTimer(withTimeInterval: self.readConsumptionTimerInterval, repeats: true, block: { _ in
                        self.checkConsumptionHorizon()
                    })
                }
                print("Twilio: set conversation's consumption horizon to last message")
            }
//            print(message.mediaFilename,message.mediaSid)
            if message.attachedMedia.count > 0{
                getAndConvertTCHImageMessageToChatMessage(message) { (chatImageMessage, isCached) in
                    self.insertMessage(chatImageMessage)
                }
            }else if let chatMessage = self.convertTCHMessageToChatMessage(message: message){
                self.insertMessage(chatMessage)
            }
        }else{
            print("Twilio: Some other conversation has received the message")
        }
    }
    
    func sendSalesForceRequest(conversation: TCHConversation?){
        self.conversation = conversation
        //logging this request to the sales force as well
        
        self.showNetworkActivity()
        EEAPIManager().sendSalesForceRequest(salesforceRequest: salesforceRequest, conversationId: conversation?.sid ?? "NoChannel", type: salesforceRequest.productType){ customBookingResponse, error in
            self.hideNetworkActivity()
            guard error == nil else {
                Crashlytics.crashlytics().record(error: error!)
                BackendError.parsing(reason: "Could not obtain the salesforce_id")
                return
            }
            Mixpanel.mainInstance().track(event: "Product Request",
                                          properties: ["Product Name" : self.salesforceRequest.productName
                                                       ,"Product Type" : self.salesforceRequest.productType
                                                       ,"ProductId" : self.salesforceRequest.productId])
            print("Twilio: conversation created, joined, channelID been sent to salesforce successfully")

        }
    }
}

extension AdvanceChatViewController: UITextViewDelegate{
    
    func textViewDidChange(_ textView: UITextView) {
        switch (textView) {
            case messageInputBar.inputTextView:
//                print("Twilio: textViewDidChange")
                if let channel = self.conversation , let conversationSid = channel.sid{
                    ConversationsManager.sharedConversationsManager.notifyTypingOnConversation(conversationSid)
                }
                
            default: break
        }
    }
    
}
