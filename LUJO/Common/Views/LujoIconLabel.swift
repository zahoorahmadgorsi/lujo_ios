import UIKit

class LujoIconLabel: UIView {
    private var iconImageView = UIImageView()
    private var textLabel = UILabel()

    @IBInspectable var text: String = "" {
        didSet {
            updateTextContent()
        }
    }

    @IBInspectable var placeholder: String = "Lujo Icon Label" {
        didSet {
            updateTextContent()
        }
    }

    @IBInspectable var icon: UIImage = UIImage(named: "alert-circle")! {
        didSet {
            iconImageView.image = icon
        }
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
        updateTextContent()
    }
}

extension LujoIconLabel {
    func setupUI() {
        layer.borderWidth = 1
        layer.borderColor = UIColor.inputBorderNoFocus.cgColor
        backgroundColor = .clear

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleToFill
        iconImageView.image = icon

        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.font = UIFont.systemFont(ofSize: 17, weight: .light)
        updateTextContent()

        addSubview(iconImageView)
        addSubview(textLabel)

        NSLayoutConstraint.activate([
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            iconImageView.heightAnchor.constraint(equalToConstant: 16),
            iconImageView.widthAnchor.constraint(equalToConstant: 16),
        ])

        NSLayoutConstraint.activate([
            textLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            textLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 10),
        ])
    }

    private func updateTextContent() {
        if text.isEmpty {
            textLabel.text = placeholder
            textLabel.textColor = UIColor.inputFieldText
            layer.borderColor = UIColor.inputBorderNoFocus.cgColor
        } else {
            textLabel.text = text
            textLabel.textColor = UIColor.whiteText
            layer.borderColor = UIColor.rgMid.cgColor
        }
    }
}
