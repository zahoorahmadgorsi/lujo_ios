import UIKit

class HomeEventSummary: UIView {
    private static let kCONTENTXIBNAME = "HomeEventSummary"
    @IBOutlet var contentView: UIView!
    @IBOutlet var primaryImage: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var priceRange: UILabel!
    @IBOutlet var location: UILabel!
    @IBOutlet var date: UILabel!

    @IBOutlet var dateContainerView: UIView!
    @IBOutlet var tagContainerView: UIView!
    @IBOutlet var tagLabel: UILabel!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }

    func initSubviews() {
        Bundle.main.loadNibNamed(HomeEventSummary.kCONTENTXIBNAME, owner: self, options: nil)
        contentView.fixInView(self)
    }

    func updateInformation(with data: Any?) {
        guard let data = data else {
            fillWithEmptyInformation()
            return
        }
        if let event = data as? Product, event.type == "event" {
            if let mediaLink = event.primaryMedia?.mediaUrl, event.primaryMedia?.type == "image" {
                primaryImage.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
            }
            name.text = event.name
            priceRange.text = event.priceRange?.first?.name ?? "-"

            var locationText = ""
            if let cityName = event.location?.first?.city?.name {
                locationText = "\(cityName), "
            }
            locationText += event.location?.first?.country.name ?? ""
            location.text = locationText.uppercased()

            dateContainerView.isHidden = false

            let startDateText = EventDetailsViewController.convertDateFormate(date: event.startDate!)
            var startTimeText = EventDetailsViewController.timeFormatter.string(from: event.startDate!)

            var endDateText = ""
            if let eventEndDate = event.endDate {
                endDateText = EventDetailsViewController.convertDateFormate(date: eventEndDate)
            }
            
            if let timezone = event.timezone {
                startTimeText = "\(startTimeText) (\(timezone))"
            }
            
            date.text = endDateText != "" ? "\(startDateText) - \(endDateText)" : "\(startDateText) \(startTimeText)"

            if event.tags?.count ?? 0 > 0, let fistTag = event.tags?[0] {
                tagContainerView.isHidden = false
                tagLabel.text = fistTag.name.uppercased()
            } else {
                tagContainerView.isHidden = true
            }
            
            return
        }

        if let experience = data as? Product, experience.type == "experience" {
            if let mediaLink = experience.primaryMedia?.mediaUrl, experience.primaryMedia?.type == "image" {
                primaryImage.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
            }
            name.text = experience.name
            priceRange.text = experience.priceRange?.first?.name ?? "-"

            var locationText = ""
            if let cityName = experience.location?.first?.city?.name {
                locationText = "\(cityName), "
            }
            locationText += experience.location?.first?.country.name ?? ""
            location.text = locationText.uppercased()

            dateContainerView.isHidden = true
            if experience.tags?.count ?? 0 > 0, let fistTag = experience.tags?[0] {
                tagContainerView.isHidden = false
                tagLabel.text = fistTag.name.uppercased() 
            } else {
                tagContainerView.isHidden = true
            }
            
            return
        }

        fillWithEmptyInformation()
    }

    func fillWithEmptyInformation() {
        primaryImage.image = UIImage(named: "placeholder-img")
        name.text = ""
        priceRange.text = ""
        location.text = ""
        date.text = ""
    }
}
