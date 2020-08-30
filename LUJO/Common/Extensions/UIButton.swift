import UIKit

extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        clipsToBounds = true // add this to maintain corner radius
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            let colorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            setBackgroundImage(colorImage, for: forState)
        }
    }
}

extension UIButton {
    func setCharacterSpacing(characterSpacing: CGFloat = 0.0) {
        guard let labelText = titleLabel?.text else { return }

        let attributedString: NSMutableAttributedString
        if let labelAttributedText = titleLabel?.attributedText {
            attributedString = NSMutableAttributedString(attributedString: labelAttributedText)
        } else {
            attributedString = NSMutableAttributedString(string: labelText)
        }

        // Character spacing attribute
        attributedString.addAttribute(NSAttributedString.Key.kern,
                                      value: characterSpacing,
                                      range: NSRange(location: 0, length: attributedString.length))

        titleLabel?.attributedText = attributedString
    }
}
