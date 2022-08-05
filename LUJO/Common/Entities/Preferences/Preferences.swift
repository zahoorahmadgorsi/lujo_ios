//
//  Preferences.swift
//  LUJO
//
//  Created by iMac on 20/05/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import Foundation
import FirebaseCrashlytics

struct Preferences: Codable {
    var gift: GiftPreferences
    var aviation: AviationPreferences
    var restaurant: RestaurantPreferences
    var event: EventPreferences
    var travel: TravelPreferences
    var yacht: YachtPreferences
    var villa: VillaPreferences
    var profile : [String]?
    
    enum CodingKeys: String, CodingKey {
        case gift
        case aviation
        case restaurant
        case event
        case travel
        case yacht
        case villa
        case profile
    }
    
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            gift = try values.decode(GiftPreferences.self, forKey: .gift)
            aviation = try values.decode(AviationPreferences.self, forKey: .aviation)
            restaurant = try values.decode(RestaurantPreferences.self, forKey: .restaurant)
            event = try values.decode(EventPreferences.self, forKey: .event)
            travel = try values.decode(TravelPreferences.self, forKey: .travel)
            yacht = try values.decode(YachtPreferences.self, forKey: .yacht)
            villa = try values.decode(VillaPreferences.self, forKey: .villa)
            profile = try values.decodeIfPresent([String].self, forKey: .profile)
        } catch {
            Crashlytics.crashlytics().record(error: error)
            throw error
        }
    }
}

struct GiftPreferences : Codable {
    var gift_habit_id : [String]?
    var gift_category_id : [String]?
    var gift_preferences_id : [String]?
    
    enum CodingKeys: String, CodingKey {
        case gift_habit_id = "gift_habit_ids"
        case gift_category_id = "gift_category_ids"
        case gift_preferences_id = "gift_preferences_ids"
    }
    
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            gift_habit_id = try values.decodeIfPresent([String].self, forKey: .gift_habit_id)
            gift_category_id = try values.decodeIfPresent([String].self, forKey: .gift_category_id)
            gift_preferences_id = try values.decodeIfPresent([String].self, forKey: .gift_preferences_id)
        } catch {
            Crashlytics.crashlytics().record(error: error)
            throw error
        }
    }
}

//List of data which we are cachig in userdefaults
struct PrefMasterData : Codable {
    var giftHabits : [Taxonomy]?
    var giftCategories : [Taxonomy]?
    var giftPreferences : [Taxonomy]?
    var cuisines : [Taxonomy]?
    var beverages : [Taxonomy]?
    var aviationCategories : [BaroqueAviationCategory]?
    var otherInterests : [Taxonomy]?
    var yachtLengths : [BaroqueAviationCategory]?
    var diningAllergies : [Taxonomy]?
    var diningPreferences : [Taxonomy]?
    var diningTimings : [Taxonomy]?
    var diningSeatings : [Taxonomy]?
    var eventCategory : [Taxonomy]?
    var eventLocation : [Taxonomy]?
    var travelHotelGroups : [Taxonomy]?
    var travelAmenities : [Taxonomy]?
    var travelActivities : [Taxonomy]?
    var travelMedicalMeals : [Taxonomy]?
    var travelAllergies : [Taxonomy]?
    var villaAmenities : [String]?
    var villaAccomodation : [String]?
    var profilePreferences : [String]?
    
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
    var aviation_preferred_beverage_id : [String]?
    var aviation_aircraft_category_id : [Int]?

    enum CodingKeys: String, CodingKey {
        case aviation_chartered_before = "aviation_chartered_before"
        case aviation_interested_in = "aviation_interested_in"
        case aviation_times_charter_corporate_jet = "aviation_times_charter_corporate_jet"
        case aviation_times_charter_leisure_jet = "aviation_times_charter_leisure_jet"
        case aviation_preferred_destinations = "aviation_preferred_destinations"
        case aviation_preferred_airports = "aviation_preferred_airports"
        case aviation_preferred_charter_range = "aviation_preferred_charter_range"
        case aviation_preferred_cuisine_id = "aviation_preferred_cuisine_ids"
        case aviation_preferred_beverage_id = "aviation_preferred_beverage_ids"
        case aviation_aircraft_category_id = "aviation_aircraft_category_ids"
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
            aviation_preferred_beverage_id = try values.decodeIfPresent([String].self, forKey: .aviation_preferred_beverage_id)
            aviation_aircraft_category_id = try values.decodeIfPresent([Int].self, forKey: .aviation_aircraft_category_id)
        } catch {
            Crashlytics.crashlytics().record(error: error)
            throw error
        }
    }
}

