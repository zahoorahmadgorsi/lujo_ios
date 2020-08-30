//
//  CustomRequestAPIManager.swift
//  LUJO
//
//  Created by Nemanja Djurisic on 11/24/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import Alamofire
import Crashlytics
import Foundation

class CustomRequestAPIManager {
    
    static let shared = CustomRequestAPIManager()
    
    private init() {}
    
    func ticketsReqeust(desc: String, count: Int, token: String, completion: @escaping (Error?) -> Void) {
        
        Alamofire.request(CustomRequestRouter.tickets(desc, count, token))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(response.result.error!)
                    return
                }
                
                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(BackendError.unhandledStatus)
                    return
                }
                
                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    completion(nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(self.handleError(response, statusCode))
                }
        }
    }
    
    func goodsReqeust(desc: String, isGift: Bool, token: String, completion: @escaping (Error?) -> Void) {
        
        Alamofire.request(CustomRequestRouter.goods(desc, isGift, token))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(response.result.error!)
                    return
                }
                
                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(BackendError.unhandledStatus)
                    return
                }
                
                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    completion(nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(self.handleError(response, statusCode))
                }
        }
    }
    
    func getCuisineCategories(token: String, completion: @escaping ([Cuisine], Error?) -> Void) {
        Alamofire.request(CustomRequestRouter.cuisineCategories(token))
            .responseJSON { response in
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
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<[Cuisine]>.self,
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
    
    func findATable(location: String, restaurantName: String?, cuisine: Cuisine?, date: String, time: String, guestsCount: Int, token: String, completion: @escaping (Error?) -> Void) {
        
        Alamofire.request(CustomRequestRouter.getTable(location, restaurantName, cuisine, date, time, guestsCount, token))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(response.result.error!)
                    return
                }
                
                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(BackendError.unhandledStatus)
                    return
                }
                
                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    completion(nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(self.handleError(response, statusCode))
                }
        }
    }
    
    func requestYacht(destination: String, yachtName: String?, yachtType: String?, yachtLenght: String, dateFrom: String, dateTo: String, guestsCount: Int, token: String, completion: @escaping (Error?) -> Void) {
        
        Alamofire.request(CustomRequestRouter.requestYacht(destination, yachtName, yachtType, yachtLenght, dateFrom, dateTo, guestsCount, token))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(response.result.error!)
                    return
                }
                
                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(BackendError.unhandledStatus)
                    return
                }
                
                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    completion(nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(self.handleError(response, statusCode))
                }
        }
    }
    
    func findHotel(cityName: String, hotelName: String?, hotelRadius: String, checkInDate: String, checkOutDate: String, adultsCount: Int, roomsCount: Int, hotelStars: Int, token: String, completion: @escaping (Error?) -> Void) {
        
        Alamofire.request(CustomRequestRouter.findHotel(cityName, hotelName, hotelRadius, checkInDate, checkOutDate, adultsCount, roomsCount, hotelStars, token))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(response.result.error!)
                    return
                }
                
                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(BackendError.unhandledStatus)
                    return
                }
                
                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    completion(nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(self.handleError(response, statusCode))
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
}
