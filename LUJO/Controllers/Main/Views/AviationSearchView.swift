import UIKit

class AviationSearchView: UIView {
    @IBOutlet var contentView: AviationSearchView!
    @IBOutlet var searchAnimationImage: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    fileprivate func commonInit() {
        Bundle.main.loadNibNamed("AviationSearchingView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        addRotationAnimation()
    }

    func addRotationAnimation() {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0.0
        rotationAnimation.toValue = Double.pi * 2
        rotationAnimation.duration = 3
        rotationAnimation.repeatCount = .infinity
        searchAnimationImage.layer.add(rotationAnimation, forKey: nil)
    }
}
