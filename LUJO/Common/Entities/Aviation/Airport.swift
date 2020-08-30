import Alamofire
import CoreLocation
import Foundation

struct AirportResponse: Codable {
    let meta: ResponseMetadata
    let links: [String: String]
    let data: [Airport]
}

struct LocationDefinition: Codable, Equatable {
    let code: String
    let name: String
}

typealias Country = LocationDefinition
typealias Province = LocationDefinition

struct AirportCellData: Equatable {
    let iata: String
    let name: String
    let city: String
    let country: String

    static func from(airport: Airport) -> AirportCellData {
        return AirportCellData(iata: airport.validId,
                               name: airport.name,
                               city: airport.city,
                               country: airport.country.name)
    }
}

struct Airport: Codable, Equatable {
    let id: String
    let name: String
    let city: String
    let country: Country
    let icao: String?
    let iata: String?
    let faaId: String?
    let type: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case city
        case country
        case icao
        case iata
        case faaId = "faa"
        case type
    }

    func airportLocation() -> String {
        return "\(city.capitalizingAllFirstLetters()), \(country.name.capitalizingAllFirstLetters())"
    }

    func toDictionary() -> [String: Any] {
        var dictionary = [String: Any]()

        dictionary["id"] = id
        dictionary["name"] = name
        dictionary["city"] = city
        dictionary["country"] = ["code": self.country.code,
                                 "name": self.country.name]
        if icao != nil { dictionary["icao"] = icao }
        if iata != nil { dictionary["iata"] = iata }
        if faaId != nil { dictionary["faa"] = faaId }

        dictionary["type"] = type

        return dictionary
    }

    func getCoordinate(completionHandler: @escaping (CLLocationCoordinate2D, Error?) -> Void) {
        let geocoder = CLGeocoder()
        let addressString = "\(name) Airport, \(country.name)" // "\(name) \(city), \(country.name)"
        geocoder.geocodeAddressString(addressString) { placemarks, error in
            if error == nil {
                if let placemark = placemarks?[0] {
                    let location = placemark.location!
                    completionHandler(location.coordinate, nil)
                    return
                }
            }

            completionHandler(kCLLocationCoordinate2DInvalid, error)
        }
    }

    var validId: String {
        return iata ?? faaId ?? icao ?? "UNK"
    }
}
