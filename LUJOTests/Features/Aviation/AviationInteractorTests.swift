@testable import LUJO
import XCTest

let SEARCH_PATTERN = "New y"
let SAMPLE_AIRPORT_LIST: [Airport] = [
    Airport(id: "aport-14267", name: "TETERBORO", city: "TETERBORO",
            country: Country(code: "US", name: "United States"), icao: "KTEB", iata: "TEB", faaId: "TEB", type: ""),
    Airport(id: "aport-14913", name: "WESTCHESTER COUNTY", city: "WHITE PLAINS",
            country: Country(code: "US", name: "United States"), icao: "KHPN", iata: "HPN", faaId: "HPN", type: ""),
]

let SAMPLE_FLIGHT_SEARCH = FlightSearchCriteria(startAirport: SAMPLE_AIRPORT_LIST.first!,
                                                endAirport: SAMPLE_AIRPORT_LIST.last!,
                                                dateTime: [Date()], paxCount: 1)

private let aircraft_1 = Aircraft(id: "1", name: "Aircraft1", seats: 1, memberPrice: 1.0, nonMemberPrice: 1.0,
                                  images: ["https://via.placeholder.com/350x150"],
                                  yearOfMake: 2001, maxRange: 100, category: "Light jet",
                                  liabilityInsurance: 1.0, luggageCapacity: 1, amenities: [])
private let aircraft_2 = Aircraft(id: "2", name: "Aircraft2", seats: 1, memberPrice: 1.0, nonMemberPrice: 1.0,
                                  images: ["https://via.placeholder.com/350x150"],
                                  yearOfMake: 2001, maxRange: 100, category: "Light jet",
                                  liabilityInsurance: 1.0, luggageCapacity: 1, amenities: [])

let SAMPLE_FLIGHTS_RESULT = [
    Lift(id: "1", aircraft: aircraft_1, departure: AIRPORT_LIST.first!, arrival: AIRPORT_LIST.last!,
         departureTime: Date(), arrivalTime: Date(),
         flightTime: 0, fuelStopCount: 0, paxCount: 1),
    Lift(id: "2", aircraft: aircraft_2, departure: AIRPORT_LIST.first!, arrival: AIRPORT_LIST.last!,
         departureTime: Date(), arrivalTime: Date(),
         flightTime: 0, fuelStopCount: 0, paxCount: 1),
]

class AviationInteractorShould: XCTestCase {
//    fileprivate var dataLayer: SpyAPIManager!
//    var interactor: AviationInteractor!

    override func setUp() {
//        dataLayer = SpyAPIManager()
//        interactor = AviationInteractor()
    }

    override func tearDown() {
//        dataLayer = nil
//        interactor = nil
    }

    func test_obtain_list_of_airports_matching_pattern_from_data_layer() {
//        interactor.getAirportListMatching(SEARCH_PATTERN, SpyDataLayer.self)

        XCTAssertTrue(SpyDataLayer.invokedSearchAirports)
        XCTAssertEqual(SEARCH_PATTERN, SpyDataLayer.invokedSearchAirportsParameter)
    }

    func test_call_presenter_with_the_result_obtained_from_data_layer_airports_search() {
        SpyDataLayer.invokedSearchAirportsCompletionParams = (SAMPLE_AIRPORT_LIST as [AnyObject], nil)
//        let presenter = SpyPresenter()

//        interactor.presenter = presenter

//        interactor.getAirportListMatching(SEARCH_PATTERN, SpyDataLayer.self)

//        XCTAssertTrue(presenter.invokedPresentAirports)
//        XCTAssertEqual(SAMPLE_AIRPORT_LIST, presenter.invokedPresentAirportsParameter!)
    }

