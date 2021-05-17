//
//  PreferencesAPIManager.swift
//  LUJO
//
//  Created by iMac on 08/05/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import Alamofire
import Crashlytics
import UIKit
import CoreLocation
import Mixpanel

extension GoLujoAPIManager  {
    
//    func setUnSetFavourites(token: String, id: Int, isUnSetFavourite: Bool, completion: @escaping (String?, Error?) -> Void) {
//        if (isUnSetFavourite){
//            Mixpanel.mainInstance().track(event: "UnLiked",
//                  properties: ["productId" : id])
//        }else{
//            Mixpanel.mainInstance().track(event: "Liked",
//                  properties: ["productId" : id])
//        }
//        var wishListRouter = WishListRouter.setFavourites(token, id)
//        if (isUnSetFavourite){
//            wishListRouter = WishListRouter.unSetFavourites(token, id)
//        }
//
//        Alamofire.request( wishListRouter )
//            .responseJSON { response in
//                guard response.result.error == nil else {
//                    completion(nil, response.result.error!)
//                    return
//                }
//
//                // Special case where status code is not received, should never happen
//                guard let statusCode = response.response?.statusCode else {
//                    completion(nil, BackendError.unhandledStatus)
//                    return
//                }
//
//                switch statusCode {
//                case 1 ... 199: // Transfer protocol-level information: Unexpected
//                    completion(nil, self.handleError(response, statusCode))
//                case 200 ... 299: // Success
//                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self, from: response.data!)
//                        else {
//                            completion(nil, BackendError.parsing(reason: "Unable to parse response"))
//                            return
//                    }
//                    completion(result.content, nil)
//                    return
//                case 300 ... 399: // Redirection: Unexpected
//                    completion(nil, self.handleError(response, statusCode))
//                case 400 ... 499: // Client Error
//                    completion(nil, self.handleError(response, statusCode))
//                default: // 500 or bigger, Server Error
//                    completion(nil, self.handleError(response, statusCode))
//                }
//        }
//    }
    
    func getGiftHabbits(_ token: String, completion: @escaping ([Taxonomy]?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.getGiftHabits(token))
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
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<[Taxonomy]>.self,
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

    func getGiftCategories(_ token: String, completion: @escaping ([Taxonomy]?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.getGiftCategories(token))
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
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<[Taxonomy]>.self,
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
    
    func getGiftPreferences(_ token: String, completion: @escaping ([Taxonomy]?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.getGiftPreferences(token))
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
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<[Taxonomy]>.self,
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
    
    func setGiftHabbits( token: String,commSepeartedString:String, completion: @escaping (String?, Error?) -> Void){
        Alamofire.request(PreferencesRouter.setGiftHabits(token, commSepeartedString))
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
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
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

    func setGiftCategories(token: String,commSepeartedString:String, completion: @escaping (String?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.setGiftCategories(token,commSepeartedString))
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
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
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
    
    func setGiftPreferences(token: String, commSepeartedString:String, completion: @escaping (String?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.setGiftPreferences(token,commSepeartedString))
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
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
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
    
    func setAviationHaveCharteredBefore( token: String,commSepeartedString:String, completion: @escaping (String?, Error?) -> Void){
        Alamofire.request(PreferencesRouter.setAviationHaveCharteredBefore(token, commSepeartedString))
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
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
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

    func setAviationWantToPurchase(token: String,commSepeartedString:String, completion: @escaping (String?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.setAviationWantToPurchase(token,commSepeartedString))
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
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
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
    
    func setAviationPreferredCharter(token: String, commSepeartedString:String, completion: @escaping (String?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.setAviationPreferredCharter(token,commSepeartedString))
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
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
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
    
    func setAviationPreferredCuisine( token: String,commSepeartedString:String, completion: @escaping (String?, Error?) -> Void){
        Alamofire.request(PreferencesRouter.setAviationPreferredCuisine(token, commSepeartedString))
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
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
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

//    func setGiftCategories(token: String,commSepeartedString:String, completion: @escaping (String?, Error?) -> Void) {
//        Alamofire.request(PreferencesRouter.setGiftCategories(token,commSepeartedString))
//            .responseJSON { response in
//                guard response.result.error == nil else {
//                    completion(nil, response.result.error!)
//                    return
//                }
//
//                // Special case where status code is not received, should never happen
//                guard let statusCode = response.response?.statusCode else {
//                    completion(nil, BackendError.unhandledStatus)
//                    return
//                }
//
//                switch statusCode {
//                case 1 ... 199: // Transfer protoco-level information: Unexpected
//                    completion(nil, self.handleError(response, statusCode))
//                case 200 ... 299: // Success
//                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
//                                                                 from: response.data!)
//                    else {
//                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
//                        return
//                    }
//                    completion(result.content, nil)
//                    return
//                case 300 ... 399: // Redirection: Unexpected
//                    completion(nil, self.handleError(response, statusCode))
//                case 400 ... 499: // Client Error
//                    completion(nil, self.handleError(response, statusCode))
//                default: // 500 or bigger, Server Error
//                    completion(nil, self.handleError(response, statusCode))
//                }
//            }
//    }
//
//    func setGiftPreferences(token: String, commSepeartedString:String, completion: @escaping (String?, Error?) -> Void) {
//        Alamofire.request(PreferencesRouter.setGiftPreferences(token,commSepeartedString))
//            .responseJSON { response in
//                guard response.result.error == nil else {
//                    completion(nil, response.result.error!)
//                    return
//                }
//
//                // Special case where status code is not received, should never happen
//                guard let statusCode = response.response?.statusCode else {
//                    completion(nil, BackendError.unhandledStatus)
//                    return
//                }
//
//                switch statusCode {
//                case 1 ... 199: // Transfer protoco-level information: Unexpected
//                    completion(nil, self.handleError(response, statusCode))
//                case 200 ... 299: // Success
//                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
//                                                                 from: response.data!)
//                    else {
//                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
//                        return
//                    }
//                    completion(result.content, nil)
//                    return
//                case 300 ... 399: // Redirection: Unexpected
//                    completion(nil, self.handleError(response, statusCode))
//                case 400 ... 499: // Client Error
//                    completion(nil, self.handleError(response, statusCode))
//                default: // 500 or bigger, Server Error
//                    completion(nil, self.handleError(response, statusCode))
//                }
//            }
//    }
    
    func getAviationBeverages(_ token: String, completion: @escaping ([Taxonomy]?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.getAviationBeverages(token))
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
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<[Taxonomy]>.self,
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
    
    
}
