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
    
    case getAllPreferences
    case getGiftHabits
    case getGiftCategories
    case getGiftPreferences
    case setGiftHabits(String)
    case setGiftCategories(String)
    case setGiftPreferences(String)
    case getCuisines
    case getEventCategory
    case getEventLocation
    
    case getAviationBeverages
    case getAviationCategories
    case setAviationHaveCharteredBefore(String,String)
    case setAviationPreferredDestinations(String,String)
    case setAviationPreferredAirports(String,String)
    case setAviationAircraftCategory(String)
    case setAviationCharterFrequency(String,Int,Int)
    case setAviationInterestedIn(String,String)
    case setAviationPreferredCharter(String,String)
    case setAviationPreferredCuisines(String,String,String)
    case setAviationPreferredBevereges(String,String,String)
    case searchDestination(String)
    case getOtherInterests
    
    case setYachtHaveCharteredBefore(String,String)
    case setYachtInterestedIn(String,String)
    case setYachtType(String,String)
    case setYachtStyle(String,String)
    case setYachtPreferredCuisines(String,String,String)
    case setYachtOtherInterests(String,String)
    case setYachtCharterFrequency(String,Int,Int)
    case setYachtPreferredRegions(String,String)
    case setYachtLength(String)
    case searchRegions(String, String)
    
    case getDiningCuisines
    case getDiningAllergies
    case getDiningPreferences
    case getDiningTimings
    case getDiningBeverages
    case getDiningSeatings
    case setDiningCuisines (String,String,String)
    case setDiningPreferences(String,String,String)
    case setDiningBeverages(String,String,String)
    case setDiningAllergies(String, String)
    case setDiningTimings(String, String)
    case setDiningSeatings(String, String)
    

    case setEventCategory(String)
    case setEventLocation(String)
    
    case getTravelHotelGroups
    case getTravelMedicalMeals
    case getTravelActivities
    case getTravelAmenities
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
    
    case setProfilePreferences(String)
    case getVillaAmenities
    case getVillaAccomodation
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
        if let token = LujoSetup().getCurrentUser()?.token{
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        print("urlRequest:\(String(describing: urlRequest.url))")
        return urlRequest
    }

    func getHTTPMethod() -> HTTPMethod {
        switch self {
        case .getAllPreferences:    fallthrough
        case .getAviationCategories:fallthrough
        case .getDiningCuisines:    fallthrough
        case .getDiningAllergies:   fallthrough
        case .getDiningPreferences: fallthrough
        case .getDiningTimings:     fallthrough
        case .getDiningBeverages:   fallthrough
        case .getDiningSeatings:    fallthrough
        case .getGiftHabits:        fallthrough
        case .getGiftCategories:    fallthrough
        case .getGiftPreferences:   fallthrough
        case .getEventCategory:     fallthrough
        case .getEventLocation:     fallthrough
        case .getCuisines:          fallthrough
        case .getAviationBeverages: fallthrough
        case .searchDestination:
            return .get

        case .setGiftHabits:        fallthrough
        case .setGiftCategories:    fallthrough
        case .setGiftPreferences:   fallthrough
            
        case .setEventCategory: fallthrough
        case .setEventLocation: fallthrough
            
        
        
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
        
        case .searchRegions:    fallthrough
            
        case .setDiningCuisines: fallthrough
        case .setDiningPreferences: fallthrough
        case .setDiningBeverages: fallthrough
        case .setDiningAllergies: fallthrough
        case .setDiningTimings: fallthrough
        case .setDiningSeatings: fallthrough
            


            
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
            
        case .setProfilePreferences: fallthrough
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
        case .getAllPreferences:        newURLComponents.path.append("/users/preferences")
        case .getAviationCategories:    newURLComponents.path.append("/baroque/aviation/categories")
        case .getGiftHabits:            newURLComponents.path.append("/gifts/gift-habit")
        case .getGiftCategories:        newURLComponents.path.append("/gifts/gift-category")
        case .getGiftPreferences:       newURLComponents.path.append("/gifts/gift-preference")
        case .setGiftHabits:        fallthrough
        case .setGiftCategories:    fallthrough
        case .setGiftPreferences:   newURLComponents.path.append("/preferences/gift")
        case .getCuisines:
            newURLComponents.path.append("/restaurants/cuisine-category")
        case .getOtherInterests:  newURLComponents.path.append("/reference/interests")
        case .getAviationBeverages:
            newURLComponents.path.append("/restaurants/beverage")
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
        case let .searchDestination(pattern):
            newURLComponents.path.append("/restaurants/preferred_location/search")
            newURLComponents.queryItems = [
                URLQueryItem(name: "search", value: pattern),
            ]
        case .getDiningCuisines:    newURLComponents.path.append("/restaurants/cuisine-category")
        case .getDiningAllergies:   newURLComponents.path.append("/restaurants/allergy")
        case .getDiningPreferences: newURLComponents.path.append("/restaurants/dining-preference")
        case .getDiningTimings:     newURLComponents.path.append("/restaurants/dining-time")
        case .getDiningBeverages:   newURLComponents.path.append("/restaurants/beverage")
        case .getDiningSeatings:    newURLComponents.path.append("/restaurants/seating")
        case .setDiningCuisines: fallthrough
        case .setDiningPreferences: fallthrough
        case .setDiningBeverages: fallthrough
        case .setDiningAllergies: fallthrough
        case .setDiningTimings: fallthrough
        case .setDiningSeatings: newURLComponents.path.append("/preferences/restaurant")
            
        case .getEventCategory: newURLComponents.path.append("/events/event-category")
        case .getEventLocation: newURLComponents.path.append("/events/event-continent")
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
        case .setProfilePreferences: newURLComponents.path.append("/users/update-profile-preference")
        
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
        case .getAllPreferences:                fallthrough
        case .getAviationCategories:            fallthrough
        case .getDiningCuisines:     fallthrough
        case .getDiningAllergies:    fallthrough
        case .getDiningPreferences:  fallthrough
        case .getDiningTimings:      fallthrough
        case .getDiningBeverages:    fallthrough
        case .getDiningSeatings:    fallthrough
        case .getGiftHabits:        fallthrough
        case .getGiftCategories:    fallthrough
        case .getGiftPreferences:   fallthrough
        case .getEventCategory: fallthrough
        case .getEventLocation: fallthrough

        case .getCuisines:    fallthrough
        case .getOtherInterests:    fallthrough
        case .getAviationBeverages: fallthrough
            

        
        case .getTravelHotelGroups: fallthrough
        case .getTravelMedicalMeals: fallthrough
        case .getTravelActivities: fallthrough
        case .getTravelAmenities: fallthrough
        case .getVillaAmenities: fallthrough
        case .getVillaAccomodation: fallthrough
        case .searchDestination:
            return nil
        case let .setGiftHabits(commaSeparatedString):
            return setGiftHabbitsAsJSONData(commaSeparatedString:commaSeparatedString)
        case let .setGiftCategories(commaSeparatedString):
            return setGiftCategoriesAsJSONData( commaSeparatedString:commaSeparatedString)
        case let .setGiftPreferences(commaSeparatedString):
            return setGiftPreferencesAsJSONData( commaSeparatedString:commaSeparatedString)
            
        case let .setEventCategory( commaSeparatedString):
            return setEventCategoryAsJSONData( commaSeparatedString:commaSeparatedString)
        case let .setEventLocation(commaSeparatedString):
            return setEventLocationAsJSONData(commaSeparatedString:commaSeparatedString)
            
        case let .setAviationHaveCharteredBefore(token, commaSeparatedString):
            return setAviationHaveCharteredBeforeAsJSONData(token: token , yesOrNoString:commaSeparatedString)
        case let .setAviationInterestedIn(token, commaSeparatedString):
            return setAviationWantToPurchaseAsJSONData(token: token , charterOrPurchase:commaSeparatedString)
        case let .setAviationPreferredDestinations(token, commaSeparatedString):
            return setAviationPreferredDestinationsAsJSONData(token: token , commaSeparatedString:commaSeparatedString)
        case let .setAviationPreferredAirports(token, commaSeparatedString):
            return setAviationPreferredAirportsAsJSONData(token: token , commaSeparatedString:commaSeparatedString)
        case let .setAviationAircraftCategory(commaSeparatedString):
            return setAviationAircraftCategoryAsJSONData(commaSeparatedString:commaSeparatedString)
        case let .setAviationCharterFrequency(token, corporateFrequency, leisureFrequency):
            return setAviationCharterFrequencyAsJSONData(token: token , corporateFrequency:corporateFrequency, leisureFrequency: leisureFrequency)
        case let .setAviationPreferredCharter(token, commaSeparatedString):
            return setAviationPreferredCharterAsJSONData(token: token , shortOrLong:commaSeparatedString)
        case let .setAviationPreferredCuisines(token, commaSeparatedString, typedPreference):
            return setAviationPreferredCuisineAsJSONData(token: token , commaSeparatedString:commaSeparatedString, typedPreference: typedPreference)
        case let .setAviationPreferredBevereges(token, commaSeparatedString, typedPreference):
            return setAviationPreferredBeveragesAsJSONData(token: token , commaSeparatedString:commaSeparatedString, typedPreference: typedPreference)
            
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
        case let .setYachtLength( commaSeparatedString):
            return setYachtLengthAsJSONData(commaSeparatedString:commaSeparatedString)
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
            
        case let.setProfilePreferences(commaSeparatedString):
            return setProfilePreferencesAsJSONData(commaSeparatedString:commaSeparatedString)
        }
    }
    
