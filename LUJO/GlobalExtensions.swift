//
//  GlobalExtensions.swift
//  LUJO
//
//  Created by Iker Kristian on 8/27/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit

extension UIStoryboard {
    
    /// Returns main storyboard of this project.
    static let main          = UIStoryboard(name: "Main",    bundle: nil)
    static let accountNEW    = UIStoryboard(name: "AccountNEW", bundle: nil)
    static let payment       = UIStoryboard(name: "Payment", bundle: nil)
    static let customRequest = UIStoryboard(name: "CustomRequests", bundle: nil)
    static let preferences = UIStoryboard(name: "Preferences", bundle: nil)
    static let filters = UIStoryboard(name: "Filters", bundle: nil)
    
    /// Instantiate view controller from storyboard.
    func instantiate<T: UIViewController>(_ identifier: String) -> T {
        return self.instantiateViewController(withIdentifier: identifier) as! T
    }
    
}

extension UINavigationController {
    
    public func pushViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> Swift.Void)? = nil) {
        CATransaction.begin()
        if let completion = completion {
            CATransaction.setCompletionBlock(completion)
        }
        pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
    
    public func popViewController(animated: Bool, completion: (() -> Swift.Void)? = nil) {
        CATransaction.begin()
        if let completion = completion {
            CATransaction.setCompletionBlock(completion)
        }
        popViewController(animated: animated)
        CATransaction.commit()
    }
    
}

extension UIImage {
    
    func resize(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: size.width, height: size.height)))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
}

extension UITextField{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
}
