import UIKit

class LujoTextField: UITextField {
    let padding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    let focusColor = UIColor.rgMid.cgColor
    let nonFocusColor = UIColor.inputBorderNoFocus.cgColor

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    required override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    override func awakeFromNib() {
        setupUI()
    }

    func setupUI() {
        layer.borderWidth = 1
        layer.borderColor = nonFocusColor

        font = UIFont.systemFont(ofSize: 17, weight: .light)
        textColor = UIColor(named: "White Text")

        backgroundColor = UIColor.clear
        tintColor = UIColor.rgMid

        guard let placeHolderText = placeholder else { return }

        var placeHolderAttributed = NSMutableAttributedString()

        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font!,
                                                         NSAttributedString.Key.foregroundColor: UIColor.placeholderText]

        placeHolderAttributed = NSMutableAttributedString(string: placeHolderText,
                                                          attributes: attributes)
        attributedPlaceholder = placeHolderAttributed

//        if translatesAutoresizingMaskIntoConstraints == false {
//            NSLayoutConstraint.activate([heightAnchor.constraint(equalToConstant: 44)])
//        }
    }

    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    open override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func becomeFirstResponder() -> Bool {
        let becomeFirstResponder = super.becomeFirstResponder()
        if becomeFirstResponder {
            layer.borderColor = focusColor
        }
        return becomeFirstResponder
    }

    override func resignFirstResponder() -> Bool {
        let resignFirstResponder = super.resignFirstResponder()
        if resignFirstResponder {
            layer.borderColor = nonFocusColor
        }
        return resignFirstResponder
    }
}
