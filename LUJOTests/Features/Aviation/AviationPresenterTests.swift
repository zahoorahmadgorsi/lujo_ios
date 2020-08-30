@testable import LUJO
import XCTest

class AviationPresenterShould: XCTestCase {
//    fileprivate var view: SpyViewAviation!
//    fileprivate var interactor: SpyInteractor!
//    fileprivate var presenter: AviationPresenter!

    override func setUp() {
//        view = SpyViewAviation()
//        interactor = SpyInteractor()
//        presenter = AviationPresenter(view, interactor)
    }

    override func tearDown() {
//        view = nil
//        interactor = nil
//        presenter = nil
    }

    func test_be_the_responder_for_the_presented_view() {
//        XCTAssertTrue(view.invokedPresenter === presenter)
    }

    func test_request_matching_airport_list_when_requested_from_view() {
//        presenter.getAirportListMatching("Catalunya")
//
//        XCTAssertTrue(interactor.invokedGetAirportListMatching)
//        XCTAssertEqual(interactor.invokedGetAirportListMatchingParameters?.pattern, "Catalunya")
    }

    func test_send_matching_criteria_airport_list_to_the_view_upon_reception() {
//        presenter.presentAirportList(AIRPORT_LIST)

//        XCTAssertTrue(view.invokedShowAirportsList)
//        XCTAssertEqual(view.invokedShowAirportsListParameters?.airports, AIRPORT_LIST)
    }

    func test_send_request_for_flight_search_to_interactor_when_requested_by_the_view() {
//        presenter.searchFlights(matching: FLIGHT_SEARCH_CRITERIA)

//        XCTAssertTrue(interactor.invokedSearchFlights)
//        XCTAssertEqual(interactor.invokedSearchFlightsParameters?.criteria, FLIGHT_SEARCH_CRITERIA)
    }

    func test_request_view_show_Empty_when_error_is_returned_on_search_flights() {
//        interactor.stubbedSearchFlightsCompletionResult = (nil, [Filter](), BackendError.parsing(reason: "No flight returned"))

//        presenter.searchFlights(matching: FLIGHT_SEARCH_CRITERIA)

//        XCTAssertTrue(view.invokedShowEmptyResult)
    }

    func test_request_view_show_Empty_when_empty_list_is_returned_on_search_flights() {
//        interactor.stubbedSearchFlightsCompletionResult = ([], [Filter](), nil)

//        presenter.searchFlights(matching: FLIGHT_SEARCH_CRITERIA)

//        XCTAssertTrue(view.invokedShowEmptyResult)
    }

    func test_request_view_to_present_empty_results_when_search_flights_returns_no_list() {
//        interactor.stubbedSearchFlightsCompletionResult = (nil, [Filter](), nil)

//        presenter.searchFlights(matching: FLIGHT_SEARCH_CRITERIA)

//        XCTAssertTrue(view.invokedShowEmptyResult)
    }

    func test_present_aircrafts_list_when_a_list_of_aircrafts_is_returned() {
//        interactor.stubbedSearchFlightsCompletionResult = (LIFTS_LIST, [Filter](), nil)

//        presenter.searchFlights(matching: FLIGHT_SEARCH_CRITERIA)

//        XCTAssertEqual(LIFTS_LIST, view.invokedShowParameters?.list)
    }

    func test_not_assign_new_view_when_asked_to_update_a_view_that_is_not_aviationRepresentable() {
//        let dummyView = LoginView()
//        let currentView = presenter.view as AnyObject
//        presenter.update(nextView: dummyView)

//        XCTAssertTrue(currentView === presenter.view as AnyObject)
    }

    func test_assign_new_view_when_asked_to_update_a_view_that_is_not_aviationRepresentable() {
//        let dummyView = AviationView()
//        presenter.update(nextView: dummyView)
//
//        XCTAssertTrue(dummyView === presenter.view as AnyObject)
    }
}

