import Foundation

struct CCProfileAccountResult: Codable {
    let acctid: Int
    let accttype: String
    let auoptout: Bool
    let defaultacct: Bool
    let expiry: String
    let gsacard: Bool
    let name: String
    let profileid: String
    let token: String

    enum CodingKeys: String, CodingKey {
        case acctid
        case accttype
        case auoptout
        case defaultacct
        case expiry
        case gsacard
        case name
        case profileid
        case token
    }
}

struct PaymentSession {
    let id: String
    let publicKey: String
    let generationDate: Date
    var payment: PaymentData?
    var paymentMethods: [Any] // All kind of payment methods
}

extension CCProfileAccountResult {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        acctid = try values.decode(String.self, to: Int.self, forKey: .acctid)
        accttype = try values.decode(String.self, forKey: .accttype)
        auoptout = try values.decode(String.self, to: Bool.self, forKey: .auoptout)
        defaultacct = try values.decode(String.self, to: Bool.self, forKey: .defaultacct)
        expiry = try values.decode(String.self, forKey: .expiry)
        gsacard = try values.decode(String.self, to: Bool.self, forKey: .gsacard)
        name = try values.decode(String.self, forKey: .name)
        profileid = try values.decode(String.self, forKey: .profileid)
        token = try values.decode(String.self, forKey: .token)
    }
}

extension KeyedDecodingContainer {
    // swiftlint:disable identifier_name
    func decode(_ from: String.Type, to: Bool.Type, forKey key: KeyedDecodingContainer.Key) throws -> Bool {
        let boolValue = try decode(String.self, forKey: key)
        guard boolValue == "Y" else { return false }

        return true
    }

    func decode(_ from: String.Type, to: Int.Type, forKey key: KeyedDecodingContainer.Key) throws -> Int {
        let stringValue = try decode(String.self, forKey: key)
        guard let intValue = Int(stringValue) else { return 0 }

        return intValue
    }

    func decode(_ from: Int.Type, to: Bool.Type, forkey key: KeyedDecodingContainer.Key) throws -> Bool {
        let boolValue = try decode(Int.self, forKey: key)

        return (boolValue > 0)
    }
}
