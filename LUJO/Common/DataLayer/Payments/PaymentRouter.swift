//
//  PaymentRouter.swift
//  LUJO
//
//  Created by Nemanja Djurisic on 10/27/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import Alamofire
import FirebaseCrashlytics
import Foundation
import UIKit

enum PaymentRouter: URLRequestConvertible {
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
    
    case validateReferralCode(String,String)
    case confirmPayment(String, String?, Double?, String?)
    case confirmBookingPayment(String, String, Double, String)
    
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
        urlRequest.print()
        return urlRequest
    }
    
    func getHTTPMethod() -> HTTPMethod {
        switch self {
        case .validateReferralCode:
            return .post
        case .confirmPayment:
            return .post
        case .confirmBookingPayment:
            return .post
        }
    }
    
    fileprivate func getRequestURL() -> URL {
        var newURLComponents = URLComponents()
        newURLComponents.scheme = EERouter.scheme
        newURLComponents.host = EERouter.baseURLString
        newURLComponents.path = EERouter.apiVersion
        
        switch self {
        case .validateReferralCode:
            newURLComponents.path.append("/validate-referral")
        case .confirmPayment:
            newURLComponents.path.append("/purchase/membership")
        case .confirmBookingPayment:
            newURLComponents.path.append("/purchase/booking")
        }
        
        do {
            let callURL = try newURLComponents.asURL()
            return callURL
        } catch {
            Crashlytics.crashlytics().record(error: error)
        }
        
        return URL(string: "https://\(EERouter.baseURLString)")!
    }
    
    fileprivate func getBodyData() -> Data? {
        switch self {
        case let .validateReferralCode(referralCode,membershipPlanId):
            return validateReferralCodeDataAsJSONData(referralCode,membershipPlanId)
        case let .confirmPayment(membershipId, transactionId, amount, referralCode):
            return getConfirmPaymentDataAsJSONData(membershipId: membershipId, transactionId: transactionId, amount: amount, referralCode: referralCode)
        case let .confirmBookingPayment(bookingId, transactionId, amount, token):
            return getConfirmBookingPaymentDataAsJSONData(bookingId: bookingId, transactionId: transactionId, amount: amount, token: token)
            
        }
    }
    
    fileprivate func validateReferralCodeDataAsJSONData(_ referralCode: String, _ membershipPlanId: String) -> Data? {
        let body: [String: Any] = [
            "referral_code": referralCode,
            "membership_plan_id": membershipPlanId
        ]
        
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func getConfirmPaymentDataAsJSONData(membershipId: String,transactionId: String?, amount: Double?, referralCode: String?) -> Data? {
        var body: [String: Any] = [
            "membership_id": membershipId
        ]
        if let transactionId = transactionId {
            body["transaction_id"] = transactionId
        }
        if let amount = amount {
            body["amount"] = amount
        }
        if let referralCode = referralCode {
            body["referral_code"] = referralCode
        }
        
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func getConfirmBookingPaymentDataAsJSONData(bookingId: String, transactionId: String, amount: Double, token: String) -> Data? {
        let body: [String: Any] = [
            "salesforce_id": bookingId,
            "transaction_id": transactionId,
            "amount": amount
        ]
        
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
}
