import UIKit

class BookingRequestLiftInfo: UIView {
    @IBOutlet var requestId: UILabel!
    @IBOutlet var liftPicture: UIImageView!
    @IBOutlet var liftModel: UILabel!
    @IBOutlet var multycity: UILabel!
    @IBOutlet var stageContainerView: UIView!

    var lift: Lift? {
        didSet {
            if let lift = lift {
                requestId.text = "LU-XXXXXX"
                if let imageURL = lift.aircraft.images.first {
                    liftPicture.downloadImageFrom(link: imageURL, contentMode: .scaleAspectFill)
                }
                liftModel.text = lift.aircraft.name
            }
        }
    }

    func setInfo(request id: String, image urlStr: String, aircraft model: String, multyleg: Bool, isTrip: Bool) {
        requestId.isHidden = false
        requestId.text = id
        liftPicture.downloadImageFrom(link: urlStr, contentMode: .scaleAspectFill)
        liftModel.text = model
        multycity.isHidden = !multyleg
        stageContainerView.isHidden = isTrip
    }

    func reSetInfo() {
        requestId.isHidden = true
        multycity.isHidden = true
        requestId.text = ""
        liftPicture.image = UIImage(named: "Sample Jet Image")
        liftModel.text = ""
        stageContainerView.isHidden = false
    }
}
