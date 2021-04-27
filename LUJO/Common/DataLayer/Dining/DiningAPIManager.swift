//
//  DiningAPIManager.swift
//  LUJO
//
//  Created by Nemanja Djurisic on 8/12/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import Alamofire
import Crashlytics
import UIKit
import CoreLocation

extension GoLujoAPIManager  {
    func home(_ token: String, completion: @escaping (DiningHomeObjects?, Error?) -> Void) {
        Alamofire.request(DiningRouter.home(token))
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
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<DiningHomeObjects>.self,
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

    func search(_ token: String, term: String?, cityId: Int?, currentLocation: CLLocation?, completion: @escaping ([Product]?, Error?) -> Void) {
        Alamofire.request(DiningRouter.search(token, term, cityId, currentLocation?.coordinate.latitude, currentLocation?.coordinate.longitude))
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

    fileprivate func handleError(_ response: DataResponse<Any>,
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
    
    func sendRequestForSalesForce(itemId: Int, date: String, time: String, persons: Int , completion: @escaping (CustomBookingResponse?, Error?) -> Void) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            print("***ERROR***: User does not exist or is not verified - can't send data to salesforce")
            return
        }
        
        Alamofire.request(DiningRouter.salesforce(itemId, date, time, persons, token)).responseJSON { response in
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
}
