//
//  PreferencesRouter.swift
//  LUJO
//
//  Created by iMac on 08/05/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//
import Alamofire
import FirebaseCrashlytics
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
    case setAviationPreferredCuisines(String,String,String)
    case setAviationPreferredBevereges(String,String,String)
    case searchDestination(String, String)
    case getOtherInterests(String)
    
    case setYachtHaveCharteredBefore(String,String)
    case setYachtInterestedIn(String,String)
    case setYachtType(String,String)
    case setYachtStyle(String,String)
    case setYachtPreferredCuisines(String,String,String)
    case setYachtOtherInterests(String,String)
    case setYachtCharterFrequency(String,Int,Int)
    case setYachtPreferredRegions(String,String)
    case setYachtLength(String,String)
    case searchRegions(String, String)
    
    case getDiningCuisines(String)
    case getDiningAllergies(String)
    case getDiningPreferences(String)
    case getDiningTimings(String)
    case getDiningBeverages(String)
    case getDiningSeatings(String)
    case setDiningCuisines (String,String,String)
    case setDiningPreferences(String,String,String)
    case setDiningBeverages(String,String,String)
    case setDiningAllergies(String, String)
    case setDiningTimings(String, String)
    case setDiningSeatings(String, String)
    
    case getEventCategory(String)
    case getEventLocation(String)
    case setEventCategory(String,String,String)
    case setEventLocation(String,String)
    
    case getTravelHotelGroups(String)
    case getTravelMedicalMeals(String)
    case getTravelActivities(String)
    case getTravelAmenities(String)
    case setTravelFrequency(String,Int,Int)
    case setTravelDestinations(String,String)
    case setTravelHotelRating(String,Int,Int)
    case setTravelDestinationType(String, String)
    case setTravelHotelGroups(String, String)
    case setTravelAmenities(String, String,String)
    case setTravelActivities(String, String)
    case setTravelAirlines(String, String)
    case setTravelAirplaneSeat(String, String)
    case setTravelCabinClass(String, String,String)
    case setTravelMeals(String, String)
    case setTravelMedicalMeals(String, String,String)
    case setTravelHotelStyles(String, String)
    case setTravelAllergies(String, String,String)
    
    case getVillaDestinations(String)
    case getVillaAmenities(String)
    case getVillaAccomodation(String)
    case setVillaDestinations(String,String)
    case setVillaAmenities(String, String,String)
    case setVillaAccomodation(String, String,String)
    
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
        case .setAviationPreferredCuisines:  fallthrough
        case .setAviationPreferredBevereges: fallthrough
            
        case .setYachtHaveCharteredBefore: fallthrough
        case .setYachtInterestedIn: fallthrough
        case .setYachtType: fallthrough
        case .setYachtStyle: fallthrough
        case .setYachtPreferredCuisines:  fallthrough
        case .setYachtOtherInterests: fallthrough
        case .setYachtCharterFrequency: fallthrough
        case .setYachtPreferredRegions: fallthrough
        case .setYachtLength: fallthrough
        case .searchDestination: fallthrough
        case .searchRegions:    fallthrough
            
        case .getDiningCuisines: fallthrough
        case .getDiningAllergies: fallthrough
        case .getDiningPreferences: fallthrough
        case .getDiningTimings: fallthrough
        case .getDiningBeverages: fallthrough
        case .getDiningSeatings: fallthrough
        case .setDiningCuisines: fallthrough
        case .setDiningPreferences: fallthrough
        case .setDiningBeverages: fallthrough
        case .setDiningAllergies: fallthrough
        case .setDiningTimings: fallthrough
        case .setDiningSeatings: fallthrough
            
        case .getEventCategory: fallthrough
        case .getEventLocation: fallthrough
        case .setEventCategory: fallthrough
        case .setEventLocation: fallthrough
            
        case .getTravelHotelGroups: fallthrough
        case .getTravelMedicalMeals: fallthrough
        case .getTravelActivities: fallthrough
        case .getTravelAmenities: fallthrough
        case .setTravelFrequency: fallthrough
        case .setTravelDestinations: fallthrough
        case .setTravelHotelRating: fallthrough
        case .setTravelDestinationType: fallthrough
        case .setTravelHotelGroups: fallthrough
        case .setTravelAmenities: fallthrough
        case .setTravelActivities: fallthrough
        case .setTravelAirlines: fallthrough
        case .setTravelAirplaneSeat: fallthrough
        case .setTravelCabinClass: fallthrough
        case .setTravelMeals: fallthrough
        case .setTravelMedicalMeals: fallthrough
        case .setTravelHotelStyles: fallthrough
        case .setTravelAllergies: fallthrough
            
        case .getVillaDestinations: fallthrough
        case .getVillaAmenities: fallthrough
        case .getVillaAccomodation: fallthrough
        case .setVillaDestinations: fallthrough
        case .setVillaAmenities: fallthrough
        case .setVillaAccomodation:
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
        case .setAviationPreferredCuisines:      fallthrough
        case .setAviationPreferredBevereges:
            newURLComponents.path.append("/preferences/aviation")
            
        case .setYachtHaveCharteredBefore: fallthrough
        case .setYachtInterestedIn: fallthrough
        case .setYachtType: fallthrough
        case .setYachtStyle: fallthrough
        case .setYachtPreferredCuisines:      fallthrough
        case .setYachtCharterFrequency: fallthrough
        case .setYachtPreferredRegions: fallthrough
        case .setYachtLength: fallthrough
        case .setYachtOtherInterests:   newURLComponents.path.append("/preferences/yacht")
        case .searchRegions:    newURLComponents.path.append("/reference/regions")
        case .searchDestination:    newURLComponents.path.append("/reference/locations")
            
        case .getDiningCuisines:  newURLComponents.path.append("/reference/cuisines")
        case .getDiningAllergies:  newURLComponents.path.append("/reference/allergies")
        case .getDiningPreferences:  newURLComponents.path.append("/reference/dining-preferences")
        case .getDiningTimings:  newURLComponents.path.append("/reference/dining-timings")
        case .getDiningBeverages:  newURLComponents.path.append("/reference/beverages")
        case .getDiningSeatings:  newURLComponents.path.append("/reference/seating")
        case .setDiningCuisines: fallthrough
        case .setDiningPreferences: fallthrough
        case .setDiningBeverages: fallthrough
        case .setDiningAllergies: fallthrough
        case .setDiningTimings: fallthrough
        case .setDiningSeatings: newURLComponents.path.append("/preferences/restaurant")
            
        case .getEventCategory: newURLComponents.path.append("/reference/event-categories")
        case .getEventLocation: newURLComponents.path.append("/reference/event-continents")
        case .setEventCategory: fallthrough
        case .setEventLocation: newURLComponents.path.append("/preferences/event")
            
        case .getTravelHotelGroups: newURLComponents.path.append("/reference/hotel-groups")
        case .getTravelMedicalMeals: newURLComponents.path.append("/reference/medical-dietary-meal")
        case .getTravelActivities: newURLComponents.path.append("/reference/hotel-activities")
        case .getTravelAmenities: newURLComponents.path.append("/reference/hotel-amenities")
        case .setTravelFrequency: fallthrough
        case .setTravelDestinations: fallthrough
        case .setTravelHotelRating: fallthrough
        case .setTravelDestinationType: fallthrough
        case .setTravelHotelGroups: fallthrough
        case .setTravelAmenities: fallthrough
        case .setTravelActivities: fallthrough
        case .setTravelAirlines: fallthrough
        case .setTravelAirplaneSeat: fallthrough
        case .setTravelCabinClass: fallthrough
        case .setTravelMeals: fallthrough
        case .setTravelMedicalMeals: fallthrough
        case .setTravelHotelStyles: fallthrough
        case .setTravelAllergies: newURLComponents.path.append("/preferences/travel")
        
        case .getVillaDestinations: newURLComponents.path.append("/reference/locations")
        case .getVillaAmenities: newURLComponents.path.append("/reference/villa-amenities")
        case .getVillaAccomodation: newURLComponents.path.append("/reference/accommodations")
        case .setVillaDestinations: fallthrough
        case .setVillaAmenities: fallthrough
        case .setVillaAccomodation: newURLComponents.path.append("/preferences/villa")
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
        case .getAllPreferences:    return nil
        case .getAviationCategories:    return nil
        case let .getGiftHabits(token):         fallthrough
        case let .getGiftCategories(token):     fallthrough
        case let .getGiftPreferences(token):    fallthrough
        case let .getCuisines(token):    fallthrough
        case let .getOtherInterests(token):    fallthrough
        case let .getAviationBeverages(token): fallthrough
            
        case let .getDiningCuisines(token):    fallthrough
        case let .getDiningAllergies(token):    fallthrough
        case let .getDiningPreferences(token):    fallthrough
        case let .getDiningTimings(token):    fallthrough
        case let .getDiningBeverages(token):    fallthrough
        case let .getDiningSeatings(token): fallthrough
        case let .getEventCategory(token): fallthrough
        case let .getEventLocation(token): fallthrough
        case let .getTravelHotelGroups(token): fallthrough
        case let .getTravelMedicalMeals(token): fallthrough
        case let .getTravelActivities(token): fallthrough
        case let .getTravelAmenities(token): fallthrough
        case let .getVillaDestinations(token): fallthrough
        case let .getVillaAmenities(token): fallthrough
        case let .getVillaAccomodation(token):
            return getTaxonomiesAsJSONData(token: token)
            
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
        case let .setAviationPreferredCuisines(token, commaSeparatedString, typedPreference):
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
        case let .setYachtPreferredCuisines(token, commaSeparatedString, typedPreference):
            return setYachtPreferredCuisineAsJSONData(token: token , commaSeparatedString:commaSeparatedString, typedPreference: typedPreference)
        case let .setYachtOtherInterests(token, commaSeparatedString ):
            return setYachtOtherInterestsAsJSONData(token: token , commaSeparatedString:commaSeparatedString)
        case let .setYachtCharterFrequency(token, corporateFrequency, leisureFrequency):
            return setYachtCharterFrequencyAsJSONData(token: token , corporateFrequency:corporateFrequency, leisureFrequency: leisureFrequency)
        case let .setYachtPreferredRegions(token, commaSeparatedString):
            return setYachtPreferredRegionsAsJSONData(token: token , commaSeparatedString:commaSeparatedString)
        case let .setYachtLength(token, commaSeparatedString):
            return setYachtLengthAsJSONData(token: token , commaSeparatedString:commaSeparatedString)
        case let .searchRegions(token , strToSearch):
            return setSearchRegionsAsJSONData(token: token , strToSearch:strToSearch)
        case let .setDiningCuisines(token, commaSeparatedString, typedPreference):
            return setDiningCuisinesAsJSONData(token: token , commaSeparatedString:commaSeparatedString, typedPreference: typedPreference)
        case let .setDiningPreferences(token, commaSeparatedString, typedPreference):
            return setDiningPreferencesAsJSONData(token: token , commaSeparatedString:commaSeparatedString, typedPreference: typedPreference)
        case let .setDiningBeverages(token, commaSeparatedString, typedPreference):
            return setDiningBeveragesAsJSONData(token: token , commaSeparatedString:commaSeparatedString, typedPreference: typedPreference)
        case let .setDiningAllergies(token, commaSeparatedString):
            return setDiningAllergiesAsJSONData(token: token , commaSeparatedString:commaSeparatedString)
        case let .setDiningTimings(token, commaSeparatedString):
            return setDiningTimingsAsJSONData(token: token , commaSeparatedString:commaSeparatedString)
        case let .setDiningSeatings(token, commaSeparatedString):
            return setDiningSeatingsAsJSONData(token: token , commaSeparatedString:commaSeparatedString)
            

        case let .setEventCategory(token, commaSeparatedString, typedPreference):
            return setEventCategoryAsJSONData(token: token , commaSeparatedString:commaSeparatedString, typedPreference: typedPreference)
        case let .setEventLocation(token, commaSeparatedString):
            return setEventLocationAsJSONData(token: token , commaSeparatedString:commaSeparatedString)
        

        case let  .setTravelFrequency(token, businessFrequency, leisureFrequency):
            return setTravelFrequencyAsJSONData(token: token , businessFrequency:businessFrequency, leisureFrequency:leisureFrequency)
        case let  .setTravelDestinations(token, commaSeparatedString):
            return setTravelDestinationsAsJSONData(token: token , commaSeparatedString:commaSeparatedString)
        case let  .setTravelHotelRating(token, businessRating, leisureRating):
            return setTravelHotelRatingAsJSONData(token: token , businessRating:businessRating, leisureRating: leisureRating)
        case let  .setTravelDestinationType(token, commaSeparatedString):
            return setTravelDestinationTypeAsJSONData(token: token , commaSeparatedString:commaSeparatedString)
        case let  .setTravelHotelGroups(token, commaSeparatedString):
            return setTravelHotelGroupsAsJSONData(token: token , commaSeparatedString:commaSeparatedString)
        case let  .setTravelAmenities(token, commaSeparatedString, typedPreference):
            return setTravelAmenitiesAsJSONData(token: token , commaSeparatedString:commaSeparatedString, typedPreference: typedPreference)
        case let  .setTravelActivities(token, commaSeparatedString):
            return setTravelActivitiesAsJSONData(token: token , commaSeparatedString:commaSeparatedString)
        case let  .setTravelAirlines(token, commaSeparatedString):
            return setTravelAirlinesAsJSONData(token: token , commaSeparatedString:commaSeparatedString)
        case let  .setTravelAirplaneSeat(token, airplaneSeat):
            return setTravelAirplaneSeatAsJSONData(token: token , airplaneSeat:airplaneSeat)
        case let  .setTravelCabinClass(token, businessCabin, leisureCabin):
            return setTravelCabinClassAsJSONData(token: token , businessCabin:businessCabin, leisureCabin: leisureCabin)
        case let  .setTravelMeals(token, commaSeparatedString):
            return setTravelMealsAsJSONData(token: token , commaSeparatedString:commaSeparatedString)
        case let  .setTravelMedicalMeals(token, commaSeparatedString, typedPreference):
            return setTravelMedicalMealsAsJSONData(token: token , commaSeparatedString:commaSeparatedString, typedPreference: typedPreference)
        case let  .setTravelHotelStyles(token, commaSeparatedString):
            return setTravelHotelStylesAsJSONData(token: token , commaSeparatedString:commaSeparatedString)
        case let  .setTravelAllergies(token, commaSeparatedString, typedPreference):
            return setTravelAllergiesAsJSONData(token: token , commaSeparatedString:commaSeparatedString, typedPreference: typedPreference)
        case let  .setVillaDestinations(token, commaSeparatedString):
            return setVillaDestinationsAsJSONData(token: token , commaSeparatedString:commaSeparatedString)
        case let  .setVillaAmenities(token, commaSeparatedString, typedPreference):
            return setVillaAmenitiesAsJSONData(token: token , commaSeparatedString:commaSeparatedString, typedPreference: typedPreference)
        case let  .setVillaAccomodation(token, commaSeparatedString, typedPreference):
            return setVillaAccomodationAsJSONData(token: token , commaSeparatedString:commaSeparatedString, typedPreference: typedPreference)
        }
    }
    
    fileprivate func getTaxonomiesAsJSONData(token: String) -> Data? {
        let body: [String: Any] = [
            "token": token
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setGiftHabbitsAsJSONData(token: String, commaSeparatedString: String, typedPreference:String) -> Data? {
        let body: [String: Any] = [
            "token": token
            ,"gift_habit_id_other" : typedPreference
            ,"gift_habit_id" : commaSeparatedString
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
     
    fileprivate func setGiftCategoriesAsJSONData(token: String, commaSeparatedString: String, typedPreference:String) -> Data? {
        let body: [String: Any] = [
            "token": token
            ,"gift_category_id_other": typedPreference
            ,"gift_category_id" : commaSeparatedString
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setGiftPreferencesAsJSONData(token: String, commaSeparatedString: String, typedPreference:String) -> Data? {
        let body: [String: Any] = [
            "token": token
            ,"gift_preferences_id_other": typedPreference
            ,"gift_preferences_id": commaSeparatedString
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
    
    fileprivate func setAviationPreferredDestinationsAsJSONData(token: String, commaSeparatedString: String) -> Data? {
        let body: [String: Any] = [
            "token": token
            ,"aviation_preferred_destinations":commaSeparatedString
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setAviationPreferredAirportsAsJSONData(token: String, commaSeparatedString: String) -> Data? {
        let body: [String: Any] = [
            "token": token
            ,"aviation_preferred_airports": commaSeparatedString
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setAviationAircraftCategoryAsJSONData(token: String, commaSeparatedString: String) -> Data? {
        let body: [String: Any] = [
            "token": token
            ,"aviation_aircraft_category_id": commaSeparatedString
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
    
    fileprivate func setAviationPreferredCuisineAsJSONData(token: String, commaSeparatedString: String , typedPreference:String) -> Data? {
        let body: [String: Any] = [
            "token": token
            ,"aviation_preferred_cuisine_id_other": typedPreference
            ,"aviation_preferred_cuisine_id": commaSeparatedString
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setAviationPreferredBeveragesAsJSONData(token: String, commaSeparatedString: String, typedPreference:String) -> Data? {
        let body: [String: Any] = [
            "token": token
            ,"aviation_preferred_beverage_id_other": typedPreference
            ,"aviation_preferred_beverage_id" : commaSeparatedString
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
    
    fileprivate func setYachtHaveCharteredBeforeAsJSONData(token: String, commaSeparatedString: String) -> Data? {
        let body: [String: Any] = [
            "token": token
            ,"yacht_chartered_before": commaSeparatedString
        ]

        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setYachtInterestedInAsJSONData(token: String, commaSeparatedString: String) -> Data? {
        let body: [String: Any] = [
            "token": token
            ,"yacht_interested_in" : commaSeparatedString
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setYachtTypeAsJSONData(token: String, commaSeparatedString: String) -> Data? {
        let body: [String: Any] = [
            "token": token
            ,"yacht_type": commaSeparatedString
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setYachtStyleAsJSONData(token: String, commaSeparatedString: String) -> Data? {
        let body: [String: Any] = [
            "token": token
            ,"yacht_style" : commaSeparatedString
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setYachtPreferredCuisineAsJSONData(token: String, commaSeparatedString: String , typedPreference:String) -> Data? {
        let body: [String: Any] = [
            "token": token
            ,"yacht_preferred_cuisine_id_other": typedPreference
            ,"yacht_preferred_cuisine_id": commaSeparatedString
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setYachtOtherInterestsAsJSONData(token: String, commaSeparatedString: String ) -> Data? {
        let body: [String: Any] = [
            "token": token
            ,"yacht_interests_id": commaSeparatedString
        ]

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
    
    fileprivate func setYachtPreferredRegionsAsJSONData(token: String, commaSeparatedString: String) -> Data? {
        let body: [String: Any] = [
            "token": token
            ,"yacht_preferred_destinations": commaSeparatedString
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setYachtLengthAsJSONData(token: String, commaSeparatedString: String) -> Data? {
        let body: [String: Any] = [
            "token": token
            ,"yacht_length": commaSeparatedString
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setSearchRegionsAsJSONData(token: String, strToSearch: String) -> Data? {
        let body: [String: Any] = [
            "token": token
            ,"search" : strToSearch
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setDiningCuisinesAsJSONData(token: String, commaSeparatedString: String , typedPreference:String) -> Data? {
        let body: [String: Any] = [
            "token": token
            ,"restaurant_preferred_cuisine_id_other": typedPreference
            ,"restaurant_preferred_cuisine_id": commaSeparatedString
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setDiningPreferencesAsJSONData(token: String, commaSeparatedString: String , typedPreference:String) -> Data? {
        let body: [String: Any] = [
            "token": token
            ,"restaurant_dinning_id_other": typedPreference
            ,"restaurant_dinning_id": commaSeparatedString
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setDiningBeveragesAsJSONData(token: String, commaSeparatedString: String , typedPreference:String) -> Data? {
        let body: [String: Any] = [
            "token": token
            ,"restaurant_beverage_id_other": typedPreference
            ,"restaurant_beverage_id": commaSeparatedString
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setDiningAllergiesAsJSONData(token: String, commaSeparatedString: String ) -> Data? {
        let body: [String: Any] = [
            "token": token
            ,"restaurant_allergy_id": commaSeparatedString
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setDiningTimingsAsJSONData(token: String, commaSeparatedString: String ) -> Data? {
        let body: [String: Any] = [
            "token": token
            ,"restaurant_timing_id": commaSeparatedString
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setDiningSeatingsAsJSONData(token: String, commaSeparatedString: String ) -> Data? {
        let body: [String: Any] = [
            "token": token
            ,"restaurant_seating_id": commaSeparatedString
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setEventCategoryAsJSONData(token: String , commaSeparatedString:String, typedPreference: String) -> Data?{
        let body: [String: Any] = [
            "token": token
            ,"event_category_id_other": typedPreference
            ,"event_category_id": commaSeparatedString
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setEventLocationAsJSONData(token: String , commaSeparatedString:String) -> Data?{
        let body: [String: Any] = [
            "token": token
            ,"event_location_id": commaSeparatedString
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setTravelFrequencyAsJSONData(token: String , businessFrequency:Int, leisureFrequency:Int) -> Data?{
        let body: [String: Any] = [
            "token": token
            ,"travel_times_business": businessFrequency
            ,"travel_times_leisure": leisureFrequency
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

    fileprivate func setTravelDestinationsAsJSONData(token: String , commaSeparatedString:String) -> Data?{
        let body: [String: Any] = [
            "token": token
            ,"travel_preferred_destinations": commaSeparatedString
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

    fileprivate func setTravelHotelRatingAsJSONData(token: String , businessRating:Int, leisureRating: Int) -> Data?{
        let body: [String: Any] = [
            "token": token
            ,"travel_rating_business_hotels": businessRating
            ,"travel_rating_leisure_hotels": leisureRating
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

    fileprivate func setTravelDestinationTypeAsJSONData(token: String , commaSeparatedString:String) -> Data?{
        let body: [String: Any] = [
            "token": token
            ,"travel_destination_type": commaSeparatedString
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

    fileprivate func setTravelHotelGroupsAsJSONData(token: String , commaSeparatedString:String) -> Data?{
        let body: [String: Any] = [
            "token": token
            ,"travel_hotel_group": commaSeparatedString
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

    fileprivate func setTravelAmenitiesAsJSONData(token: String , commaSeparatedString:String, typedPreference: String) -> Data?{
        let body: [String: Any] = [
            "token": token
            ,"travel_amenity_id": commaSeparatedString
            ,"travel_amenity_id_other": typedPreference
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

    fileprivate func setTravelActivitiesAsJSONData(token: String , commaSeparatedString:String) -> Data?{
        let body: [String: Any] = [
            "token": token
            ,"travel_activity_id": commaSeparatedString
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

    fileprivate func setTravelAirlinesAsJSONData(token: String , commaSeparatedString:String) -> Data?{
        let body: [String: Any] = [
            "token": token
            ,"travel_airline_id": commaSeparatedString
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

    fileprivate func setTravelAirplaneSeatAsJSONData(token: String , airplaneSeat:String) -> Data?{
        let body: [String: Any] = [
            "token": token
            ,"travel_airplane_seat": airplaneSeat
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

    fileprivate func setTravelCabinClassAsJSONData(token: String , businessCabin:String, leisureCabin: String) -> Data?{
        let body: [String: Any] = [
            "token": token
            ,"travel_airplane_business_cabin_class": businessCabin
            ,"travel_airplane_leisure_cabin_class": leisureCabin
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

    fileprivate func setTravelMealsAsJSONData(token: String , commaSeparatedString:String) -> Data?{
        let body: [String: Any] = [
            "token": token
            ,"travel_airplane_meals": commaSeparatedString
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

    fileprivate func setTravelMedicalMealsAsJSONData(token: String , commaSeparatedString:String, typedPreference: String) -> Data?{
        let body: [String: Any] = [
            "token": token
            ,"travel_media_dietary_meal": commaSeparatedString
            ,"travel_media_dietary_meal_other": typedPreference
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

    fileprivate func setTravelHotelStylesAsJSONData(token: String , commaSeparatedString:String) -> Data?{
        let body: [String: Any] = [
            "token": token
            ,"travel_hotel_types": commaSeparatedString
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

    fileprivate func setTravelAllergiesAsJSONData(token: String , commaSeparatedString:String, typedPreference: String) -> Data?{
        let body: [String: Any] = [
            "token": token
            ,"travel_allergy_id": commaSeparatedString
            ,"travel_allergy_id_other": typedPreference
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func  setVillaDestinationsAsJSONData(token: String , commaSeparatedString:String) -> Data?{
        let body: [String: Any] = [
            "token": token
            ,"villa_preferred_destinations_id": commaSeparatedString
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func  setVillaAmenitiesAsJSONData(token: String , commaSeparatedString:String, typedPreference: String) -> Data?{
        let body: [String: Any] = [
            "token": token
            ,"villa_preferred_amenities_id": commaSeparatedString
            ,"villa_preferred_amenities_id_other": typedPreference
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func  setVillaAccomodationAsJSONData(token: String , commaSeparatedString:String, typedPreference: String) -> Data?{
        let body: [String: Any] = [
            "token": token
            ,"villa_preferred_accommodations_id": commaSeparatedString
            ,"villa_preferred_accommodations_id_other": typedPreference
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

}

