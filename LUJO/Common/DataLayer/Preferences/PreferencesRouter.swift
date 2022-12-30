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
    case setAviationHaveCharteredBefore(String)
    case setAviationPreferredDestinations(String)
    case setAviationPreferredAirports(String)
    case setAviationAircraftCategory(String)
    case setAviationCharterFrequency(Int,Int)
    case setAviationInterestedIn(String)
    case setAviationPreferredCharter(String)
    case setAviationPreferredCuisines(String)
    case setAviationPreferredBevereges(String)
    case searchDestination(String)
    case getOtherInterests
    
    case setYachtHaveCharteredBefore(String)
    case setYachtInterestedIn(String)
    case setYachtType(String)
    case setYachtStyle(String)
    case setYachtPreferredCuisines(String)
    case setYachtOtherInterests(String)
    case setYachtCharterFrequency(Int,Int)
    case setYachtPreferredRegions(String)
    case setYachtLength(String)
    case searchRegions(String)
    case searchCurrencies(String)
    
    case getDiningCuisines
    case getDiningAllergies
    case getDiningPreferences
    case getDiningTimings
    case getDiningBeverages
    case getDiningSeatings
    case setDiningCuisines (String)
    case setDiningPreferences(String)
    case setDiningBeverages(String)
    case setDiningAllergies( String)
    case setDiningTimings( String)
    case setDiningSeatings( String)
    

    case setEventCategory(String)
    case setEventLocation(String)
    
    case getTravelHotelGroups
    case getTravelMedicalMeals
    case getTravelActivities
    case getTravelAmenities
    case setTravelFrequency(Int,Int)
    case setTravelDestinations(String)
    case setTravelHotelRating(Int,Int)
    case setTravelDestinationType( String)
    case setTravelHotelGroups( String)
    case setTravelAmenities(String)
    case setTravelActivities( String)
    case setTravelAirlines( String)
    case setTravelAirplaneSeat( String)
    case setTravelCabinClass( Int, Int)
    case setTravelMeals( String)
    case setTravelMedicalMeals( String)
    case setTravelHotelStyles( String)
    case setTravelAllergies( String)
    
    case setProfilePreferences(String)
    case getVillaAmenities
    case getVillaAccomodation
    case setVillaDestinations(String)
    case setVillaAmenities( String)
    case setVillaAccomodation(String)
    
    
    
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
        case .searchDestination:    fallthrough
            
        case .getVillaAmenities:    fallthrough
        case .getVillaAccomodation: fallthrough
        case .getOtherInterests:    fallthrough
        case .searchRegions:        fallthrough
        case .getTravelHotelGroups: fallthrough
        case .getTravelMedicalMeals: fallthrough
        case .getTravelActivities:  fallthrough
        case .getTravelAmenities:
            return .get

        case .setGiftHabits:        fallthrough
        case .setGiftCategories:    fallthrough
        case .setGiftPreferences:   fallthrough
            
        case .setEventCategory: fallthrough
        case .setEventLocation: fallthrough
                    
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
            
        case .setDiningCuisines: fallthrough
        case .setDiningPreferences: fallthrough
        case .setDiningBeverages: fallthrough
        case .setDiningAllergies: fallthrough
        case .setDiningTimings: fallthrough
        case .setDiningSeatings: fallthrough
        
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
        
        case .setVillaDestinations: fallthrough
        case .setVillaAmenities: fallthrough
        case .setVillaAccomodation: fallthrough
        case .searchCurrencies:
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
        case .setGiftPreferences:       newURLComponents.path.append("/preferences/gift")
        case .getCuisines:              newURLComponents.path.append("/restaurants/cuisine-category")
        case .getOtherInterests:        newURLComponents.path.append("/reference/interests")
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
        case let .searchRegions(pattern):
            newURLComponents.path.append("/reference/regions")
            newURLComponents.queryItems = [
                URLQueryItem(name: "search", value: pattern),
            ]
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
            
        case .searchCurrencies: newURLComponents.path.append("/currencies")
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
        case .getEventCategory:     fallthrough
        case .getEventLocation:     fallthrough

        case .getCuisines:          fallthrough
        case .getOtherInterests:    fallthrough
        case .getAviationBeverages: fallthrough
            

        
        case .getTravelHotelGroups: fallthrough
        case .getTravelMedicalMeals: fallthrough
        case .getTravelActivities:  fallthrough
        case .getTravelAmenities:   fallthrough
        case .getVillaAmenities:    fallthrough
        case .getVillaAccomodation: fallthrough
        case .searchDestination:    fallthrough
        case .searchRegions:
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
            
        case let .setAviationHaveCharteredBefore( commaSeparatedString):
            return setAviationHaveCharteredBeforeAsJSONData( yesOrNoString:commaSeparatedString)
        case let .setAviationInterestedIn( commaSeparatedString):
            return setAviationWantToPurchaseAsJSONData( charterOrPurchase:commaSeparatedString)
        case let .setAviationPreferredDestinations( commaSeparatedString):
            return setAviationPreferredDestinationsAsJSONData( commaSeparatedString:commaSeparatedString)
        case let .setAviationPreferredAirports( commaSeparatedString):
            return setAviationPreferredAirportsAsJSONData( commaSeparatedString:commaSeparatedString)
        case let .setAviationAircraftCategory(commaSeparatedString):
            return setAviationAircraftCategoryAsJSONData(commaSeparatedString:commaSeparatedString)
        case let .setAviationCharterFrequency( corporateFrequency, leisureFrequency):
            return setAviationCharterFrequencyAsJSONData( corporateFrequency:corporateFrequency, leisureFrequency: leisureFrequency)
        case let .setAviationPreferredCharter( commaSeparatedString):
            return setAviationPreferredCharterAsJSONData( shortOrLong:commaSeparatedString)
        case let .setAviationPreferredCuisines( commaSeparatedString):
            return setAviationPreferredCuisineAsJSONData( commaSeparatedString:commaSeparatedString)
        case let .setAviationPreferredBevereges( commaSeparatedString):
            return setAviationPreferredBeveragesAsJSONData( commaSeparatedString:commaSeparatedString)
            
        case let .setYachtHaveCharteredBefore( commaSeparatedString):
            return setYachtHaveCharteredBeforeAsJSONData( yesOrNo:commaSeparatedString)
        case let .setYachtInterestedIn( charterPurchaseOrBoth):
            return setYachtInterestedInAsJSONData( charterPurchaseOrBoth:charterPurchaseOrBoth)
        case let .setYachtType( motorSailOrBoth):
            return setYachtTypeAsJSONData( string:motorSailOrBoth)
        case let .setYachtStyle( commaSeparatedString):
            return setYachtStyleAsJSONData( modernClassicOrBoth:commaSeparatedString)
        case let .setYachtPreferredCuisines( commaSeparatedString):
            return setYachtPreferredCuisineAsJSONData( commaSeparatedString:commaSeparatedString)
        case let .setYachtOtherInterests( commaSeparatedString ):
            return setYachtOtherInterestsAsJSONData( commaSeparatedString:commaSeparatedString)
        case let .setYachtCharterFrequency( corporateFrequency, leisureFrequency):
            return setYachtCharterFrequencyAsJSONData( corporateFrequency:corporateFrequency, leisureFrequency: leisureFrequency)
        case let .setYachtPreferredRegions( commaSeparatedString):
            return setYachtPreferredRegionsAsJSONData( commaSeparatedString:commaSeparatedString)
        case let .setYachtLength( commaSeparatedString):
            return setYachtLengthAsJSONData(commaSeparatedString:commaSeparatedString)
        case let .setDiningCuisines( commaSeparatedString):
            return setDiningCuisinesAsJSONData( commaSeparatedString:commaSeparatedString)
        case let .setDiningPreferences( commaSeparatedString):
            return setDiningPreferencesAsJSONData( commaSeparatedString:commaSeparatedString)
        case let .setDiningBeverages( commaSeparatedString):
            return setDiningBeveragesAsJSONData( commaSeparatedString:commaSeparatedString)
        case let .setDiningAllergies( commaSeparatedString):
            return setDiningAllergiesAsJSONData( commaSeparatedString:commaSeparatedString)
        case let .setDiningTimings( commaSeparatedString):
            return setDiningTimingsAsJSONData( commaSeparatedString:commaSeparatedString)
        case let .setDiningSeatings( commaSeparatedString):
            return setDiningSeatingsAsJSONData( commaSeparatedString:commaSeparatedString)
            


        

        case let  .setTravelFrequency( businessFrequency, leisureFrequency):
            return setTravelFrequencyAsJSONData( businessFrequency:businessFrequency, leisureFrequency:leisureFrequency)
        case let  .setTravelDestinations( commaSeparatedString):
            return setTravelDestinationsAsJSONData( commaSeparatedString:commaSeparatedString)
        case let  .setTravelHotelRating( businessRating, leisureRating):
            return setTravelHotelRatingAsJSONData( businessRating:businessRating, leisureRating: leisureRating)
        case let  .setTravelDestinationType( commaSeparatedString):
            return setTravelDestinationTypeAsJSONData( commaSeparatedString:commaSeparatedString)
        case let  .setTravelHotelGroups( commaSeparatedString):
            return setTravelHotelGroupsAsJSONData( commaSeparatedString:commaSeparatedString)
        case let  .setTravelAmenities( commaSeparatedString):
            return setTravelAmenitiesAsJSONData( commaSeparatedString:commaSeparatedString)
        case let  .setTravelActivities( commaSeparatedString):
            return setTravelActivitiesAsJSONData( commaSeparatedString:commaSeparatedString)
        case let  .setTravelAirlines( commaSeparatedString):
            return setTravelAirlinesAsJSONData( commaSeparatedString:commaSeparatedString)
        case let  .setTravelAirplaneSeat( airplaneSeat):
            return setTravelAirplaneSeatAsJSONData( airplaneSeat:airplaneSeat)
        case let  .setTravelCabinClass( businessCabin, leisureCabin):
            return setTravelCabinClassAsJSONData( businessCabin:businessCabin, leisureCabin: leisureCabin)
        case let  .setTravelMeals( commaSeparatedString):
            return setTravelMealsAsJSONData( commaSeparatedString:commaSeparatedString)
        case let  .setTravelMedicalMeals( commaSeparatedString):
            return setTravelMedicalMealsAsJSONData( commaSeparatedString:commaSeparatedString)
        case let  .setTravelHotelStyles( commaSeparatedString):
            return setTravelHotelStylesAsJSONData( commaSeparatedString:commaSeparatedString)
        case let  .setTravelAllergies( commaSeparatedString):
            return setTravelAllergiesAsJSONData( commaSeparatedString:commaSeparatedString)
        case let  .setVillaDestinations( commaSeparatedString):
            return setVillaDestinationsAsJSONData( commaSeparatedString:commaSeparatedString)
        case let  .setVillaAmenities( commaSeparatedString):
            return setVillaAmenitiesAsJSONData( commaSeparatedString:commaSeparatedString)
        case let  .setVillaAccomodation(commaSeparatedString):
            return setVillaAccomodationAsJSONData( commaSeparatedString:commaSeparatedString)
            
        case let.setProfilePreferences(commaSeparatedString):
            return setProfilePreferencesAsJSONData(commaSeparatedString:commaSeparatedString)
            
        case let .searchCurrencies(search):
            return setCurrencySearchAsJSONData(search: search)
            
        }
    }
    