    func test_call_presenter_with_the_empty_list_when_data_layer_airports_search_raises_an_error() {
        SpyDataLayer.invokedSearchAirportsCompletionParams = (SAMPLE_AIRPORT_LIST as [AnyObject],
                                                              BackendError.parsing(reason: "Generic Error"))
//        let presenter = SpyPresenter()

//        interactor.presenter = presenter

//        interactor.getAirportListMatching(SEARCH_PATTERN, SpyDataLayer.self)

//        XCTAssertTrue(presenter.invokedPresentAirports)
//        XCTAssertEqual(0, presenter.invokedPresentAirportsParameter!.count)
    }

    func test_call_presenter_with_the_empty_list_when_data_layer_airports_search_returns_empty_list() {
        SpyDataLayer.invokedSearchAirportsCompletionParams = (nil, nil)
//        let presenter = SpyPresenter()

//        interactor.presenter = presenter

//        interactor.getAirportListMatching(SEARCH_PATTERN, SpyDataLayer.self)

//        XCTAssertTrue(presenter.invokedPresentAirports)
//        XCTAssertEqual(0, presenter.invokedPresentAirportsParameter!.count)
    }

    func test_obtain_flights_list_matching_criteria_from_data_layer() {
//        let dataLayer = SpyAPIManager()
//        let interactor = AviationInteractor(dataLayer)
//
//        interactor.searchFlights(matching: SAMPLE_FLIGHT_SEARCH) { aircrafts, filter, error in }

        XCTAssertTrue(SpyDataLayer.invokedSearchAirports)
        XCTAssertEqual(SEARCH_PATTERN, SpyDataLayer.invokedSearchAirportsParameter)
    }

    func test_raise_the_error_when_flight_search_returned_an_error() {
        let expectation = XCTestExpectation(description: "Error is raised")
//        dataLayer.stubSearchFlightsParameters = ([], BackendError.parsing(reason: "Nothing to parse"))

//        interactor.searchFlights(matching: SAMPLE_FLIGHT_SEARCH) { aircrafts, filter, error in
//            XCTAssertNotNil(error)
//            expectation.fulfill()
//        }

        wait(for: [expectation], timeout: 1)
    }

    func test_extratct_aircrafts_infromation_from_flights_and_return_to_caller() {
        let expectation = XCTestExpectation(description: "Aircraft list is returned")
//        dataLayer.stubSearchFlightsParameters = (SAMPLE_FLIGHTS_RESULT, nil)

//        interactor.searchFlights(matching: SAMPLE_FLIGHT_SEARCH) { result, filter, error in
//            XCTAssertEqual(result![0], SAMPLE_FLIGHTS_RESULT[0])
//            expectation.fulfill()
//        }

        wait(for: [expectation], timeout: 1)
    }
}

private class SpyDataLayer: Searchable {
    static var invokedSearchAirports = false
    static var invokedSearchAirportsParameter: String?
    static var invokedSearchAirportsCompletionParams: ([AnyObject]?, Error?)?

    static func search(matching pattern: String, completion: @escaping ([AnyObject]?, Error?) -> Void) {
        invokedSearchAirports = true
        invokedSearchAirportsParameter = pattern

        if let returnParams = invokedSearchAirportsCompletionParams {
            completion(returnParams.0, returnParams.1)
        }
    }
}
//
//private class SpyPresenter: AviationInteractuable {
//    var invokedPresentAirports = false
//    var invokedPresentAirportsParameter: [Airport]?
//
//    func presentAirportList(_ airports: [Airport]) {
//        invokedPresentAirports = true
//        invokedPresentAirportsParameter = airports
//    }
//}

//private class SpyAPIManager: AviationAPIManager {
//    var invokedSearchFlights = false
//    var invokedSearchFlightsParameters: FlightSearchCriteria?
//    var stubSearchFlightsParameters: ([Lift], Error?)?
//
//    func searchFlights(matching criteria: FlightSearchCriteria, completion: @escaping ([Lift], Error?) -> Void) {
//        invokedSearchFlights = true
//        invokedSearchFlightsParameters = criteria
//
//        if let result = stubSearchFlightsParameters {
//            completion(result.0, result.1)
//        }
//    }
//}
