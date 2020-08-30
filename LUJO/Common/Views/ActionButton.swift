import UIKit

class ActionButton: UIButton {
    private var gradient: CAGradientLayer!
    private var background: CALayer!
    private let charSpacing: CGFloat = 3.0

    private func setupUI() {
        background = CALayer()
        background.backgroundColor = UIColor.grayButton.cgColor
        background.frame = bounds
        layer.addSublayer(background)
        
        let gradientColors = [UIColor.buttonGradientStart.cgColor,
                              UIColor.buttonGradientEnd.cgColor]
        gradient = CAGradientLayer(start: .centerLeft, end: .centerRight, colors: gradientColors, type: .axial)
        gradient.frame = bounds
        layer.addSublayer(gradient)
        
        titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        setCharacterSpacing(characterSpacing: charSpacing)
        
        setEnabled()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        background?.frame = bounds
        gradient?.frame = bounds
    }

    override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        setCharacterSpacing(characterSpacing: charSpacing)
    }
    
    func setEnabled() {
        isEnabled = true
        gradient.opacity = 1
        setTitleColor(UIColor.actionButtonText, for: .normal)
    }

    func setDisabled() {
        isEnabled = false
        gradient.opacity = 0
        setTitleColor(UIColor.white, for: .normal)
    }
}
