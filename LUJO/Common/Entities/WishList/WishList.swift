//
//  WishList.swift
//  LUJO
//
//  Created by I MAC on 05/11/2020.
//  Copyright © 2020 Baroque Access. All rights reserved.
//

import Foundation

struct wishListRestaurants: Codable {
    let restaurant: Restaurants?

    init(from decoder: Decoder) throws {
        do {
            var container = try decoder.unkeyedContainer()  // having no key
            self.restaurant = try container.decodeIfPresent(Restaurants.self)
        } catch {
            Crashlytics.sharedInstance().recordError(error)
            throw error
        }
    }
}

struct wishListEventsExperiences: Codable {
    let eventsExperience: EventsExperiences?

    init(from decoder: Decoder) throws {
        do {
            var container = try decoder.unkeyedContainer()  // having no key
            self.eventsExperience = try container.decodeIfPresent(EventsExperiences.self)
        } catch {
            Crashlytics.sharedInstance().recordError(error)
            throw error
        }
    }
}

struct wishListHotel: Codable {
    let hotel: Hotel?

    init(from decoder: Decoder) throws {
        do {
            var container = try decoder.unkeyedContainer()  // having no key
            self.hotel = try container.decodeIfPresent(Hotel.self)
        } catch {
            Crashlytics.sharedInstance().recordError(error)
            throw error
        }
    }
}

struct wishListYacht: Codable {
    let yacht: Yacht?

    init(from decoder: Decoder) throws {
        do {
            var container = try decoder.unkeyedContainer()  // having no key
            self.yacht = try container.decodeIfPresent(Yacht.self)
        } catch {
            Crashlytics.sharedInstance().recordError(error)
            throw error
        }
    }
}

struct wishListVilla: Codable {
    let villa: Villa?

    init(from decoder: Decoder) throws {
        do {
            var container = try decoder.unkeyedContainer()  // having no key
            self.villa = try container.decodeIfPresent(Villa.self)
        } catch {
            Crashlytics.sharedInstance().recordError(error)
            throw error
        }
    }
}

struct wishListGift: Codable {
    let gift: Gift?

    init(from decoder: Decoder) throws {
        do {
            var container = try decoder.unkeyedContainer()  // having no key
            self.gift = try container.decodeIfPresent(Gift.self)
        } catch {
            Crashlytics.sharedInstance().recordError(error)
            throw error
        }
    }
}

struct WishListObjects: Codable {
    let restaurant: [wishListRestaurants]?
    let event: [wishListEventsExperiences]?
    let specialEvent: [wishListEventsExperiences]?
    let experience: [wishListEventsExperiences]?
    let hotel: [wishListHotel]?
    let villa: [wishListVilla]?
    let gift: [wishListGift]?
    let yacht: [wishListYacht]?
    

    enum CodingKeys: String, CodingKey {
        case restaurant
        case event
        case specialEvent = "special_event"
        case experience
        case hotel
        case villa
        case gift
        case yacht
    }

}

extension WishListObjects {
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            
            restaurant = try values.decodeIfPresent([wishListRestaurants].self, forKey: .restaurant)
            event = try values.decodeIfPresent([wishListEventsExperiences].self, forKey: .event)
            specialEvent = try values.decodeIfPresent([wishListEventsExperiences].self, forKey: .specialEvent)
            experience = try values.decodeIfPresent([wishListEventsExperiences].self, forKey: .experience)
            hotel = try values.decodeIfPresent([wishListHotel].self, forKey: .hotel)
            villa = try values.decodeIfPresent([wishListVilla].self, forKey: .villa)
            gift = try values.decodeIfPresent([wishListGift].self, forKey: .gift)
            yacht = try values.decodeIfPresent([wishListYacht].self, forKey: .yacht)
        } catch {
            Crashlytics.sharedInstance().recordError(error)
            throw error
        }
    }
}
