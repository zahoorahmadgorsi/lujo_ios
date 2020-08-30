struct BAAirportResponse: Codable {
    let meta: ResponseMetadata
    let links: [String: String]
    let data: [BAAirport]
}

// swiftlint:disable variable_name
struct BAAirport: Codable {
    let id: String
    let href: String
    let type: String
    let name: String
    let city: String
    let iata: String?
    let faa: String?
    let icao: String?
    let country: Country
    let province: Province?

    func toAirport() -> Airport {
        return Airport(id: id,
                       name: name,
                       city: city,
                       country: country,
                       icao: icao,
                       iata: iata,
                       faaId: faa,
                       type: "airports")
    }
}
