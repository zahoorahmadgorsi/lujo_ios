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

/// A base class for the example controllers
class ChatViewController: MessagesViewController, MessagesDataSource {

    // MARK: - Public properties

    /// The `BasicAudioController` control the AVAudioPlayer state (play, pause, stop) and update audio cell UI accordingly.
//    lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)

    lazy var messageList: [ChatMessage] = []
    var conversationId:String = ""
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

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMessageCollectionView()
        configureMessageInputBar()
        getConversationDetails(showActivity: true)
        title = "LUJO"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        MockSocket.shared.disconnect()
//        audioController.stopAnyOngoingPlaying()
    }

    func getConversationDetails(showActivity: Bool) {
        if showActivity {
            self.showNetworkActivity()
        }
        getConversationDetails() {information, error in
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
    
    func getConversationDetails(completion: @escaping (ConversationDetails?, Error?) -> Void) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            completion(nil, LoginError.errorLogin(description: "User does not exist or is not verified"))
            return
        }
        
        GoLujoAPIManager().getConversationDetails(token: token,conversationID: conversationId) { items, error in
            guard error == nil else {
                Crashlytics.sharedInstance().recordError(error!)
                let error = BackendError.parsing(reason: "Could not obtain the chat list")
                completion(nil, error)
                return
            }
            completion(items, error)
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
//                let strDate = myDate.localDateFormatter.string(from: dtDate)
//                print (dateFromServer)
//                print (dtDate.asDateAndTime())
//                print (strDate)
                let chatMessage:ChatMessage = ChatMessage(text: item.body, user: chatUser, messageId: "0000", date: dtDate)
                self.messageList.append(chatMessage)
            }
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func loadFirstMessages() {
        getConversationDetails(showActivity: true)
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
            let system = ChatUser(senderId: "000000", displayName: "LUJO")
            return system
        }
    }

//    func currentSender() -> ChatUser {
//        if let currentUser = LujoSetup().getLujoUser(){
//            let currentSender:ChatUser = ChatUser(senderId: String(currentUser.id), displayName: currentUser.firstName + " " + currentUser.lastName)
//            return currentSender
//        }
//    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }

    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        return nil
    }

    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(string: "Read", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
    }

    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }

    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
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

//    func didTapPlayButton(in cell: AudioMessageCell) {
//        guard let indexPath = messagesCollectionView.indexPath(for: cell),
//            let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) else {
//                print("Failed to identify message when audio cell receive tap gesture")
//                return
//        }
//        guard audioController.state != .stopped else {
//            // There is no audio sound playing - prepare to start playing for given audio message
//            audioController.playSound(for: message, in: cell)
//            return
//        }
//        if audioController.playingMessage?.messageId == message.messageId {
//            // tap occur in the current cell that is playing audio sound
//            if audioController.state == .playing {
//                audioController.pauseSound(for: message, in: cell)
//            } else {
//                audioController.resumeSound()
//            }
//        } else {
//            // tap occur in a difference cell that the one is currently playing sound. First stop currently playing and start the sound for given message
//            audioController.stopAnyOngoingPlaying()
//            audioController.playSound(for: message, in: cell)
//        }
//    }

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
        DispatchQueue.global(qos: .default).async {
            // fake send request task
            sleep(1)
            DispatchQueue.main.async { [weak self] in
                inputBar.sendButton.stopAnimating()
                inputBar.inputTextView.placeholder = "Aa"
                self?.insertMessages(components)
                self?.messagesCollectionView.scrollToLastItem(animated: true)
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
