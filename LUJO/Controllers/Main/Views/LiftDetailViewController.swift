import CoreLocation
import MapKit
import UIKit

protocol LiftDetailDelegate: class {
    func finished(payment: PaymentResult, for aircraft: String, method: Int, completion: @escaping (Error?) -> Void)
    func performAction(for result: String)
}

class LiftDetailViewController: UIViewController {
    @IBOutlet var planeMainImage: UIImageView!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var selectionButtons: [UIButton]!
    
    private var overview: LiftOverviewSubVIew!
    private var route: LiftRouteSubView!
    private var specs: LiftSpecsSubView!

    var lift: Lift?
    var segments = [AviationSegment]()
    weak var delegate: LiftDetailDelegate?

    var initalMessageSent = false

    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "us_US")
        formatter.dateFormat = "dd/MM/yy HH:mm 'h'"
        return formatter
    }()

    let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "us_US")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    let HELLOMESSAGE = """
    Hi there, I'm interested in doing %s flight from %s to %s
    on %s%s with %d seats. Can we reserve %s for it?
    """

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let subviews = Bundle.main.loadNibNamed("LiftDetailViewController",
                                                      owner: self,
                                                      options: nil) else {
            return
        }

        if let firstImage = lift?.aircraft.images.first {
            planeMainImage.downloadImageFrom(link: firstImage, contentMode: .scaleAspectFill)
        }

        guard subviews[1] is LiftOverviewSubVIew else { fatalError("Review LiftDetailsVIewController for errors") }

        guard subviews[2] is LiftRouteSubView else { fatalError("Review LiftDetailsVIewController for errors") }

        guard subviews[3] is LiftSpecsSubView else { fatalError("Review LiftDetailsVIewController for errors") }

        // swiftlint:disable force_cast
        overview = (subviews[1] as! LiftOverviewSubVIew)
        route = (subviews[2] as! LiftRouteSubView)
        specs = (subviews[3] as! LiftSpecsSubView)

        setupOverview()
        setupFlightRoute()
        setupSpecs()

        stackView.addArrangedSubview(overview)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activateKeyboardManager()
    }

    fileprivate func setupOverview() {
        guard let aircraft = lift?.aircraft else { return }

        overview.aircraftName.text = aircraft.name
        overview.numberOfSeats.text = String(aircraft.seats)

        if let price = formatter.string(from: aircraft.memberPrice as NSNumber) {
            overview.memberPrice.text = price
        } else {
            overview.memberPrice.text = ""
        }

        if let price = formatter.string(from: aircraft.nonMemberPrice as NSNumber) {
            overview.nonMemberPrice.text = price
        } else {
            overview.nonMemberPrice.text = ""
        }
    }

    fileprivate func setupFlightRoute() {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "us_US")
        dateFormatter.dateFormat = "dd MMM yyyy"

        if let date = lift?.departureTime {
            route.departureDate.text = dateFormatter.string(from: date)
            route.departureTime.text = timeFormatter.string(from: date)
        } else {
            route.departureTime.text = ""
            route.departureDate.text = ""
        }

        if let date = lift?.arrivalTime {
            route.arrivalDate.text = dateFormatter.string(from: date)
            route.arrivalTime.text = timeFormatter.string(from: date)
        } else {
            route.arrivalTime.text = ""
            route.arrivalDate.text = ""
        }

        if let time = lift?.flightTime {
            let hours = String(format: "%02d", time / 60)
            let minutes = String(format: "%02d", time % 60)
            route.flightTime.text = "\(hours):\(minutes) h"
        } else {
            route.flightTime.text = ""
        }

        lift?.departure.getCoordinate { coordinates, error in
            guard error == nil else {
//                print(error!)
                return
            }

            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            annotation.title = self.lift!.departure.name
            self.route.mapDeparture.addAnnotation(annotation)

            let region = MKCoordinateRegion(center: coordinates, latitudinalMeters: 5000, longitudinalMeters: 5000)
            self.route.mapDeparture.setRegion(region, animated: false)
        }

        lift?.arrival.getCoordinate { coordinates, error in
            guard error == nil else {
//                print(error!)
                return
            }

            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            annotation.title = self.lift!.arrival.name
            self.route.mapArrival.addAnnotation(annotation)

            let region = MKCoordinateRegion(center: coordinates, latitudinalMeters: 5000, longitudinalMeters: 5000)
            self.route.mapArrival.setRegion(region, animated: false)
        }
    }

    fileprivate func setupSpecs() {
        guard let aircraft = lift?.aircraft else { return }

        specs.aircraftName.text = aircraft.name
        specs.yearOfMake.text = aircraft.yearOfMake > 0 ? "\(aircraft.yearOfMake)" : ""

        if let price = formatter.string(from: aircraft.liabilityInsurance as NSNumber) {
            specs.insurance.text = price
        } else {
            specs.insurance.text = ""
        }

        var dotsString: String = ""
        var amenitiesString: String = ""
        aircraft.amenities.forEach { amenites in
            dotsString += "∙\n"
            amenitiesString += "\(amenites)\n"
        }

        specs.amenities.text = amenitiesString
        specs.dotsLabel.text = dotsString

        specs.amenities.setLineSpacing(lineSpacing: 5.0)
        specs.dotsLabel.setLineSpacing(lineSpacing: 5.0)
    }

    fileprivate func updateUI(_ view: UIView) {}

    @IBAction func infoSelectionChanged(_ sender: UIButton) {
        overview.removeFromSuperview()
        route.removeFromSuperview()
        specs.removeFromSuperview()

        var selectedView: UIView

        for button in selectionButtons {
            button.isSelected = button == sender
        }
        
        if sender.tag == 0 {
            selectedView = overview
        } else  if sender.tag == 1 {
            selectedView = route
        } else {
            selectedView = specs
        }

        stackView.addArrangedSubview(selectedView)
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func galleryButton_onClick(_ sender: UIButton) {
        if !(lift?.aircraft.images.isEmpty ?? true) {
            let viewController = GalleryViewControllerNEW.instantiate(dataSource: lift!.aircraft.images)
            present(viewController, animated: true, completion: nil)
        } else {
            print("There are no images in the gallery, sorry!")
//            showInformationPopup(withTitle: "Info", message: "There are no images in the gallery, sorry!")
        }
    }

    @IBAction func requestBook(_ sender: Any) {
        let stbrd = UIStoryboard(name: "Booking", bundle: nil)
        // swiftlint:disable force_cast
        let bookingVC = stbrd.instantiateViewController(withIdentifier: "Step1") as! BookingStep2
        // swiftlint:enable force_cast
        bookingVC.paymentDelegate = self
        let userId = LujoSetup().getLujoUser()!.id

        // TODO: Move amount to setup
        bookingVC.paymentData = PaymentData(id: "0000001",
                                            description: lift!.aircraft.name,
                                            amount: 500.00, // Amount for reservation
                                            currency: .dollar,
                                            country: "US",
                                            reference: lift!.id,
                                            locale: "en_US",
                                            shopper: "customer\(userId)")

        present(bookingVC, animated: true, completion: nil)
    }

//    @objc func chatConnected(sender: AnyObject) {
//        guard ZDCChat.instance()?.api.connectionStatus == .connected else { return }
//        guard initalMessageSent == false else { return }
//        sendInitialInformation()
//    }

    @IBAction func showChat(_ sender: Any) {
        if LujoSetup().getLujoUser()?.membershipPlan != nil {
            startChatWithInitialMessage()
        } else {
            showInformationPopup(withTitle: "Information", message: "24/7 agent chat is only available to Lujo members. Please upgrade to enjoy full benefits of Lujo.")
        }
    }

    fileprivate func sendInitialInformation() {
//        ZDCChatAPI.instance()?.setNote("---------------------")
//        if let currentUser = LujoSetup().getUserInformation() {
//            ZDCChat.updateVisitor { user in
//                user?.email = currentUser.email
//                user?.name = "\(currentUser.firstName) \(currentUser.lastName)"
//                user?.phone = currentUser.phoneNumber.readableNumber
//            }
//        }

        if let currentLift = self.lift {
            var returnTrip = false
            var back = ""
//            ZDCChatAPI.instance().appendNote("Lift Id: \(currentLift.id)")

//            var bookingInformation = "Total of \(currentLift.paxCount) passengers "
//            ZDCChatAPI.instance().appendNote(bookingInformation)

            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "us_US")
            formatter.dateFormat = "dd/MM/yy"

            let origin = currentLift.departure.airportLocation()
            let destination = currentLift.arrival.airportLocation()
            let depart = formatter.string(from: currentLift.departureTime)

//            bookingInformation = "From \(origin)\n to \(destination)"

//            ZDCChatAPI.instance().appendNote(bookingInformation)

//            bookingInformation = "on \(depart)"
//
            if let returnDate = currentLift.arrivalTime {
                returnTrip = true
                back = formatter.string(from: returnDate)
//                bookingInformation.append(" and returning on \(back)")
                back = " to \(back)"
            }
//
//            ZDCChatAPI.instance().appendNote(bookingInformation)

            // swiftlint:disable line_length
            let presentationMessage = """
            Hi there, I'm interested in doing \(returnTrip ? "a round trip" : "one way") flight from \(origin) to \(destination) on \(depart)\(back) with \(currentLift.paxCount) seats. Can we reserve \(currentLift.aircraft.name) for it?
            """

            startChatWithInitialMessage(presentationMessage)
        }

        initalMessageSent = true
    }
}

extension LiftDetailViewController: PaymentSelectionDelegate {
    func paymentCompleted(with result: String) {
        delegate?.performAction(for: result)
    }

    func paymentFished(with result: PaymentResult, at session: PaymentSession?, completion: @escaping (Error?) -> Void) {
        delegate?.finished(payment: result, for: lift!.id, method: 0, completion: completion)
    }
}
