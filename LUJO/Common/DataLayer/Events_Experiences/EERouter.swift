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
    case events(Bool, String?, String?, String?)
    case experiences( String?, String?, String?)
    case salesforce(String, String, String?)
    case geopoint(type: String, latitude: Float, longitude: Float)
    case citySearch(token: String, searchTerm: String)
    case cityInfo(token: String, cityId: String)
    case villas(String, String?, String?, String?)
    case goods(String?, String?, String?)
    case yachts(String, String?, String?, String?)
    case getYachtGallery(String, String)
    case topRated(type: String?,term: String?)   //type is villa,event etc and term is search text
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
        print("urlRequest:\(String(describing: urlRequest.url))")
        return urlRequest
    }

    func getHTTPMethod() -> HTTPMethod {
        switch self {
        case .home:
            return .get
        case let .events(_, _, _, id):
            if let id = id , id.count > 0 {  //if event is search by id then user different API
                return .get
            }else{
                return .post
            }
        case let .experiences(_, _, id):
            if let id = id , id.count > 0 {  //if event is search by id then user different API
                return .get
            }else{
                return .post
            }
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
        case let .goods(_, giftCategoryId, id):
            if let id = id , id.count > 0 {  //if event is search by id then user different API
                return .get
            }else if let id = giftCategoryId , id.count > 0 {  //if event is search by id then user different API
                return .get
            }
            else{
                return .post
            }
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
            case let .events(_, _, _, id):
                if let productId = id , !productId.isEmpty {  //if event is search by id then user different API
                        newURLComponents.path.append("/events/detail/" + productId)
                }else{
                    newURLComponents.path.append("/events/search")
                }
            case let .experiences(_, _, id):
                if let productId = id , !productId.isEmpty {  //if event is search by id then user different API
                        newURLComponents.path.append("/experiences/detail/" + productId)
                    }else{
                        newURLComponents.path.append("/experiences/search")
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
            case let .goods( _, gift_category_id, id):
                if let giftId = id , !giftId.isEmpty {  //if gift is search by giftId then user different API (called when push notificatino is receveid )
                        newURLComponents.path.append("/gifts/detail/" + giftId)
                }else if let giftCategoryId = gift_category_id , !giftCategoryId.isEmpty {  //if gift is search by categoryid, when user has tapped on seeAll button of a particular category on gifts by category view screen (percity)
                    newURLComponents.path.append("/gifts/per-category")
                    newURLComponents.queryItems = [
                        URLQueryItem(name: "category_id", value: giftCategoryId),
                    ]
                }else{
                    newURLComponents.path.append("/gifts/search")
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

        case let .geopoint(type,_,_):
            if type == "event"{
                newURLComponents.path.append("/events/search")
            }else if type == "restaurant"{
                newURLComponents.path.append("/restaurants/search")
            }
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
                
                if (type.equals(rhs: "gift")){
                    newURLComponents.path.append("/gifts/per-category")
//                    newURLComponents.path.append("/gifts")
                }else{
                    newURLComponents.path.append("/per-city")
                    newURLComponents.queryItems = [
                        URLQueryItem(name: "type", value: type),
                    ]
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
        case let .events(past, search, location, id):
            if let id = id , id.count > 0 {  //if event is search by id then user different API
                return nil
            }else{
                return getEventsSearchDataAsJSONData(past, search, location)
            }
        case let .experiences(search, location, id):
            if let id = id , id.count > 0 {  //if event is search by id then user different API
                return nil
            }else{
                return getExperiencesSearchDataAsJSONData(search, location)
            }
            
        case .villas:
            return nil
        case let .goods(search, giftCategoryId, id):
            if let id = id , id.count > 0 {  //if event is search by id then user different API
                return nil
            }else if let id = giftCategoryId , id.count > 0 {  //if event is search by id then user different API
                return nil
            }else{
                return getGoodsSearchDataAsJSONData(search)
            }
            
        case .yachts:
            return nil
        case.getYachtGallery:
            return nil
        case let .topRated(type,term):
            return getTopRatedDataAsJSONData( type: type, term:term )
        case .recents:
            return nil
        case let .salesforce(itemId, token, channelID):
            return getSalesforceDataAsJSONData(itemId: itemId, token: token, channelId: channelID)
        case let .geopoint(_, latitude, longitude):
            return getGeopointDataAsJSONData(latitude: latitude, longitude: longitude)
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
    
    fileprivate func getEventsSearchDataAsJSONData(_ past: Bool, _ search: String?, _ location:String?) -> Data? {
        var body: [String: Any] = [:]
        if let search = search , !search.isEmpty {    //type wont contain nil but empty string if viewing topRate yachts, event, gifts
            body["search"] = search
        }
        if let location = location, !location.isEmpty  {
            body["location"] = location
        }
        if past{
            body["show_past"] = true
        }
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func getExperiencesSearchDataAsJSONData(_ search: String?, _ location:String?) -> Data? {
        var body: [String: Any] = [:]
        if let search = search , !search.isEmpty {    //type wont contain nil but empty string if viewing topRate yachts, event, gifts
            body["search"] = search
        }
        if let location = location, !location.isEmpty  {
            body["location"] = location
        }
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func getGoodsSearchDataAsJSONData(_ search: String?) -> Data? {
        var body: [String: Any] = [:]
        if let search = search , !search.isEmpty {    //type wont contain nil but empty string if viewing topRate yachts, event, gifts
            body["search"] = search
        }
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func getTopRatedDataAsJSONData( type: String?, term:String? ) -> Data? {
        var body: [String: Any] = [:]
        if let type = type , !type.isEmpty {    //type wont contain nil but empty string if viewing topRate yachts, event, gifts
            body["type"] = type
        }
        if let term = term {
            body["search"] = term
        }
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func getGeopointDataAsJSONData( latitude: Float, longitude: Float) -> Data? {
        let body: [String: Any] = [
            "latitude": latitude,
            "longitude": longitude
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func getSalesforceDataAsJSONData(itemId: String, token: String, channelId: String?) -> Data? {
        var body: [String: Any] = [
            "item_id": itemId
        ]
        if let channelId = channelId {
            body["channelId"] = channelId
        }
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func getFiltersDataAsJSONData(type: String, token: String) -> Data? {
        let body: [String: Any] = [
            "type": type
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
}
