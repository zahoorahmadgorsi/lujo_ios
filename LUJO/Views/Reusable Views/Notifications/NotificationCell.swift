//
//  NotificationCell.swift
//  LUJO
//
//  Created by Zahoor Gorsi on 22/08/2022.
//  Copyright © 2022 Baroque Access. All rights reserved.
//

import Foundation
import UIKit

class NotificationCell: UITableViewCell {
//    static var identifier: String = "NotificationCell"
    @IBOutlet weak var imgProduct: UIImageView!
    @IBOutlet weak var lblNotificationTitle: UILabel!
    
    @IBOutlet weak var lblNotificationSubtitle: UILabel!
    @IBOutlet weak var lblNotificationBody: UILabel!
    @IBOutlet weak var lblCreatedAt: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        reset()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }

    private func reset() {
        lblNotificationTitle.text = ""
        lblNotificationSubtitle.text = ""
        lblNotificationBody.text = ""
        lblCreatedAt.text = ""
    }
    
}
