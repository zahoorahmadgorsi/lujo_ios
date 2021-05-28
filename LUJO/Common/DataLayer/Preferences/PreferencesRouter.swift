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
    case getCuisines(String)
    
    case getAviationBeverages(String)
    case getAviationCategories(String)
    case setAviationHaveCharteredBefore(String,String)
    case setAviationPreferredDestinations(String,String)
    case setAviationPreferredAirports(String,String)
    case setAviationAircraftCategory(String,String)
    case setAviationCharterFrequency(String,Int,Int)
    case setAviationInterestedIn(String,String)
    case setAviationPreferredCharter(String,String)
    case setPreferredCuisines(String,String,String)
    case setAviationPreferredBevereges(String,String,String)
    case searchDestination(String, String)
    case getOtherInterests(String)
    
    case setYachtHaveCharteredBefore(String,String)
    case setYachtInterestedIn(String,String)
    case setYachtType(String,String)
    case setYachtStyle(String,String)
    case setOtherInterests(String,String)
    case setYachtCharterFrequency(String,Int,Int)
    case setYachtPreferredRegions(String,String)
    case setYachtLength(String,String)
    
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
        case .getAllPreferences:    fallthrough
        case .getAviationCategories: return .get
        case .getGiftHabits:        fallthrough
        case .getGiftCategories:    fallthrough
        case .getGiftPreferences:   fallthrough
        case .setGiftHabits:        fallthrough
        case .setGiftCategories:    fallthrough
        case .setGiftPreferences:   fallthrough
        case .getAviationBeverages: fallthrough
        case .getCuisines: fallthrough
        case .getOtherInterests: fallthrough
        case .setAviationHaveCharteredBefore:    fallthrough
        case .setAviationInterestedIn:         fallthrough
        case .setAviationPreferredDestinations: fallthrough
        case .setAviationPreferredAirports: fallthrough
        case .setAviationAircraftCategory: fallthrough
        case .setAviationCharterFrequency: fallthrough
        case .setAviationPreferredCharter:       fallthrough
        case .setPreferredCuisines:  fallthrough
        case .setAviationPreferredBevereges: fallthrough
            
        case .setYachtHaveCharteredBefore: fallthrough
        case .setYachtInterestedIn: fallthrough
        case .setYachtType: fallthrough
        case .setYachtStyle: fallthrough
        case .setOtherInterests: fallthrough
        case .setYachtCharterFrequency: fallthrough
        case .setYachtPreferredRegions: fallthrough
        case .setYachtLength: fallthrough
            
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
        case let .getAviationCategories(token):
            newURLComponents.path.append("/baroque/aviation/categories")
            newURLComponents.queryItems = [
                URLQueryItem(name: "token", value: token),
            ]
        case .getGiftHabits:        newURLComponents.path.append("/reference/gift-habits")
        case .getGiftCategories:    newURLComponents.path.append("/reference/gift-categories")
        case .getGiftPreferences:   newURLComponents.path.append("/reference/gift-preferences")
        case .setGiftHabits:        fallthrough
        case .setGiftCategories:    fallthrough
        case .setGiftPreferences:   newURLComponents.path.append("/preferences/gift")
        case .getCuisines:  newURLComponents.path.append("/reference/cuisines")
        case .getOtherInterests:  newURLComponents.path.append("/reference/interests")
        case .getAviationBeverages:  newURLComponents.path.append("/reference/beverages")
        case .setAviationHaveCharteredBefore:    fallthrough
        case .setAviationInterestedIn:         fallthrough
        case .setAviationPreferredDestinations: fallthrough
        case .setAviationPreferredAirports: fallthrough
        case .setAviationAircraftCategory: fallthrough
        case .setAviationCharterFrequency: fallthrough
        case .setAviationPreferredCharter:       fallthrough
        case .setPreferredCuisines:      fallthrough
        case .setAviationPreferredBevereges:
            newURLComponents.path.append("/preferences/aviation")
            
        case .setYachtHaveCharteredBefore: fallthrough
        case .setYachtInterestedIn: fallthrough
        case .setYachtType: fallthrough
        case .setYachtStyle: fallthrough
        case .setYachtCharterFrequency: fallthrough
        case .setYachtPreferredRegions: fallthrough
        case .setYachtLength: fallthrough
        case .setOtherInterests:
            newURLComponents.path.append("/preferences/yacht")
            
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
        case .getAviationCategories:    return nil
        case let .getGiftHabits(token):         fallthrough
        case let .getGiftCategories(token):     fallthrough
        case let .getGiftPreferences(token):    fallthrough
        case let .getCuisines(token):    fallthrough
        case let .getOtherInterests(token):    fallthrough
        case let .getAviationBeverages(token):
            return getGiftTaxonomiesAsJSONData(token: token)
        case let .setGiftHabits(token,commaSeparatedString, typedPreference):
            return setGiftHabbitsAsJSONData(token: token, commaSeparatedString:commaSeparatedString, typedPreference: typedPreference)
        case let .setGiftCategories(token, commaSeparatedString, typedPreference):
            return setGiftCategoriesAsJSONData(token: token , commaSeparatedString:commaSeparatedString, typedPreference: typedPreference)
        case let .setGiftPreferences(token, commaSeparatedString, typedPreference):
            return setGiftPreferencesAsJSONData(token: token , commaSeparatedString:commaSeparatedString, typedPreference: typedPreference)
        
        case let .setAviationHaveCharteredBefore(token, commaSeparatedString):
            return setAviationHaveCharteredBeforeAsJSONData(token: token , yesOrNoString:commaSeparatedString)
        case let .setAviationInterestedIn(token, commaSeparatedString):
            return setAviationWantToPurchaseAsJSONData(token: token , charterOrPurchase:commaSeparatedString)
        case let .setAviationPreferredDestinations(token, commaSeparatedString):
            return setAviationPreferredDestinationsAsJSONData(token: token , commaSeparatedString:commaSeparatedString)
        case let .setAviationPreferredAirports(token, commaSeparatedString):
            return setAviationPreferredAirportsAsJSONData(token: token , commaSeparatedString:commaSeparatedString)
        case let .setAviationAircraftCategory(token, commaSeparatedString):
            return setAviationAircraftCategoryAsJSONData(token: token , commaSeparatedString:commaSeparatedString)
        case let .setAviationCharterFrequency(token, corporateFrequency, leisureFrequency):
            return setAviationCharterFrequencyAsJSONData(token: token , corporateFrequency:corporateFrequency, leisureFrequency: leisureFrequency)
        case let .setAviationPreferredCharter(token, commaSeparatedString):
            return setAviationPreferredCharterAsJSONData(token: token , shortOrLong:commaSeparatedString)
        case let .setPreferredCuisines(token, commaSeparatedString, typedPreference):
            return setAviationPreferredCuisineAsJSONData(token: token , commaSeparatedString:commaSeparatedString, typedPreference: typedPreference)
        case let .setAviationPreferredBevereges(token, commaSeparatedString, typedPreference):
            return setAviationPreferredBeveragesAsJSONData(token: token , commaSeparatedString:commaSeparatedString, typedPreference: typedPreference)
        case let .searchDestination(token , strToSearch):
            return setSearchDestinationAsJSONData(token: token , strToSearch:strToSearch)
            
        case let .setYachtHaveCharteredBefore(token, commaSeparatedString):
            return setYachtHaveCharteredBeforeAsJSONData(token: token , commaSeparatedString:commaSeparatedString)
        case let .setYachtInterestedIn(token, commaSeparatedString):
            return setYachtInterestedInAsJSONData(token: token , commaSeparatedString:commaSeparatedString)
        case let .setYachtType(token, commaSeparatedString):
            return setYachtTypeAsJSONData(token: token , commaSeparatedString:commaSeparatedString)
        case let .setYachtStyle(token, commaSeparatedString):
            return setYachtStyleAsJSONData(token: token , commaSeparatedString:commaSeparatedString)
        case let .setOtherInterests(token, commaSeparatedString):
            return setOtherInterestsAsJSONData(token: token , commaSeparatedString:commaSeparatedString)
        case let .setYachtCharterFrequency(token, corporateFrequency, leisureFrequency):
            return setYachtCharterFrequencyAsJSONData(token: token , corporateFrequency:corporateFrequency, leisureFrequency: leisureFrequency)
        case let .setYachtPreferredRegions(token, commaSeparatedString):
            return setYachtPreferredRegionsAsJSONData(token: token , commaSeparatedString:commaSeparatedString)
        case let .setYachtLength(token, commaSeparatedString):
            return setYachtLengthAsJSONData(token: token , commaSeparatedString:commaSeparatedString)
        }
    }
    
    fileprivate func getGiftTaxonomiesAsJSONData(token: String) -> Data? {
        let body: [String: Any] = [
            "token": token
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setGiftHabbitsAsJSONData(token: String, commaSeparatedString: String?, typedPreference:String) -> Data? {
        var body: [String: Any] = [
            "token": token
            ,"gift_habit_id_other" : typedPreference
        ]
        if let commaSeparatedString = commaSeparatedString, !commaSeparatedString.isEmpty {
            body["gift_habit_id"] = commaSeparatedString
        }

        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
     
    fileprivate func setGiftCategoriesAsJSONData(token: String, commaSeparatedString: String?, typedPreference:String) -> Data? {
        var body: [String: Any] = [
            "token": token
            ,"gift_category_id_other": typedPreference
        ]
        if let commaSeparatedString = commaSeparatedString, !commaSeparatedString.isEmpty {
            body["gift_category_id"] = commaSeparatedString
        }
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setGiftPreferencesAsJSONData(token: String, commaSeparatedString: String?, typedPreference:String) -> Data? {
        var body: [String: Any] = [
            "token": token
            ,"gift_preferences_id_other": typedPreference
        ]
        if let commaSeparatedString = commaSeparatedString, !commaSeparatedString.isEmpty {
            body["gift_preferences_id"] = commaSeparatedString
        }

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
    
    fileprivate func setAviationPreferredDestinationsAsJSONData(token: String, commaSeparatedString: String?) -> Data? {
        var body: [String: Any] = [
            "token": token
        ]
        if let commaSeparatedString = commaSeparatedString, !commaSeparatedString.isEmpty {
            body["aviation_preferred_destinations"] = commaSeparatedString
        }
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setAviationPreferredAirportsAsJSONData(token: String, commaSeparatedString: String?) -> Data? {
        var body: [String: Any] = [
            "token": token
        ]
        if let commaSeparatedString = commaSeparatedString, !commaSeparatedString.isEmpty {
            body["aviation_preferred_airports"] = commaSeparatedString
        }
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setAviationAircraftCategoryAsJSONData(token: String, commaSeparatedString: String?) -> Data? {
        var body: [String: Any] = [
            "token": token
        ]
        if let commaSeparatedString = commaSeparatedString, !commaSeparatedString.isEmpty {
            body["aviation_aircraft_category_id"] = commaSeparatedString
        }
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
    
    fileprivate func setAviationPreferredCuisineAsJSONData(token: String, commaSeparatedString: String? , typedPreference:String) -> Data? {
        var body: [String: Any] = [
            "token": token
            ,"aviation_preferred_cuisine_id_other": typedPreference
        ]
        if let commaSeparatedString = commaSeparatedString, !commaSeparatedString.isEmpty {
            body["aviation_preferred_cuisine_id"] = commaSeparatedString
        }
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setAviationPreferredBeveragesAsJSONData(token: String, commaSeparatedString: String?, typedPreference:String) -> Data? {
        var body: [String: Any] = [
            "token": token
            ,"aviation_preferred_beverage_id_other": typedPreference
        ]
        if let commaSeparatedString = commaSeparatedString, !commaSeparatedString.isEmpty {
            body["aviation_preferred_beverage_id"] = commaSeparatedString
        }

        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setSearchDestinationAsJSONData(token: String, strToSearch: String) -> Data? {
        let body: [String: Any] = [
            "token": token
            ,"search" : strToSearch
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setYachtHaveCharteredBeforeAsJSONData(token: String, commaSeparatedString: String?) -> Data? {
        var body: [String: Any] = [
            "token": token
        ]
        if let commaSeparatedString = commaSeparatedString, !commaSeparatedString.isEmpty {
            body["yacht_chartered_before"] = commaSeparatedString
        }
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setYachtInterestedInAsJSONData(token: String, commaSeparatedString: String?) -> Data? {
        var body: [String: Any] = [
            "token": token
        ]
        if let commaSeparatedString = commaSeparatedString, !commaSeparatedString.isEmpty {
            body["yacht_interested_in"] = commaSeparatedString
        }
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setYachtTypeAsJSONData(token: String, commaSeparatedString: String?) -> Data? {
        var body: [String: Any] = [
            "token": token
        ]
        if let commaSeparatedString = commaSeparatedString, !commaSeparatedString.isEmpty {
            body["yacht_type"] = commaSeparatedString
        }
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setYachtStyleAsJSONData(token: String, commaSeparatedString: String?) -> Data? {
        var body: [String: Any] = [
            "token": token
        ]
        if let commaSeparatedString = commaSeparatedString, !commaSeparatedString.isEmpty {
            body["yacht_style"] = commaSeparatedString
        }
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setOtherInterestsAsJSONData(token: String, commaSeparatedString: String?) -> Data? {
        var body: [String: Any] = [
            "token": token
        ]
        if let commaSeparatedString = commaSeparatedString, !commaSeparatedString.isEmpty {
            body["yacht_interests_id"] = commaSeparatedString
        }
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setYachtCharterFrequencyAsJSONData(token: String, corporateFrequency: Int , leisureFrequency: Int) -> Data? {
        let body: [String: Any] = [
            "token": token
            ,"yacht_times_charter_corporate_jet" : corporateFrequency
            ,"yacht_times_charter_leisure_jet" : leisureFrequency
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setYachtPreferredRegionsAsJSONData(token: String, commaSeparatedString: String?) -> Data? {
        var body: [String: Any] = [
            "token": token
        ]
        if let commaSeparatedString = commaSeparatedString, !commaSeparatedString.isEmpty {
            body["yacht_preferred_destinations"] = commaSeparatedString
        }
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setYachtLengthAsJSONData(token: String, commaSeparatedString: String?) -> Data? {
        var body: [String: Any] = [
            "token": token
        ]
        if let commaSeparatedString = commaSeparatedString, !commaSeparatedString.isEmpty {
            body["yacht_length"] = commaSeparatedString
        }
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
}

