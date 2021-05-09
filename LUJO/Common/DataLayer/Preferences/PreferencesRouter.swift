//
//  PreferencesRouter.swift
//  LUJO
//
//  Created by iMac on 08/05/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//
import Alamofire
import Crashlytics
import Foundation
import UIKit

enum PreferencesRouter: URLRequestConvertible {
    
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
    
    case getGiftHabits(String)
    case getGiftCategories(String)
    case getGiftPreferences(String)
    case setGiftHabits(String,String)
    case setGiftCategories(String,String)
    case setGiftPreferences(String,String)
    
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

        return urlRequest
    }

    func getHTTPMethod() -> HTTPMethod {
        switch self {
            case .getGiftHabits:        fallthrough
            case .getGiftCategories:    fallthrough
            case .getGiftPreferences:   fallthrough
            case .setGiftHabits:        fallthrough
            case .setGiftCategories:    fallthrough
            case .setGiftPreferences:
                return .post
        }
    }

    fileprivate func getRequestURL() -> URL {
        var newURLComponents = URLComponents()
        newURLComponents.scheme = EERouter.scheme
        newURLComponents.host = EERouter.baseURLString
        newURLComponents.path = EERouter.apiVersion
        
        switch self {
            case .getGiftHabits:        newURLComponents.path.append("/reference/gift-habits")
            case .getGiftCategories:    newURLComponents.path.append("/reference/gift-categories")
            case .getGiftPreferences:   newURLComponents.path.append("/reference/gift-preferences")
            case .setGiftHabits:        fallthrough
            case .setGiftCategories:    fallthrough
            case .setGiftPreferences:   newURLComponents.path.append("/preferences/gift")
        }
        
        do {
            let callURL = try newURLComponents.asURL()
            return callURL
        } catch {
            Crashlytics.sharedInstance().recordError(error)
        }

        return URL(string: "https://\(EERouter.baseURLString)")!
            
            
        
        
    }
    
    fileprivate func getBodyData() -> Data? {
        switch self {
            case let .getGiftHabits(token):     fallthrough
            case let .getGiftCategories(token): fallthrough
            case let .getGiftPreferences(token):
                return getGiftTaxonomiesAsJSONData(token: token)
            case let .setGiftHabits(token,commSepeartedString):
                return setGiftHabbitsAsJSONData(token: token, commSepeartedString:commSepeartedString)
            case let .setGiftCategories(token, commSepeartedString):
                return setGiftCategoriesAsJSONData(token: token , commSepeartedString:commSepeartedString)
            case let .setGiftPreferences(token, commSepeartedString):return setGiftPreferencesAsJSONData(token: token , commSepeartedString:commSepeartedString)
        }
    }
    
    fileprivate func getGiftTaxonomiesAsJSONData(token: String) -> Data? {
        let body: [String: Any] = [
            "token": token
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setGiftHabbitsAsJSONData(token: String, commSepeartedString: String) -> Data? {
        let body: [String: Any] = [
            "token": token
            ,"gift_habit_id" : commSepeartedString
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
     
    fileprivate func setGiftCategoriesAsJSONData(token: String, commSepeartedString: String) -> Data? {
        let body: [String: Any] = [
            "token": token
            ,"gift_category_id" : commSepeartedString
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setGiftPreferencesAsJSONData(token: String, commSepeartedString: String) -> Data? {
        let body: [String: Any] = [
            "token": token
            ,"gift_preferences_id" : commSepeartedString
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
}

