import Alamofire
import Crashlytics

class CCAPIManager: PaymentAPIManager {
    // swiftlint:disable line_length
    func requestSession(for token: String, with payment: PaymentData, completion: @escaping (PaymentSession?, Error?) -> Void) {
        Alamofire.request(CCRouter.session(token)).responseJSON { response in

            let (data, error) = self.checkErrors(response)
            guard error == nil, data != nil else {
                completion(nil, error)
                return
            }

            var session: PaymentSession?

            guard let result = try? JSONDecoder().decode([CCProfileAccountResult].self, from: data!) else {
                completion(nil, CCError.badFormattedResponse)
                return
            }

            var methodsList = [PaymentMethod<CreditCardInfo>]()
            var profileId = ""

            for method in result {
                if profileId == "" { profileId = method.profileid }
                let paymentMethod = PaymentMethod<CreditCardInfo>(
                    name: method.accttype,
                    displayName: method.name,
                    logoURL: "",
                    currency: .dollar,
                    acctId: method.acctid,
                    methodInfo: CreditCardInfo(cardToken: method.token,
                                               cardNumber: "",
                                               expiryDate: method.expiry,
                                               codeCVV: 0)
                )
                methodsList.append(paymentMethod)
            }

            session = PaymentSession(id: profileId,
                                     publicKey: "",
                                     generationDate: Date(),
                                     payment: nil,
                                     paymentMethods: methodsList)

            completion(session, nil)
        }
    }

    func encodeCard(number: String, completion: @escaping (String?, Error?) -> Void) {
        Alamofire.request(CCRouter.cardEncode(number)).responseString { response in
            let (data, error) = self.checkErrors(response)
            guard error == nil, data != nil else {
                self.logError(error: error!,
                              response: data,
                              description: "CardConnect Encode Card Error",
                              reason: "Either error or emtpy response")
                completion("", error!)
                return
            }

            guard let jsonContent = response.result.value?.slice(from: "(", to: ")") else {
                self.logError(error: CCError.badFormattedResponse,
                              response: data,
                              description: "CardConnect Encode Card Error",
                              reason: "Json does not contain parenthesis")
                completion("", CCError.badFormattedResponse)
                return
            }

            guard let result = try? JSONDecoder().decode(CCCardEncodeResponse.self, from: jsonContent.data(using: .utf8)!) else {
                self.logError(error: CCError.badFormattedResponse,
                              response: data,
                              description: "CardConnect Encode Card Error",
                              reason: "Unable to parse response")
                completion("", CCError.badFormattedResponse)
                return
            }

            completion(result.data, nil)
        }
    }

    func authorize(_ session: PaymentSession?, using method: PaymentMethod<CreditCardInfo>, amount: Double = 0.0,
                   completion: @escaping (ResultPayment<CCAuthorizationResult>) -> Void) {
        let authorizationAmount = session?.payment?.amount ?? amount

        Alamofire.request(CCRouter.authorize(session, method, authorizationAmount)).responseJSON { response in
            let (data, error) = self.checkErrors(response)
            guard error == nil, data != nil else {
                self.logError(error: error!,
                              response: data,
                              description: "Authorize Session at CardConnect Error",
                              reason: "Either error reported or emtpty response",
                              otherInfo: response.request)
                completion(ResultPayment.failure(error!))
                return
            }

            guard let result = try? JSONDecoder().decode(CCAuthorizationResult.self, from: data!) else {
                self.logError(error: CCError.badFormattedResponse,
                              response: data,
                              description: "Authorize Session at CardConnect Error",
                              reason: "Unable to parse response")
                completion(ResultPayment.failure(CCError.badFormattedResponse))
                return
            }

            completion(ResultPayment.success(result))
        }
    }

    func add(_ card: PaymentMethod<CreditCardInfo>, to session: PaymentSession, completion: @escaping (Error?) -> Void) {
        Alamofire.request(CCRouter.addMethod(session, card)).responseJSON { response in
            guard response.error == nil else {
                self.logError(error: response.error!,
                              response: response.data,
                              description: "Add card to CardConnect",
                              reason: "Reported error")
                completion(response.error)
                return
            }
            completion(nil)
        }
    }
}

extension CCAPIManager {
    func checkErrors<T>(_ response: Alamofire.DataResponse<T>) -> (Data?, Error?) {
        guard response.result.error == nil else {
            logError(error: response.result.error!,
                     response: response.data,
                     description: "Check Error",
                     reason: "Unable to parse response")

            return (nil, response.result.error)
        }

        guard (200 ... 299).contains(response.response!.statusCode) else {
            logError(error: CCError.unexpectedStatusCode(response.response!.statusCode),
                     response: response.data,
                     description: "Check Error",
                     reason: "Response code not valid \(response.response!.statusCode)")
            return (nil, CCError.unexpectedStatusCode(response.response!.statusCode))
        }

        guard let data = response.data else {
            logError(error: CCError.emptyResponse,
                     response: nil,
                     description: "Check Error",
                     reason: "Empty response")
            return (nil, CCError.emptyResponse)
        }

        return (data, nil)
    }

    private func logError(error: Error, response: Data?, description: String, reason: String, otherInfo: Any? = nil) {
        let responseStr = response == nil ? "" : String(decoding: response!, as: UTF8.self)
        var userInfo: [String: Any] = [
            NSLocalizedDescriptionKey: description,
            NSLocalizedFailureReasonErrorKey: reason,
            "response": responseStr,
        ]

        if let extraInfo = otherInfo {
            userInfo["otherInfo"] = extraInfo
        }

        Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: userInfo)
    }
}

extension CCAPIManager {
    enum CCError: Error {
        case invalidToken
        case unexpectedStatusCode(Int)
        case emptyResponse
        case badFormattedResponse
    }
}
