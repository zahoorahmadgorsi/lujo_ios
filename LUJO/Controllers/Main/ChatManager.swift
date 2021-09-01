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
    func receivedNewMessage(message: TCHMessage , channel: TCHChannel)
    func channelJoined(channel: TCHChannel)
    func showNetworkActivity()
    func hideNetworkActivity()
}

class ChatManager: NSObject, TwilioChatClientDelegate {

    let TOKEN_URL =   "https://seashell-snowshoe-5113.twil.io/chat-token"
    
    // the unique name of the channel you create
    private var uniqueChannelName = "generalTwo"
    private var friendlyChannelName = "General Channel"

    // For the quickstart, this will be the view controller
    weak var delegate: ChatManagerDelegate?

    // MARK: Chat variables
    private var client: TwilioChatClient?
    private var channel: TCHChannel?
    private(set) var messages: [TCHMessage] = []
    private var identity: String?
    
    init( channelName : String ){
        self.uniqueChannelName = channelName
        self.friendlyChannelName = channelName
    }
    
    func chatClient(_ client: TwilioChatClient, synchronizationStatusUpdated status: TCHClientSynchronizationStatus) {
        guard status == .completed else {
            return
        }
        checkChannelCreation { (_, channel) in
            if let channel = channel {
                self.joinChannel(channel)
            } else {
                self.createChannel { (success, channel) in
                    if success, let channel = channel {
                        self.joinChannel(channel)
                    }else{  //joining already existed channel
                        guard let channelsList = client.channelsList() else {
                            return
                        }
                        channelsList.channel(withSidOrUniqueName:self.uniqueChannelName, completion: { channelResult, channel in
                            if let channel = channel {
                                channel.join(completion: { channelResult in
                                    if channelResult.isSuccessful() {
                                        print("Channel joined.")
                                    } else {
                                        print("Channel NOT joined.")
                                    }
                                })
                            }else{
                                self.delegate?.hideNetworkActivity()
                            }
                        })
                    }
                }
            }
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
        print("Chat Client Token will expire.")
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
               print("Error retrieving token: \(error.debugDescription)")
               return
           }
            self.client?.updateToken(token, completion: { (result) in
                if (result.isSuccessful()) {
                    print("Access token refreshed")
                } else {
                    print("Unable to refresh access token")
                }
            })
        }
    }

    func sendMessage(_ messageText: String,
                     completion: @escaping (TCHResult, TCHMessage?) -> Void) {
        if let messages = self.channel?.messages {
            let messageOptions = TCHMessageOptions().withBody(messageText)
            messages.sendMessage(with: messageOptions, completion: { (result, message) in
                completion(result, message)
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
                print("Error retrieving token: \(error.debugDescription)")
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

    private func createChannel(_ completion: @escaping (Bool, TCHChannel?) -> Void) {
        guard let client = client, let channelsList = client.channelsList() else {
            return
        }
        // Create the channel if it hasn't been created yet
        let options: [String: Any] = [
            TCHChannelOptionUniqueName: uniqueChannelName,
            TCHChannelOptionFriendlyName: friendlyChannelName,
            TCHChannelOptionType: TCHChannelType.private.rawValue
            ]
        channelsList.createChannel(options: options, completion: { channelResult, channel in
            if channelResult.isSuccessful() {
                print("Channel created: \(channel?.sid)")
            } else {
                print(channelResult.resultText)
            }
            completion(channelResult.isSuccessful(), channel)
        })
    }

    private func checkChannelCreation(_ completion: @escaping(TCHResult?, TCHChannel?) -> Void) {
        guard let client = client, let channelsList = client.channelsList() else {
            return
        }
        channelsList.channel(withSidOrUniqueName: uniqueChannelName, completion: { (result, channel) in
            completion(result, channel)
        })
    }

    private func joinChannel(_ channel: TCHChannel) {
        self.channel = channel
        delegate?.channelJoined(channel: channel)
        if channel.status == .joined {
            print("Current user already exists in channel")
        } else {
            channel.join(completion: { result in
                print("Result of channel join: \(result.resultText ?? "No Result")")
            })
        }
    }
    
    //func getSubscribeChannels(_ completion: @escaping( [TCHChannel]?) -> Void){
    func getUserChannels(_ completion: @escaping([TCHChannelDescriptor]) -> Void){
//        if let channels = client?.channelsList()?.subscribedChannels(){
//            completion(channels)
//        }
        client?.channelsList()?.userChannelDescriptors(completion: { (result, paginator) in
          if (result.isSuccessful()) {
            if let channels = paginator?.items() {
                completion(channels)
            }
          }
        })

    }
}