let AIRPORT_LIST: [Airport] = [
//    Airport(id: "aport-14267", name: "TETERBORO", city: "New Jersey",
//            country: Country(code: "US", name: "United States"), icao: "KTEB", iata: "TEB", faaId: "TEB"),
//    Airport(id: "aport-14913", name: "WESTCHESTER COUNTY", city: "New York",
//            country: Country(code: "US", name: "United States"), icao: "KHPN", iata: "HPN", faaId: "HPN"),
]

let FLIGHT_SEARCH_CRITERIA = FlightSearchCriteria(startAirport: AIRPORT_LIST.first!,
                                                  endAirport: AIRPORT_LIST.last!,
                                                  dateTime: [Date()],
                                                  paxCount: 1)

//private let aircraft_1 = Aircraft(id: "1", name: "Aircraft1", seats: 1, memberPrice: 1.0, nonMemberPrice: 1.0,
//                                  images:  ["https://via.placeholder.com/350x150"],
//                                  yearOfMake: 2001, maxRange: 100, category: .lightJet,
//                                  liabilityInsurance: 1.0, luggageCapacity: 1, amenities: [])
//private let aircraft_2 = Aircraft(id: "2", name: "Aircraft2", seats: 1, memberPrice: 1.0, nonMemberPrice: 1.0,
//                                  mainImageURL: "https://via.placeholder.com/350x150",
//                                  yearOfMake: 2001, maxRange: 100, category: .lightJet,
//                                  liabilityInsurance: 1.0, luggageCapacity: 1, amenities: [])

