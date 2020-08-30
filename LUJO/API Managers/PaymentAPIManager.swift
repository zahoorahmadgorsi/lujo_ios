//
//  PaymentAPIManager.swift
//  LUJO
//
//  Created by Nemanja Djurisic on 10/27/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import Alamofire
import Crashlytics
import Foundation

class PaymentAPIManagerNEW {

    static let shared = PaymentAPIManagerNEW()
    
    private init() { }
    
    func validateReferralCode(token: String, code: String, completion: @escaping (Error?) -> Void) {
        
        Alamofire.request(PaymentRouter.validateReferralCode(token, code))
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
    
    func confirmMembershipPayment(membershipId: Int, transactionId: String, amount: Double, code: String?, token: String, completion: @escaping (Membership?, Error?) -> Void) {
        
        Alamofire.request(PaymentRouter.confirmPayment(membershipId, transactionId, amount, code, token))
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
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<Membership>.self,
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
    
    func confirmBookingPayment(bookingId: String, transactionId: String, amount: Double, token: String, completion: @escaping (Error?) -> Void) {
        
        Alamofire.request(PaymentRouter.confirmBookingPayment(bookingId, transactionId, amount, token))
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
