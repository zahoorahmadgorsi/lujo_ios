//
//  QuickstartChatManager.swift
//  ChatQuickstart
//
//  Created by Jeffrey Linwood on 3/11/20.
//  Copyright © 2020 Twilio, Inc. All rights reserved.
//

import UIKit
import TwilioConversationsClient

protocol ChatManagerDelegate: AnyObject {
    func reloadMessages()
    func receivedNewMessage(message: TCHMessage , channel: TCHConversation )
    func channelJoined(channel: TCHConversation)
    func showNetworkActivity()
    func hideNetworkActivity()
    
}

class ConversationManager: NSObject, TwilioConversationsClientDelegate {

    let TOKEN_URL =   "https://seashell-snowshoe-5113.twil.io/chat-token"
    var serverURL = "https://seashell-snowshoe-5113.twil.io/send-notification"

    static let sharedChatManager = ConversationManager()
    static let sharedCache = NSCache<NSString, UIImage>()
    
    // For the quickstart, this will be the view controller
    weak var delegate: ChatManagerDelegate?

    // MARK: Conversations variables
    private var client: TwilioConversationsClient?
    private var conversation: TCHConversation?
    private(set) var messages: [TCHMessage] = []
    private var identity: String?
    
    func setChannel (channel: TCHConversation){
        self.conversation = channel
    }
    
    func conversationsClient(_ client: TwilioConversationsClient, synchronizationStatusUpdated status: TCHClientSynchronizationStatus) {
        guard status == .completed else {
            return
        }

    }
    
