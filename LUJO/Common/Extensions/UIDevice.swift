//
//  UIDevice.swift
//  LUJO
//
//  Created by Nemanja Djurisic on 6/21/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit

extension UIDevice {
    class var isSimulator: Bool {
        #if arch(i386) || arch(x86_64)
            return true
        #else
            return false
        #endif
    }

    class var isiPhone4: Bool { return UIScreen.main.nativeBounds.height == 960 }
    class var isiPhone5: Bool { return UIScreen.main.nativeBounds.height == 1136 }
    class var isiPhone6: Bool { return UIScreen.main.nativeBounds.height == 1334 }
    class var isiPhone6Plus: Bool { return UIScreen.main.nativeBounds.height == 2208 }
    class var isIphoneX: Bool { return UIScreen.main.nativeBounds.height == 2436 }
    class var isIphoneXr: Bool { return UIScreen.main.nativeBounds.height == 1792 }
    class var isIphoneXmax: Bool { return UIScreen.main.nativeBounds.height == 2688 }

    class var isIphone6PlusZoomed: Bool {
        return (UIScreen.main.bounds.size.height == 667.0 && UIScreen.main.nativeScale < UIScreen.main.scale)
    }

    class var isIphone6Zoomed: Bool {
        return (UIScreen.main.bounds.size.height == 568.0 && UIScreen.main.nativeScale > UIScreen.main.scale)
    }
}
