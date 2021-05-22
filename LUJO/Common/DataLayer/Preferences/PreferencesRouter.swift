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
    
    case getAllPreferences(String)
    case getGiftHabits(String)
    case getGiftCategories(String)
    case getGiftPreferences(String)
    case setGiftHabits(String,String,String)
    case setGiftCategories(String,String,String)
    case setGiftPreferences(String,String,String)
    case getAviationBeverages(String)
    case setAviationHaveCharteredBefore(String,String)
    case setAviationCharterFrequency(String,Int,Int)
    case setAviationWantToPurchase(String,String)
    case setAviationPreferredCharter(String,String)
    case setAviationPreferredCuisine(String,String,String)
    case setAviationPreferredBevereges(String,String,String)
    case searchDestination(String, String)
//    case setAviationOtherInterests(String,String)
    
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
        case .getAllPreferences:    return .get
        case .getGiftHabits:        fallthrough
        case .getGiftCategories:    fallthrough
        case .getGiftPreferences:   fallthrough
        case .setGiftHabits:        fallthrough
        case .setGiftCategories:    fallthrough
        case .setGiftPreferences:   fallthrough
        case .getAviationBeverages: fallthrough
        case .setAviationHaveCharteredBefore:    fallthrough
        case .setAviationWantToPurchase:         fallthrough
        case .setAviationCharterFrequency: fallthrough
        case .setAviationPreferredCharter:       fallthrough
        case .setAviationPreferredCuisine:  fallthrough
        case .setAviationPreferredBevereges: fallthrough
        case .searchDestination:
                return .post
        }
    }

    fileprivate func getRequestURL() -> URL {
        var newURLComponents = URLComponents()
        newURLComponents.scheme = EERouter.scheme
        newURLComponents.host = EERouter.baseURLString
        newURLComponents.path = EERouter.apiVersion
        
        switch self {
        case let .getAllPreferences(token):
            newURLComponents.path.append("/users/preferences")
            newURLComponents.queryItems = [
                URLQueryItem(name: "token", value: token),
            ]
        case .getGiftHabits:        newURLComponents.path.append("/reference/gift-habits")
        case .getGiftCategories:    newURLComponents.path.append("/reference/gift-categories")
        case .getGiftPreferences:   newURLComponents.path.append("/reference/gift-preferences")
        case .setGiftHabits:        fallthrough
        case .setGiftCategories:    fallthrough
        case .setGiftPreferences:   newURLComponents.path.append("/preferences/gift")
        case .getAviationBeverages:  newURLComponents.path.append("/reference/beverages")
        case .setAviationHaveCharteredBefore:    fallthrough
        case .setAviationWantToPurchase:         fallthrough
        case .setAviationCharterFrequency: fallthrough
        case .setAviationPreferredCharter:       fallthrough
        case .setAviationPreferredCuisine:      fallthrough
        case .setAviationPreferredBevereges:
            newURLComponents.path.append("/preferences/aviation")
        case .searchDestination:
            newURLComponents.path.append("/reference/locations")
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
        case .getAllPreferences:    return nil
        case let .getGiftHabits(token):         fallthrough
        case let .getGiftCategories(token):     fallthrough
        case let .getGiftPreferences(token):    fallthrough
        case let .getAviationBeverages(token):
            return getGiftTaxonomiesAsJSONData(token: token)
        case let .setGiftHabits(token,commSepeartedString, typedPreference):
            return setGiftHabbitsAsJSONData(token: token, commSepeartedString:commSepeartedString, typedPreference: typedPreference)
        case let .setGiftCategories(token, commSepeartedString, typedPreference):
            return setGiftCategoriesAsJSONData(token: token , commSepeartedString:commSepeartedString, typedPreference: typedPreference)
        case let .setGiftPreferences(token, commSepeartedString, typedPreference):
            return setGiftPreferencesAsJSONData(token: token , commSepeartedString:commSepeartedString, typedPreference: typedPreference)
        case let .setAviationHaveCharteredBefore(token, commSepeartedString):
            return setAviationHaveCharteredBeforeAsJSONData(token: token , yesOrNoString:commSepeartedString)
        case let .setAviationWantToPurchase(token, commSepeartedString):
            return setAviationWantToPurchaseAsJSONData(token: token , charterOrPurchase:commSepeartedString)
        case let .setAviationCharterFrequency(token, corporateFrequency, leisureFrequency):
            return setAviationCharterFrequencyAsJSONData(token: token , corporateFrequency:corporateFrequency, leisureFrequency: leisureFrequency)
        case let .setAviationPreferredCharter(token, commSepeartedString):
            return setAviationPreferredCharterAsJSONData(token: token , shortOrLong:commSepeartedString)
        case let .setAviationPreferredCuisine(token, commSepeartedString, typedPreference):
            return setAviationPreferredCuisineAsJSONData(token: token , commSepeartedString:commSepeartedString, typedPreference: typedPreference)
        case let .setAviationPreferredBevereges(token, commSepeartedString, typedPreference):
            return setAviationPreferredBeveragesAsJSONData(token: token , commSepeartedString:commSepeartedString, typedPreference: typedPreference)
        case let .searchDestination(token , strToSearch):
            return setSearchDestinationAsJSONData(token: token , strToSearch:strToSearch)
        }
    }
    
    fileprivate func getGiftTaxonomiesAsJSONData(token: String) -> Data? {
        let body: [String: Any] = [
            "token": token
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setGiftHabbitsAsJSONData(token: String, commSepeartedString: String, typedPreference:String) -> Data? {
        let body: [String: Any] = [
            "token": token
            ,"gift_habit_id" : commSepeartedString
            ,"gift_habit_id_other" : typedPreference
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
     
    fileprivate func setGiftCategoriesAsJSONData(token: String, commSepeartedString: String, typedPreference:String) -> Data? {
        let body: [String: Any] = [
            "token": token
            ,"gift_category_id" : commSepeartedString
            ,"gift_category_id_other" : typedPreference
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setGiftPreferencesAsJSONData(token: String, commSepeartedString: String, typedPreference:String) -> Data? {
        let body: [String: Any] = [
            "token": token
            ,"gift_preferences_id" : commSepeartedString
            ,"gift_preferences_id_other" : typedPreference
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setAviationHaveCharteredBeforeAsJSONData(token: String, yesOrNoString: String) -> Data? {
        let body: [String: Any] = [
            "token": token
            ,"aviation_chartered_before" : yesOrNoString
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    fileprivate func setAviationWantToPurchaseAsJSONData(token: String, charterOrPurchase: String) -> Data? {
        let body: [String: Any] = [
            "token": token
            ,"aviation_interested_in" : charterOrPurchase
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setAviationCharterFrequencyAsJSONData(token: String, corporateFrequency: Int , leisureFrequency: Int) -> Data? {
        let body: [String: Any] = [
            "token": token
            ,"aviation_times_charter_corporate_jet" : corporateFrequency
            ,"aviation_times_charter_leisure_jet" : leisureFrequency
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setAviationPreferredCharterAsJSONData(token: String, shortOrLong: String) -> Data? {
        let body: [String: Any] = [
            "token": token
            ,"aviation_preferred_charter_range" : shortOrLong
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setAviationPreferredCuisineAsJSONData(token: String, commSepeartedString: String , typedPreference:String) -> Data? {
        let body: [String: Any] = [
            "token": token
            ,"aviation_preferred_cuisine_id" : commSepeartedString
            ,"aviation_preferred_cuisine_id_other" : typedPreference
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setAviationPreferredBeveragesAsJSONData(token: String, commSepeartedString: String, typedPreference:String) -> Data? {
        let body: [String: Any] = [
            "token": token
            ,"aviation_preferred_beverage_id" : commSepeartedString
            ,"aviation_preferred_beverage_id_other" : typedPreference
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setSearchDestinationAsJSONData(token: String, strToSearch: String) -> Data? {
        let body: [String: Any] = [
            "token": token
            ,"search" : strToSearch
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
}

