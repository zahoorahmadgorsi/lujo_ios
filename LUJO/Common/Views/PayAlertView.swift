//
//  CardAlertView.swift
//  LUJO
//
//  Created by Iker Kristian on 8/21/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import SwiftMessages

class PayAlertView: MessageView {
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBAction func cancelButton_onClick(_ sender: UIButton) {
        SwiftMessages.hide(id: self.id)
    }
}
