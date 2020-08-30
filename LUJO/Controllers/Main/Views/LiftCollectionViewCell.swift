import UIKit

class LiftCollectionViewCell: UICollectionViewCell {
    @IBOutlet var image: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var seats: UILabel!
    @IBOutlet var luggage: UILabel!
    @IBOutlet var memberPrice: UILabel!
    @IBOutlet var nonMemberPrice: UILabel!

    func displayContent(image: String,
                        name: String,
                        seats: Int, luggage: Int,
                        memberPrice: String, nonMemberPrice: String) {
        if !image.isEmpty {
            self.image.downloadImageFrom(link: image, contentMode: .scaleAspectFill)
        }
        self.name.text = name
        self.seats.text = String(seats)
        self.luggage.text = String(luggage)
        self.memberPrice.text = memberPrice
        self.nonMemberPrice.text = nonMemberPrice
    }

    override func prepareForReuse() {
        image.image = UIImage(named: "placeholder-img")
        name.text = ""
        seats.text = ""
        memberPrice.text = "$0.0"
        nonMemberPrice.text = "$0.0"
    }
}
