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
    @IBOutlet weak var lblAuthorName: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblCreatedAt: UILabel!
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
        lblAuthorName.text = ""
        lblTitle.text = ""
        lblCreatedAt.text = ""

    }
    
}
