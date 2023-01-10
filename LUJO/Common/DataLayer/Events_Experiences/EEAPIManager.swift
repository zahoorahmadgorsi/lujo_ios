import Alamofire
import FirebaseCrashlytics
import UIKit

class EEAPIManager {
    
    func geopoint(type: String, latitude: Float, longitude: Float, completion: @escaping ([Product]?, Error?) -> Void) {
        Alamofire.request(EERouter.geopoint(type: type, latitude: latitude, longitude: longitude))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }
                
                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }
                
                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<[Product]>.self,
                                                                 from: response.data!)
                        else {
                            completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                            return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
        }
    }
    
    func home( completion: @escaping (HomeObjects?, Error?) -> Void) {
        Alamofire.request(EERouter.home)
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<HomeObjects>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
//                    //DON'T DELETE THE BELOW BLOCK, IT WILL HELP IN DEBUGGING, JUST UNCOMMENT AND COMMENT THE ABOVE CODE AND SEE THE ERROR
//                    do {
//                        let result = try JSONDecoder().decode(LujoServerResponse<HomeObjects>.self,
//                                                                     from: response.data!)
//                        completion(result.content, nil)
//                        return
//                    }catch {
//                        print(error)
//                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
//                        return
//                      }
                    
                    
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }

    func getEvents( past: Bool, term: String?, cityId: String?, productId: String?, filtersToApply:AppliedFilters? = nil,
                    completion: @escaping ([Product], Error?) -> Void) {
        Alamofire.request(EERouter.events(past, term, cityId, productId, filtersToApply)).responseJSON { response in
            guard response.result.error == nil else {
                completion([], response.result.error!)
                return
            }

            // Special case where status code is not received, should never happen
            guard let statusCode = response.response?.statusCode else {
                completion([], BackendError.unhandledStatus)
                return
            }

            switch statusCode {
            case 1 ... 199: // Transfer protoco-level information: Unexpected
                completion([], self.handleError(response, statusCode))
            case 200 ... 299: // Success
                if let id = productId , !id.isEmpty{
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<Product>.self, from: response.data!)
                    else {
                        completion([], BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    var products = [Product]()
                    products.append(result.content) //result.content would be an object, but completion is expecting an array
                    completion(products, nil)
                }else{
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<DiscoverSearchResponse>.self, from: response.data!)
                    else {
                        completion([], BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content.docs, nil)
                }
                
                return
            case 300 ... 399: // Redirection: Unexpected
                completion([], self.handleError(response, statusCode))
            case 400 ... 499: // Client Error
                completion([], self.handleError(response, statusCode))
            default: // 500 or bigger, Server Error
                completion([], self.handleError(response, statusCode))
            }
        }
    }


    func getExperiences( term: String?, cityId: String?, productId: String?, filtersToApply:AppliedFilters? = nil, completion: @escaping ([Product], Error?) -> Void) {
        Alamofire.request(EERouter.experiences( term, cityId, productId, filtersToApply)).responseJSON { response in
            guard response.result.error == nil else {
                completion([], response.result.error!)
                return
            }

            // Special case where status code is not received, should never happen
            guard let statusCode = response.response?.statusCode else {
                completion([], BackendError.unhandledStatus)
                return
            }

            switch statusCode {
            case 1 ... 199: // Transfer protoco-level information: Unexpected
                completion([], self.handleError(response, statusCode))
            case 200 ... 299: // Success
                if let id = productId , !id.isEmpty{
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<Product>.self, from: response.data!)
                    else {
                        completion([], BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    var products = [Product]()
                    products.append(result.content) //result.content would be an object, but completion is expecting an array
                    completion(products, nil)
                }else{
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<DiscoverSearchResponse>.self, from: response.data!)
                    else {
                        completion([], BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content.docs, nil)
                
                }
                return
            case 300 ... 399: // Redirection: Unexpected
                completion([], self.handleError(response, statusCode))
            case 400 ... 499: // Client Error
                completion([], self.handleError(response, statusCode))
            default: // 500 or bigger, Server Error
                completion([], self.handleError(response, statusCode))
            }
        }
    }
    
    func getVillas(term: String?, cityId: String?, productId: String?, completion: @escaping ([Product], Error?) -> Void) {
        Alamofire.request(EERouter.villas( term, cityId, productId)).responseJSON { response in
            guard response.result.error == nil else {
                completion([], response.result.error!)
                return
            }

            // Special case where status code is not received, should never happen
            guard let statusCode = response.response?.statusCode else {
                completion([], BackendError.unhandledStatus)
                return
            }

            switch statusCode {
            case 1 ... 199: // Transfer protoco-level information: Unexpected
                completion([], self.handleError(response, statusCode))
            case 200 ... 299: // Success
                if let id = productId , !id.isEmpty{
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<Product>.self, from: response.data!)
                    else {
                        completion([], BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    var products = [Product]()
                    products.append(result.content) //result.content would be an object, but completion is expecting an array
                    completion(products, nil)
                }else{
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<[Product]>.self,
                                                                 from: response.data!)
                    else {
                        completion([], BackendError.parsing(reason: "Unable to parse the response"))
                        return
                    }
                    completion(result.content, nil)
                }
                return
            case 300 ... 399: // Redirection: Unexpected
                completion([], self.handleError(response, statusCode))
            case 400 ... 499: // Client Error
                completion([], self.handleError(response, statusCode))
            default: // 500 or bigger, Server Error
                completion([], self.handleError(response, statusCode))
            }
        }
    }
    
    func getGoods(term: String?, giftCategoryId: String?, productId: String? , completion: @escaping ([Product], Error?) -> Void) {
        Alamofire.request(EERouter.goods(term, giftCategoryId, productId)).responseJSON { response in
            guard response.result.error == nil else {
                completion([], response.result.error!)
                return
            }

            // Special case where status code is not received, should never happen
            guard let statusCode = response.response?.statusCode else {
                completion([], BackendError.unhandledStatus)
                return
            }

            switch statusCode {
            case 1 ... 199: // Transfer protoco-level information: Unexpected
                completion([], self.handleError(response, statusCode))
            case 200 ... 299: // Success
                if let id = productId , !id.isEmpty{
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<Product>.self, from: response.data!)
                    else {
                        completion([], BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    var products = [Product]()
                    products.append(result.content) //result.content would be an object, but completion is expecting an array
                    completion(products, nil)
                }else if let id = giftCategoryId , !id.isEmpty{
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<PerCityObjects>.self, from: response.data!)
                    else {
                        completion([], BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content.categories?[0].items ?? [], nil)
                }else{
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<DiscoverSearchResponse>.self, from: response.data!)
                    else {
                        completion([], BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content.docs, nil)
                
                }
                return
            case 300 ... 399: // Redirection: Unexpected
                completion([], self.handleError(response, statusCode))
            case 400 ... 499: // Client Error
                completion([], self.handleError(response, statusCode))
            default: // 500 or bigger, Server Error
                completion([], self.handleError(response, statusCode))
            }
        }
    }
    
    func getYachts(term: String?, cityId: String?, productId: String?, filtersToApply:AppliedFilters? = nil, completion: @escaping ([Product], Error?) -> Void) {
        Alamofire.request(EERouter.yachts(term, cityId, productId, filtersToApply)).responseJSON { response in
            guard response.result.error == nil else {
                completion([], response.result.error!)
                return
            }

            // Special case where status code is not received, should never happen
            guard let statusCode = response.response?.statusCode else {
                completion([], BackendError.unhandledStatus)
                return
            }

            switch statusCode {
            case 1 ... 199: // Transfer protoco-level information: Unexpected
                completion([], self.handleError(response, statusCode))
            case 200 ... 299: // Success
                if let id = productId , !id.isEmpty{
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<Product>.self, from: response.data!)
                    else {
                        completion([], BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    var products = [Product]()
                    products.append(result.content) //result.content would be an object, but completion is expecting an array
                    completion(products, nil)
                }else{
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<[Product]>.self,
                                                                 from: response.data!)
                    else {
                        completion([], BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                }
                return
            case 300 ... 399: // Redirection: Unexpected
                completion([], self.handleError(response, statusCode))
            case 400 ... 499: // Client Error
                completion([], self.handleError(response, statusCode))
            default: // 500 or bigger, Server Error
                completion([], self.handleError(response, statusCode))
            }
        }
    }
    
    func getTopRated(type: String?, term: String?, completion: @escaping ([Product], Error?) -> Void) {
        Alamofire.request(EERouter.topRated( type: type,  term:term)).responseJSON { response in
            guard response.result.error == nil else {
                completion([], response.result.error!)
                return
            }

            // Special case where status code is not received, should never happen
            guard let statusCode = response.response?.statusCode else {
                completion([], BackendError.unhandledStatus)
                return
            }

            switch statusCode {
            case 1 ... 199: // Transfer protoco-level information: Unexpected
                completion([], self.handleError(response, statusCode))
            case 200 ... 299: // Success
                guard let result = try? JSONDecoder().decode(LujoServerResponse<[Product]>.self,
                                                             from: response.data!)
                else {
                    completion([], BackendError.parsing(reason: "Unable to parse response"))
                    return
                }
                completion(result.content, nil)
                return
            case 300 ... 399: // Redirection: Unexpected
                completion([], self.handleError(response, statusCode))
            case 400 ... 499: // Client Error
                completion([], self.handleError(response, statusCode))
            default: // 500 or bigger, Server Error
                completion([], self.handleError(response, statusCode))
            }
        }
    }
    
    func getRecents(_ token: String, limit: String?, type: String?, completion: @escaping ([Product], Error?) -> Void) {
        Alamofire.request(EERouter.recents(token, limit, type)).responseJSON { response in
            guard response.result.error == nil else {
                completion([], response.result.error!)
                return
            }

            // Special case where status code is not received, should never happen
            guard let statusCode = response.response?.statusCode else {
                completion([], BackendError.unhandledStatus)
                return
            }

            switch statusCode {
            case 1 ... 199: // Transfer protoco-level information: Unexpected
                completion([], self.handleError(response, statusCode))
            case 200 ... 299: // Success
                guard let result = try? JSONDecoder().decode(LujoServerResponse<[Product]>.self,
                                                             from: response.data!)
                else {
                    completion([], BackendError.parsing(reason: "Unable to parse response"))
                    return
                }
                completion(result.content, nil)
                return
            case 300 ... 399: // Redirection: Unexpected
                completion([], self.handleError(response, statusCode))
            case 400 ... 499: // Client Error
                completion([], self.handleError(response, statusCode))
            default: // 500 or bigger, Server Error
                completion([], self.handleError(response, statusCode))
            }
        }
    }
    
    func search(token: String, searchText: String, completion: @escaping ([City], Error?) -> Void) {
        Alamofire.request(EERouter.citySearch(token: token, searchTerm: searchText)).responseJSON { response in
            guard response.result.error == nil else {
                completion([], response.result.error!)
                return
            }
            
            // Special case where status code is not received, should never happen
            guard let statusCode = response.response?.statusCode else {
                completion([], BackendError.unhandledStatus)
                return
            }
            
            switch statusCode {
            case 1 ... 199: // Transfer protoco-level information: Unexpected
                completion([], self.handleError(response, statusCode))
            case 200 ... 299: // Success
                guard let result = try? JSONDecoder().decode(LujoServerResponse<[City]>.self,
                                                             from: response.data!)
                    else {
                        completion([], BackendError.parsing(reason: "Unable to parse response"))
                        return
                }
                completion(result.content, nil)
                return
            case 300 ... 399: // Redirection: Unexpected
                completion([], self.handleError(response, statusCode))
            case 400 ... 499: // Client Error
                completion([], self.handleError(response, statusCode))
            default: // 500 or bigger, Server Error
                completion([], self.handleError(response, statusCode))
            }
        }
    }
    
    func getInfoForCity(token: String, cityId: String, completion: @escaping (CityInfo?, Error?) -> Void) {
        Alamofire.request(EERouter.cityInfo(token: token, cityId: cityId)).responseJSON { response in
            guard response.result.error == nil else {
                completion(nil, response.result.error!)
                return
            }
            
            // Special case where status code is not received, should never happen
            guard let statusCode = response.response?.statusCode else {
                completion(nil, BackendError.unhandledStatus)
                return
            }
            
            switch statusCode {
            case 1 ... 199: // Transfer protoco-level information: Unexpected
                completion(nil, self.handleError(response, statusCode))
            case 200 ... 299: // Success
                guard let result = try? JSONDecoder().decode(LujoServerResponse<CityInfo>.self,
                                                             from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                }
                completion(result.content, nil)
                return
            case 300 ... 399: // Redirection: Unexpected
                completion(nil, self.handleError(response, statusCode))
            case 400 ... 499: // Client Error
                completion(nil, self.handleError(response, statusCode))
            default: // 500 or bigger, Server Error
                completion(nil, self.handleError(response, statusCode))
            }
        }
    }

    func handleError(_ response: DataResponse<Any>,
                                 _ statusCode: Int) -> Error {
        var serverError: String!
        do {
            let errorResult = try JSONDecoder().decode(LujoServerResponse<String>.self, from: response.data!)
            serverError = errorResult.content
        } catch {
            serverError = "Unknown server error"
        }
        reportError(statusCode, response)
        return BackendError.unexpectedCode(description: serverError)
    }

    fileprivate func reportError(_ statusCode: Int, _ response: DataResponse<Any>) {
        let sourceURL = String(describing: response.request?.url)
        let error = NSError(domain: NSURLErrorDomain,
                            code: NSURLErrorBadServerResponse,
                            userInfo: [
                                NSLocalizedDescriptionKey: "Unexpected \(statusCode) received on \(sourceURL)",
                                NSLocalizedFailureReasonErrorKey: "Expected code 20X, 40X or 50X",
                            ])
        Crashlytics.crashlytics().record(error: error)
    }
    
    func sendSalesForceRequest(salesforceRequest: SalesforceRequest, conversationId: String? = nil, type: String, completion: @escaping (CustomBookingResponse?, Error?) -> Void) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            print("***ERROR***: User does not exist or is not verified - can't send data to salesforce")
            return
        }
        
        Alamofire.request(EERouter.salesforce(salesforceRequest,conversationId)).responseJSON { response in
            guard response.result.error == nil else {
                print("***ERROR***: \(response.result.error?.localizedDescription ?? "UNKNOWN ERROR")")
                return
            }
            
            // Special case where status code is not received, should never happen
            guard let statusCode = response.response?.statusCode else {
                print("***ERROR***: \(BackendError.unhandledStatus)")
                return
            }
            
            print("***STATUS CODE***: \(statusCode)")
            
            switch statusCode {
            case 1 ... 199: // Transfer protoco-level information: Unexpected
                completion(nil, self.handleError(response, statusCode))
            case 200 ... 299: // Success
                guard let result = try? JSONDecoder().decode(LujoServerResponse<CustomBookingResponse>.self,
                                                             from: response.data!)
                else {
                    completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                    return
                }
                completion(result.content, nil)
                return
            case 300 ... 399: // Redirection: Unexpected
                completion(nil, self.handleError(response, statusCode))
            case 400 ... 499: // Client Error
                completion(nil, self.handleError(response, statusCode))
            default: // 500 or bigger, Server Error
                completion(nil, self.handleError(response, statusCode))
            }
        }
    }
    
    func getPerCity(type: String
                    , yachtName:String?
                    , yachtCharter:String?
                    , yachtGuests:String?
                    , yachtLengthFeet:String?
                    , yachtLengthMeters:String?
                    , yachtType:String?
                    , yachtBuiltAfter:String?
                    , yachtTag:String?
                    , yachtStatus:String?
                    , region:String?
                    , minPrice:String?
                    , maxPrice:String?
                    , completion: @escaping (PerCityObjects?, Error?) -> Void) {
        Alamofire.request(EERouter.perCity( type, yachtName, yachtCharter, yachtGuests, yachtLengthFeet, yachtLengthMeters, yachtType, yachtBuiltAfter, yachtTag, yachtStatus, region, minPrice, maxPrice)).responseJSON { response in
            guard response.result.error == nil else {
                completion(nil, response.result.error!)
                return
            }

            // Special case where status code is not received, should never happen
            guard let statusCode = response.response?.statusCode else {
                completion(nil, BackendError.unhandledStatus)
                return
            }

            switch statusCode {
            case 1 ... 199: // Transfer protoco-level information: Unexpected
                completion(nil, self.handleError(response, statusCode))
            case 200 ... 299: // Success
                guard let result = try? JSONDecoder().decode(LujoServerResponse<PerCityObjects>.self,
                                                             from: response.data!)
                else {
                    completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                    return
                }
                completion(result.content, nil)
                return
            case 300 ... 399: // Redirection: Unexpected
                completion(nil, self.handleError(response, statusCode))
            case 400 ... 499: // Client Error
                completion(nil, self.handleError(response, statusCode))
            default: // 500 or bigger, Server Error
                completion(nil, self.handleError(response, statusCode))
            }
        }
    }
    
    func getFilters(type: String, completion: @escaping ([Filters]?, Error?) -> Void) {
        Alamofire.request(EERouter.filters(type)).responseJSON { response in
            guard response.result.error == nil else {
                completion(nil, response.result.error!)
                return
            }

            // Special case where status code is not received, should never happen
            guard let statusCode = response.response?.statusCode else {
                completion(nil, BackendError.unhandledStatus)
                return
            }

            switch statusCode {
            case 1 ... 199: // Transfer protoco-level information: Unexpected
                completion(nil, self.handleError(response, statusCode))
            case 200 ... 299: // Success
                guard let result = try? JSONDecoder().decode(LujoServerResponse<[Filters]>.self,
                                                             from: response.data!)
                else {
                    completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                    return
                }
                completion(result.content, nil)
                return
            case 300 ... 399: // Redirection: Unexpected
                completion(nil, self.handleError(response, statusCode))
            case 400 ... 499: // Client Error
                completion(nil, self.handleError(response, statusCode))
            default: // 500 or bigger, Server Error
                completion(nil, self.handleError(response, statusCode))
            }
        }
    }
    
    

}
