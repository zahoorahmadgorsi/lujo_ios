//
//  ConversationsManager.swift
//  ChatQuickstart
//
//  Created by Jeffrey Linwood on 3/11/20.
//  Copyright © 2020 Twilio, Inc. All rights reserved.
//

import UIKit
import TwilioConversationsClient
import Alamofire

protocol ConversationsManagerDelegate: AnyObject {
    func reloadMessages()
    func receivedNewMessage(message: TCHMessage , conversation: TCHConversation )
    func channelJoined(channel: TCHConversation)
    func showNetworkActivity()
    func hideNetworkActivity()
    func typingOn(_ conversation: TCHConversation, _ participant: TCHParticipant, isTyping:Bool)
//    func conversationUpdated(conversation: TCHConversation, updated: TCHConversationUpdate) //not working
}

class ConversationsManager: NSObject, TwilioConversationsClientDelegate {
//    let TOKEN_URL = "https://seashell-snowshoe-5113.twil.io/chat-token" (project go lujo SMS project)
    let TOKEN_URL = "https://boysenberry-flamingo-2375.twil.io/chat-token"  //(project name baroque-group)

    static let sharedConversationsManager = ConversationsManager()
//    static let sharedCache = NSCache<NSString, UIImage>()
    
    // For the quickstart, this will be the view controller
    weak var delegate: ConversationsManagerDelegate?

    // MARK: Conversations variables
    private var client: TwilioConversationsClient?
    private var conversation: TCHConversation?
    private(set) var messages: [TCHMessage] = []
    private var identity: String?
    
    func getClient()->TwilioConversationsClient?{
        if client == nil{
            // get a reference to the app delegate
            let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
            appDelegate?.loginToTwilio()
        }
        return client
    }
    
    func setConversation (conversation: TCHConversation){
        self.conversation = conversation
    }
    
    func conversationsClient(_ client: TwilioConversationsClient, synchronizationStatusUpdated status: TCHClientSynchronizationStatus) {
        guard status == .completed else {
            return
        }
    }
    
    // Called whenever a conversation we've joined receives a new message
    func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, messageAdded message: TCHMessage) {
        messages.append(message)

        DispatchQueue.main.async {
            if let delegate = self.delegate {
                delegate.reloadMessages()
                if self.messages.count > 0 {
                    delegate.receivedNewMessage(message: message, conversation: conversation)
                }
            }
        }
    }
    //called when some one is typing on in any conversation you are the participant
    func conversationsClient(_ client: TwilioConversationsClient, typingStartedOn conversation: TCHConversation, participant: TCHParticipant) {
        guard participant.sid != nil else {
            return
        }
        delegate?.typingOn(conversation, participant , isTyping: true)
    }

    func conversationsClient(_ client: TwilioConversationsClient, typingEndedOn conversation: TCHConversation, participant: TCHParticipant) {
        guard participant.sid != nil else {
            return
        }
        delegate?.typingOn(conversation, participant, isTyping: false)
    }
    
