import Foundation
enum PaymentCurrency: String, Codable, Equatable {
    case dollar = "USD"
    case euro = "EUR"
}

struct PaymentData {
    let id: String
    let description: String
    let amount: Double
    let currency: PaymentCurrency
    let country: String
    let reference: String
    let locale: String
    let shopperReference: String

    init(id: String, description: String,
         amount: Double,
         currency: PaymentCurrency,
         country: String,
         reference: String,
         locale: String,
         shopper: String) {
        self.id = id
        self.description = description
        self.amount = amount
        self.currency = currency
        self.country = country
        self.reference = reference
        self.locale = locale
        shopperReference = shopper
    }

    func asDictionary() -> [String: Any] {
        let totalAmount = Int(amount * 1.21)
        return ["id": id,
                "description": description,
                "amountExcludingTax": Int(amount),
                "amountIncludingTax": totalAmount,
                "taxAmount": totalAmount - Int(amount),
                "taxPercentage": 2100,
                "quantity": 1,
                "taxCategory": "High"]
    }

    func buildPaymentDetails(for token: String) -> [String: Any] {
        let paymentDetails: [String: Any] = [
            "amount": [
                "currency": currency.rawValue,
                "value": Int(amount),
            ],
            "channel": "ios",
            "reference": reference,
            "token": token,
            "configuration": [
                "cardHolderName": "required",
            ],
            "returnUrl": "golujo-app://",
            "countryCode": country,
            "shopperReference": shopperReference,
            "shopperLocale": locale,
            "company": PaymentConfiguration.companyInformation.asDictionary(),
            "lineItems": [asDictionary()],
        ]

        return paymentDetails
    }
}
