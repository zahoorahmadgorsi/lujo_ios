//
//  Preferences.swift
//  LUJO
//
//  Created by iMac on 20/05/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import Foundation
struct Preferences: Codable {
    var gift: GiftPreferences
    var aviation: AviationPreferences
//    var restaurant: RestaurantPreferences
//    var event: EventPreferences
//    var travel: TravelPreferences
//    var yacht: YachtPreferences
    
    
    enum CodingKeys: String, CodingKey {
        case gift
        case aviation
//        case restaurant
//        case event
//        case travel
//        case yacht
    }
    
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            gift = try values.decode(GiftPreferences.self, forKey: .gift)
            aviation = try values.decode(AviationPreferences.self, forKey: .aviation)
//            restaurant = try values.decode(RestaurantPreferences.self, forKey: .restaurant)
//            event = try values.decode(EventPreferences.self, forKey: .event)
//            travel = try values.decode(TravelPreferences.self, forKey: .travel)
//            yacht = try values.decode(YachtPreferences.self, forKey: .yacht)
        } catch {
            Crashlytics.sharedInstance().recordError(error)
            throw error
        }
    }
}

struct GiftPreferences : Codable {
    var gift_habit_id : [String]?
    var gift_habit_id_other : String?
    var gift_category_id : [String]?
    var gift_category_id_other : String?
    var gift_preferences_id : [String]?
    var gift_preferences_id_other : String?
    
    enum CodingKeys: String, CodingKey {
        case gift_habit_id = "gift_habit_id"
        case gift_habit_id_other = "gift_habit_id_other"
        case gift_category_id = "gift_category_id"
        case gift_category_id_other = "gift_category_id_other"
        case gift_preferences_id = "gift_preferences_id"
        case gift_preferences_id_other = "gift_preferences_id_other"
    }
    
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            gift_habit_id = try values.decodeIfPresent([String].self, forKey: .gift_habit_id)
            gift_habit_id_other = try values.decodeIfPresent(String.self, forKey: .gift_habit_id_other)
            gift_category_id = try values.decodeIfPresent([String].self, forKey: .gift_category_id)
            gift_category_id_other = try values.decodeIfPresent(String.self, forKey: .gift_category_id_other)
            gift_preferences_id = try values.decodeIfPresent([String].self, forKey: .gift_preferences_id)
            gift_preferences_id_other = try values.decodeIfPresent(String.self, forKey: .gift_preferences_id_other)
        } catch {
            Crashlytics.sharedInstance().recordError(error)
            throw error
        }
    }
}

//List of data which we are cachig in userdefaults
struct PrefMasterData : Codable {
    var giftHabits : [Taxonomy]?
    var giftCategories : [Taxonomy]?
    var giftPreferences : [Taxonomy]?
    var aviationCuisines : [Taxonomy]?
    var aviationBeverages : [Taxonomy]?
    var aviationCategories : [BaroqueAviationCategory]?
    
    init(giftHabits:[Taxonomy]? = [] ,giftCategories : [Taxonomy]? = [], giftPreferences : [Taxonomy]? = []){
        self.giftHabits = giftHabits
        self.giftCategories = giftCategories
        self.giftPreferences = giftPreferences
    }
}


struct AviationPreferences  : Codable {
    var aviation_chartered_before : String?
    var aviation_interested_in : String?
    var aviation_times_charter_corporate_jet : Int?
    var aviation_times_charter_leisure_jet : Int?
    var aviation_preferred_destinations : [String]?
    var aviation_preferred_airports : [String]?
    var aviation_preferred_charter_range : String?
    var aviation_preferred_cuisine_id : [String]?
    var aviation_preferred_cuisine_id_other  : String?
    var aviation_preferred_beverage_id : [String]?
    var aviation_preferred_beverage_id_other  : String?
    var aviation_aircraft_category_id : [String]?

    enum CodingKeys: String, CodingKey {
        case aviation_chartered_before = "aviation_chartered_before"
        case aviation_interested_in = "aviation_interested_in"
        case aviation_times_charter_corporate_jet = "aviation_times_charter_corporate_jet"
        case aviation_times_charter_leisure_jet = "aviation_times_charter_leisure_jet"
        case aviation_preferred_destinations = "aviation_preferred_destinations"
        case aviation_preferred_airports = "aviation_preferred_airports"
        case aviation_preferred_charter_range = "aviation_preferred_charter_range"
        case aviation_preferred_cuisine_id = "aviation_preferred_cuisine_id"
        case aviation_preferred_cuisine_id_other = "aviation_preferred_cuisine_id_other"
        case aviation_preferred_beverage_id = "aviation_preferred_beverage_id"
        case aviation_preferred_beverage_id_other = "aviation_preferred_beverage_id_other"
        case aviation_aircraft_category_id = "aviation_aircraft_category_id"
    }
    
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            aviation_chartered_before = try values.decodeIfPresent(String.self, forKey: .aviation_chartered_before)
            aviation_interested_in = try values.decodeIfPresent(String.self, forKey: .aviation_interested_in)
            aviation_times_charter_corporate_jet = try values.decodeIfPresent(Int.self, forKey: .aviation_times_charter_corporate_jet)
            aviation_times_charter_leisure_jet = try values.decodeIfPresent(Int.self, forKey: .aviation_times_charter_leisure_jet)
            aviation_preferred_destinations = try values.decodeIfPresent([String].self, forKey: .aviation_preferred_destinations)
            aviation_preferred_airports = try values.decodeIfPresent([String].self, forKey: .aviation_preferred_airports)
            aviation_preferred_charter_range = try values.decodeIfPresent(String.self, forKey: .aviation_preferred_charter_range)
            aviation_preferred_cuisine_id = try values.decodeIfPresent([String].self, forKey: .aviation_preferred_cuisine_id)
            aviation_preferred_cuisine_id_other = try values.decodeIfPresent(String.self, forKey: .aviation_preferred_cuisine_id_other)
            aviation_preferred_beverage_id = try values.decodeIfPresent([String].self, forKey: .aviation_preferred_beverage_id)
            aviation_preferred_beverage_id_other = try values.decodeIfPresent(String.self, forKey: .aviation_preferred_beverage_id_other)
            aviation_aircraft_category_id = try values.decodeIfPresent([String].self, forKey: .aviation_aircraft_category_id)
        } catch {
            Crashlytics.sharedInstance().recordError(error)
            throw error
        }
    }

}

