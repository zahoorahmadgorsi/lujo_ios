import Foundation

enum PaymentError: Error, Equatable {
    case declined(description: String)
    case retry(description: String)
    case unknown(description: String)

    static func error(from status: PaymentStatus, description text: String) -> PaymentError {
        switch status {
        case .declined:
            return .declined(description: text)
        case .retry:
            return .retry(description: text)
        case .unknown:
            return .unknown(description: text)
        default:
            return .unknown(description: "Not an error")
        }
    }
}

extension PaymentError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .declined(description):
            return NSLocalizedString(description, comment: "PaymentError")
        case let .retry(description):
            return NSLocalizedString(description, comment: "PaymentError")
        case let .unknown(description):
            return NSLocalizedString(description, comment: "PaymentError")
        }
    }
}

enum PaymentStatus: Int, Codable {
    case approved = 0
    case declined = 1
    case retry = 2
    case unknown = 3
}

protocol PaymentResult: Codable {
    var sessionId: String? { get set }
    var resultCode: PaymentStatus { get }
    var reference: String { get }
    var account: String { get }
    var token: String? { get }
    var amount: Double { get }
    var sellerReference: String { get }
    var description: String { get }
    var acctid: Int? { get set }
}

struct CCCardEncodeResponse: Codable {
    let action: String
    let data: String
}

struct CCAuthorizationResult: PaymentResult, Codable {
    let resultCode: PaymentStatus
    let reference: String
    let account: String
    var acctid: Int?
    let token: String?
    let amount: Double
    let sellerReference: String
    var sessionId: String?
    let respCode: String
    let description: String
    let respProc: String
    let binType: String?
    let entryMode: String?

    let avsResponse: String?
    let cvvResponse: String?
    let authCode: String?
    let signature: String?
    let commCard: String?
    let emvCryptogram: String?
    let emvTagData: String?

    enum CodingKeys: String, CodingKey {
        case resultCode = "respstat"
        case reference = "retref"
        case account
        case acctid
        case token
        case amount
        case sellerReference = "merchid"
        case sessionId = "profileid"
        case respCode = "respcode"
        case description = "resptext"
        case respProc = "respproc"
        case binType = "bintype"
        case entryMode = "entrymode"

        case avsResponse = "avsresp"
        case cvvResponse = "cvvresp"
        case authCode = "authcode"
        case signature
        case commCard = "commcard"
        case emvCryptogram = "emv"
        case emvTagData
    }
}

extension CCAuthorizationResult {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let statusCode = try values.decode(String.self, forKey: .resultCode)
        switch statusCode {
        case "A":
            resultCode = .approved
        case "C":
            resultCode = .declined
        case "B":
            resultCode = .retry
        default:
            resultCode = .unknown
        }

        reference = try values.decode(String.self, forKey: .reference)
        account = try values.decode(String.self, forKey: .account)
        acctid = try? values.decode(Int.self, forKey: .acctid)
        token = try? values.decode(String.self, forKey: .token)

        let amountStr = try values.decode(String.self, forKey: .amount)
        amount = Double(amountStr) ?? 0.0

        sellerReference = try values.decode(String.self, forKey: .sellerReference)
        sessionId = try? values.decode(String.self, forKey: .sessionId)
        respCode = try values.decode(String.self, forKey: .respCode)
        description = try values.decode(String.self, forKey: .description)
        respProc = try values.decode(String.self, forKey: .respProc)
        binType = try? values.decode(String.self, forKey: .binType)
        entryMode = try? values.decode(String.self, forKey: .entryMode)

        avsResponse = try? values.decode(String.self, forKey: .avsResponse)
        cvvResponse = try? values.decode(String.self, forKey: .cvvResponse)
        authCode = try? values.decode(String.self, forKey: .authCode)
        signature = try? values.decode(String.self, forKey: .signature)
        commCard = try? values.decode(String.self, forKey: .entryMode)
        emvCryptogram = try? values.decode(String.self, forKey: .entryMode)
        emvTagData = try? values.decode(String.self, forKey: .entryMode)
    }
}
