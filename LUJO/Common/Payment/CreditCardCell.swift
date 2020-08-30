import UIKit

class CreditCardCell: UITableViewCell {
    @IBOutlet var creditCardImage: UIImageView!
    @IBOutlet var creditCardBrandName: UILabel!
    @IBOutlet var creditCardEndNumber: UILabel!

    @IBOutlet var selectedIndicator: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selectedIndicator.isHidden = !selected
    }
}
