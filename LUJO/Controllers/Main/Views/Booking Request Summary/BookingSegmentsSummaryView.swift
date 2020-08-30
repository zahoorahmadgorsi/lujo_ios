import UIKit

class BookingSegmentsSummaryView: UIView {
    @IBOutlet var contentView: UIStackView!
    var heightConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        heightConstraint = heightAnchor.constraint(equalToConstant: 32)
        heightConstraint?.isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        heightConstraint = heightAnchor.constraint(equalToConstant: 32)
        heightConstraint?.isActive = true
    }

    var segments: [AviationSegment]? {
        didSet {
            updateContentView(with: segments!)
        }
    }
}

extension BookingSegmentsSummaryView {
    private func updateContentView(with segments: [AviationSegment]) {
        contentView.removeAllArrangedSubviews()

        for segment in segments {
            guard let newView: BookingSegmentView = BookingSegmentView.instantiateFromNib() else {
                fatalError("Nib file not found at Aviation Options")
            }
            newView.segment = segment
            contentView.addArrangedSubview(newView)
        }
        let newHeight: CGFloat = CGFloat((45 * segments.count) + 32)
        heightConstraint?.constant = newHeight

        updateConstraints()
    }
}
