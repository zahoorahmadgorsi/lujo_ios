import Foundation

enum BookingType: String, Codable {
    case active
    case cancelled
    case trip = "trips"
}

enum BookingStage: String, Codable {
    case request = "Request"
    case stage1 = "Stage 1"
    case stage2 = "Stage 2"
    case stage3 = "Stage 3"
    case stage4 = "Stage 4"
    case trip = "Trip"

    var description: String {
        switch self {
        case .request:
            return "Booking details approval"
        case .stage1:
            return "Booking details approval"
        case .stage2:
            return "Agreement signing"
        case .stage3:
            return "Booking payment"
        case .stage4:
            return "Passenger info"
        case .trip:
            return "Trip"
        }
    }

    static func stage(from rawValue: String) -> BookingStage? {
        var formattedValue = rawValue.capitalizingFirstLetter()
        if CharacterSet.decimalDigits.contains(formattedValue.unicodeScalars.last!) {
            formattedValue.insert(" ", at: formattedValue.index(before: formattedValue.endIndex))
        }
        return BookingStage(rawValue: formattedValue)
    }
}

struct FeePivot: Codable {
    let priceId: Int
    let feeId: Int
}

struct TripFeePivot: Codable {
    let additionalExpenseId: Int
    let feeId: Int
}

struct BookingFee: Codable {
    let amount: Double
    let name: String
    let type: String
    let pivot: FeePivot
}

struct TripFee: Codable {
    let amount: Double
    let name: String
    let type: String
    let pivot: TripFeePivot
}

struct BookingRequestPrices: Codable {
    let priceFet: Double
    let markup: Double
    let price: Double
    let totalPrice: Double
    let fees: [BookingFee]

    enum CodingKeys: String, CodingKey {
        case priceFet = "fet"
        case markup
        case price
        case totalPrice
        case fees
    }
}

struct TripAdditionalExpenses: Codable {
    let price: Double
    let paid: Bool
    let paymentInstructionsSent: Bool
    let captured: Bool
    let paymentMethod: BookingPaymentMethod
    let fees: [TripFee]

    enum CodingKeys: String, CodingKey {
        case price
        case paid
        case paymentInstructionsSent
        case captured
        case paymentMethod
        case fees
    }
}

extension TripAdditionalExpenses {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        price = try values.decode(Double.self, forKey: .price)
        paid = try values.decode(Int.self, to: Bool.self, forkey: .paid)
        paymentInstructionsSent = try values.decode(Int.self, to: Bool.self, forkey: .paymentInstructionsSent)
        captured = try values.decode(Int.self, to: Bool.self, forkey: .captured)
        paymentMethod = try values.decode(BookingPaymentMethod.self, forKey: .paymentMethod)
        fees = try values.decode([TripFee].self, forKey: .fees)
    }
}

struct BookingAirport: Codable {
    let city: String
    let icao: String?
    let iata: String?
    let faaId: String?

    func toAirport() -> Airport {
        return Airport(id: "",
                       name: city,
                       city: city,
                       country: Country(code: "", name: ""),
                       icao: icao,
                       iata: iata,
                       faaId: faaId,
                       type: "airport")
    }
}

struct BookingAircraftItinerary: Codable {
    let departureDateTime: Date?
    let arrivalDateTime: Date?
    let startAirport: BookingAirport
    let endAirport: BookingAirport

    enum CodingKeys: String, CodingKey {
        case departureDateTime = "departureDatetime"
        case arrivalDateTime = "arivalDatetime"
        case startAirport
        case endAirport
    }

    func toAviationSegment() -> AviationSegment {
        return AviationSegment(startAirport: startAirport.toAirport(),
                               endAirport: endAirport.toAirport(),
                               dateTime: SearchTime.from(date: departureDateTime),
                               returnDate: SearchTime.from(date: arrivalDateTime),
                               passengers: AviationPassengers(adults: 0, children: 0, infants: 0, pets: 0),
                               luggage: AviationLuggage(carryOn: 0, hold: 0, golfBag: 0, skis: 0, other: 0))
    }
}

extension BookingAircraftItinerary {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let RFC3339DateFormatter = DateFormatter()
        RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"

        let strDepartureDateTime = try values.decode(String.self, forKey: .departureDateTime)
        departureDateTime = RFC3339DateFormatter.date(from: strDepartureDateTime)

        let strArrivalDateTime = try values.decode(String.self, forKey: .arrivalDateTime)
        arrivalDateTime = RFC3339DateFormatter.date(from: strArrivalDateTime)

        startAirport = try values.decode(BookingAirport.self, forKey: .startAirport)
        endAirport = try values.decode(BookingAirport.self, forKey: .endAirport)
    }
}

struct BookingAircraftPhoto: Codable {
    let imageURL: String
    enum CodingKeys: String, CodingKey {
        case imageURL = "url"
    }
}

struct BookingAircraft: Codable {
    let type: String
    let aircraftItineraries: [BookingAircraftItinerary]
    let aircraftPhotos: [BookingAircraftPhoto]
}

struct BookingPaymentMethod: Codable {
    let name: String
}

struct AviationBooking: Codable {
    let paid: Bool
    let passengersFilled: Bool
    let tripType: AviationTripType
    let stage: BookingStage?
    let number: String
    let paymentInstructionsSent: Bool
    let aircraft: BookingAircraft
    let prices: BookingRequestPrices?
    let captured: Bool?
    let paymentMethod: BookingPaymentMethod
    let additionalExpenses: [TripAdditionalExpenses]?
}

extension AviationBooking {
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)

            paid = try values.decode(Int.self, to: Bool.self, forkey: .paid)
            passengersFilled = try values.decode(Int.self, to: Bool.self, forkey: .passengersFilled)

            let strTripType = try values.decode(String.self, forKey: .tripType)
            if strTripType == "round-trip" {
                tripType = .roundTrip
            } else {
                tripType = .oneWay
            }

            let stageStr = try values.decode(String.self, forKey: .stage)
            stage = BookingStage.stage(from: stageStr)

            number = try values.decode(String.self, forKey: .number)
            paymentInstructionsSent = try values.decode(Int.self, to: Bool.self, forkey: .paymentInstructionsSent)
            aircraft = try values.decode(BookingAircraft.self, forKey: .aircraft)
            prices = try? values.decode(BookingRequestPrices.self, forKey: .prices)
            captured = try? values.decode(Int.self, to: Bool.self, forkey: .captured)
            paymentMethod = try values.decode(BookingPaymentMethod.self, forKey: .paymentMethod)
            additionalExpenses = try values.decodeIfPresent([TripAdditionalExpenses].self, forKey: .additionalExpenses)
        } catch {
            print(error)
            throw error
        }
    }
}