    // Called whenever a conversation we've joined receives a new message
//    func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, messageAdded message: TCHMessage)
    func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, messageAdded message: TCHMessage) {
        messages.append(message)

        DispatchQueue.main.async {
            if let delegate = self.delegate {
                delegate.reloadMessages()
                if self.messages.count > 0 {
                    delegate.receivedNewMessage(message: message, channel: conversation)
                }
            }
        }
    }
    
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

    func login(_ identity: String, completion: @escaping (Bool) -> Void) {
        // Fetch Access Token from the server and initialize Chat Client - this assumes you are
        // calling a Twilio function, as described in the Quickstart docs
        let urlString = "\(TOKEN_URL)?identity=\(identity)"
        self.identity = identity
        delegate?.showNetworkActivity()
        TokenUtils.retrieveToken(url: urlString) { (token, _, error) in
            guard let token = token else {
                print("Twilio: Error retrieving token: \(error.debugDescription)")
                completion(false)
                self.delegate?.hideNetworkActivity()
                return
            }
            // Set up Twilio Chat client
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
    
    public func createConversation(uniqueChannelName: String, friendlyName: String, customAttribute: Dictionary<String,String>,_ completion: @escaping (Bool, TCHConversation?) -> Void) {
        guard let client = self.client else {
            // get a reference to the app delegate
            let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
            appDelegate?.loginToTwilio()
            return
        }
        // Create a channel if it hasn't been created yet
        let options: [String: Any] = [
            TCHConversationOptionUniqueName: uniqueChannelName,
            TCHConversationOptionFriendlyName: friendlyName
//            ,TCHConversationNotificationLevel: .
            ,TCHConversationOptionAttributes: customAttribute
            ]
        client.createConversation(options: options) { (result, conversation: TCHConversation?) in
            if result.isSuccessful{
                print("Twilio: Conversation created")
                if let convers = conversation{
                    self.joinConversation(convers) { (channelResult) in
                        completion(channelResult, conversation)
                    }

                    conversation?.addParticipant(byIdentity: "shujahm@gmail.com", attributes: nil, completion: { (result) in
                        if result.isSuccessful {
                            print("Twilio: User added.")
                        } else {
                            print("Twilio: User could NOT added.")
                        }
                    })
                }
            }else{
                print("Twilio: Conversation could not created")
            }
        }
    }

    private func joinConversation(_ conversation: TCHConversation, completion: @escaping (Bool) -> Void) {
        self.conversation = conversation
        delegate?.channelJoined(channel: conversation)
        if conversation.status == .joined {
            print("Twilio: Current user already exists in channel")
            completion(true)
        } else {
            conversation.join(completion: { result in
                print("Twilio: Conversation joined result: \(result.isSuccessful )")
                completion(result.isSuccessful)
            })
            
        }
    }
    
    //zahoor start
    
    func getConversations(_ completion: @escaping([TCHConversation]) -> Void){
        if let client = self.client{
            if let conversations = client.myConversations(){
                completion(conversations)
            }
        }
    }
    
//    func getUserChannelDescriptors(_ completion: @escaping([TCHConversationDescriptor]) -> Void){
//        if let client = self.client{
//            client.channelsList()? .userChannelDescriptors(completion: { (result, paginator) in
//              if (result.isSuccessful()) {
//                if let channelDecriptors = paginator?.items() {
//                    completion(channelDecriptors)
//                }
//              }
//            })
//        }
//    }
    
    //zahoor
//    func getChannelFromDescriptor(channelDescriptor:TCHConversationDescriptor, completion: @escaping (Bool,TCHConversation) -> Void){
//        channelDescriptor.channel(completion:{ (result, channel) in
//            if let channel = channel{
//                if result.isSuccessful() {
//                    completion(result.isSuccessful(),channel)
//                }
//            }
//        })
//    }
    
    func getLastMessagesWithCount(_ channel: TCHConversation, msgsCount:UInt,completion: @escaping([TCHMessage]) -> Void ){
        
        channel.getLastMessages(withCount:msgsCount, completion: { (result, messages) in
            if let msgs = messages{
                self.setAllMessagesConsumed(channel) { (result, count) in
                    print("Twilio: setAllMessagesConsumed Result:\(result.isSuccessful)" , "Count:\(count)")
                }
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

    func setAllMessagesConsumed(_ channel: TCHConversation,completion: @escaping (TCHResult,UInt) -> Void){
        channel.setAllMessagesUnreadWithCompletion({ (result, count) in
            print("Twilio: Unread Message Index:\(String(describing: count))")
            completion(result, count?.uintValue ?? 0)
        })
    }

//    func getTotalUnConsumedMessagesCount(completion: @escaping (UInt) -> Void){
//        var count = 0
//        self.getUserChannelDescriptors(){channelDescriptors in
//            for channelDescriptor in channelDescriptors {
//                count += channelDescriptor.unconsumedMessagesCount()?.intValue ?? 0
//            }
//            completion(UInt(count))
//        }
//    }
    
    //zahoor end
    
    func deleteChannel(_ channel: TCHConversation,completion: @escaping (TCHResult) -> Void){
        channel.destroy(completion: { (result) in
            print("Twilio: channel deleted:\(result.isSuccessful)")
            completion(result)
        })
    }
    
    func sendMessage(_ messageText: String
                     , _ cutomAttributes: Dictionary<String,String>
                     , completion: @escaping (TCHResult, TCHMessage?) -> Void) {
        if let conversation = self.conversation{
            let messageOptions = TCHMessageOptions().withBody(messageText)  //setting message body
            let attributes:TCHJsonAttributes = .init(dictionary: cutomAttributes)
            //messageOptions.withAttributes(attributes, error: AutoreleasingUnsafeMutablePointer<TCHError?>?)
            messageOptions.withAttributes(attributes, error: nil) //, error: AutoreleasingUnsafeMutablePointer<TCHError?>?)
            conversation.sendMessage(with: messageOptions) { (result, message:TCHMessage?) in
                completion(result, message)
            }
        }else{
            print("Twilio: conversation doesnt exist.")
        }
    }
    
    func sendImageMessage(photo  : UIImage
                          ,_ conversation: TCHConversation
                          , completion: @escaping (TCHResult, TCHMessage?) -> Void){
        // The data for the image you would like to send
        //let data = Data()
        if let data = photo.pngData(){
            // Prepare the upload stream and parameters
            let messageOptions = TCHMessageOptions()
            let inputStream = InputStream(data: data)
            let fileName = Date.dateToString(date: Date(),format: "yyyy-MM-dd-HH-mm-ss") + ".png"

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
                ConversationManager.sharedCache.setObject(photo, forKey: mediaSid as NSString)
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
}


