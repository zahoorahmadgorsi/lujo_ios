import Foundation

public struct PaymentSessionToken {
    let token: String
    let encoded: String

    init() {
        token = "Generate new token"
        let data = token.data(using: .utf8, allowLossyConversion: true)
        encoded = data!.base64EncodedString()
    }
}
