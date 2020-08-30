import JTAppleCalendar
import UIKit

class CalendarCell: JTAppleCell {
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var selectedView: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        selectedView.layer.borderColor = UIColor(named: "Action Button")?.cgColor
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        selectedView.layer.borderColor = UIColor(named: "Action Button")?.cgColor
    }
}