//    fileprivate func getTaxonomiesAsJSONData() -> Data? {
//        let body: [String: Any] = [:]
//        return try? JSONSerialization.data(withJSONObject: body, options: [])
//    }
    
    fileprivate func setGiftHabbitsAsJSONData(commaSeparatedString: String) -> Data? {
        let body: [String: Any] = [
            "gift_habit_ids" : commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
     
    fileprivate func setGiftCategoriesAsJSONData( commaSeparatedString: String) -> Data? {
        let body: [String: Any] = [
            "gift_category_ids" : commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setGiftPreferencesAsJSONData( commaSeparatedString: String) -> Data? {
        let body: [String: Any] = [
            "gift_preferences_ids": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setAviationHaveCharteredBeforeAsJSONData(token: String, yesOrNoString: String) -> Data? {
        let body: [String: Any] = [
            "aviation_chartered_before" : yesOrNoString
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setAviationWantToPurchaseAsJSONData(token: String, charterOrPurchase: String) -> Data? {
        let body: [String: Any] = [
            "aviation_interested_in" : charterOrPurchase
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setAviationPreferredDestinationsAsJSONData(token: String, commaSeparatedString: String) -> Data? {
        let body: [String: Any] = [
            "aviation_preferred_destinations":commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setAviationPreferredAirportsAsJSONData(token: String, commaSeparatedString: String) -> Data? {
        let body: [String: Any] = [
            "aviation_preferred_airports": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setAviationAircraftCategoryAsJSONData(commaSeparatedString: String) -> Data? {
        let body: [String: Any] = [
            "aviation_aircraft_category_ids": commaSeparatedString.components(separatedBy: ",").map{Int($0)}
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setAviationCharterFrequencyAsJSONData(token: String, corporateFrequency: Int , leisureFrequency: Int) -> Data? {
        let body: [String: Any] = [
            "aviation_times_charter_corporate_jet" : corporateFrequency
            ,"aviation_times_charter_leisure_jet" : leisureFrequency
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setAviationPreferredCharterAsJSONData(token: String, shortOrLong: String) -> Data? {
        let body: [String: Any] = [
            "aviation_preferred_charter_range" : shortOrLong
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setAviationPreferredCuisineAsJSONData(token: String, commaSeparatedString: String , typedPreference:String) -> Data? {
        let body: [String: Any] = [
            "aviation_preferred_cuisine_id_other": typedPreference
            ,"aviation_preferred_cuisine_ids": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setAviationPreferredBeveragesAsJSONData(token: String, commaSeparatedString: String, typedPreference:String) -> Data? {
        let body: [String: Any] = [
            "aviation_preferred_beverage_id_other": typedPreference
            ,"aviation_preferred_beverage_ids" : commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
//    fileprivate func setSearchDestinationAsJSONData( strToSearch: String) -> Data? {
//        let body: [String: Any] = [
//            "search" : strToSearch
//        ]
//        return try? JSONSerialization.data(withJSONObject: body, options: [])
//    }
    
    fileprivate func setYachtHaveCharteredBeforeAsJSONData(token: String, commaSeparatedString: String) -> Data? {
        let body: [String: Any] = [
            "yacht_chartered_before": commaSeparatedString.components(separatedBy: ",")
        ]

        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setYachtInterestedInAsJSONData(token: String, commaSeparatedString: String) -> Data? {
        let body: [String: Any] = [
            "yacht_interested_in" : commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setYachtTypeAsJSONData(token: String, commaSeparatedString: String) -> Data? {
        let body: [String: Any] = [
            "yacht_type": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setYachtStyleAsJSONData(token: String, commaSeparatedString: String) -> Data? {
        let body: [String: Any] = [
            "yacht_style" : commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setYachtPreferredCuisineAsJSONData(token: String, commaSeparatedString: String , typedPreference:String) -> Data? {
        let body: [String: Any] = [
            "yacht_preferred_cuisine_id_other": typedPreference
            ,"yacht_preferred_cuisine_ids": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setYachtOtherInterestsAsJSONData(token: String, commaSeparatedString: String ) -> Data? {
        let body: [String: Any] = [
            "yacht_interests_ids": commaSeparatedString.components(separatedBy: ",")
        ]

        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setYachtCharterFrequencyAsJSONData(token: String, corporateFrequency: Int , leisureFrequency: Int) -> Data? {
        let body: [String: Any] = [
            "yacht_times_charter_corporate_jet" : corporateFrequency
            ,"yacht_times_charter_leisure_jet" : leisureFrequency
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setYachtPreferredRegionsAsJSONData(token: String, commaSeparatedString: String) -> Data? {
        let body: [String: Any] = [
            "yacht_preferred_destinations": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setYachtLengthAsJSONData(commaSeparatedString: String) -> Data? {
        let body: [String: Any] = [
            "yacht_length": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setSearchRegionsAsJSONData(token: String, strToSearch: String) -> Data? {
        let body: [String: Any] = [
            "search" : strToSearch
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setDiningCuisinesAsJSONData(token: String, commaSeparatedString: String , typedPreference:String) -> Data? {
        let body: [String: Any] = [
            "restaurant_preferred_cuisine_id_other": typedPreference
            ,"restaurant_preferred_cuisine_ids": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setDiningPreferencesAsJSONData(token: String, commaSeparatedString: String , typedPreference:String) -> Data? {
        let body: [String: Any] = [
            "restaurant_dinning_id_other": typedPreference
            ,"restaurant_dinning_ids": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setDiningBeveragesAsJSONData(token: String, commaSeparatedString: String , typedPreference:String) -> Data? {
        let body: [String: Any] = [
            "restaurant_beverage_id_other": typedPreference
            ,"restaurant_beverage_ids": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setDiningAllergiesAsJSONData(token: String, commaSeparatedString: String ) -> Data? {
        let body: [String: Any] = [
            "restaurant_allergy_ids": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setDiningTimingsAsJSONData(token: String, commaSeparatedString: String ) -> Data? {
        let body: [String: Any] = [
            "restaurant_timing_ids": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setDiningSeatingsAsJSONData(token: String, commaSeparatedString: String ) -> Data? {
        let body: [String: Any] = [
            "restaurant_seating_ids": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setEventCategoryAsJSONData(commaSeparatedString:String) -> Data?{
        let body: [String: Any] = [
            "event_category_ids": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setEventLocationAsJSONData( commaSeparatedString:String) -> Data?{
        let body: [String: Any] = [
            "event_continent_ids": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setTravelFrequencyAsJSONData(token: String , businessFrequency:Int, leisureFrequency:Int) -> Data?{
        let body: [String: Any] = [
            "travel_times_business": businessFrequency
            ,"travel_times_leisure": leisureFrequency
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

    fileprivate func setTravelDestinationsAsJSONData(token: String , commaSeparatedString:String) -> Data?{
        let body: [String: Any] = [
            "travel_preferred_destinations": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

    fileprivate func setTravelHotelRatingAsJSONData(token: String , businessRating:Int, leisureRating: Int) -> Data?{
        let body: [String: Any] = [
            "travel_rating_business_hotels": businessRating
            ,"travel_rating_leisure_hotels": leisureRating
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

    fileprivate func setTravelDestinationTypeAsJSONData(token: String , commaSeparatedString:String) -> Data?{
        let body: [String: Any] = [
            "travel_destination_type": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

    fileprivate func setTravelHotelGroupsAsJSONData(token: String , commaSeparatedString:String) -> Data?{
        let body: [String: Any] = [
            "travel_hotel_group": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

    fileprivate func setTravelAmenitiesAsJSONData(token: String , commaSeparatedString:String, typedPreference: String) -> Data?{
        let body: [String: Any] = [
            "travel_amenity_ids": commaSeparatedString.components(separatedBy: ",")
            ,"travel_amenity_id_other": typedPreference
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

    fileprivate func setTravelActivitiesAsJSONData(token: String , commaSeparatedString:String) -> Data?{
        let body: [String: Any] = [
            "travel_activity_ids": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

    fileprivate func setTravelAirlinesAsJSONData(token: String , commaSeparatedString:String) -> Data?{
        let body: [String: Any] = [
            "travel_airline_ids": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

    fileprivate func setTravelAirplaneSeatAsJSONData(token: String , airplaneSeat:String) -> Data?{
        let body: [String: Any] = [
            "travel_airplane_seat": airplaneSeat
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

    fileprivate func setTravelCabinClassAsJSONData(token: String , businessCabin:String, leisureCabin: String) -> Data?{
        let body: [String: Any] = [
            "travel_airplane_business_cabin_class": businessCabin
            ,"travel_airplane_leisure_cabin_class": leisureCabin
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

    fileprivate func setTravelMealsAsJSONData(token: String , commaSeparatedString:String) -> Data?{
        let body: [String: Any] = [
            "travel_airplane_meals": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

    fileprivate func setTravelMedicalMealsAsJSONData(token: String , commaSeparatedString:String, typedPreference: String) -> Data?{
        let body: [String: Any] = [
            "travel_media_dietary_meal": commaSeparatedString.components(separatedBy: ",")
            ,"travel_media_dietary_meal_other": typedPreference
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

    fileprivate func setTravelHotelStylesAsJSONData(token: String , commaSeparatedString:String) -> Data?{
        let body: [String: Any] = [
            "travel_hotel_types": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

    fileprivate func setTravelAllergiesAsJSONData(token: String , commaSeparatedString:String, typedPreference: String) -> Data?{
        let body: [String: Any] = [
            "travel_allergy_ids": commaSeparatedString.components(separatedBy: ",")
            ,"travel_allergy_id_other": typedPreference
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func  setVillaDestinationsAsJSONData(token: String , commaSeparatedString:String) -> Data?{
        let body: [String: Any] = [
            "villa_preferred_destinations_ids": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func  setVillaAmenitiesAsJSONData(token: String , commaSeparatedString:String, typedPreference: String) -> Data?{
        let body: [String: Any] = [
            "villa_preferred_amenities_ids": commaSeparatedString.components(separatedBy: ",")
            ,"villa_preferred_amenities_id_other": typedPreference
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func  setVillaAccomodationAsJSONData(token: String , commaSeparatedString:String, typedPreference: String) -> Data?{
        let body: [String: Any] = [
            "villa_preferred_accommodations_ids": commaSeparatedString.components(separatedBy: ",")
            ,"villa_preferred_accommodations_id_other": typedPreference
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

    
    fileprivate func setProfilePreferencesAsJSONData(commaSeparatedString:String) -> Data?{
        let body: [String: Any] = [
            "type": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
}

