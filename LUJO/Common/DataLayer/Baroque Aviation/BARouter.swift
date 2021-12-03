import Alamofire
import FirebaseCrashlytics
import Foundation

enum BARouter: URLRequestConvertible {
    static let baseURLString: String = {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "BACKEND_URL") as? String else {
            return "https://"
        }
        return urlString
    }()

    static let apiVersion: String = {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "BACKEND_API_VERSION") as? String else {
            return ""
        }
        return "/" + urlString
    }()

    static let scheme: String = {
        guard let scheme = Bundle.main.object(forInfoDictionaryKey: "BACKEND_SCHEME") as? String else {
            return "https"
        }
        return scheme
    }()

    case searchAirport(String, String)
    case search(AviationSearch, String)
    case authorize(BAPaymentAutorization)
    case bookings(BookingType, String)
    case allBookings(String)

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

        return urlRequest
    }
}

extension BARouter {
    fileprivate func getHTTPMethod() -> HTTPMethod {
        switch self {
        case .searchAirport:
            return .get
        case .search:
            return .post
        case .authorize:
            return .post
        case .bookings:
            return .get
        case .allBookings:
            return .get
        }
    }

    fileprivate func getRequestURL() -> URL {
        var newURLComponents = URLComponents()
        newURLComponents.scheme = BARouter.scheme
        newURLComponents.host = BARouter.baseURLString
        newURLComponents.path = BARouter.apiVersion

        addQueryItems(to: &newURLComponents)

        do {
            print(try newURLComponents.asURL())
            return try newURLComponents.asURL()
        } catch {
            Crashlytics.crashlytics().record(error: error)
        }
//        print("https://\(BARouter.baseURLString)")a
        return URL(string: "https://\(BARouter.baseURLString)")!
    }

    fileprivate func addQueryItems(to components: inout URLComponents) {
        switch self {
        case let .searchAirport(filter, token):
            components.path = "/baroque/aviation/airport-search"
            components.queryItems = [
                URLQueryItem(name: "filter", value: filter),
                URLQueryItem(name: "token", value: token),
            ]
        case .search:
            components.path = "/baroque/aviation/search"    //this API isnt working often on staging and many times on production
        case .authorize:
            components.path = "/baroque/credit-cards/authorize"
        case let .bookings(type, token):
            components.path = "/baroque/aviation"
            if type != .trip { components.path.append("/booking-requests") }
            components.path.append("/\(type.rawValue)")
            components.queryItems = [
                URLQueryItem(name: "token", value: token),
            ]
        case let .allBookings(token):
            components.path = "/bookings"
            components.queryItems = [
                URLQueryItem(name: "token", value: token)
            ]
        }
    }

    fileprivate func getBodyData() -> Data? {
        switch self {
        case .searchAirport:
            break
        case let .search(criteria, token):

            guard var searchCriteria = criteria.asDictionary() else {
                fatalError("Error on parsing search criteria")
            }

            searchCriteria["token"] = token

            do {
                let data = try JSONSerialization.data(withJSONObject: searchCriteria, options: [])
//                let dataString = String(data: data, encoding: .utf8)!
//                print(dataString)
                return data
//                return try JSONSerialization.data(withJSONObject: searchCriteria, options: [])
            } catch {
                fatalError(error.localizedDescription)
            }
        case let .authorize(authorization):
            do {
                return try JSONEncoder().encode(authorization)
            } catch {
                print(error)
            }
        case .bookings:
            break
        case .allBookings:
            break
        }
        return nil
    }
}
