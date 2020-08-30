import UIKit

protocol AviationLegCellDelegate: class {
    func editRow(at index: Int)
    func deleteRow(at index: Int)
}

class AviationLegCell: UITableViewCell {
    static let cellHeight: CGFloat = 200.5
    static let reuseIdentifier = "AviationLegCell"

    @IBOutlet var legNumber: UILabel!
    @IBOutlet var originAirport: UILabel!
    @IBOutlet var originCity: UILabel!
    @IBOutlet var destinationAirport: UILabel!
    @IBOutlet var destinationCity: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!

    weak var delegate: AviationLegCellDelegate?

    var legNum: Int = 0 {
        didSet {
            legNumber.text = "Leg \(legNum + 1)"
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupCell(with segment: AviationSegment) {
        originAirport.text = "(\(segment.startAirport.validId))"
        originCity.text = segment.startAirport.city

        destinationAirport.text = "(\(segment.endAirport.validId))"
        destinationCity.text = segment.endAirport.city

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        if let date = segment.dateTime.toDate {
            dateLabel.text = formatter.string(from: date)
        } else {
            dateLabel.text = segment.dateTime.date
        }

        timeLabel.text = segment.dateTime.time
    }

    @IBAction func editLeg(_ sender: Any) {
        delegate?.editRow(at: legNum)
    }

    @IBAction func deleteLeg(_ sender: Any) {
        delegate?.deleteRow(at: legNum)
    }
}
