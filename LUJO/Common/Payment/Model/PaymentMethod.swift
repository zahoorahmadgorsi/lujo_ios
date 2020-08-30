import Foundation

public struct CreditCardInfo: Codable, Equatable {
    let cardToken: String
    let cardNumber: String
    let expiryDate: String
    let codeCVV: Int

    // swiftlint:disable identifier_name
    enum CardRegex: String {
        case visa = "^4[0-9]{6,}$"
        case master = "^5[1-5][0-9]{5,}|222[1-9][0-9]{3,}|22[3-9][0-9]{4,}|2[3-6][0-9]{5,}|27[01][0-9]{4,}|2720[0-9]{3,}$"
        case amex = "^3[47][0-9]{5,}$"
        case diners = "^3(?:0[0-5]|[68][0-9])[0-9]{4,}$"
        case discover = "^6(?:011|5[0-9]{2})[0-9]{3,}$"
        case jcb = "^(?:2131|1800|35[0-9]{3})[0-9]{3,}$"
        case maestro = "^(5[06789]|6)[0-9]{0,}$"
    }

    var cardType: String {
        switch cardNumber {
        case Regex(pattern: CardRegex.visa.rawValue):
            return "visa"
        case Regex(pattern: CardRegex.master.rawValue):
            return "mastercard"
        case Regex(pattern: CardRegex.amex.rawValue):
            return "amex"
        case Regex(pattern: CardRegex.diners.rawValue):
            return "diners"
        case Regex(pattern: CardRegex.discover.rawValue):
            return "discover"
        case Regex(pattern: CardRegex.jcb.rawValue):
            return "jcb"
        case Regex(pattern: CardRegex.maestro.rawValue):
            return "maestro"
        default:
            return "credit"
        }
    }

    var cardLogo: String {
        return "https://www.merchantequip.com/image/?bgcolor=FFFFFF&logos=\(cardType)&height=32"
    }
}

public struct BancAccountInfo: Codable, Equatable {
    let bancName: String
    let IBAN: String
}

public struct PaymentMethod<T: Codable>: Codable, Equatable where T: Equatable {
    let name: String
    let displayName: String
    let logoURL: String
    let currency: PaymentCurrency
    let acctId: Int?
    let methodInfo: T
}

private extension Regex {}