//private let lift_1 = Lift(id: "1", aircraft: aircraft_1, departure: AIRPORT_LIST.first!, arrival: AIRPORT_LIST.last!,
//                          departureTime: Date(), arrivalTime: Date(),
//                          flightTime: 0, fuelStopCount: 0, paxCount: 1)
//private let lift_2 = Lift(id: "2", aircraft: aircraft_2, departure: AIRPORT_LIST.first!, arrival: AIRPORT_LIST.last!,
//                          departureTime: Date(), arrivalTime: Date(),
//                          flightTime: 0, fuelStopCount: 0, paxCount: 1)
//
//let LIFTS_LIST: [Lift] = [lift_1, lift_2]
//
//private class SpyViewAviation: AviationRepresentable {
//    var invokedPresenterSetter = false
//    var invokedPresenterSetterCount = 0
//    var invokedPresenter: AviationPresenter?
//    var invokedPresenterList = [AviationPresenter?]()
//    var invokedPresenterGetter = false
//    var invokedPresenterGetterCount = 0
//    var stubbedPresenter: AviationPresenter!
//    var presenter: AviationPresenter? {
//        set {
//            invokedPresenterSetter = true
//            invokedPresenterSetterCount += 1
//            invokedPresenter = newValue
//            invokedPresenterList.append(newValue)
//        }
//        get {
//            invokedPresenterGetter = true
//            invokedPresenterGetterCount += 1
//            return stubbedPresenter
//        }
//    }
//
//    var invokedShowAirportsList = false
//    var invokedShowAirportsListCount = 0
//    var invokedShowAirportsListParameters: (airports: [Airport], Void)?
//    var invokedShowAirportsListParametersList = [(airports: [Airport], Void)]()
//    func showAirportsList(_ airports: [Airport]) {
//        invokedShowAirportsList = true
//        invokedShowAirportsListCount += 1
//        invokedShowAirportsListParameters = (airports, ())
//        invokedShowAirportsListParametersList.append((airports, ()))
//    }
//
//    var invokedShowEmptyResult = false
//    var invokedShowEmptyResultCount = 0
//    func showEmptyResult() {
//        invokedShowEmptyResult = true
//        invokedShowEmptyResultCount += 1
//    }
//
//    var invokedShow = false
//    var invokedShowCount = 0
//    var invokedShowParameters: (list: [Lift], filter: [Filter])?
//    var invokedShowParametersList = [(list: [Lift], filter: [Filter])]()
//    func show(lifts list: [Lift], filter: [Filter]) {
//        invokedShow = true
//        invokedShowCount += 1
//        invokedShowParameters = (list, filter)
//        invokedShowParametersList.append((list, filter))
//    }
//
//    var invokedWaitingAnimation = false
//    var invokedWaitingAnimationCount = 0
//    var invokedWaitingAnimationParameters: (show: Bool, Void)?
//    var invokedWaitingAnimationParametersList = [(show: Bool, Void)]()
//    func waitingAnimation(show: Bool) {
//        invokedWaitingAnimation = true
//        invokedWaitingAnimationCount += 1
//        invokedWaitingAnimationParameters = (show, ())
//        invokedWaitingAnimationParametersList.append((show, ()))
//    }
//
//    var invokedShowNetworkActivity = false
//    var invokedShowNetworkActivityCount = 0
//    func showNetworkActivity() {
//        invokedShowNetworkActivity = true
//        invokedShowNetworkActivityCount += 1
//    }
//
//    var invokedHideNetworkActivity = false
//    var invokedHideNetworkActivityCount = 0
//    func hideNetworkActivity() {
//        invokedHideNetworkActivity = true
//        invokedHideNetworkActivityCount += 1
//    }
//}
//
//private class SpyInteractor: AviationPresenterResponder {
//    var invokedPresenterSetter = false
//    var invokedPresenterSetterCount = 0
//    var invokedPresenter: AviationInteractuable?
//    var invokedPresenterList = [AviationInteractuable?]()
//    var invokedPresenterGetter = false
//    var invokedPresenterGetterCount = 0
//    var stubbedPresenter: AviationInteractuable!
//    var presenter: AviationInteractuable? {
//        set {
//            invokedPresenterSetter = true
//            invokedPresenterSetterCount += 1
//            invokedPresenter = newValue
//            invokedPresenterList.append(newValue)
//        }
//        get {
//            invokedPresenterGetter = true
//            invokedPresenterGetterCount += 1
//            return stubbedPresenter
//        }
//    }
//
//    var invokedGetAirportListMatching = false
//    var invokedGetAirportListMatchingCount = 0
//    var invokedGetAirportListMatchingParameters: (pattern: String, entity: Searchable.Type)?
//    var invokedGetAirportListMatchingParametersList = [(pattern: String, entity: Searchable.Type)]()
//    func getAirportListMatching(_ pattern: String, _ entity: Searchable.Type) {
//        invokedGetAirportListMatching = true
//        invokedGetAirportListMatchingCount += 1
//        invokedGetAirportListMatchingParameters = (pattern, entity)
//        invokedGetAirportListMatchingParametersList.append((pattern, entity))
//    }
//
//    var invokedSearchFlights = false
//    var invokedSearchFlightsCount = 0
//    var invokedSearchFlightsParameters: (criteria: FlightSearchCriteria, Void)?
//    var invokedSearchFlightsParametersList = [(criteria: FlightSearchCriteria, Void)]()
//    var stubbedSearchFlightsCompletionResult: ([Lift]?, [Filter], Error?)?
//    func searchFlights(matching criteria: FlightSearchCriteria, completion: @escaping ([Lift]?, [Filter], Error?) -> Void) {
//        invokedSearchFlights = true
//        invokedSearchFlightsCount += 1
//        invokedSearchFlightsParameters = (criteria, ())
//        invokedSearchFlightsParametersList.append((criteria, ()))
//        if let result = stubbedSearchFlightsCompletionResult {
//            completion(result.0, result.1, result.2)
//        }
//    }
//
//    var invokedFilterFlights = false
//    var invokedFilterFlightsCount = 0
//    var invokedFilterFlightsParameters: (criteria: [Filter], Void)?
//    var invokedFilterFlightsParametersList = [(criteria: [Filter], Void)]()
//    var stubbedFilterFlightsCompletionResult: ([Lift]?, [Filter], Error?)?
//    func filterFlights(matching criteria: [Filter], completion: @escaping ([Lift]?, [Filter], Error?) -> Void) {
//        invokedFilterFlights = true
//        invokedFilterFlightsCount += 1
//        invokedFilterFlightsParameters = (criteria, ())
//        invokedFilterFlightsParametersList.append((criteria, ()))
//        if let result = stubbedFilterFlightsCompletionResult {
//            completion(result.0, result.1, result.2)
//        }
//    }
//}
