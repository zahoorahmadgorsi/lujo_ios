import ActiveLabel
import UIKit

class AviationEmptyResultsView: UIView {
    @IBOutlet var contentVIew: UIView!
    @IBOutlet var searchAgainButton: UIButton!

    @IBOutlet var customRequestLabel: ActiveLabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    fileprivate func commonInit() {
        Bundle.main.loadNibNamed("AviationEmptyResult", owner: self, options: nil)
        addSubview(contentVIew)
        contentVIew.frame = bounds
        contentVIew.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        setupActiveLabels()
    }

    fileprivate func setupActiveLabels() {
        let termsOfUseType = ActiveType.custom(pattern: "\\scustom request\\b")
        customRequestLabel.enabledTypes = [termsOfUseType]

        customRequestLabel.customize { label in
            label.text = "or create a custom request"
            label.font = UIFont.systemFont(ofSize: 17, weight: .light)
            label.textColor = UIColor.whiteText
            label.customColor[termsOfUseType] = UIColor.rgMid
            label.handleCustomTap(for: termsOfUseType) { [weak self] _ in
                self?.parentViewController?.startChatWithInitialMessage()
                self?.isHidden = true
            }
        }
    }

    @IBAction func requestNewSearch(_ sender: Any) {
        isHidden = true
    }
}
