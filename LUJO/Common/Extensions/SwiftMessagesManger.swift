//
//  SwiftMessagesManger.swift
//  LUJO
//
//  Created by Iker Kristian on 8/21/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import SwiftMessages

func showCardAlertWith(title: String, body: String, buttonTitle: String = "Dismiss", cancelButtonTitle: String? = nil, buttonTapHandler: (()->Swift.Void)? = nil) {
    let view: CardAlertView! = try! SwiftMessages.viewFromNib(named: "CardAlertView") as! CardAlertView
    view.configureDropShadow()
    view.configureContent(title: title, body: body)
    view.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 40, bottom: 20, right: 40)
    (view.backgroundView as? CornerRoundingView)?.cornerRadius = 10
    view.button?.setTitle(buttonTitle, for: .normal)
    view.buttonTapHandler = { button in
        SwiftMessages.hide(id: view.id)
        buttonTapHandler?()
    }
    if let cancelButtonTitle = cancelButtonTitle {
        view.cancelButton.setTitle(cancelButtonTitle, for: .normal)
    } else {
        view.cancelButton.isHidden = true
    }
    var config = SwiftMessages.Config()
    config.duration = SwiftMessages.Duration.forever
    config.presentationStyle = .center
    config.dimMode = .color(color: UIColor.black.withAlphaComponent(0.4), interactive: buttonTapHandler == nil)
    SwiftMessages.show(config: config, view: view)
}

func showPayAlertWith(title: String, body: String, buttonTitle: String = "Dismiss", cancelButtonTitle: String? = nil, buttonTapHandler: (()->Swift.Void)? = nil) {
    let view: PayAlertView! = try! SwiftMessages.viewFromNib(named: "PayAlertView") as! PayAlertView
    view.configureDropShadow()
    view.configureContent(title: title, body: body)
    view.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 40, bottom: 20, right: 40)
    (view.backgroundView as? CornerRoundingView)?.cornerRadius = 10
    view.button?.setTitle(buttonTitle, for: .normal)
    view.buttonTapHandler = { button in
        SwiftMessages.hide(id: view.id)
        buttonTapHandler?()
    }
    if let cancelButtonTitle = cancelButtonTitle {
        view.cancelButton.setTitle(cancelButtonTitle, for: .normal)
    } else {
        view.cancelButton.isHidden = true
    }
    var config = SwiftMessages.Config()
    config.duration = SwiftMessages.Duration.forever
    config.presentationStyle = .center
    config.dimMode = .color(color: UIColor.black.withAlphaComponent(0.4), interactive: buttonTapHandler == nil)
    SwiftMessages.show(config: config, view: view)
}

