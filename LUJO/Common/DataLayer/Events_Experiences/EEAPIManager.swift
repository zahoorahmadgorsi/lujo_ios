import Alamofire
import FirebaseCrashlytics
import UIKit

class EEAPIManager {
    
    func geopoint(type: String, latitude: Float, longitude: Float,page: Int, perPage: Int, completion: @escaping (DiscoverSearchResponse?, Error?) -> Void) {
        Alamofire.request(EERouter.geopoint(type: type, latitude: latitude, longitude: longitude,page,perPage))
            .responseJSON { response in
                print("Request URL: \(String(describing: response.request)) \nRequest Body: \(String(data: response.request?.httpBody ?? Data(), encoding: .utf8)!) \nResponse Body: \(String(data: response.data ?? Data(), encoding: .utf8)!)")

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
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<DiscoverSearchResponse>.self,
//                    guard let result = try? JSONDecoder().decode(LujoServerResponse<[Product]>.self,
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
                print("Request URL: \(String(describing: response.request)) \nRequest Body: \(String(data: response.request?.httpBody ?? Data(), encoding: .utf8)!) \nResponse Body: \(String(data: response.data ?? Data(), encoding: .utf8)!)")

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


    func getEvents( past: Bool, term: String?, productId: String?, filtersToApply:AppliedFilters? = nil, page: Int, perPage: Int, completion: @escaping (DiscoverSearchResponse?, Error?) -> Void) {
        
        //Alamofire.request(EERouter.events(past, term, latitude, longitude, productId, filtersToApply, page, perPage)).responseJSON { response in
        Alamofire.request(EERouter.events(past, term, productId, filtersToApply, page, perPage)).responseJSON { response in
            print("Request URL: \(String(describing: response.request)) \nRequest Body: \(String(data: response.request?.httpBody ?? Data(), encoding: .utf8)!) \nResponse Body: \(String(data: response.data ?? Data(), encoding: .utf8)!)")

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
                if let id = productId , !id.isEmpty{
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<Product>.self, from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    
                    var products = [Product]()
                    products.append(result.content) //result.content would be an object, but completion is expecting an array
                    
                    let _discoverSearchResponse = DiscoverSearchResponse(docs: products, totalDocs: 1)
                    completion(_discoverSearchResponse, nil)
                }else{
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<DiscoverSearchResponse>.self, from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                }
                
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

    func getExperiences( term: String?, productId: String?, filtersToApply:AppliedFilters? = nil, page: Int, perPage: Int, completion: @escaping (DiscoverSearchResponse?, Error?) -> Void) {
       // Alamofire.request(EERouter.experiences( term, latitude, longitude, productId, filtersToApply, page, perPage)).responseJSON { response in
        Alamofire.request(EERouter.experiences( term, productId, filtersToApply, page, perPage)).responseJSON { response in
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
                if let id = productId , !id.isEmpty{
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<Product>.self, from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    var products = [Product]()
                    products.append(result.content) //result.content would be an object, but completion is expecting an array
                    //                    completion(products, nil)
                                        
                    let _discoverSearchResponse = DiscoverSearchResponse(docs: products, totalDocs: 1)
                    completion(_discoverSearchResponse, nil)
                }else{
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<DiscoverSearchResponse>.self, from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                
                }
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
    
    func getVillas(term: String?, productId: String?, filtersToApply:AppliedFilters? = nil, page: Int, perPage: Int, completion: @escaping (DiscoverSearchResponse?, Error?) -> Void) {
        //Alamofire.request(EERouter.villas( term, latitude, longitude, productId,filtersToApply, page, perPage)).responseJSON { response in
        Alamofire.request(EERouter.villas( term, productId,filtersToApply, page, perPage)).responseJSON { response in
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
                if let id = productId , !id.isEmpty{
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<Product>.self, from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    var products = [Product]()
                    products.append(result.content) //result.content would be an object, but completion is expecting an array
                    //                    completion(products, nil)
                                        
                    let _discoverSearchResponse = DiscoverSearchResponse(docs: products, totalDocs: 1)
                    completion(_discoverSearchResponse, nil)
                }else{
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<DiscoverSearchResponse>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse the response"))
                        return
                    }
                    completion(result.content, nil)
                }
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
    
    func getHotels(term: String?, productId: String?, filtersToApply:AppliedFilters? = nil, page: Int, perPage: Int, completion: @escaping (DiscoverSearchResponse?, Error?) -> Void) {
        Alamofire.request(EERouter.hotels( term, productId,filtersToApply, page, perPage)).responseJSON { response in
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
                if let id = productId , !id.isEmpty{
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<Product>.self, from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    var products = [Product]()
                    products.append(result.content) //result.content would be an object, but completion is expecting an array
                    //                    completion(products, nil)
                                        
                    let _discoverSearchResponse = DiscoverSearchResponse(docs: products, totalDocs: 1)
                    completion(_discoverSearchResponse, nil)
                }else{
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<DiscoverSearchResponse>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse the response"))
                        return
                    }
                    completion(result.content, nil)
                }
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
    
    func getGoods(term: String?, giftCategoryId: String?, productId: String?, filtersToApply:AppliedFilters? = nil, page: Int, perPage: Int , completion: @escaping (DiscoverSearchResponse?, Error?) -> Void) {
        Alamofire.request(EERouter.goods(term, giftCategoryId, productId, filtersToApply, page, perPage)).responseJSON { response in
            print("Request URL: \(String(describing: response.request)) \nRequest Body: \(String(data: response.request?.httpBody ?? Data(), encoding: .utf8)!) \nResponse Body: \(String(data: response.data ?? Data(), encoding: .utf8)!)")
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
                if let id = productId , !id.isEmpty{
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<Product>.self, from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    var products = [Product]()
                    products.append(result.content) //result.content would be an object, but completion is expecting an array
                    //                    completion(products, nil)
                                        
                    let _discoverSearchResponse = DiscoverSearchResponse(docs: products, totalDocs: 1)
                    completion(_discoverSearchResponse, nil)
                }
//                else if let id = giftCategoryId , !id.isEmpty{
//                    guard let result = try? JSONDecoder().decode(LujoServerResponse<PerCityObjects>.self, from: response.data!)
//                    else {
//                        completion([], BackendError.parsing(reason: "Unable to parse response"))
//                        return
//                    }
//                    completion(result.content.categories?[0].items ?? [], nil)
//                }
                else{
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<DiscoverSearchResponse>.self, from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                
                }
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
    
    func getYachts(term: String?, cityId: String?, productId: String?, filtersToApply:AppliedFilters? = nil, page: Int, perPage: Int, completion: @escaping (DiscoverSearchResponse?, Error?) -> Void) {
        Alamofire.request(EERouter.yachts(term, cityId, productId, filtersToApply, page, perPage)).responseJSON { response in
            
            print("Request URL: \(String(describing: response.request)) \nRequest Body: \(String(data: response.request?.httpBody ?? Data(), encoding: .utf8)!) \nResponse Body: \(String(data: response.data ?? Data(), encoding: .utf8)!)")
            
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
                if let id = productId , !id.isEmpty{
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<Product>.self, from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    var products = [Product]()
                    products.append(result.content) //result.content would be an object, but completion is expecting an array
                    //                    completion(products, nil)
                                        
                    let _discoverSearchResponse = DiscoverSearchResponse(docs: products, totalDocs: 1)
                    completion(_discoverSearchResponse, nil)
                }else{
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<DiscoverSearchResponse>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                }
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
    
    func getRestaurant(productId: String, completion: @escaping (DiscoverSearchResponse?, Error?) -> Void) {
        Alamofire.request(EERouter.restaurants(productId)).responseJSON { response in
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
//                if let id = productId , !id.isEmpty{
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<Product>.self, from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                var products = [Product]()
                products.append(result.content) //result.content would be an object, but completion is expecting an array
                //                    completion(products, nil)
                                    
                let _discoverSearchResponse = DiscoverSearchResponse(docs: products, totalDocs: 1)
                completion(_discoverSearchResponse, nil)
//                }else{
//                    guard let result = try? JSONDecoder().decode(LujoServerResponse<[Product]>.self,
//                                                                 from: response.data!)
//                    else {
//                        completion([], BackendError.parsing(reason: "Unable to parse response"))
//                        return
//                    }
//                    completion(result.content, nil)
//                }
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
    
    func getTopRated(type: String?, term: String?, page: Int, perPage: Int, completion: @escaping (DiscoverSearchResponse?, Error?) -> Void) {
        Alamofire.request(EERouter.topRated( type: type,  term:term, page,perPage)).responseJSON { response in
            
            print("Request URL: \(String(describing: response.request)) \nRequest Body: \(String(data: response.request?.httpBody ?? Data(), encoding: .utf8)!) \nResponse Body: \(String(data: response.data ?? Data(), encoding: .utf8)!)")
            
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
                guard let result = try? JSONDecoder().decode(LujoServerResponse<DiscoverSearchResponse>.self,
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
    
    func getRecents( limit: String?, type: String?, completion: @escaping (DiscoverSearchResponse?, Error?) -> Void) {
        Alamofire.request(EERouter.recents(limit, type)).responseJSON { response in
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
                guard let result = try? JSONDecoder().decode(LujoServerResponse<DiscoverSearchResponse>.self,
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
    
//    func search(token: String, searchText: String, completion: @escaping ([City], Error?) -> Void) {
//        Alamofire.request(EERouter.citySearch(token: token, searchTerm: searchText)).responseJSON { response in
//            guard response.result.error == nil else {
//                completion([], response.result.error!)
//                return
//            }
//
//            // Special case where status code is not received, should never happen
//            guard let statusCode = response.response?.statusCode else {
//                completion([], BackendError.unhandledStatus)
//                return
//            }
//
//            switch statusCode {
//            case 1 ... 199: // Transfer protoco-level information: Unexpected
//                completion([], self.handleError(response, statusCode))
//            case 200 ... 299: // Success
//                guard let result = try? JSONDecoder().decode(LujoServerResponse<[City]>.self,
//                                                             from: response.data!)
//                    else {
//                        completion([], BackendError.parsing(reason: "Unable to parse response"))
//                        return
//                }
//                completion(result.content, nil)
//                return
//            case 300 ... 399: // Redirection: Unexpected
//                completion([], self.handleError(response, statusCode))
//            case 400 ... 499: // Client Error
//                completion([], self.handleError(response, statusCode))
//            default: // 500 or bigger, Server Error
//                completion([], self.handleError(response, statusCode))
//            }
//        }
//    }
    
    func searchCities(searchText: String, completion: @escaping ([Taxonomy], Error?) -> Void) {
        Alamofire.request(EERouter.searchCity(searchTerm: searchText)).responseJSON { response in
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
                guard let result = try? JSONDecoder().decode(LujoServerResponse<[Taxonomy]>.self,
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
    
    func getInfoForCity(cityId: String, completion: @escaping (CityInfo?, Error?) -> Void) {
        Alamofire.request(EERouter.cityInfo(cityId: cityId)).responseJSON { response in
            print("Request URL: \(String(describing: response.request)) \nRequest Body: \(String(data: response.request?.httpBody ?? Data(), encoding: .utf8)!) \nResponse Body: \(String(data: response.data ?? Data(), encoding: .utf8)!)")
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
        var strServerError: String!
        do {
            let errorResult = try JSONDecoder().decode(LujoServerResponse<String>.self, from: response.data!)
            strServerError = errorResult.content
        } catch {
            strServerError = "Unknown server error"
        }
        let _error = reportError(statusCode, response)
        return _error
    }

    fileprivate func reportError(_ statusCode: Int, _ response: DataResponse<Any>) -> Error{

        let sourceURL = String(describing: response.request?.url)
        let error = NSError(domain: NSURLErrorDomain,
                            code: statusCode,
                            userInfo: [
                                NSLocalizedDescriptionKey: "Unexpected \(statusCode) received on \(sourceURL)",
                                NSLocalizedFailureReasonErrorKey: "Expected code 20X, 40X or 50X",
                            ])
        Crashlytics.crashlytics().record(error: error)
        return error
    }
    
    func sendSalesForceRequest(salesforceRequest: SalesforceRequest, conversationId: String? = nil, type: String, completion: @escaping (CustomBookingResponse?, Error?) -> Void) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            print("***ERROR***: User does not exist or is not verified - can't send data to salesforce")
            return
        }
        
        Alamofire.request(EERouter.salesforce(salesforceRequest,conversationId)).responseJSON { response in
            
            print("Request URL: \(String(describing: response.request)) \nRequest Body: \(String(data: response.request?.httpBody ?? Data(), encoding: .utf8)!) \nResponse Body: \(String(data: response.data ?? Data(), encoding: .utf8)!)")

            
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
            
            print("Request URL: \(String(describing: response.request)) \nRequest Body: \(String(data: response.request?.httpBody ?? Data(), encoding: .utf8)!) \nResponse Body: \(String(data: response.data ?? Data(), encoding: .utf8)!)")

            
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
