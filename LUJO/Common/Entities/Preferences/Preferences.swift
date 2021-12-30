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
    var villaAmenities : [Taxonomy]?
    var villaAccomodation : [Taxonomy]?
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
    var yacht_preferred_cuisine_id_other : String?
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
        case yacht_preferred_cuisine_id = "yacht_preferred_cuisine_id"
        case yacht_preferred_cuisine_id_other = "yacht_preferred_cuisine_id_other"
        case yacht_interests_id = "yacht_interests_id"
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
            yacht_preferred_cuisine_id_other = try values.decodeIfPresent(String.self, forKey: .yacht_preferred_cuisine_id_other)
            yacht_interests_id = try values.decodeIfPresent([String].self, forKey: .yacht_interests_id)
        } catch {
            Crashlytics.crashlytics().record(error: error)
            throw error
        }
    }
}

struct RestaurantPreferences : Codable {
    var restaurant_preferred_cuisine_id : [String]?
    var restaurant_preferred_cuisine_id_other : String?
    var restaurant_allergy_id : [String]?
//    var restaurant_allergy_id_other : String?
    var restaurant_dinning_id : [String]?
    var restaurant_dinning_id_other : String?
    var restaurant_timing_id : [String]?
    var restaurant_beverage_id : [String]?
    var restaurant_beverage_id_other : String?
    var restaurant_seating_id : [String]?
    
    enum CodingKeys: String, CodingKey {
        case restaurant_preferred_cuisine_id = "restaurant_preferred_cuisine_id"
        case restaurant_preferred_cuisine_id_other = "restaurant_preferred_cuisine_id_other"
        case restaurant_allergy_id = "restaurant_allergy_id"
//        case restaurant_allergy_id_other = "restaurant_allergy_id_other"
        case restaurant_dinning_id = "restaurant_dinning_id"
        case restaurant_dinning_id_other = "restaurant_dinning_id_other"
        case restaurant_timing_id = "restaurant_timing_id"
        case restaurant_beverage_id = "restaurant_beverage_id"
        case restaurant_beverage_id_other = "restaurant_beverage_id_other"
        case restaurant_seating_id = "restaurant_seating_id"
    }
    
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            restaurant_preferred_cuisine_id = try values.decodeIfPresent([String].self, forKey: .restaurant_preferred_cuisine_id)
            restaurant_preferred_cuisine_id_other  = try values.decodeIfPresent(String.self, forKey: .restaurant_preferred_cuisine_id_other)
            restaurant_allergy_id = try values.decodeIfPresent([String].self, forKey: .restaurant_allergy_id)
//            restaurant_allergy_id_other = try values.decodeIfPresent(String.self, forKey: .restaurant_allergy_id_other)
            restaurant_dinning_id = try values.decodeIfPresent([String].self, forKey: .restaurant_dinning_id)
            restaurant_dinning_id_other = try values.decodeIfPresent(String.self, forKey: .restaurant_dinning_id_other)
            restaurant_timing_id = try values.decodeIfPresent([String].self, forKey: .restaurant_timing_id)
            restaurant_beverage_id = try values.decodeIfPresent([String].self, forKey: .restaurant_beverage_id)
            restaurant_beverage_id_other = try values.decodeIfPresent(String.self, forKey: .restaurant_beverage_id_other)
            restaurant_seating_id = try values.decodeIfPresent([String].self, forKey: .restaurant_seating_id)
        } catch {
            Crashlytics.crashlytics().record(error: error)
            throw error
        }
    }
}


struct EventPreferences : Codable {
    var event_category_id : [String]?
    var event_category_id_other : String?
    var event_location_id : [String]?
    
    enum CodingKeys: String, CodingKey {
        case event_category_id = "event_category_id"
        case event_category_id_other = "event_category_id_other"
        case event_location_id = "event_location_id"
    }
    
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            event_category_id = try values.decodeIfPresent([String].self, forKey: .event_category_id)
            event_category_id_other = try values.decodeIfPresent(String.self, forKey: .event_category_id_other)
            event_location_id = try values.decodeIfPresent([String].self, forKey: .event_location_id)
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
    var travel_amenity_id_other : String?
    var travel_activity_id : [String]?
    var travel_airline_id: [String]?
    var travel_airplane_seat : [String]?
//    travel_airplane_seat_other
    var travel_airplane_business_cabin_class : [String]?
    var travel_airplane_leisure_cabin_class : [String]?
    var travel_airplane_meals : [String]?
    var travel_medical_dietary_meal : [String]?
    var travel_medical_dietary_meal_other: String?
    var travel_hotel_styles : [String]?
    var travel_allergy_id : [String]?
    var travel_allergy_id_other : String?

