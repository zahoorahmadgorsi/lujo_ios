import Alamofire
import FirebaseCrashlytics
import Foundation

enum CCRouter: URLRequestConvertible {
    private static let userName: String = {
        guard let username = Bundle.main.object(forInfoDictionaryKey: "CARDCONNECT_USERNAME") as? String else {
            return "testing"
        }

        return username
    }()

    private static let password: String = {
        guard let password = Bundle.main.object(forInfoDictionaryKey: "CARDCONNECT_PASSWORD") as? String else {
            return "testing123"
        }

        return password
    }()

    private static let authorization: String = {
        let authInfo = "\(CCRouter.userName):\(CCRouter.password)"
        let utf8str = authInfo.data(using: .utf8)

        guard let base64Auth = utf8str?.base64EncodedString() else {
            return ""
        }

        return "Basic \(base64Auth)"
    }()

    private static let merchantId: String = {
        guard let merchantId = Bundle.main.object(forInfoDictionaryKey: "CARDCONNECT_ID") as? String else {
            return "496160873888"
        }

        return merchantId
    }()

    private static let baseURLHost: String = {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "CARDCONNECT_URL") as? String else {
            return "fts.cardconnect.com"
        }
        return urlString
    }()

    private static let baseURLPort: Int = {
        guard let stPort = Bundle.main.object(forInfoDictionaryKey: "CARDCONNECT_PORT") as? String,
            let port = Int(stPort) else {
            return 6443
        }
        return port
    }()

    private static let baseURLPath: String = {
        "/cardconnect/rest"
    }()

    case session(String)
    case profile(Int, Int?)
    case cardEncode(String)
    case authorize(PaymentSession?, PaymentMethod<CreditCardInfo>, Double?)
    case addMethod(PaymentSession, PaymentMethod<CreditCardInfo>)

    func asURLRequest() throws -> URLRequest {
        let method: HTTPMethod = {
            getHTTPMethod()
        }()

        let requestURL: URL = {
            getRequestURL()
        }()

        let body: Data? = {
            getBodyData()
        }()

        var urlRequest = URLRequest(url: requestURL)
        urlRequest.httpMethod = method.rawValue
        urlRequest.httpBody = body
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(CCRouter.authorization, forHTTPHeaderField: "Authorization")
//        if let token = LujoSetup().getCurrentUser()?.token{
//            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        }
        urlRequest.print()
        return urlRequest
    }
}

extension CCRouter {
    fileprivate func getHTTPMethod() -> HTTPMethod {
        switch self {
        case .session:
            return .get
        case .profile:
            return .get
        case .cardEncode:
            return .get
        case .authorize:
            return .put
        case .addMethod:
            return .put
        }
    }

    fileprivate func getRequestURL() -> URL {
        var newURLComponents = URLComponents()
        newURLComponents.scheme = "https"
        newURLComponents.host = CCRouter.baseURLHost
        newURLComponents.port = CCRouter.baseURLPort  //making it same as android by removing port zahoor
        newURLComponents.path = CCRouter.baseURLPath

        switch self {
        case let .session(profileId):
            let profileIdStr = String(profileId)

            newURLComponents.path.append("/profile/\(profileIdStr)/\(CCRouter.merchantId)")
        case let .profile(profileId, accId):
            let profileIdStr = String(profileId)
            let accIdStr = accId == nil ? "" : String(accId!)

            newURLComponents.path.append("/profile/\(profileIdStr)/\(accIdStr)/\(CCRouter.merchantId)")
        case let .cardEncode(cardNumber):
            newURLComponents.path = "/cardsecure/cs"
            newURLComponents.queryItems = [
                URLQueryItem(name: "action", value: "CE"),
                URLQueryItem(name: "data", value: cardNumber),
                URLQueryItem(name: "type", value: "json"),
            ]
        case .authorize:
            newURLComponents.path.append("/auth")
        case .addMethod:
            newURLComponents.path.append("/profile")
        }

        do {
            print(newURLComponents)
            return try newURLComponents.asURL()
        } catch {
            Crashlytics.crashlytics().record(error: error)
        }

        return URL(string: "https://\(CCRouter.baseURLHost)")!
    }

    fileprivate func buildAuthorizeData(_ data: inout [String: Any]?,
                                        _ amountVal: Double,
                                        _ method: PaymentMethod<CreditCardInfo>, _ session: PaymentSession?) {
        data = [
            "merchid": String(CCRouter.merchantId),
            "amount": String(amountVal.roundTo(places: 2)),
            "expiry": method.methodInfo.expiryDate,
            "account": method.methodInfo.cardToken,
            "currency": method.currency.rawValue
            ,"profile": session?.id == "" ? "Y" : "N",
            "tokenize": "Y",
            "ccv2": String(method.methodInfo.codeCVV),
            "name": method.displayName,
            "ecomind": "E",
        ]
    }

    fileprivate func buildAddMethodData(_ data: inout [String: Any]?,
                                        _ session: PaymentSession, _ method: PaymentMethod<CreditCardInfo>) {
        data = [
            "merchid": String(CCRouter.merchantId),
            "profile": session.id,
            "defaultacct": "N",
            "profileupdate": "Y",
            "account": method.methodInfo.cardToken,
            "expiry": method.methodInfo.expiryDate,
            "name": method.displayName,
        ]
    }

    fileprivate func getBodyData() -> Data? {
        var data: [String: Any]?

        switch self {
        case .session:
            break
        case .profile:
            break
        case .cardEncode:
            break
        case let .authorize(session, method, amount):
            let amountVal = session?.payment?.amount ?? (amount ?? 0)
            buildAuthorizeData(&data, amountVal, method, session)

            if method.acctId != nil {
                data!["acctid"] = method.acctId
            } else {
                let methods = session?.paymentMethods ?? [Any]()
                if !methods.isEmpty {
                    data!["acctid"] = methods.count + 1
                }
            }
        case let .addMethod(session, method):
            buildAddMethodData(&data, session, method)
        }

        guard let bodyData = data else { return nil }

        do {
            return try JSONSerialization.data(withJSONObject: bodyData, options: [])
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

extension CCRouter {
    enum Error: Swift.Error {
        case malformedProfileId
    }
}
