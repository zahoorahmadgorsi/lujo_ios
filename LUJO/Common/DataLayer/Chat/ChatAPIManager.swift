//
//  ChatAPIManager.swift
//  LUJO
//
//  Created by iMac on 24/07/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import Foundation

import Alamofire
import Crashlytics
import UIKit
import CoreLocation
import Mixpanel


extension GoLujoAPIManager  {
    
    func getChats(token: String, completion: @escaping (ChatList?, Error?) -> Void) {
        let chatRouter = ChatRouter.getChats(token)
        
        Alamofire.request( chatRouter )
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
                case 1 ... 199: // Transfer protocol-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<ChatList>.self, from: response.data!)
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
    
//    func getFavourites(_ token: String, completion: @escaping (WishListObjects?, Error?) -> Void) {
//        Alamofire.request(WishListRouter.getFavourites(token))
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
//                    guard let result = try? JSONDecoder().decode(LujoServerResponse<WishListObjects>.self,
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
