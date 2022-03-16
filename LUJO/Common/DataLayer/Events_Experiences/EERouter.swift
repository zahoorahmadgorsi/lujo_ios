import Alamofire
import FirebaseCrashlytics
import Foundation
import UIKit

enum EERouter: URLRequestConvertible {
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

    case home(String)
    case events(String, Bool, String?, Int?, Int?)
    case experiences(String, String?, Int?, Int?)
    case salesforce(Int, String, String?)
    case geopoint(token: String, type: String, latitude: Float, longitude: Float, radius: Int)
    case citySearch(token: String, searchTerm: String)
    case cityInfo(token: String, cityId: String)
    case villas(String, String?, Int?, Int?)
    case goods(String, String?, Int?, Int?)
    case yachts(String, String?, Int?, Int?)
    case getYachtGallery(String, Int)
    case topRated(token: String, type: String?,term: String?)   //type is villa,event etc and term is search text
    case recents(String, String?, String?)
    case perCity(String, String, String?, String?, String?, String?, String?, String?, String?, String?, String?, String?, String?, String?)
    case filters(String, String)
    
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
        }
        return urlRequest
    }

    func getHTTPMethod() -> HTTPMethod {
        switch self {
        case .home:
            return .get
        case .events:
            return .get
        case .experiences:
            return .get
        case .salesforce:
            return .post
        case .geopoint:
            return .post
        case .citySearch:
            return .get
        case .cityInfo:
            return .get
        case .villas:
            return .get
        case .goods:
            return .get
        case .yachts:
            return .get
        case .getYachtGallery:
            return .get
        case .topRated:
            return .post
        case .recents:
            return .get
        case .perCity:
            return .get
        case .filters:
            return .post
        }
    }

    fileprivate func getRequestURL() -> URL {
        var newURLComponents = URLComponents()
        newURLComponents.scheme = EERouter.scheme
        newURLComponents.host = EERouter.baseURLString
        newURLComponents.path = EERouter.apiVersion

        switch self {
            case let .home(token):
                newURLComponents.path.append("/home")
                newURLComponents.queryItems = [
                    URLQueryItem(name: "token", value: token),
                ]
            case let .events(token, past, term, cityId, productId):
                newURLComponents.path.append("/events")
                newURLComponents.queryItems = [
                    URLQueryItem(name: "token", value: token),
                ]
                if past {
                    newURLComponents.queryItems?.append(URLQueryItem(name: "show_past", value: "true"))
                }
                if let term = term {
                    newURLComponents.queryItems?.append(URLQueryItem(name: "search", value: term))
                }
                if let cityId = cityId {
                    newURLComponents.queryItems?.append(URLQueryItem(name: "location", value: "\(cityId)"))
                }
                if let id = productId {
                    newURLComponents.queryItems?.append(URLQueryItem(name: "id", value: "\(id)"))
                }
            case let .experiences(token, term, cityId, productId):
                newURLComponents.path.append("/experiences")
                newURLComponents.queryItems = [
                    URLQueryItem(name: "token", value: token),
                ]
                if let term = term {
                    newURLComponents.queryItems?.append(URLQueryItem(name: "search", value: term))
                }
                if let cityId = cityId {
                    newURLComponents.queryItems?.append(URLQueryItem(name: "location", value: "\(cityId)"))
                }
                if let id = productId {
                    newURLComponents.queryItems?.append(URLQueryItem(name: "id", value: "\(id)"))
                }
            case let .villas(token, term, cityId, productId):
                newURLComponents.path.append("/villas")
                newURLComponents.queryItems = [
                    URLQueryItem(name: "token", value: token),
                ]
                if let term = term {
                    newURLComponents.queryItems?.append(URLQueryItem(name: "search", value: term))
                }
                if let cityId = cityId {
                    newURLComponents.queryItems?.append(URLQueryItem(name: "location", value: "\(cityId)"))
                }
                if let id = productId {
                    newURLComponents.queryItems?.append(URLQueryItem(name: "id", value: "\(id)"))
                }
                newURLComponents.queryItems?.append(URLQueryItem(name: "per_page", value: "\(20)"))
            case let .goods(token, term, category_term_id, productId):
                if (category_term_id ?? 0 > 0){ //because category_term_id isnt working on /gifts API and backend developer rather then fixing it created new API
                    //newURLComponents.path.append("/gifts/per-category")
                    newURLComponents.path.append("/gifts")
                    
                    if let categoryTermId = category_term_id {
                        newURLComponents.queryItems?.append(URLQueryItem(name: "gift_category", value: "\(categoryTermId)"))
                    }
                    
                    
                }else{
                    newURLComponents.path.append("/gifts")        //its response format is [Product]
                    newURLComponents.queryItems?.append(URLQueryItem(name: "per_page", value: "\(20)"))
                    
                    newURLComponents.queryItems = [
                        URLQueryItem(name: "token", value: token),
                    ]
                    if let term = term {
                        newURLComponents.queryItems?.append(URLQueryItem(name: "search", value: term))
                    }
                    if let categoryTermId = category_term_id {
                        //newURLComponents.queryItems?.append(URLQueryItem(name: "category_term_id", value: "\(categoryTermId)"))
                        newURLComponents.queryItems?.append(URLQueryItem(name: "gift_category", value: "\(categoryTermId)"))
                    }
                    if let id = productId {
                        newURLComponents.queryItems?.append(URLQueryItem(name: "id", value: "\(id)"))
                    }
                }
            
                
            case let .yachts(token, term, cityId, productId):
                newURLComponents.path.append("/yachts")
                newURLComponents.queryItems = [
                    URLQueryItem(name: "token", value: token),
                ]
                if let term = term {
                    newURLComponents.queryItems?.append(URLQueryItem(name: "search", value: term))
                }
                if let cityId = cityId {
                    newURLComponents.queryItems?.append(URLQueryItem(name: "location", value: "\(cityId)"))
                }
                if let id = productId {
                    newURLComponents.queryItems?.append(URLQueryItem(name: "id", value: "\(id)"))
                }
                newURLComponents.queryItems?.append(URLQueryItem(name: "per_page", value: "\(20)"))
                
            case let .getYachtGallery(token, postId):
                newURLComponents.path.append("/yachts/photos")
                newURLComponents.queryItems = [
                    URLQueryItem(name: "token", value: token),
                    URLQueryItem(name: "post_id", value: "\(postId)")
                ]
            case let .recents(token, limit, type):
                newURLComponents.path.append("/recent")
                
                newURLComponents.queryItems = [
                    URLQueryItem(name: "token", value: token),
                ]
                if let limit = limit {
                    newURLComponents.queryItems?.append(URLQueryItem(name: "limit", value: limit))
                }
                if let type = type {
                    newURLComponents.queryItems?.append(URLQueryItem(name: "type", value: type))
                }
            case .topRated:  //its a POST
                newURLComponents.path.append("/top-rated")
                
            case .salesforce:
                newURLComponents.path.append("/request")

            case .geopoint:
                newURLComponents.path.append("/geopoint")
            
            case let .citySearch(token, searchTerm):
                newURLComponents.path.append("/search-cities")
                newURLComponents.queryItems = [
                    URLQueryItem(name: "token", value: token),
                    URLQueryItem(name: "search", value: searchTerm)
                ]
                
            case let .cityInfo(token, cityId):
                newURLComponents.path.append("/discover")
                newURLComponents.queryItems = [
                    URLQueryItem(name: "token", value: token),
                    URLQueryItem(name: "place_id", value: cityId)
                ]
            case let .perCity(token, type, yachtName, yachtCharter, yachtGuests, yachtLengthFeet, yachtLengthMeters, yachtType, yachtBuiltAfter, yachtTag, yachtStatus, region, minPrice, MaxPrice):
                newURLComponents.queryItems = [
                    URLQueryItem(name: "token", value: token),
                ]
                
                if (type.equals(rhs: "gift")){
                    //newURLComponents.path.append("/gifts/per-category")
                    newURLComponents.path.append("/gifts")
                }else{
                    newURLComponents.path.append("/per-city")
                    newURLComponents.queryItems?.append(URLQueryItem(name: "type", value: type))
                    if let filter = yachtName , filter.count > 0 {
                        newURLComponents.queryItems?.append(URLQueryItem(name: "yacht_name", value: filter))
                    }
                    if let filter = yachtCharter , filter.count > 0{
                        newURLComponents.queryItems?.append(URLQueryItem(name: "charter_term_id", value: filter))
                    }
                    if let filter = yachtGuests , filter.count > 0{
                        newURLComponents.queryItems?.append(URLQueryItem(name: "guests", value: filter))
                    }
                    if let filter = yachtLengthFeet , filter.count > 0{
                        newURLComponents.queryItems?.append(URLQueryItem(name: "length_feet_term_id", value: filter))
                    }
                    if let filter = yachtLengthMeters , filter.count > 0{
                        newURLComponents.queryItems?.append(URLQueryItem(name: "length_meter_term_id", value: filter))
                    }
                    if let filter = yachtType , filter.count > 0{
                        newURLComponents.queryItems?.append(URLQueryItem(name: "type_term_id", value: filter))
                    }
                    if let filter = yachtBuiltAfter , filter.count > 0{
                        newURLComponents.queryItems?.append(URLQueryItem(name: "build_year", value: filter))
                    }
                    if let filter = yachtTag , filter.count > 0{
                        newURLComponents.queryItems?.append(URLQueryItem(name: "lujo_tag_term_id", value: filter))
                    }
                    if let filter = yachtStatus , filter.count > 0{
                        newURLComponents.queryItems?.append(URLQueryItem(name: "yacht_status", value: filter))
                    }
                    if let filter = region , filter.count > 0{
                        newURLComponents.queryItems?.append(URLQueryItem(name: "region_term_id", value: filter))
                    }
                    
                    if let filter = minPrice , filter.count > 0{
                        newURLComponents.queryItems?.append(URLQueryItem(name: "min_price", value: filter))
                    }
                    if let filter = MaxPrice , filter.count > 0{
                        newURLComponents.queryItems?.append(URLQueryItem(name: "max_price", value: filter))
                    }
                }
            case .filters:
                newURLComponents.path.append("/filters")
        }
        
        do {
            let callURL = try newURLComponents.asURL()
//            print (callURL)
            return callURL
        } catch {
            Crashlytics.crashlytics().record(error: error)
        }
//        print("https://\(EERouter.baseURLString)")
        return URL(string: "https://\(EERouter.baseURLString)")!
    }

    fileprivate func getBodyData() -> Data? {
        switch self {
        case .home:
            return nil
        case .events:
            return nil
        case .experiences:
            return nil
        case .villas:
            return nil
        case .goods:
            return nil
        case .yachts:
            return nil
        case.getYachtGallery:
            return nil
        case let .topRated(token,type,term):
            return getTopRatedDataAsJSONData(token: token, type: type, term:term )
        case .recents:
            return nil
        case let .salesforce(itemId, token, channelID):
            return getSalesforceDataAsJSONData(itemId: itemId, token: token, channelId: channelID)
        case let .geopoint(token, type, latitude, longitude, _):
            return getGeopointDataAsJSONData(type: type, latitude: latitude, longitude: longitude, token: token)
        case .citySearch:
            return nil
        case .cityInfo:
            return nil
        case .perCity:
            return nil
        case let .filters(token, type):
            return getFiltersDataAsJSONData(type: type, token: token)
        }
    }
    
    fileprivate func getTopRatedDataAsJSONData(token: String, type: String?, term:String? ) -> Data? {
        var body: [String: Any] = [
            "token": token
        ]
        if let type = type , !type.isEmpty {    //type wont contain nil but empty string if viewing topRate yachts, event, gifts
            body["type"] = type
        }
        if let term = term {
            body["search"] = term
        }
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func getGeopointDataAsJSONData(type: String, latitude: Float, longitude: Float, token: String) -> Data? {
        let body: [String: Any] = [
            "type": type,
            "latitude": latitude,
            "longitude": longitude,
            "token": token
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func getSalesforceDataAsJSONData(itemId: Int, token: String, channelId: String?) -> Data? {
        var body: [String: Any] = [
            "item_id": itemId,
            "token": token
        ]
        if let channelId = channelId {
            body["channelId"] = channelId
        }
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func getFiltersDataAsJSONData(type: String, token: String) -> Data? {
        let body: [String: Any] = [
            "type": type,
            "token": token
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
}
