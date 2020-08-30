import UIKit

class BookingSegmentView: UIView {
    @IBOutlet var originAirport: UILabel!
    @IBOutlet var destinationAirport: UILabel!

    @IBOutlet var departureDate: UILabel!
    @IBOutlet var departureTime: UILabel!

    @IBOutlet var returnDate: UILabel!
    @IBOutlet var returnTime: UILabel!

    var segment: AviationSegment? {
        didSet {
            updateLabelsWith(segment!)
        }
    }
}

extension BookingSegmentView {
    private func updateLabelsWith(_ segment: AviationSegment) {
        originAirport.text = segment.startAirport.name + " (\(segment.startAirport.validId))"
        destinationAirport.text = segment.endAirport.name + " (\(segment.endAirport.validId))"

        departureDate.text = segment.dateTime.date
        departureTime.text = segment.dateTime.time

        if let returnDateTime = segment.returnDate {
            returnDate.text = returnDateTime.date
            returnTime.text = returnDateTime.time
        } else {
            returnDate.isHidden = true
            returnTime.isHidden = true
        }
    }
}
