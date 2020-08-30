import MapKit
import UIKit

class LiftRouteSubView: UIView {
    @IBOutlet var departureDate: UILabel!
    @IBOutlet var departureTime: UILabel!
    @IBOutlet var arrivalDate: UILabel!
    @IBOutlet var arrivalTime: UILabel!
    @IBOutlet var flightTime: UILabel!

    @IBOutlet var mapDeparture: MKMapView!
    @IBOutlet var mapArrival: MKMapView!
}
