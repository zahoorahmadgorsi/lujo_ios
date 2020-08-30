//
//  PreloadDataManager.swift
//  LUJO
//
//  Created by Iker Kristian on 8/14/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit

/// Preload data manager is used to group and hold references to diferent data
/// structures used by different screens.
enum PreloadDataManager {
    /// Home screen data references.
    enum HomeScreen {
        /// Home Objects reference.
        static var scrollViewData: HomeObjects?
    }

    enum DiningScreen {
        // Dining Objects reference.
        static var scrollViewData: DiningHomeObjects?
    }
    
    enum Memberships {
        static var memberships: [Membership] = []
    }
    
    enum UserEntryType {
        static var isOldUser: Bool = true
    }
}