struct YachtPreferences : Codable {
    var yacht_chartered_before : String?
    var yacht_interested_in  : String?
    var yacht_times_charter_corporate_jet : Int?
    var yacht_times_charter_leisure_jet : Int?
    var yacht_preferred_destinations : [String]?
    var yacht_length : [String]?
    var yacht_type : String?
    var yacht_style : String?
    var yacht_preferred_cuisine_id : [String]?
    var yacht_interests_id : [String]?
    
    enum CodingKeys: String, CodingKey {
        case yacht_chartered_before = "yacht_chartered_before"
        case yacht_interested_in = "yacht_interested_in"
        case yacht_times_charter_corporate_jet = "yacht_times_charter_corporate_jet"
        case yacht_times_charter_leisure_jet = "yacht_times_charter_leisure_jet"
        case yacht_preferred_destinations = "yacht_preferred_destinations"
        case yacht_length = "yacht_length"
        case yacht_type = "yacht_type"
        case yacht_style = "yacht_style"
        case yacht_preferred_cuisine_id = "yacht_preferred_cuisine_ids"
        case yacht_interests_id = "yacht_interests_ids"
    }
    
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            yacht_chartered_before = try values.decodeIfPresent(String.self, forKey: .yacht_chartered_before)
            yacht_interested_in = try values.decodeIfPresent(String.self, forKey: .yacht_interested_in)
            yacht_times_charter_corporate_jet = try values.decodeIfPresent(Int.self, forKey: .yacht_times_charter_corporate_jet)
            yacht_times_charter_leisure_jet = try values.decodeIfPresent(Int.self, forKey: .yacht_times_charter_leisure_jet)
            yacht_preferred_destinations = try values.decodeIfPresent([String].self, forKey: .yacht_preferred_destinations)
            yacht_length = try values.decodeIfPresent([String].self, forKey: .yacht_length)
            yacht_type = try values.decodeIfPresent(String.self, forKey: .yacht_type)
            yacht_style = try values.decodeIfPresent(String.self, forKey: .yacht_style)
            yacht_preferred_cuisine_id = try values.decodeIfPresent([String].self, forKey: .yacht_preferred_cuisine_id)
            yacht_interests_id = try values.decodeIfPresent([String].self, forKey: .yacht_interests_id)
        } catch {
            Crashlytics.crashlytics().record(error: error)
            throw error
        }
    }
}

struct RestaurantPreferences : Codable {
    var restaurant_preferred_cuisine_id : [String]?
    var restaurant_allergy_id : [String]?
    var restaurant_dinning_id : [String]?
    var restaurant_timing_id : [String]?
    var restaurant_beverage_id : [String]?
    var restaurant_seating_id : [String]?
    
    enum CodingKeys: String, CodingKey {
        case restaurant_preferred_cuisine_id = "restaurant_preferred_cuisine_ids"
        case restaurant_allergy_id = "restaurant_allergy_ids"
        case restaurant_dinning_id = "restaurant_dinning_ids"
        case restaurant_timing_id = "restaurant_timing_ids"
        case restaurant_beverage_id = "restaurant_beverage_ids"
        case restaurant_seating_id = "restaurant_seating_ids"
    }
    
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            restaurant_preferred_cuisine_id = try values.decodeIfPresent([String].self, forKey: .restaurant_preferred_cuisine_id)
            restaurant_allergy_id = try values.decodeIfPresent([String].self, forKey: .restaurant_allergy_id)
            restaurant_dinning_id = try values.decodeIfPresent([String].self, forKey: .restaurant_dinning_id)
            restaurant_timing_id = try values.decodeIfPresent([String].self, forKey: .restaurant_timing_id)
            restaurant_beverage_id = try values.decodeIfPresent([String].self, forKey: .restaurant_beverage_id)
            restaurant_seating_id = try values.decodeIfPresent([String].self, forKey: .restaurant_seating_id)
        } catch {
            Crashlytics.crashlytics().record(error: error)
            throw error
        }
    }
}


struct EventPreferences : Codable {
    var event_category_id : [String]?
    var event_continent_ids : [String]?
    
    enum CodingKeys: String, CodingKey {
        case event_category_id = "event_category_ids"
        case event_continent_ids = "event_continent_ids"
    }
    
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            event_category_id = try values.decodeIfPresent([String].self, forKey: .event_category_id)
            event_continent_ids = try values.decodeIfPresent([String].self, forKey: .event_continent_ids)
        } catch {
            Crashlytics.crashlytics().record(error: error)
            throw error
        }
    }
}

