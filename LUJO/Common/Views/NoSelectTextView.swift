//
//  UnselectableTextView.swift
//  LUJO
//
//  Created by Nemanja Djurisic on 7/9/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import Foundation
import UIKit

class NoSelectTextView: UITextView {
    public override var selectedTextRange: UITextRange? {
        get {
            return nil
        }
        set {}
    }
}
