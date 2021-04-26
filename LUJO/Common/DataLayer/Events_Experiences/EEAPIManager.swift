import Alamofire
import Crashlytics
import UIKit

class EEAPIManager {
    
    func geopoint(token: String, type: String, latitude: Float, longitude: Float, radius: Int, completion: @escaping ([Product]?, Error?) -> Void) {
        Alamofire.request(EERouter.geopoint(token: token, type: type, latitude: latitude, longitude: longitude, radius: radius))
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
    
    func home(_ token: String, completion: @escaping (HomeObjects?, Error?) -> Void) {
        Alamofire.request(EERouter.home(token))
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
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }

    func getEvents(_ token: String, past: Bool, term: String?, cityId: Int?, completion: @escaping ([Product], Error?) -> Void) {
        Alamofire.request(EERouter.events(token, past, term, cityId)).responseJSON { response in
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

    func getExperiences(_ token: String, term: String?, cityId: Int?, completion: @escaping ([Product], Error?) -> Void) {
        Alamofire.request(EERouter.experiences(token, term, cityId)).responseJSON { response in
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
    
    func getVillas(_ token: String, term: String?, cityId: Int?, completion: @escaping ([Product], Error?) -> Void) {
        Alamofire.request(EERouter.villas(token, term, cityId)).responseJSON { response in
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
    
    func getGoods(_ token: String, term: String?, category_term_id: Int?, completion: @escaping ([Product], Error?) -> Void) {
        Alamofire.request(EERouter.goods(token, term, category_term_id)).responseJSON { response in
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
                if (term?.count ?? 0 > 0){
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<[Product]>.self, from: response.data!)
                    else {
                        completion([], BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content , nil)
                }else{
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<PerCityObjects>.self, from: response.data!)
                    else {
                        completion([], BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content.categories?[0].items ?? [], nil)
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
    
    func getYachts(_ token: String, term: String?, cityId: Int?, completion: @escaping ([Product], Error?) -> Void) {
        Alamofire.request(EERouter.yachts(token, term, cityId)).responseJSON { response in
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
    
    func getTopRated(_ token: String, type: String?, term: String?, completion: @escaping ([Product], Error?) -> Void) {
        Alamofire.request(EERouter.topRated(token: token, type: type,  term:term)).responseJSON { response in
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
        Crashlytics.sharedInstance().recordError(error)
    }
    
    func sendRequestForSalesForce(itemId: Int, completion: @escaping (CustomBookingResponse?, Error?) -> Void) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            print("***ERROR***: User does not exist or is not verified - can't send data to salesforce")
            return
        }
        
        Alamofire.request(EERouter.salesforce(itemId, token)).responseJSON { response in
            guard response.result.error == nil else {
                print("***ERROR***: \(response.result.error?.localizedDescription ?? "UNKNOW ERROR")")
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
    
    //*********
    func getFavourites(_ token: String, completion: @escaping (WishListObjects?, Error?) -> Void) {
        Alamofire.request(WishListRouter.getFavourites(token))
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
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<WishListObjects>.self,
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
    //*********
    func getPerCity(_ token: String, type: String, completion: @escaping (PerCityObjects?, Error?) -> Void) {
        Alamofire.request(EERouter.perCity(token, type)).responseJSON { response in
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

}
