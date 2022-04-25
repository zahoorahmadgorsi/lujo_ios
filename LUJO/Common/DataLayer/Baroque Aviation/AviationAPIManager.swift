//
//  AviationAPIManager.swift
//  LUJO
//
//  Created by Nemanja Djurisic on 9/23/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import Alamofire
import FirebaseCrashlytics

let LIGHTJETS = "Light Jets"
let SUPERMIDJETS = "Super midsize Jets"
let HEAVYJETS = "Heavy Jets"
let NOFUELSTOPS = "No fuel stops"
let PETSALLOWED = "Pets Allowed"
let BUILDAFTER2000 = "Build After 2000"

class AviationAPIManagerNEW {
    
    static let shared = AviationAPIManagerNEW()
    
    var authorisationToken: String?
    var searchFlightsCache: BAFLightSearchResponse?
    var lastSearch: [Lift]?
    
    private init() { }
    
    func searchFlights(matching criteria: AviationSearch,
                       completion: @escaping ([Lift]?, [Filter], Error?) -> Void) {
        searchFlights(matching: criteria) { flights, error in
            guard error == nil else {
                completion([], [], error)
                return
            }
            // Count filters
            let lightJets = flights.filter({ $0.aircraft.category == "Light jet" }).count
            let superMidJets = flights.filter({ $0.aircraft.category == "Super midsize jet" }).count
            let heavyJets = flights.filter({ $0.aircraft.category == "Heavy jet" }).count
            let nofuelStops = flights.filter({ $0.fuelStopCount == 0 }).count
            let petsAllowed = flights.filter { $0.aircraft.amenities.contains("Pets allowed") }.count
            let buildAfter2000 = flights.filter { $0.aircraft.yearOfMake >= 2000 }.count
            
            let filters = [
                Filter(name: LIGHTJETS, selected: false, count: lightJets),
                Filter(name: SUPERMIDJETS, selected: false, count: superMidJets),
                Filter(name: HEAVYJETS, selected: false, count: heavyJets),
                Filter(name: NOFUELSTOPS, selected: false, count: nofuelStops),
                Filter(name: PETSALLOWED, selected: false, count: petsAllowed),
                Filter(name: BUILDAFTER2000, selected: false, count: buildAfter2000)
            ]
            
            self.lastSearch = flights
            completion(flights, filters, nil)
        }
    }
    
    func filterFlights(matching criteria: [Filter], completion: @escaping ([Lift]?, [Filter], Error?) -> Void) {
        guard let flights = lastSearch else {
            let error = BackendError.parsing(reason: "Can't filter an empty search")
            completion([], [], error)
            return
        }
        
        let filteredFlights = flights.filter {
            var conditions: [Bool] = []
            
            if filterList(criteria, containsFilter: LIGHTJETS) {
                conditions.append($0.aircraft.category == "Light jet")
            }
            
            if filterList(criteria, containsFilter: SUPERMIDJETS) {
                conditions.append($0.aircraft.category == "Super midsize jet")
            }
            
            if filterList(criteria, containsFilter: HEAVYJETS) {
                conditions.append($0.aircraft.category == "Heavy jet")
            }
            
            if filterList(criteria, containsFilter: NOFUELSTOPS) {
                conditions.append($0.fuelStopCount == 0)
            }
            
            if filterList(criteria, containsFilter: PETSALLOWED) {
                conditions.append($0.aircraft.amenities.contains("Pets allowed"))
            }
            
            if filterList(criteria, containsFilter: BUILDAFTER2000) {
                conditions.append($0.aircraft.yearOfMake >= 2000)
            }
            
            let result = conditions.reduce(true, { (previous, next) -> Bool in previous && next })
            
            return result
        }
        
        let filter = buildFilters(flights, selections: criteria)
        completion(filteredFlights, filter, nil)
    }
    
    fileprivate func filterList(_ criteria: [Filter], containsFilter: String) -> Bool {
        return criteria.contains { $0.name == containsFilter }
    }
    
    fileprivate func getSelectedValue(from: [Filter]?, forFilter: String) -> Bool {
        guard let filters = from else { return false }
        
        guard filterList(filters, containsFilter: forFilter) else { return false }
        
        return filters.filter { $0.name == forFilter }.first!.selected
    }
    
    fileprivate func buildFilters(_ flights: [Lift], selections: [Filter]? = nil) -> [Filter] {
        // Count filters
        let lightJets = flights.filter({ $0.aircraft.category == "Light jet" }).count
        let superMidJets = flights.filter({ $0.aircraft.category == "Super midsize jet" }).count
        let heavyJets = flights.filter({ $0.aircraft.category == "Heavy jet" }).count
        let nofuelStops = flights.filter({ $0.fuelStopCount == 0 }).count
        let petsAllowed = flights.filter { $0.aircraft.amenities.contains("Pets allowed") }.count
        let buildAfter2000 = flights.filter { $0.aircraft.yearOfMake >= 2000 }.count
        
        let filters = [
            
            Filter(name: LIGHTJETS,
                   selected: getSelectedValue(from: selections, forFilter: LIGHTJETS),
                   count: lightJets),
            Filter(name: SUPERMIDJETS,
                   selected: getSelectedValue(from: selections, forFilter: SUPERMIDJETS),
                   count: superMidJets),
            Filter(name: HEAVYJETS,
                   selected: getSelectedValue(from: selections, forFilter: HEAVYJETS),
                   count: heavyJets),
            Filter(name: NOFUELSTOPS,
                   selected: getSelectedValue(from: selections, forFilter: NOFUELSTOPS),
                   count: nofuelStops),
            Filter(name: PETSALLOWED,
                   selected: getSelectedValue(from: selections, forFilter: PETSALLOWED),
                   count: petsAllowed),
            Filter(name: BUILDAFTER2000,
                   selected: getSelectedValue(from: selections, forFilter: BUILDAFTER2000),
                   count: buildAfter2000)
        ]
        
        return filters
    }
    
