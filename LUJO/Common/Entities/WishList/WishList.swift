//
//  WishList.swift
//  LUJO
//
//  Created by I MAC on 05/11/2020.
//  Copyright © 2020 Baroque Access. All rights reserved.
//

import Foundation

class Favourite{
    internal init(id: Int? = nil, name: String? = nil, description: String? = nil, primaryMedia: Gallery? = nil, location: [TaxonomyLocation]? = nil, isFavourite: Bool? = nil
                  , gallery: [Gallery]? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.primaryMedia = primaryMedia
        self.location = location
        self.isFavourite = isFavourite
        self.gallery = gallery
    }
    
    var id: Int?
    var name: String?
    var description: String?
    var primaryMedia: Gallery?
    var location: [TaxonomyLocation]?
    var isFavourite: Bool?
    let gallery: [Gallery]?
 
    func getGalleryImagesURL() -> [String] {
        return gallery?.filter({ $0.type == "image" }).map({ $0.mediaUrl }) ?? []
    }
}

struct WishListObjects: Codable {
    var events: [Product]?
    var experiences: [Product]?
    var specialEvents: [Product]?
    var restaurants: [Restaurant]?
    var hotels: [Hotel]?
    var villas: [Product]?
    var gifts: [Product]?
    var yachts: [Product]?
    
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
            restaurants = try values.decodeIfPresent([Restaurant].self, forKey: .restaurants)
            events = try values.decodeIfPresent([Product].self, forKey: .events)
            specialEvents = try values.decodeIfPresent([Product].self, forKey: .specialEvents)
            experiences = try values.decodeIfPresent([Product].self, forKey: .experiences)
            hotels = try values.decodeIfPresent([Hotel].self, forKey: .hotels)
            villas = try values.decodeIfPresent([Product].self, forKey: .villas)
            gifts = try values.decodeIfPresent([Product].self, forKey: .gifts)
            yachts = try values.decodeIfPresent([Product].self, forKey: .yachts)
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

struct wishListProducts: Codable {
    let product: Product?

    init(from decoder: Decoder) throws {
        do {
            var container = try decoder.unkeyedContainer()  // having no key
            self.product = try container.decodeIfPresent(Product.self)
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
