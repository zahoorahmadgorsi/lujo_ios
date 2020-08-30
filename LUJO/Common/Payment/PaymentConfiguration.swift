import Foundation

struct CompanyInformation {
    let name: String
    let registrationNumber: String
    let taxId: String
    let registryLocation: String
    let type: String
    let homepage: String

    func asDictionary() -> [String: String] {
        return ["name": name,
                "registrationNumber": registrationNumber,
                "taxId": taxId,
                "registryLocation": registryLocation,
                "type": type,
                "homepage": homepage]
    }
}

// Fill in your app identifier and secret key here.
struct PaymentConfiguration {
    static var companyInformation: CompanyInformation {
        return CompanyInformation(name: "LUJO LLC",
                                  registrationNumber: "100114617",
                                  taxId: "100114617",
                                  registryLocation: "New York",
                                  type: "Events",
                                  homepage: "http://golujo.com")
    }
}
