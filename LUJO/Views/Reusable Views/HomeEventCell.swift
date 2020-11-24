import UIKit

class HomeEventCell: UICollectionViewCell {
    static let reuseIdentifier = "eventExperienceCellId"
    @IBOutlet var image: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var dateContainerView: UIView!
    @IBOutlet var date: UILabel!
    @IBOutlet var location: UILabel!
    @IBOutlet var tagContainerView: UIView!
    @IBOutlet var tagLabel: UILabel!

    var item: Any?

    func setupContent(_ item: Any) {
        if let event = item as? EventsExperiences, event.type == "event" {
            if let mediaLink = event.primaryMedia?.mediaUrl, event.primaryMedia?.type == "image" {
                image.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
            }
            name.text = event.name
            priceLabel.text = event.priceRange?.first?.name ?? "-"

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

            if event.tags?.count ?? 0 > 0, let firstTag = event.tags?[0] {
                tagContainerView.isHidden = false
                tagLabel.text = firstTag.name.uppercased()
            } else {
                tagContainerView.isHidden = true
            }

//            startDate.text = EventExperienceDetailView.convertDateFormate(date: event.startDate!)
//            startTime.text = EventExperienceDetailView.timeFormatter.string(from: event.startDate!)
//            let city = event.location.first?.city?.name.uppercased() ?? ""
//            let country = event.location.first?.country.name.uppercased() ?? ""
//            location.text = "\(city) " + (!city.isEmpty && !country.isEmpty ? "|" : "") + " \(country)"
            self.item = item
            return
        }

        if let experience = item as? EventsExperiences, experience.type == "experience" {
            if let mediaLink = experience.primaryMedia?.mediaUrl, experience.primaryMedia?.type == "image" {
                image.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
            }
            name.text = experience.name
            priceLabel.text = experience.priceRange?.first?.name ?? "-"

            var locationText = ""
            if let cityName = experience.location?.first?.city?.name {
                locationText = "\(cityName), "
            }
            locationText += experience.location?.first?.country.name ?? ""
            location.text = locationText.uppercased()

            dateContainerView.isHidden = true
            if experience.tags?.count ?? 0 > 0, let firstTag = experience.tags?[0] {
                tagContainerView.isHidden = false
                tagLabel.text = firstTag.name.uppercased()
            } else {
                tagContainerView.isHidden = true
            }

//            let city = experience.location.first?.city?.name.uppercased() ?? ""
//            let country = experience.location.first?.country.name.uppercased() ?? ""
//            location.text = "\(city) " + (!city.isEmpty && !country.isEmpty ? "|" : "") + " \(country)"
            self.item = item
            return
        }

        clearData()
    }

    func clearData() {
        item = nil
        image.image = UIImage(named: "placeholder-img")
        name.text = ""
        priceLabel.text = ""
        date.text = ""
        location.text = ""
        tagLabel.text = ""
    }

    override func prepareForReuse() {
        clearData()
    }
}
