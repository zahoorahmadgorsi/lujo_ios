import UIKit

class DarkActionButton: UIButton {
    private let charSpacing: CGFloat = 3.0

    func setupUI() {
        layer.borderColor = UIColor.rgMid.cgColor
        layer.borderWidth = 1

        setTitleColor(UIColor.whiteText, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .light)
        setCharacterSpacing(characterSpacing: charSpacing)

        backgroundColor = UIColor.clear
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

    override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        setCharacterSpacing(characterSpacing: charSpacing)
    }
}
