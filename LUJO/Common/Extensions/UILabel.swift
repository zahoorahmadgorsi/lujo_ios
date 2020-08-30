//
//  UILabel.swift
//  LUJO
//
//  Created by Nemanja Djurisic on 6/19/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit

extension UILabel {
    func setCharacterSpacing(characterSpacing: CGFloat = 0.0) {
        guard let labelText = text else { return }

        let attributedString: NSMutableAttributedString
        if let labelAttributedText = attributedText {
            attributedString = NSMutableAttributedString(attributedString: labelAttributedText)
        } else {
            attributedString = NSMutableAttributedString(string: labelText)
        }

        // Character spacing attribute
        attributedString.addAttribute(NSAttributedString.Key.kern,
                                      value: characterSpacing,
                                      range: NSRange(location: 0, length: attributedString.length))

        attributedText = attributedString
    }

    func setLineSpacing(lineSpacing: CGFloat = 0.0, lineHeightMultiple: CGFloat = 0.0) {
        guard let labelText = self.text else { return }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.lineHeightMultiple = lineHeightMultiple

        let attributedString: NSMutableAttributedString
        if let labelattributedText = self.attributedText {
            attributedString = NSMutableAttributedString(attributedString: labelattributedText)
        } else {
            attributedString = NSMutableAttributedString(string: labelText)
        }

        // (Swift 4.2 and above) Line spacing attribute
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))

        attributedText = attributedString
    }
}
