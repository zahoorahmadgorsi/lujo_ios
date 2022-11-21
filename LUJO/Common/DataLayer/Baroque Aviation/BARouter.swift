import Alamofire
import FirebaseCrashlytics
import Foundation

enum BARouter: URLRequestConvertible {

    // Obtain backend URL from configuration
    static let baseURLString: String = {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "BACKEND_URL") as? String else {
            return ""
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
    
    case searchAirport(String)
    case search(AviationSearch, String)
    case authorize(BAPaymentAutorization)
    case allBookings


    func asURLRequest() throws -> URLRequest {
        var method: HTTPMethod {
            return getHTTPMethod()
        }

        let requestUrl: URL = {
            getRequestURL()
        }()

        let body: Data? = {
            getBodyData()
        }()

        var urlRequest = URLRequest(url: requestUrl)
        urlRequest.httpMethod = method.rawValue
        urlRequest.httpBody = body
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        if let token = LujoSetup().getCurrentUser()?.token{
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("Bearer \(token)")
        }
        print("urlRequest:\(String(describing: urlRequest.url))")
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
        case .allBookings:
            return .get
        }
    }

    fileprivate func getRequestURL() -> URL {
        var newURLComponents = URLComponents()
        newURLComponents.scheme = BARouter.scheme
        newURLComponents.host = BARouter.baseURLString
        newURLComponents.path = BARouter.apiVersion
        
        switch self {
        case let .searchAirport(filter):
            newURLComponents.path.append ("/baroque/aviation/airport-search")
            newURLComponents.queryItems = [
                URLQueryItem(name: "filter", value: filter)
            ]
        case .search:
            newURLComponents.path.append("/baroque/aviation/search")    //this API isnt working often on staging and many times on production
        case .authorize:
            newURLComponents.path.append("/baroque/credit-cards/authorize")
        case .allBookings:
            newURLComponents.path.append ("/bookings")
        }

        do {
            let callURL = try newURLComponents.asURL()
//            print (callURL)
            return callURL
        } catch {
            Crashlytics.crashlytics().record(error: error)
        }
//        print("https://\(BARouter.baseURLString)")
        return URL(string: "https://\(BARouter.baseURLString)")!
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
        case .allBookings:
            break
        }
        return nil
    }
}
