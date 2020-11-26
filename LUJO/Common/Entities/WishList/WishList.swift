//
//  WishList.swift
//  LUJO
//
//  Created by I MAC on 05/11/2020.
//  Copyright © 2020 Baroque Access. All rights reserved.
//

import Foundation

class Favourite{
    internal init(id: Int? = nil, name: String? = nil, description: String? = nil, primaryMedia: Gallery? = nil, location: [TaxonomyLocation]? = nil, isFavourite: Bool? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.primaryMedia = primaryMedia
        self.location = location
        self.isFavourite = isFavourite
    }
    
    var id: Int?
    var name: String?
    var description: String?
    var primaryMedia: Gallery?
    var location: [TaxonomyLocation]?
    var isFavourite: Bool?
    
    
}

struct WishListObjects: Codable {
    let events: [wishListEventsExperiences]?
    let experiences: [wishListEventsExperiences]?
    let specialEvents: [wishListEventsExperiences]?
    
    
    let restaurants: [wishListRestaurants]?
    let hotels: [wishListHotel]?
    let villas: [wishListVilla]?
    let gifts: [wishListGift]?
    let yachts: [wishListYacht]?
    

    enum CodingKeys: String, CodingKey {
        case restaurants = "restaurant"
        case events = "event"
        case specialEvents = "special_event"
        case experiences = "experience"
        case hotels = "hotel"
        case villas = "villa"
        case gifts = "gift"
        case yachts = "yacht"
    }

}

extension WishListObjects {
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            
            restaurants = try values.decodeIfPresent([wishListRestaurants].self, forKey: .restaurants)
            events = try values.decodeIfPresent([wishListEventsExperiences].self, forKey: .events)
            specialEvents = try values.decodeIfPresent([wishListEventsExperiences].self, forKey: .specialEvents)
            experiences = try values.decodeIfPresent([wishListEventsExperiences].self, forKey: .experiences)
            hotels = try values.decodeIfPresent([wishListHotel].self, forKey: .hotels)
            villas = try values.decodeIfPresent([wishListVilla].self, forKey: .villas)
            gifts = try values.decodeIfPresent([wishListGift].self, forKey: .gifts)
            yachts = try values.decodeIfPresent([wishListYacht].self, forKey: .yachts)
        } catch {
            Crashlytics.sharedInstance().recordError(error)
            throw error
        }
    }
}

struct wishListRestaurants: Codable {
    let restaurant: Restaurant?

    init(from decoder: Decoder) throws {
        do {
            var container = try decoder.unkeyedContainer()  // having no key
            self.restaurant = try container.decodeIfPresent(Restaurant.self)
        } catch {
            Crashlytics.sharedInstance().recordError(error)
            throw error
        }
    }
}

struct wishListEventsExperiences: Codable {
    let eventsExperience: Product?

    init(from decoder: Decoder) throws {
        do {
            var container = try decoder.unkeyedContainer()  // having no key
            self.eventsExperience = try container.decodeIfPresent(Product.self)
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
