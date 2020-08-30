import UIKit

class CountryCodeCell: UITableViewCell {
    @IBOutlet var flag: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var code: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
