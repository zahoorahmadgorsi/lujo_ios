import Foundation

enum AircraftCategory {
    case lightJet, midsize, heavyJet
}

enum AviationTripType: Int, Codable {
    case oneWay, roundTrip, multiCity
    
    static func aviationTypeFromRawValue(value: Int) -> AviationTripType {
        switch value {
        case 0:
            return .oneWay
        case 1:
            return .roundTrip
        default:
            return .multiCity
        }
    }
}

struct FlightSearchCriteria: Equatable {
    let startAirport: Airport
    let endAirport: Airport
    let dateTime: [Date]
    let paxCount: Int

    func asArray() -> [[String: Any]] {
        let startAirport = self.startAirport.toDictionary()
        let endAirport = self.endAirport.toDictionary()
        let departureTime = dateTime.first!.asDateAndTime() as [String: Any]

        var segments = [[
            "startAirport": startAirport,
            "endAirport": endAirport,
            "dateTime": departureTime,
            "passengers": [
                "adult": paxCount,
                "children": 0,
                "infant": 0,
                "pets": 0,
            ],
        ]]

        if dateTime.count > 1 {
            let returnTime = dateTime[1].asDateAndTime() as [String: Any]
            let returnSegment = [
                "startAirport": endAirport,
                "endAirport": startAirport,
                "dateTime": returnTime,
                "passengers": [
                    "adult": paxCount,
                    "children": 0,
                    "infant": 0,
                    "pets": 0,
                ],
            ]
            segments.append(returnSegment)
        }

        return segments
    }
}

struct AircraftAmenity: Equatable {
    let code: String
    let name: String
}

struct Aircraft: Equatable, Codable {
    let id: String
    let name: String
    let seats: Int
    let memberPrice: Double
    let nonMemberPrice: Double
    let images: [String]
    let yearOfMake: Int
    let maxRange: Int
    let category: String
    let liabilityInsurance: Double
    let luggageCapacity: Int
    let amenities: [String]
}

struct Lift: Equatable {
    let id: String

    let aircraft: Aircraft

    let departure: Airport
    let arrival: Airport

    let departureTime: Date
    let arrivalTime: Date?
    let flightTime: Int
    let fuelStopCount: Int

    let paxCount: Int
}

struct Filter {
    let name: String
    let selected: Bool
    let count: Int
}
