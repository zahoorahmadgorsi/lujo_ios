import Foundation

struct BAFLightSearchResponse: Codable {
    let returnContent: [BAAircraft]
    let searchId: Int

    enum CodingKeys: String, CodingKey {
        case returnContent = "return"
        case searchId
    }
}

struct BAAircraft: Codable {
    let convertedPrice: Double
    let id: String
    let aircraftCategory: String
    let aircraftTail: String
    let type: String
    let maxPax: Int
    let details: BAAircaftDetails
    let aircraftItineraries: [BAAircraftItinerary]
    let aircraftPhotos: [BAPhoto]
}

struct BAAircaftDetails: Codable {
    let sellerCompany: String
    let yearOfMake: Int
    let amenities: [String]?
    let ownerApprovalRequired: Int
    let interiorRefurbished: String?
    let exteriorRefurbished: String?
    let safetyRatings: [[String: String?]]
}

struct BAAircraftItinerary: Codable {
    let startAirport: BAAirport
    let endAirport: BAAirport
    let departureDateTime: BAADateTime
    let arrivalDateTime: BAADateTime
    let timeTBD: Bool
    let paxCount: Int
    let paxSegment: Bool
    let blockMinutes: Int
    let flightMinutes: Int
    let fuelMinutes: Int
    let distanceNM: Int
    let fuelStopCount: Int
}

struct BAADateTime: Codable {
    let dateTimeUTC: String
    let dateTimeLocal: String
    let calculated: Bool
}

struct BAPhoto: Codable {
    let type: String
    let photoURL: String

    enum CodingKeys: String, CodingKey {
        case type
        case photoURL = "url"
    }
}

extension BAAircraft {
    func toLift() -> Lift {
        let setup = LujoSetup()
        let memberMargin = setup.getMembersMargin() ?? 0.0
        let nonMemberMargin = setup.getNonMembersMargin() ?? 0.0

        let aircraft = Aircraft(
            id: aircraftTail,
            name: type,
            seats: maxPax,
            memberPrice: convertedPrice * (1.0 + memberMargin),
            nonMemberPrice: convertedPrice * (1.0 + nonMemberMargin),
            images: aircraftPhotos.map { $0.photoURL },
            yearOfMake: details.yearOfMake,
            maxRange: 0,
            category: aircraftCategory,
            liabilityInsurance: 0.0,
            luggageCapacity: 0,
            amenities: details.amenities ?? []
        )

        let arrivalAirport = aircraftItineraries.count > 1 ?
            aircraftItineraries.last!.startAirport.toAirport() :
            aircraftItineraries.first!.endAirport.toAirport()

        let arrivalDate = aircraftItineraries.count > 1 ?
            Date.dateFromISOString(string: aircraftItineraries.last!.arrivalDateTime.dateTimeLocal) ?? Date() :
            Date.dateFromISOString(string: aircraftItineraries.first!.arrivalDateTime.dateTimeLocal) ?? Date()

        let totalFlightTime = aircraftItineraries.reduce(0, { (result, nextItinerary) -> Int in
            result + nextItinerary.flightMinutes })

        let totalFuelStops = aircraftItineraries.reduce(0, { (result, nextItinerary) -> Int in
            result + nextItinerary.fuelStopCount })

        let departureTime = Date.dateFromISOString(string: aircraftItineraries.first!.departureDateTime.dateTimeLocal)

        let lift = Lift(
            id: id,
            aircraft: aircraft,
            departure: aircraftItineraries.first!.startAirport.toAirport(),
            arrival: arrivalAirport,
            departureTime: departureTime ?? Date(),
            arrivalTime: arrivalDate,
            flightTime: totalFlightTime,
            fuelStopCount: totalFuelStops,
            paxCount: aircraftItineraries.first!.paxCount
        )

        return lift
    }
}

struct BAPaymentAutorization: Codable {
    let token: String
    let baToken: String
    let customerId: Int
    let aircraft: BAAircraft
    let searchId: Int
    let paymentMethod: Int
    let retref: String
    let acctId: Int
    let profileId: String

    enum CodingKeys: String, CodingKey {
        case token
        case baToken = "ba_token"
        case customerId
        case aircraft
        case searchId
        case paymentMethod
        case retref
        case acctId
        case profileId
    }
}
