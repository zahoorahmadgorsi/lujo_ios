import UIKit

class DestinationSearchCell: UITableViewCell {
    @IBOutlet var lblTermId: UILabel!
    @IBOutlet var lblDestinationName: UILabel!
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
