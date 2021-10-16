//
//  QuickstartChatManager.swift
//  ChatQuickstart
//
//  Created by Jeffrey Linwood on 3/11/20.
//  Copyright © 2020 Twilio, Inc. All rights reserved.
//

import UIKit
import TwilioChatClient

protocol ChatManagerDelegate: AnyObject {
    func reloadMessages()
    func receivedNewMessage(message: TCHMessage , channel: TCHChannel) -> ChatMessage?
    func channelJoined(channel: TCHChannel)
    func showNetworkActivity()
    func hideNetworkActivity()
    
}

class ChatManager: NSObject, TwilioChatClientDelegate {

    let TOKEN_URL =   "https://seashell-snowshoe-5113.twil.io/chat-token"
    var serverURL = "https://seashell-snowshoe-5113.twil.io/send-notification"

    static let sharedChatManager = ChatManager()
//    static let shared = ChatManager()
    // the unique name of the channel you create
//    var uniqueChannelName = "general"
//    var friendlyChannelName = "General Channel"

    // For the quickstart, this will be the view controller
    weak var delegate: ChatManagerDelegate?

    // MARK: Chat variables
    private var client: TwilioChatClient?
    private var channel: TCHChannel?
    private(set) var messages: [TCHMessage] = []
    private var identity: String?
    
//    private init (channelName:String = ""){
//        self.uniqueChannelName = channelName
//        self.friendlyChannelName = channelName
//    }
    
    func setChannel (channel: TCHChannel){
        self.channel = channel
    }
    
    func chatClient(_ client: TwilioChatClient, synchronizationStatusUpdated status: TCHClientSynchronizationStatus) {
        guard status == .completed else {
            return
        }
    }
    
    // Called whenever a channel we've joined receives a new message
    func chatClient(_ client: TwilioChatClient, channel: TCHChannel,
                    messageAdded message: TCHMessage) {
        messages.append(message)

        DispatchQueue.main.async {
            if let delegate = self.delegate {
                delegate.reloadMessages()
                if self.messages.count > 0 {
                    delegate.receivedNewMessage(message: message, channel: channel)
                }
            }
        }
    }
    
    func chatClientTokenWillExpire(_ client: TwilioChatClient) {
        print("Twilio:Chat Client Token will expire.")
        // the chat token is about to expire, so refresh it
        refreshAccessToken()
    }
    