    enum CodingKeys: String, CodingKey {
        case travel_times_business = "travel_times_business"
        case travel_times_leisure = "travel_times_leisure"
        case travel_preferred_destinations = "travel_preferred_destinations"
        case travel_rating_business_hotels = "travel_rating_business_hotels"
        case travel_rating_leisure_hotels = "travel_rating_leisure_hotels"
        case travel_destination_type = "travel_destination_type"
        case travel_hotel_group = "travel_hotel_group"
        case travel_amenity_id = "travel_amenity_id"
        case travel_amenity_id_other = "travel_amenity_id_other"
        case travel_activity_id = "travel_activity_id"
        case travel_airline_id = "travel_airline_id"
        case travel_airplane_seat = "travel_airplane_seat"
//            case travel_airplane_seat_other = "travel_airplane_seat_other"
        case travel_airplane_business_cabin_class = "travel_airplane_business_cabin_class"
        case travel_airplane_leisure_cabin_class = "travel_airplane_leisure_cabin_class"
        case travel_airplane_meals = "travel_airplane_meals"
        case travel_medical_dietary_meal = "travel_media_dietary_meal"
        case travel_medical_dietary_meal_other = "travel_media_dietary_meal_other"
        case travel_hotel_styles = "travel_hotel_types"
        case travel_allergy_id = "travel_allergy_id"
        case travel_allergy_id_other = "travel_allergy_id_other"
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
            travel_amenity_id_other = try values.decodeIfPresent(String.self, forKey: .travel_amenity_id_other)
            travel_activity_id = try values.decodeIfPresent([String].self, forKey: .travel_activity_id)
            travel_airline_id = try values.decodeIfPresent([String].self, forKey: .travel_airline_id)
            travel_airplane_seat = try values.decodeIfPresent([String].self, forKey: .travel_airplane_seat)
        //    travel_airplane_seat_other = try values.decodeIfPresent([String].self, forKey: .travel_airplane_seat_other)
            travel_airplane_business_cabin_class = try values.decodeIfPresent([String].self, forKey: .travel_airplane_business_cabin_class)
            travel_airplane_leisure_cabin_class = try values.decodeIfPresent([String].self, forKey: .travel_airplane_leisure_cabin_class)
            travel_airplane_meals = try values.decodeIfPresent([String].self, forKey: .travel_airplane_meals)
            travel_medical_dietary_meal = try values.decodeIfPresent([String].self, forKey: .travel_medical_dietary_meal)
            travel_medical_dietary_meal_other = try values.decodeIfPresent(String.self, forKey: .travel_medical_dietary_meal_other)
            travel_hotel_styles = try values.decodeIfPresent([String].self, forKey: .travel_hotel_styles)
            travel_allergy_id = try values.decodeIfPresent([String].self, forKey: .travel_allergy_id)
            travel_allergy_id_other = try values.decodeIfPresent(String.self, forKey: .travel_allergy_id_other)
        } catch {
            Crashlytics.crashlytics().record(error: error)
            throw error
        }
    }
}

struct VillaPreferences : Codable {
    var villa_preferred_destinations_id : [String]?
    var villa_preferred_amenities_id : [String]?
    var villa_preferred_amenities_id_other : String?
    var villa_preferred_accommodations_id : [String]?
    var villa_preferred_accommodations_id_other : String?

    enum CodingKeys: String, CodingKey {
        case villa_preferred_destinations_id = "villa_preferred_destinations_id"
        case villa_preferred_amenities_id = "villa_preferred_amenities_id"
        case villa_preferred_amenities_id_other = "villa_preferred_amenities_id_other"
        case villa_preferred_accommodations_id = "villa_preferred_accommodations_id"
        case villa_preferred_accommodations_id_other = "villa_preferred_accommodations_id_other"
    }
    
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            villa_preferred_destinations_id = try values.decodeIfPresent([String].self, forKey: .villa_preferred_destinations_id)
            villa_preferred_amenities_id = try values.decodeIfPresent([String].self, forKey: .villa_preferred_amenities_id)
            villa_preferred_amenities_id_other = try values.decodeIfPresent(String.self, forKey: .villa_preferred_amenities_id_other)
            villa_preferred_accommodations_id = try values.decodeIfPresent([String].self, forKey: .villa_preferred_accommodations_id)
            villa_preferred_accommodations_id_other = try values.decodeIfPresent(String.self, forKey: .villa_preferred_accommodations_id_other)
        } catch {
            Crashlytics.crashlytics().record(error: error)
            throw error
        }
    }
}