//    fileprivate func getTaxonomiesAsJSONData() -> Data? {
//        let body: [String: Any] = [:]
//        return try? JSONSerialization.data(withJSONObject: body, options: [])
//    }
    
    fileprivate func setGiftHabbitsAsJSONData(commaSeparatedString:String) -> Data? {
        let body: [String: Any] = [
            "gift_habit_ids" : commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
     
    fileprivate func setGiftCategoriesAsJSONData( commaSeparatedString:String) -> Data? {
        let body: [String: Any] = [
            "gift_category_ids" : commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setGiftPreferencesAsJSONData( commaSeparatedString:String) -> Data? {
        let body: [String: Any] = [
            "gift_preferences_ids": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setAviationHaveCharteredBeforeAsJSONData( yesOrNoString:String) -> Data? {
        let body: [String: Any] = [
            "aviation_chartered_before" : yesOrNoString
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setAviationWantToPurchaseAsJSONData( charterOrPurchase: String) -> Data? {
        let body: [String: Any] = [
            "aviation_interested_in" : charterOrPurchase
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setAviationPreferredDestinationsAsJSONData( commaSeparatedString:String) -> Data? {
        let body: [String: Any] = [
            "aviation_preferred_destinations":commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setAviationPreferredAirportsAsJSONData( commaSeparatedString:String) -> Data? {
        let body: [String: Any] = [
            "aviation_preferred_airports": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setAviationAircraftCategoryAsJSONData(commaSeparatedString:String) -> Data? {
        let body: [String: Any] = [
            "aviation_aircraft_category_ids": commaSeparatedString.components(separatedBy: ",").map{Int($0)}
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setAviationCharterFrequencyAsJSONData( corporateFrequency: Int , leisureFrequency: Int) -> Data? {
        let body: [String: Any] = [
            "aviation_times_charter_corporate_jet" : corporateFrequency
            ,"aviation_times_charter_leisure_jet" : leisureFrequency
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setAviationPreferredCharterAsJSONData( shortOrLong: String) -> Data? {
        let body: [String: Any] = [
            "aviation_preferred_charter_range" : shortOrLong
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setAviationPreferredCuisineAsJSONData( commaSeparatedString:String) -> Data? {
        let body: [String: Any] = [
            "aviation_preferred_cuisine_ids": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setAviationPreferredBeveragesAsJSONData( commaSeparatedString:String) -> Data? {
        let body: [String: Any] = [
            "aviation_preferred_beverage_ids" : commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setYachtHaveCharteredBeforeAsJSONData( yesOrNo:String) -> Data? {
        let body: [String: Any] = [
            "yacht_chartered_before": yesOrNo
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setYachtInterestedInAsJSONData( charterPurchaseOrBoth:String) -> Data? {
        let body: [String: Any] = [
            "yacht_interested_in" : charterPurchaseOrBoth
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setYachtTypeAsJSONData( string:String) -> Data? {
        let body: [String: Any] = [
            "yacht_type": string    //motorSailOrBoth
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setYachtStyleAsJSONData( modernClassicOrBoth:String) -> Data? {
        let body: [String: Any] = [
            "yacht_style" : modernClassicOrBoth
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setYachtPreferredCuisineAsJSONData( commaSeparatedString:String) -> Data? {
        let body: [String: Any] = [
            "yacht_preferred_cuisine_ids": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setYachtOtherInterestsAsJSONData( commaSeparatedString:String ) -> Data? {
        let body: [String: Any] = [
            "yacht_interests_ids": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setYachtCharterFrequencyAsJSONData( corporateFrequency: Int , leisureFrequency: Int) -> Data? {
        let body: [String: Any] = [
            "yacht_times_charter_corporate_jet" : corporateFrequency
            ,"yacht_times_charter_leisure_jet" : leisureFrequency
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setYachtPreferredRegionsAsJSONData( commaSeparatedString:String) -> Data? {
        let body: [String: Any] = [
            "yacht_preferred_destinations": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setYachtLengthAsJSONData(commaSeparatedString:String) -> Data? {
        let body: [String: Any] = [
            "yacht_length": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setDiningCuisinesAsJSONData( commaSeparatedString:String) -> Data? {
        let body: [String: Any] = [
            "restaurant_preferred_cuisine_ids": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setDiningPreferencesAsJSONData( commaSeparatedString:String) -> Data? {
        let body: [String: Any] = [
            "restaurant_dinning_ids": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setDiningBeveragesAsJSONData( commaSeparatedString:String) -> Data? {
        let body: [String: Any] = [
            "restaurant_beverage_ids": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setDiningAllergiesAsJSONData( commaSeparatedString:String ) -> Data? {
        let body: [String: Any] = [
            "restaurant_allergy_ids": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setDiningTimingsAsJSONData( commaSeparatedString:String ) -> Data? {
        let body: [String: Any] = [
            "restaurant_timing_ids": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setDiningSeatingsAsJSONData( commaSeparatedString:String ) -> Data? {
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
    
    fileprivate func setTravelFrequencyAsJSONData( businessFrequency:Int, leisureFrequency:Int) -> Data?{
        let body: [String: Any] = [
            "travel_times_charter_corporate": businessFrequency
            ,"travel_times_charter_leisure": leisureFrequency
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

    fileprivate func setTravelDestinationsAsJSONData( commaSeparatedString:String) -> Data?{
        let body: [String: Any] = [
            "travel_preferred_destinations": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

    fileprivate func setTravelHotelRatingAsJSONData( businessRating:Int, leisureRating: Int) -> Data?{
        let body: [String: Any] = [
            "travel_star_rating_corporate": businessRating
            ,"travel_star_rating_leisure": leisureRating
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

    fileprivate func setTravelDestinationTypeAsJSONData( commaSeparatedString:String) -> Data?{
        let body: [String: Any] = [
            "travel_destination_type": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

    fileprivate func setTravelHotelGroupsAsJSONData( commaSeparatedString:String) -> Data?{
        let body: [String: Any] = [
            "travel_hotel_groups": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

    fileprivate func setTravelAmenitiesAsJSONData( commaSeparatedString:String) -> Data?{
        let body: [String: Any] = [
            "travel_preffered_amenities": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

    fileprivate func setTravelActivitiesAsJSONData( commaSeparatedString:String) -> Data?{
        let body: [String: Any] = [
            "travel_activities": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

    fileprivate func setTravelAirlinesAsJSONData( commaSeparatedString:String) -> Data?{
        let body: [String: Any] = [
            "travel_preferred_airlines": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

    fileprivate func setTravelAirplaneSeatAsJSONData( airplaneSeat:String) -> Data?{
        let body: [String: Any] = [
            "travel_preferred_seat": airplaneSeat
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

    fileprivate func setTravelCabinClassAsJSONData( businessCabin:Int, leisureCabin: Int) -> Data?{
        let body: [String: Any] = [
            "travel_preferred_cabin_corporate": businessCabin
            ,"travel_preferred_cabin_leisure": leisureCabin
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

    fileprivate func setTravelMealsAsJSONData( commaSeparatedString:String) -> Data?{
        let body: [String: Any] = [
            "travel_preferred_meals": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

    fileprivate func setTravelMedicalMealsAsJSONData( commaSeparatedString:String) -> Data?{
        let body: [String: Any] = [
            "travel_preferred_medical_dietry_meals": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

    fileprivate func setTravelHotelStylesAsJSONData( commaSeparatedString:String) -> Data?{
        let body: [String: Any] = [
            "travel_hotel_styles": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

    fileprivate func setTravelAllergiesAsJSONData( commaSeparatedString:String) -> Data?{
        let body: [String: Any] = [
            "travel_allergy_ids": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func  setVillaDestinationsAsJSONData( commaSeparatedString:String) -> Data?{
        let body: [String: Any] = [
            "villa_preferred_destinations": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func  setVillaAmenitiesAsJSONData( commaSeparatedString:String) -> Data?{
        let body: [String: Any] = [
            "villa_preferred_amenities": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func  setVillaAccomodationAsJSONData( commaSeparatedString:String) -> Data?{
        let body: [String: Any] = [
            "villa_preferred_accommodations": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

    
    fileprivate func setProfilePreferencesAsJSONData(commaSeparatedString:String) -> Data?{
        let body: [String: Any] = [
            "type": commaSeparatedString.components(separatedBy: ",")
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func setCurrencySearchAsJSONData( search:String) -> Data?{
        let body: [String: Any] = [
            "search": search,
            "page" : 1,
            "per_page" : 100
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
}

