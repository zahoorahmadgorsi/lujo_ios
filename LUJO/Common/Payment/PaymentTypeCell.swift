import UIKit

class PaymentTypeCell: UITableViewCell {
    @IBOutlet var paymentTypeImage: UIImageView!
    @IBOutlet var paymentTypeName: UILabel!
    @IBOutlet var paymentTypeComment: UILabel!

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