struct TravelPreferences : Codable {
    var travel_times_business : Int?
    var travel_times_leisure : Int?
    var travel_preferred_destinations : [String]?
    var travel_rating_business_hotels : Int?
    var travel_rating_leisure_hotels : Int?
    var travel_destination_type : [String]?
    var travel_hotel_group : [String]?
    var travel_amenity_id : [String]?
    var travel_activity_id : [String]?
    var travel_airline_id: [String]?
    var travel_airplane_seat : String?
    var travel_airplane_business_cabin_class : Int?
    var travel_airplane_leisure_cabin_class : Int?
    var travel_airplane_meals : [String]?
    var travel_medical_dietary_meal : [String]?
    var travel_hotel_styles : [String]?
    var travel_allergy_id : [String]?

    enum CodingKeys: String, CodingKey {
        case travel_times_business = "travel_times_charter_corporate"
        case travel_times_leisure = "travel_times_charter_leisure"
        case travel_preferred_destinations = "travel_preferred_destinations"
        case travel_rating_business_hotels = "travel_star_rating_corporate"
        case travel_rating_leisure_hotels = "travel_star_rating_leisure"
        case travel_destination_type = "travel_destination_type"
        case travel_hotel_group = "travel_hotel_groups"
        case travel_amenity_id = "travel_preffered_amenities"
        case travel_activity_id = "travel_activities"
        case travel_airline_id = "travel_preferred_airlines"
        case travel_airplane_seat = "travel_preferred_seat"
        case travel_airplane_business_cabin_class = "travel_preferred_cabin_corporate"
        case travel_airplane_leisure_cabin_class = "travel_preferred_cabin_leisure"
        case travel_airplane_meals = "travel_preferred_meals"
        case travel_medical_dietary_meal = "travel_preferred_medical_dietry_meals"
        case travel_hotel_styles = "travel_hotel_styles"
        case travel_allergy_id = "travel_allergy_ids"
    }
    
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            travel_times_business = try values.decodeIfPresent(Int.self, forKey: .travel_times_business)
            travel_times_leisure = try values.decodeIfPresent(Int.self, forKey: .travel_times_leisure)
            travel_preferred_destinations = try values.decodeIfPresent([String].self, forKey: .travel_preferred_destinations)
            travel_rating_business_hotels = try values.decodeIfPresent(Int.self, forKey: .travel_rating_business_hotels)
            travel_rating_leisure_hotels = try values.decodeIfPresent(Int.self, forKey: .travel_rating_leisure_hotels)
            travel_destination_type = try values.decodeIfPresent([String].self, forKey: .travel_destination_type)
            travel_hotel_group = try values.decodeIfPresent([String].self, forKey: .travel_hotel_group)
            travel_amenity_id = try values.decodeIfPresent([String].self, forKey: .travel_amenity_id)
            travel_activity_id = try values.decodeIfPresent([String].self, forKey: .travel_activity_id)
            travel_airline_id = try values.decodeIfPresent([String].self, forKey: .travel_airline_id)
            travel_airplane_seat = try values.decodeIfPresent(String.self, forKey: .travel_airplane_seat)
            travel_airplane_business_cabin_class = try values.decodeIfPresent(Int.self, forKey: .travel_airplane_business_cabin_class)
            travel_airplane_leisure_cabin_class = try values.decodeIfPresent(Int.self, forKey: .travel_airplane_leisure_cabin_class)
            travel_airplane_meals = try values.decodeIfPresent([String].self, forKey: .travel_airplane_meals)
            travel_medical_dietary_meal = try values.decodeIfPresent([String].self, forKey: .travel_medical_dietary_meal)
            travel_hotel_styles = try values.decodeIfPresent([String].self, forKey: .travel_hotel_styles)
            travel_allergy_id = try values.decodeIfPresent([String].self, forKey: .travel_allergy_id)
        } catch {
            Crashlytics.crashlytics().record(error: error)
            throw error
        }
    }
}

struct VillaPreferences : Codable {
    var villa_preferred_destinations : [String]?
    var villa_preferred_amenities : [String]?
    var villa_preferred_accommodations : [String]?

    enum CodingKeys: String, CodingKey {
        case villa_preferred_destinations = "villa_preferred_destinations"
        case villa_preferred_amenities = "villa_preferred_amenities"
        case villa_preferred_accommodations = "villa_preferred_accommodations"
    }
    
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            villa_preferred_destinations = try values.decodeIfPresent([String].self, forKey: .villa_preferred_destinations)
            villa_preferred_amenities = try values.decodeIfPresent([String].self, forKey: .villa_preferred_amenities)
            villa_preferred_accommodations = try values.decodeIfPresent([String].self, forKey: .villa_preferred_accommodations)
        } catch {
            Crashlytics.crashlytics().record(error: error)
            throw error
        }
    }
}