    func searchAirports(matching pattern: String, completionHandler: @escaping ([Airport]?, Error?) -> Void) {
        guard let token = authorisationToken else { return }
        Alamofire.request(BARouter.searchAirport(pattern, token)).responseJSON { response in
            guard response.result.error == nil else {
                completionHandler([], LoginError.errorLogin(description: response.result.error!.localizedDescription))
                return
            }
            
            guard (200 ... 299).contains(response.response!.statusCode) else {
                completionHandler([], BackendError.parsing(reason: "Error from server \(response.response!.statusCode)"))
                return
            }
            
            var airportList = [Airport]()
            
            do {
                let airportResponse = try JSONDecoder().decode(LujoServerResponse<BAAirportResponse>.self,
                                                               from: response.data!)
                airportList = airportResponse.content.data.map { $0.toAirport() }
            } catch {
                Crashlytics.crashlytics().record(error: error)
            }
            
            completionHandler(airportList, nil)
        }
    }
    
    func searchFlights(matching criteria: AviationSearch, completion: @escaping ([Lift], Error?) -> Void) {
        guard let token = authorisationToken else { return }
        searchFlightsCache = nil
        
        Alamofire.request(BARouter.search(criteria, token)).responseJSON { response in
            
            guard response.result.error == nil else {
                completion([], LoginError.errorLogin(description: response.result.error!.localizedDescription))
                return
            }
            
            guard (200 ... 299).contains(response.response!.statusCode) else {
                completion([], BackendError.parsing(reason: "Error from server \(response.response!.statusCode)"))
                return
            }
            
            guard let resultResponse = try? JSONDecoder().decode(LujoServerResponse<BAFLightSearchResponse>.self,
                                                                 from: response.data!) else {
                                                                    completion([], BackendError.parsing(reason: "Error from parsing server response"))
                                                                    return
            }
            
            self.searchFlightsCache = resultResponse.content
            
            var resultLifts = [Lift]()
            for result in resultResponse.content.returnContent {
                resultLifts.append(result.toLift())
            }
            
            completion(resultLifts, nil)
        }
    }
    
    func authorizePayment(for information: PaymentInformation, completion: @escaping (Error?) -> Void) {
        guard let token = authorisationToken else { return }
        guard let aircraftsList = searchFlightsCache?.returnContent else { return }
        
        let baAircraft = aircraftsList.filter { $0.id == information.aircraftId }.first
        guard let selectedAircraft = baAircraft else { return }
        
        let authorization = BAPaymentAutorization(
            token: token,
            baToken: information.token,
            customerId: information.customerId,
            aircraft: selectedAircraft,
            searchId: searchFlightsCache!.searchId,
            paymentMethod: information.paymentMethod,
            retref: information.retref,
            acctId: information.acctId,
            profileId: information.profileId
        )
        
        Alamofire.request(BARouter.authorize(authorization)).responseJSON { response in
            guard response.result.error == nil else {
                completion(LoginError.errorLogin(description: response.result.error!.localizedDescription))
                return
            }
            
            guard (200 ... 299).contains(response.response!.statusCode) else {
                completion(BackendError.parsing(reason: "Error from server \(response.response!.statusCode)"))
                return
            }
            
            completion(nil)
        }
    }
    
    func getBookings(type: BookingType, completion: @escaping ([AviationBooking], Error?) -> Void) {
        guard let token = authorisationToken else { return }
        
        Alamofire.request(BARouter.bookings(type, token)).responseJSON { response in
            guard response.result.error == nil else {
                completion([], LoginError.errorLogin(description: response.result.error!.localizedDescription))
                return
            }
            
            guard (200 ... 299).contains(response.response!.statusCode) else {
                completion([], BackendError.parsing(reason: "Error from server \(response.response!.statusCode)"))
                return
            }
            
            guard let resultResponse = try? JSONDecoder().decode(LujoServerResponse<[AviationBooking]>.self,
                                                                 from: response.data!) else {
                                                                    completion([], BackendError.parsing(reason: "Error from parsing server response"))
                                                                    return
            }
            
            completion(resultResponse.content, nil)
        }
    }
    
    func getAllBookings(completion: @escaping ([Booking], Error?) -> Void) {
        guard let token = authorisationToken else { return }
        
        Alamofire.request(BARouter.allBookings(token)).responseJSON { response in
            guard response.result.error == nil else {
                completion([], LoginError.errorLogin(description: response.result.error!.localizedDescription))
                return
            }
            
            guard (200 ... 299).contains(response.response!.statusCode) else {
                completion([], BackendError.parsing(reason: "Error from server \(response.response!.statusCode)"))
                return
            }
            
            guard let resultResponse = try? JSONDecoder().decode(LujoServerResponse<[Booking]>.self,
                                                                 from: response.data!) else {
                                                                    completion([], BackendError.parsing(reason: "Error from parsing server response"))
                                                                    return
            }
            
            completion(resultResponse.content, nil)
        }
    }
}
