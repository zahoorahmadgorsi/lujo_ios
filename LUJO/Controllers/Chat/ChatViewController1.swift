//
//  ChatViewController.swift
//  LUJO
//
//  Created by iMac on 15/07/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//
import MessageKit

public struct Sender: SenderType {
    public let senderId: String
    public let displayName: String
}

// Some global variables for the sake of the example. Using globals is not recommended!
let sender = Sender(senderId: "any_unique_id", displayName: "Steven")
let messages: [MessageType] = []

class ChatViewController1: MessagesViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
}

extension ChatViewController1: MessagesDataSource {

    func currentSender() -> SenderType {
        return Sender(senderId: "any_unique_id", displayName: "Steven")
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

    //we use the indexPath.section to retrieve our MessageType from the array as opposed to the traditional indexPath.row property. This is because the default behavior of MessageKit is to put each MessageType is in its own section of the MessagesCollectionView.
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
}

extension ChatViewController1: MessagesDisplayDelegate, MessagesLayoutDelegate {
    //The MessagesLayoutDelegate and MessagesDisplayDelegate don't require you to implement any methods as they have default implementations for everything. You just need to make your MessagesViewController subclass conform to these two protocols and set them in the MessagesCollectionView object.
}
