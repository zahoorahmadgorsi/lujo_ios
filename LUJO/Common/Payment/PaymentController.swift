import FirebaseCrashlytics
import DefaultsKit
import Foundation

extension DefaultsKey {
    static let sessionId = Key<String>("sessionId")
    static let creditCards = Key<[PaymentMethod<CreditCardInfo>]>("creditCards")
    static let bankAccounts = Key<[PaymentMethod<BancAccountInfo>]>("bankAccounts")
}

// Payment Gateway Specific imports
import CardConnectConsumerSDK

final class PaymentController {
    public private(set) weak var delegate: PaymentControllerDelegate!
    public private(set) var paymentSession: PaymentSession?
    public private(set) var paymentMethod: Any?

    private let defaults = Defaults()
    private let paymentAPI: PaymentAPIManager!

    public init(delegate: PaymentControllerDelegate) {
        self.delegate = delegate
        paymentAPI = CCAPIManager() // Payment Gateway selected CardConnect
    }

    deinit {
        // Close any active session
    }

    // MARK: Private and internal functions

    private func dispatch(_ closure: @escaping () -> Void) {
        if Thread.isMainThread {
            closure()
        } else {
            DispatchQueue.main.async(execute: closure)
        }
    }

    private func finish(with paymentResult: PaymentResult) {
        finish(with: .success(paymentResult))
    }

    private func finish(with error: Swift.Error) {
        finish(with: .failure(error))
    }

    private func finish(with result: ResultPayment<PaymentResult>) {
        dispatch {
            self.delegate.didFinish(with: result, for: self)
        }
    }
}

extension PaymentController {
    func startSession(with payment: PaymentData) {
        guard let profileId = defaults.get(for: .sessionId) else {
            paymentSession = PaymentSession(id: "",
                                            publicKey: "",
                                            generationDate: Date(),
                                            payment: payment,
                                            paymentMethods: [])

            delegate.startNewPaymentSession { method in
                self.paymentMethod = method as Any
            }
            return
        }

        paymentAPI.requestSession(for: profileId, with: payment) { session, error in
            guard error == nil else {
                self.delegate.show("Unable to connect with payment gateway")
                return
            }

            self.paymentSession = session
            self.paymentSession?.payment = payment

            let currentMethods = self.loadPaymentMethods()
            // swiftlint:disable line_length
            var methods = [PaymentMethod<CreditCardInfo>]()

            // Merge information
            if let sessionMethods = self.paymentSession?.paymentMethods as? [PaymentMethod<CreditCardInfo>],
                let creditCardMethods = currentMethods["creditCards"] as? [PaymentMethod<CreditCardInfo>] {
                for method in sessionMethods {
                    if let savedMethod = creditCardMethods.first(where: { $0.methodInfo.cardToken == method.methodInfo.cardToken }) {
                        methods.append(PaymentMethod<CreditCardInfo>(name: method.name,
                                                                     displayName: method.displayName,
                                                                     logoURL: method.logoURL,
                                                                     currency: method.currency,
                                                                     acctId: method.acctId,
                                                                     methodInfo: CreditCardInfo(cardToken: method.methodInfo.cardToken,
                                                                                                cardNumber: savedMethod.methodInfo.cardNumber,
                                                                                                expiryDate: savedMethod.methodInfo.expiryDate,
                                                                                                codeCVV: savedMethod.methodInfo.codeCVV)))
                    }
                }
                self.paymentSession?.paymentMethods = methods
            }

            self.delegate.selectPaymentMethod(from: methods, for: self) { method in
                self.paymentMethod = method as Any
            }
        }
    }

    func encode(_ card: CardInputData) {
        paymentAPI.encodeCard(number: card.cardNumber) { cardToken, error in
            guard error == nil, let token = cardToken else {
                self.delegate.show("Error saving your credit card")
                Crashlytics.crashlytics().record(error: error!)
                return
            }
            let cardInfo = CreditCardInfo(cardToken: token,
                                          cardNumber: card.cardNumber,
                                          expiryDate: card.expiryDate,
                                          codeCVV: card.ccv2)

            let newPaymentMethod = PaymentMethod<CreditCardInfo>(name: "Credit Card",
                                                                 displayName: card.holderName,
                                                                 logoURL: "",
                                                                 currency: .dollar,
                                                                 acctId: nil,
                                                                 methodInfo: cardInfo)

            self.delegate.added(payment: newPaymentMethod, to: self.paymentSession)
        }
    }

    func performPayment(with method: PaymentMethod<CreditCardInfo>? = nil, amount: Double = 0) {
        guard let paymentMethodSelected = method ?? paymentMethod as? PaymentMethod<CreditCardInfo> else {
            delegate.show("Please select a payment method")
            return
        }

        paymentAPI.authorize(paymentSession, using: paymentMethodSelected, amount: amount) { result in
            let paymentResult: ResultPayment<PaymentResult>!

            switch result {
            case let .success(authorization):
                if let sessionId = authorization.sessionId {
                    self.defaults.set(sessionId, for: .sessionId)
                }

                var result = authorization as PaymentResult
                result.sessionId = authorization.sessionId ?? self.paymentSession?.id
                if let acctId = paymentMethodSelected.acctId {
                    result.acctid = acctId
                } else if let sessionMethods = self.paymentSession?.paymentMethods {
                    result.acctid = sessionMethods.isEmpty ? 1 : sessionMethods.count + 1
                } else {
                    result.acctid = 1
                }

                guard result.resultCode == .approved else {
                    let error = PaymentError.error(from: result.resultCode, description: result.description)
                    self.finish(with: error)
                    return
                }

                paymentResult = ResultPayment.success(result)

                let existing = self.paymentSession?.paymentMethods.contains(where: {
                    guard let current = $0 as? PaymentMethod<CreditCardInfo> else {
                        return false
                    }
                    return current == paymentMethodSelected
                })

                if existing == false {
                    self.paymentAPI.add(paymentMethodSelected, to: self.paymentSession!) { error in
                        guard error == nil else {
                            self.delegate.show("Unable to save your credit card")
                            Crashlytics.crashlytics().record(error: error!)
                            return
                        }
                        self.paymentSession?.paymentMethods.append(paymentMethodSelected as Any)

                        if let methods = self.paymentSession?.paymentMethods as? [PaymentMethod<CreditCardInfo>] {
                            self.defaults.set(methods, for: .creditCards)
                        }
                    }
                }
            case let .failure(error):
                paymentResult = ResultPayment.failure(error)
            }

            self.finish(with: paymentResult)
        }
    }

    private func loadPaymentMethods() -> [String: Any] {
        var paymentMethods = [String: Any]()

        let cards = defaults.get(for: .creditCards)
        let accounts = defaults.get(for: .bankAccounts)

        paymentMethods["creditCards"] = cards
        paymentMethods["accounts"] = accounts

        return paymentMethods
    }
}
