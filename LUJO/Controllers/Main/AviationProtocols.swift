import UIKit

// Airport Selection Delegate
protocol AviationSearchCriteriaDelegate: class {
    func get(destination airport: OriginAirport)
    func getTripDates(from date: Date?, isReturnDate: Bool)
    func getLuggage(from luggage: AviationLuggage?)
    func search(using criteria: AviationSearch)
    func showSearchFeedback(_ message: String)
    func showMultiLegDetailVC(selectedIndex: Int?, segments: [AviationSegment], addMore: Bool)
}

protocol SearchCriteriaDelegate: class {
    var tripType: AviationTripType { get set }
    var aviationSearchCriteriaDelegate: AviationSearchCriteriaDelegate? { get set }
    func set(_ airport: Airport, for destination: OriginAirport)
    func set(departure: Date, returnDate: Date?)
    func set(luggage: AviationLuggage)
}
