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
    @IBOutlet weak var lblCreatedAtDate: UILabel!
    @IBOutlet weak var lblCreatedAtTime: UILabel!
    
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
        lblCreatedAtDate.text = ""

    }
    
}
