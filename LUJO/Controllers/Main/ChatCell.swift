//
//  ChatCell.swift
//  LUJO
//
//  Created by I MAC on 24/07/2021.
//  Copyright © 2020 Baroque Access. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {
//    static var identifier: String = "chatCell"
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblChannelFriendlyName: UILabel!
    @IBOutlet weak var lblLastMessage: UILabel!
    @IBOutlet weak var lblCreatedAt: UILabel!
    @IBOutlet weak var lblCreatedAtTime: UILabel!
    @IBOutlet weak var lblUnConsumedMessagesCount: UILabel!
    @IBOutlet weak var viewUnConsumedMessagesCount: UIView!
    //    var customer_id: String
//    var conversation_id: String
    
    override func awakeFromNib() {
        super.awakeFromNib()
        reset()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }

    private func reset() {
        lblChannelFriendlyName.text = ""
        lblLastMessage.text = ""
        lblCreatedAt.text = ""
        lblUnConsumedMessagesCount.text = ""
        viewUnConsumedMessagesCount.addViewBorder(borderColor: UIColor.clear.cgColor, borderWidth: 1.0, borderCornerRadius: viewUnConsumedMessagesCount.frame.height/2)
    }
    
}
