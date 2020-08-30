import Foundation

public struct CardConnectSetup {
    static let userName: String = {
        guard let username = Bundle.main.object(forInfoDictionaryKey: "CARDCONNECT_USERNAME") as? String else {
            return "testing"
        }

        return username
    }()

    static let password: String = {
        guard let password = Bundle.main.object(forInfoDictionaryKey: "CARDCONNECT_PASSWORD") as? String else {
            return "testing123"
        }

        return password
    }()

    static let apiURL: String = {
        guard let username = Bundle.main.object(forInfoDictionaryKey: "CARDCONNECT_URL") as? String else {
            return "fts.cardconnect.com:6443"
        }

        return username
    }()

    static let merchantID: String = {
        guard let username = Bundle.main.object(forInfoDictionaryKey: "CARDCONNECT_ID") as? String else {
            return "496160873888"
        }

        return username
    }()
}