//    func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, updated: TCHConversationUpdate) {
//        if updated == .lastReadMessageIndex{
//            print("Twilio: Conversation: \(String(describing: conversation.friendlyName)) updated: \(updated.rawValue) ")
//        }
//        delegate?.conversationUpdated(conversation: conversation, updated: updated)
//    }
    
    func conversationsClientTokenWillExpire(_ client: TwilioConversationsClient) {
            print("Twilio: Access token will expire.")
            refreshAccessToken()
        }
        
        func conversationsClientTokenExpired(_ client: TwilioConversationsClient) {
            print("Twilio: Access token expired.")
            refreshAccessToken()
        }
    
    private func refreshAccessToken() {
        guard let identity = identity else {
            return
        }
        let urlString = "\(TOKEN_URL)?identity=\(identity)"

        TokenUtils.retrieveToken(url: urlString) { (token, _, error) in
            guard let token = token else {
               print("Twilio: Error retrieving token: \(error.debugDescription)")
               return
           }
            self.client?.updateToken(token, completion: { (result) in
                if (result.isSuccessful) {
                    print("Twilio: Access token refreshed")
                } else {
                    print("Twilio: Unable to refresh access token")
                }
            })
        }
    }

    //this login is only called from the appDelegate
    func login(_ identity: String, completion: @escaping (Bool) -> Void) {
        // Fetch Access Token from the server and initialize Chat Client - this assumes you are
        // calling a Twilio function, as described in the Quickstart docs
        let urlString = "\(TOKEN_URL)?identity=\(identity)"
        self.identity = identity
//        delegate?.showNetworkActivity()
        TokenUtils.retrieveToken(url: urlString) { (token, _, error) in
            guard let token = token else {
                print("Twilio: Error retrieving token: \(error.debugDescription)")
                completion(false)
//                self.delegate?.hideNetworkActivity()
                return
            }
//            completion(false)// for login failure testing
            // Set up Twilio Chat client zahoor
            TwilioConversationsClient.conversationsClient(withToken: token, properties: nil,
                                        delegate: self) { (result, chatClient) in
                self.client = chatClient
                completion(result.isSuccessful)
            }
        }
    }

    func shutdown() {
        if let client = client {
            client.delegate = nil
            client.shutdown()
            self.client = nil
        }
    }
    
    // MARK: - Create conversation
    
    public func createConversation(uniqueChannelName: String, friendlyName: String, customAttribute: Dictionary<String,Any>,_ completion: @escaping (Bool, TCHConversation?) -> Void) {
        guard let client = self.client else {
            completion(false,nil)
            return
        }
        // Create a conversation if it hasn't been created yet
        let options: [String: Any] = [
            TCHConversationOptionUniqueName: uniqueChannelName,
            TCHConversationOptionFriendlyName: friendlyName
            ,TCHConversationOptionAttributes: customAttribute
            ]
        
        client.createConversation(options: options) { (result, conversation: TCHConversation?) in
            if result.isSuccessful{
//                self.conversation = conversation
                print("Twilio: Conversation created sID: \(String(describing: conversation?.sid))")
                if let convers = conversation{
                    self.joinConversation(convers) { (channelResult) in
                        completion(channelResult, conversation)
                    }
                }else{
                    print("Twilio: this must not execute")
                    completion(result.isSuccessful, conversation)
                }
            }else{
                print("Twilio: Conversation could not created")
                completion(result.isSuccessful, conversation)
            }
        }
    }

    private func joinConversation(_ conversation: TCHConversation, completion: @escaping (Bool) -> Void) {
        setConversation(conversation: conversation)
        delegate?.channelJoined(channel: conversation)
        if conversation.status == .joined {
            print("Twilio: Current user already exists in conversation")
            completion(true)
        } else {
            conversation.join(completion: { result in
                print("Twilio: Conversation joined result: \(result.isSuccessful )")
                completion(result.isSuccessful)
            })
            
        }
    }
    
    func getConversations(_ completion: @escaping([TCHConversation]) -> Void){
        if let client = self.client{
            if let conversations = client.myConversations(){
                completion(conversations)
            }
        }
    }
    
    //read the last messages and set the consumption horizon to last message
    func getLastMessagesWithCount(_ conversation: TCHConversation, msgsCount:UInt,completion: @escaping([TCHMessage]) -> Void ){
        conversation.getLastMessages(withCount:msgsCount, completion: { (result, messages) in
            if let msgs = messages{
//                self.setAllMessagesRead(conversation) { (result, count) in
//                }
                completion(msgs)
            }
        })
    }

    func getOldMessagesWithCount(_ channel: TCHConversation, startingIndex:UInt = 0 ,msgsCount:UInt,completion: @escaping([TCHMessage]) -> Void ){
        channel.getMessagesBefore(startingIndex,withCount: msgsCount, completion: { (result, messages) in
            if let msgs = messages{
                completion(msgs)
            }
        })
    }

    func setAllMessagesRead(_ conversation: TCHConversation,completion: @escaping (TCHResult,UInt) -> Void){
        //Consumption horizon
        conversation.setAllMessagesReadWithCompletion({ (result, count) in
            print("Twilio: set All Messages Read result:\(String(describing: result.isSuccessful))")
            completion(result, count)
        })

    }

    func getTotalUnReadMessagesCount(completion: @escaping (UInt) -> Void){
        var unReadCount = 0
        if let conversations = self.client?.myConversations(){
            let myGroup = DispatchGroup()
            for conversation in conversations{
                myGroup.enter()
                conversation.getUnreadMessagesCount { (result, unReadMsgsCount: NSNumber?) in
                    myGroup.leave()
                    if result.isSuccessful ,let count = unReadMsgsCount{
                        if count.intValue > 0{
                            unReadCount += count.intValue
                        }
                    }
                }
            }
            myGroup.notify(queue: .main) {
                print("Twilio: getTotalUnReadMessagesCount Finished whole DispatchGroup.")
                completion(UInt(unReadCount))
            }
        }
        
    }
    
    //This method will iterate through the list of participants of this conversation and will fetch the max last message read index of all particiapnts other then me
    func getOthersLastMessageRead() -> Int{
        var lastReadMessageIndex = -1
        let participants = conversation?.participants()
        if let participants = participants{
            for participant in participants{
                if (participant.identity != self.identity){
//                    print(participant.identity as Any,self.identity as Any)
                    if let lastMessageIndex = participant.lastReadMessageIndex?.intValue{
                        lastReadMessageIndex = lastMessageIndex > lastReadMessageIndex ? lastMessageIndex : lastReadMessageIndex
                    }
                    
                }
            }
        }
        return lastReadMessageIndex;
    }
    
    func deleteChannel(_ channel: TCHConversation,completion: @escaping (TCHResult) -> Void){
        channel.destroy(completion: { (result) in
            print("Twilio: conversation deleted:\(result.isSuccessful)")
            completion(result)
        })
    }
    
    func sendMessage(_ messageText: String
                     , _ cutomAttributes: Dictionary<String,Any>
                     , completion: @escaping (TCHResult, TCHMessage?) -> Void) {
        if let converse = self.conversation{
            let messageOptions = TCHMessageOptions().withBody(messageText)  //setting message body
            let attributes:TCHJsonAttributes = .init(dictionary: cutomAttributes)
            //messageOptions.withAttributes(attributes, error: AutoreleasingUnsafeMutablePointer<TCHError?>?)
            messageOptions.withAttributes(attributes, error: nil) //, error: AutoreleasingUnsafeMutablePointer<TCHError?>?)
            converse.sendMessage(with: messageOptions) { (result, message:TCHMessage?) in
                completion(result, message)
            }
        }else{
            print("Twilio: conversation doesnt exist.")
        }
    }
    
    func sendMessageHavingImage(photo  : UIImage
                          ,_ conversation: TCHConversation
                          , _ cutomAttributes: Dictionary<String,Any>
                          , completion: @escaping (TCHResult, TCHMessage?) -> Void){
        // The data for the image you would like to send
        //let data = Data()
        if let data = photo.pngData(){
            // Prepare the upload stream and parameters
            let messageOptions = TCHMessageOptions()
            
            let inputStream = InputStream(data: data)
            let fileName = Date.dateToString(date: Date(),format: "yyyy-MM-dd-HH-mm-ss") + ".png"
            //adding custom attributes in the message
            let attributes:TCHJsonAttributes = .init(dictionary: cutomAttributes)
            messageOptions.withAttributes(attributes, error: nil)
            
            messageOptions.withMediaStream(inputStream,
                                           contentType: "image/jpeg"
                                           ,defaultFilename: fileName , //optional
                                           onStarted: {
                                            // Called when upload of media begins.
                                            print("Twilio: Media upload started")
            },
                                           onProgress: { (bytes) in
                                            // Called as upload progresses, with the current byte count.
                                            print("Twilio: Media upload progress: \(bytes)")
            }) { (mediaSid) in
                // Called when upload is completed, with the new mediaSid if successful.
                // Full failure details will be provided through sendMessage's completion.
//                ConversationsManager.sharedCache.setObject(photo, forKey: mediaSid as NSString)
                UserDefaults.standard.set(data, forKey: mediaSid)
                print("Twilio: Media uploaded and cached successfully")
            }

            // Trigger the sending of the message. it will be received at receivedNewMessage in chatViewController
            conversation.sendMessage(with: messageOptions,
                                   completion: { (result, message) in
                                    if !result.isSuccessful {
                                        print("Twilio: Image creation failed: \(String(describing: result.error))")
                                    } else {
                                        print("Twilio: Image creation successful")
                                    }
                                    completion(result, message)
            })
        }
    }
    
    func notifyTypingOnConversation(_ conversationSid: String) {
        guard let client = self.client else {
            print ("Twilio: No client exists")
            return
        }
        client.conversation(withSidOrUniqueName: conversationSid) { result, conversation in
            conversation?.typing()
        }
    }

    func updateConversationAttributes(customAttributes: Dictionary<String,Any>){
        //updating user
        if let conversation = self.conversation{
            let attributes:TCHJsonAttributes = .init(dictionary: customAttributes)
            conversation.setAttributes(attributes, completion: { (result) in
                print("Twilio: conversation attributes are updated: \(result.isSuccessful)")
//                completion(result.isSuccessful)
            })
        }else{
//            completion(false)
            print("Twilio: conversation not available to update")
        }
    }
    
    func addParticipants(productType:String){
        if let convers = self.conversation{
            Alamofire.request(GoLujoRouter.getTwilioParticipants(Utility.getVerticalType(productType)))
                .responseJSON { response in
                    guard response.result.error == nil else {
                        print("Twilio: Could not get any participant to add into the twilio conversation")
                        return
                    }
                    if let statusCode = response.response?.statusCode  {
                        switch statusCode {
                        case 200 ... 299: // Success
                            guard let result = try? JSONDecoder().decode(LujoServerResponse<[String]>.self, from: response.data!) else {
                                print("Twilio: Response format is different then the expected")
                                return
                            }
                            var participantEmails = result.content
//                            participantEmails.append("zahoor.gorsi@gmail.com")
//                            participantEmails.append("zahoor.ahmad@live.com")
                            for participantEmail in participantEmails{
//                                print("Twilio: Participant Email \(participantEmail)")
                                convers.addParticipant(byIdentity: participantEmail, attributes: nil, completion: { (result) in
                                    if result.isSuccessful == false {
                                        print("Twilio: \(participantEmail) could not added.")
                                    }
//                                    else{
//                                        print("Twilio: \(participantEmail) added successfully.")
//                                    }
                                })
                            }
                        default: // 500 or bigger, Server Error
                            print("Twilio: Received statusCode:\(statusCode)")
                        }
                    }
                }
        }
    }
    
    func setFriendlyName(friendlyName:String
                         , completion: @escaping (Bool) -> Void){
        if let conversation = self.conversation{
            conversation.setFriendlyName(friendlyName, completion: { (result) in
                completion(result.isSuccessful)
            })
        }else{
            completion(false)
            print("Twilio: conversation not available to update")
        }
    }
    
}