    private func refreshAccessToken() {
        guard let identity = identity else {
            return
        }
        let urlString = "\(TOKEN_URL)?identity=\(identity)"

        TokenUtils.retrieveToken(url: urlString) { (token, _, error) in
            guard let token = token else {
               print("Twilio:Error retrieving token: \(error.debugDescription)")
               return
           }
            self.client?.updateToken(token, completion: { (result) in
                if (result.isSuccessful()) {
                    print("Twilio:Access token refreshed")
                } else {
                    print("Twilio:Unable to refresh access token")
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
            TwilioChatClient.chatClient(withToken: token, properties: nil,
                                        delegate: self) { (result, chatClient) in
                self.client = chatClient
                completion(result.isSuccessful())
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
    
    // MARK: - Create channel
    
    public func createChannel(uniqueChannelName: String, friendlyName: String, customAttribute: Dictionary<String,String>,_ completion: @escaping (Bool, TCHChannel?) -> Void) {
        guard let client = client, let channelsList = client.channelsList() else {
            return
        }
        
//        checkChannelCreation(uniqueName: uniqueChannelName) { (_, channel) in
//            if let channel = channel {
//                self.joinChannel(channel)
//            } else {
                // Create a channel if it hasn't been created yet
                let options: [String: Any] = [
                    TCHChannelOptionUniqueName: uniqueChannelName,
                    TCHChannelOptionFriendlyName: friendlyName,
                    TCHChannelOptionType: TCHChannelType.private.rawValue
                    ,TCHChannelOptionAttributes: customAttribute
                    ]
                channelsList.createChannel(options: options, completion: { channelResult, channel in
                    if channelResult.isSuccessful() {
                        if let channel = channel{
                            self.joinChannel(channel, completion: { channelResult in
                                completion(channelResult, channel)
                            })
                        }
                        print("Twilio: Channel created: \(String(describing: channel?.sid))")
                    } else {
                        print("Twilio: Channel Result: \(channelResult.resultText as Any)")
                        completion(channelResult.isSuccessful(), channel)
                    }
                    
                })
//            }
//        }
    }

    private func joinChannel(_ channel: TCHChannel, completion: @escaping (Bool) -> Void) {
        self.channel = channel
        delegate?.channelJoined(channel: channel)
        if channel.status == .joined {
            print("Current user already exists in channel")
            completion(true)
        } else {
            channel.join(completion: { result in
                print("Twilio: Channel joined result: \(result.isSuccessful() )")
                completion(result.isSuccessful())
            })
        }
    }
    
    //func getSubscribeChannels(_ completion: @escaping( [TCHChannel]?) -> Void){
    func getUserChannelDescriptors(_ completion: @escaping([TCHChannelDescriptor]) -> Void){
//        if let channels = client?.channelsList()?.subscribedChannels(){
//            completion(channels)
//        }
        self.client?.channelsList()?.userChannelDescriptors(completion: { (result, paginator) in
          if (result.isSuccessful()) {
            if let channelDecriptors = paginator?.items() {
                completion(channelDecriptors)
            }
          }
        })

    }
    
    func getChannelFromDescriptor(channelDescriptor:TCHChannelDescriptor, completion: @escaping (Bool,TCHChannel) -> Void){
        channelDescriptor.channel(completion:{ (result, channel) in
            if let channel = channel{
                if result.isSuccessful() {
                    completion(result.isSuccessful(),channel)
                }
            }
        })
    }
    
    func getLastMessagesWithCount(_ channel: TCHChannel, msgsCount:UInt,completion: @escaping([TCHMessage]) -> Void ){
        channel.messages?.getLastWithCount(msgsCount, completion: { (result, messages) in
            if let msgs = messages{
                self.setAllMessagesConsumed(channel) { (result, count) in
                    print("Twilio: setAllMessagesConsumed Result:\(result.isSuccessful())" , "Count:\(count)")
                }
                completion(msgs)
            }
        })
    }
    
    func getOldMessagesWithCount(_ channel: TCHChannel, startingIndex:UInt = 0 ,msgsCount:UInt,completion: @escaping([TCHMessage]) -> Void ){
        channel.messages?.getBefore(startingIndex,withCount: msgsCount, completion: { (result, messages) in
            if let msgs = messages{
                completion(msgs)
            }
        })
    }
    
    func setAllMessagesConsumed(_ channel: TCHChannel,completion: @escaping (TCHResult,UInt) -> Void){
        channel.messages?.setAllMessagesConsumedWithCompletion({ (result, count) in
            print("Twilio: Consumed Message Index:\(count)")
            completion(result, count)
        })
    }
    
    func getTotalUnConsumedMessagesCount(completion: @escaping (UInt) -> Void){
        var count = 0
        self.getUserChannelDescriptors(){channelDescriptors in
            for channelDescriptor in channelDescriptors {
                count += channelDescriptor.unconsumedMessagesCount()?.intValue ?? 0
            }
            completion(UInt(count))
        }
    }
    
    func deleteChannel(_ channel: TCHChannel,completion: @escaping (TCHResult) -> Void){
        channel.destroy(completion: { (result) in
            print("Twilio: channel deleted:\(result.isSuccessful())")
            completion(result)
        })
    }
    
    func sendMessage(_ messageText: String
                     , _ cutomAttributes: Dictionary<String,String>
                     , completion: @escaping (TCHResult, TCHMessage?) -> Void) {
        if let messages = self.channel?.messages{
            let messageOptions = TCHMessageOptions().withBody(messageText)  //setting message body

            let attributes:TCHJsonAttributes = .init(dictionary: cutomAttributes)
            messageOptions.withAttributes(attributes) { (result) in //setting message attributes
                print("Twilio: Attributes has been set with the message")
//                messages.sendMessage(with: messageOptions, completion: { (result, message) in
//                    completion(result, message)
//                })
            }
            messages.sendMessage(with: messageOptions, completion: { (result, message) in
                completion(result, message)
            })
        }else{
            print("Twilio: Message could not sent")
        }
    }
    
    //func sendImageMessage(photo  : UIImage,_ channel: TCHChannel, completion: @escaping (TCHResult, TCHMessage?) -> Void){
    func sendImageMessage(photo  : UIImage,_ channel: TCHChannel){
        // The data for the image you would like to send
        //let data = Data()
        if let data = photo.pngData(){
            // Prepare the upload stream and parameters
            let messageOptions = TCHMessageOptions()
            let inputStream = InputStream(data: data)
            messageOptions.withMediaStream(inputStream,
                                           contentType: "image/jpeg"
                                           ,defaultFilename: Date.dateToString(date: Date(),format: "yyyy-MM-dd-HH-mm-ss") + ".png" , //optional
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
                print("Media upload completed")
            }

            // Trigger the sending of the message. it will be received at receivedNewMessage in chatViewController
            channel.messages?.sendMessage(with: messageOptions,
                                               completion: { (result, message) in
                                                if !result.isSuccessful() {
                                                    print("Twilio: Image creation failed: \(String(describing: result.error))")
                                                } else {
                                                    print("Twilio: Image creation successful")
                                                }
//                                                completion(result, message)
            })
        }
    }
}


