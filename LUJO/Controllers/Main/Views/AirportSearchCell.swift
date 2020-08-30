import UIKit

class AirportSearchCell: UITableViewCell {
    @IBOutlet var faaIdentifier: UILabel!
    @IBOutlet var airportName: UILabel!
    @IBOutlet var airportProvince: UILabel!
    @IBOutlet var separatorView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