//struct RestaurantPreferences : Codable {
//    let restaurant_preferred_cuisine_id : [String]?
//    let restaurant_preferred_cuisine_id_other : [String]?
//    let restaurant_allergy_id : [String]?
//    let restaurant_allergy_id_other : [String]?
//    let restaurant_dinning_id : [String]?
//    let restaurant_dinning_id_other : [String]?
//    let restaurant_timing_id : [String]?
//    let restaurant_beverage_id : [String]?
//    let restaurant_beverage_id_other : [String]?
//    let restaurant_seating_id : [String]?
//    
//    enum CodingKeys: String, CodingKey {
//        case restaurant_preferred_cuisine_id = "restaurant_preferred_cuisine_id"
//        case restaurant_preferred_cuisine_id_other = "restaurant_preferred_cuisine_id_other"
//        case restaurant_allergy_id = "restaurant_allergy_id"
//        case restaurant_allergy_id_other = "restaurant_allergy_id_other"
//        case restaurant_dinning_id = "restaurant_dinning_id"
//        case restaurant_dinning_id_other = "restaurant_dinning_id_other"
//        case restaurant_timing_id = "restaurant_timing_id"
//        case restaurant_beverage_id = "restaurant_beverage_id"
//        case restaurant_beverage_id_other = "restaurant_beverage_id_other"
//        case restaurant_seating_id = "restaurant_seating_id"
//    }
//    
//    init(from decoder: Decoder) throws {
//        do {
//            let values = try decoder.container(keyedBy: CodingKeys.self)
//            restaurant_preferred_cuisine_id = try values.decodeIfPresent([String].self, forKey: .restaurant_preferred_cuisine_id)
//            restaurant_preferred_cuisine_id_other  = try values.decodeIfPresent([String].self, forKey: .restaurant_preferred_cuisine_id)
//            restaurant_allergy_id = try values.decodeIfPresent([String].self, forKey: .restaurant_allergy_id)
//            restaurant_allergy_id_other = try values.decodeIfPresent([String].self, forKey: .restaurant_allergy_id_other)
//            restaurant_dinning_id = try values.decodeIfPresent([String].self, forKey: .restaurant_dinning_id)
//            restaurant_dinning_id_other = try values.decodeIfPresent([String].self, forKey: .restaurant_dinning_id_other)
//            restaurant_timing_id = try values.decodeIfPresent([String].self, forKey: .restaurant_timing_id)
//            restaurant_beverage_id = try values.decodeIfPresent([String].self, forKey: .restaurant_beverage_id)
//            restaurant_beverage_id_other = try values.decodeIfPresent([String].self, forKey: .restaurant_beverage_id_other)
//            restaurant_seating_id = try values.decodeIfPresent([String].self, forKey: .restaurant_seating_id)
//        } catch {
//            Crashlytics.sharedInstance().recordError(error)
//            throw error
//        }
//    }
//}


//struct EventPreferences : Codable {
//    event_category_id
//    event_category_id_other
//    event_location_id
//
//}
//
//
//
//struct TravelPreferences    : Codable {
//    travel_times_business
//    travel_times_leisure
//    travel_preferred_destinations
//    travel_rating_business_hotels
//    travel_rating_leisure_hotels
//    travel_destination_type
//    travel_hotel_group
//    travel_amenity_id
//    travel_amenity_id_other
//    travel_activity_id
//    travel_airline_id
//    travel_airplane_seat
//    travel_airplane_seat_other
//    travel_airplane_business_cabin_class
//    travel_airplane_leisure_cabin_class
//    travel_airplane_meals
//    travel_media_dietary_meal
//    travel_media_dietary_meal_other
//    travel_hotel_types
//    travel_allergy_id
//    travel_allergy_id_other
//
//}
//
//struct YachtPreferences    : Codable {
//    yacht_chartered_before
//    yacht_interested_in
//    yacht_times_charter_corporate_jet
//    yacht_times_charter_leisure_jet
//    yacht_preferred_destinations
//    yacht_length
//    yacht_type
//    yacht_style
//    yacht_preferred_cuisine_id
//    yacht_preferred_cuisine_id_other
//}
