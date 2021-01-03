import Foundation

struct SearchTime: Codable {
    var date: String
    var time: String

    var isEmpty: Bool { return (date.isEmpty || time.isEmpty) }

    var toDate: Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "us_US")
        
        if time == "" {
            formatter.dateFormat = "MM/dd/yyyy"
//            print(formatter.date(from: date)! )
            return formatter.date(from: date)
        } else {
            formatter.dateFormat = "MM/dd/yyyy HH:mm"
//            print(formatter.date(from: "\(date) \(time)") as Any)
            return formatter.date(from: "\(date) \(time)")
        }
        
    }

    static func from(date: Date?) -> SearchTime {
        guard let date = date else { return SearchTime(date: "", time: "") }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "us_US")
        formatter.dateFormat = "MM/dd/yyyy"

        let dateStr = formatter.string(from: date)
        formatter.dateFormat = "HH:mm"
        let timeStr = formatter.string(from: date)
        return SearchTime(date: dateStr, time: timeStr)
    }
    
    var formatedDateForServer: String? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "us_US")
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let date = toDate {
            return formatter.string(from: date)
        }
        
        return nil
    }
}

struct AviationPassengers: Codable {
    let adults: Int
    let children: Int
    let infants: Int
    let pets: Int
}

struct AviationLuggage: Codable {
    var carryOn: Int
    var hold: Int
    var golfBag: Int
    var skis: Int
    var other: Int

    var totalBags: Int { return carryOn + golfBag + hold + skis + other }
}

struct AviationSegment: Codable {
    let startAirport: Airport
    let endAirport: Airport
    let dateTime: SearchTime
    let returnDate: SearchTime?
    let passengers: AviationPassengers
    let luggage: AviationLuggage
}

struct AviationAditionalRequirements: Codable {
    let smoker: Int
}

struct AviationSearch: Codable {
    var customerId: Int
    let data: [AviationSegment]
    let additional: AviationAditionalRequirements

    func asDictionary() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}
