//
//  ChatMessage.swift
//  LUJO
//
//  Created by iMac on 27/07/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import MessageKit

struct ChatMessage: MessageType {
    var messageId: String
    var messageIndex: NSNumber?
    var sender: SenderType {
        return user
    }
    var sentDate: Date
    var kind: MessageKind
    var user: ChatUser

    private init(kind: MessageKind, user: ChatUser, messageId: String, date: Date , index:NSNumber = 0) {
        self.kind = kind
        self.user = user
        self.messageId = messageId
        self.sentDate = date
        self.messageIndex = index
    }
    
//    init(custom: Any?, user: ChatUser, messageId: String, date: Date) {
//        self.init(kind: .custom(custom), user: user, messageId: messageId, date: date)
//    }

    init(text: String, user: ChatUser, messageId: String, date: Date, messageIndex:NSNumber = 0) {
        self.init(kind: .text(text), user: user, messageId: messageId, date: date,index: messageIndex)
    }

//    init(attributedText: NSAttributedString, user: ChatUser, messageId: String, date: Date) {
//        self.init(kind: .attributedText(attributedText), user: user, messageId: messageId, date: date)
//    }
//
    init(image: UIImage, user: ChatUser, messageId: String, date: Date, messageIndex:NSNumber = 0) {
        let mediaItem = ImageMediaItem(image: image)
        self.init(kind: .photo(mediaItem), user: user, messageId: messageId, date: date,index: messageIndex)
    }
//
//    init(imageURL: URL, user: ChatUser, messageId: String, date: Date) {
//        let mediaItem = ImageMediaItem(imageURL: imageURL)
//        self.init(kind: .photo(mediaItem), user: user, messageId: messageId, date: date)
//    }
//
//    init(thumbnail: UIImage, user: ChatUser, messageId: String, date: Date) {
//        let mediaItem = ImageMediaItem(image: thumbnail)
//        self.init(kind: .video(mediaItem), user: user, messageId: messageId, date: date)
//    }
//
//    init(location: CLLocation, user: ChatUser, messageId: String, date: Date) {
//        let locationItem = CoordinateItem(location: location)
//        self.init(kind: .location(locationItem), user: user, messageId: messageId, date: date)
//    }
//
//    init(emoji: String, user: ChatUser, messageId: String, date: Date) {
//        self.init(kind: .emoji(emoji), user: user, messageId: messageId, date: date)
//    }
//
//    init(audioURL: URL, user: ChatUser, messageId: String, date: Date) {
//        let audioItem = MockAudioItem(url: audioURL)
//        self.init(kind: .audio(audioItem), user: user, messageId: messageId, date: date)
//    }
//
//    init(contact: MockContactItem, user: ChatUser, messageId: String, date: Date) {
//        self.init(kind: .contact(contact), user: user, messageId: messageId, date: date)
//    }
//
//    init(linkItem: LinkItem, user: ChatUser, messageId: String, date: Date) {
//        self.init(kind: .linkPreview(linkItem), user: user, messageId: messageId, date: date)
//    }
}

private struct ImageMediaItem: MediaItem {

    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize

    init(image: UIImage) {
        self.image = image
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }

    init(imageURL: URL) {
        self.url = imageURL
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage(imageLiteralResourceName: "image_message_placeholder")
    }
}
