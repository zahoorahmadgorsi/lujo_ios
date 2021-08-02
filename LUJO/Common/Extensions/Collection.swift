//
//  Collection.swift
//  LUJO
//
//  Created by iMac on 03/08/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import Foundation

extension Collection {

    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
