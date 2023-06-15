//
//  WishList.swift
//  LUJO
//
//  Created by I MAC on 05/11/2020.
//  Copyright © 2020 Baroque Access. All rights reserved.
//

import Foundation
import FirebaseCrashlytics

struct WishListObjects: Codable {
    var events: [Product]?
    var experiences: [Product]?
    var specialEvents: [Product]?
    var restaurants: [Product]?
    var villas: [Product]?
    var hotels: [Product]?
    var gifts: [Product]?
    var yachts: [Product]?
    
    enum CodingKeys: String, CodingKey {
        case restaurants = "restaurant"
        case events = "event"
        case specialEvents = "special_event"
        case experiences = "experience"
        case hotels = "travel"
        case villas = "villa"
        case gifts = "gift"
        case yachts = "yacht"
    }
    
    func isEmpty()-> Bool{
        if (events?.count == 0 && experiences?.count == 0 && specialEvents?.count == 0 && restaurants?.count == 0 && hotels?.count == 0 && villas?.count == 0 && gifts?.count == 0 && yachts?.count == 0){
            return true
        }else{
            return false
        }
    }
}

extension WishListObjects {
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            restaurants = try values.decodeIfPresent([Product].self, forKey: .restaurants)
            events = try values.decodeIfPresent([Product].self, forKey: .events)
            specialEvents = try values.decodeIfPresent([Product].self, forKey: .specialEvents)
            experiences = try values.decodeIfPresent([Product].self, forKey: .experiences)
            villas = try values.decodeIfPresent([Product].self, forKey: .villas)
            hotels = try values.decodeIfPresent([Product].self, forKey: .hotels)
            gifts = try values.decodeIfPresent([Product].self, forKey: .gifts)
            yachts = try values.decodeIfPresent([Product].self, forKey: .yachts)
        } catch {
            Crashlytics.crashlytics().record(error: error)
            throw error
        }
    }
}

struct wishListRestaurants: Codable {
    let restaurant: Product?

    init(from decoder: Decoder) throws {
        do {
            var container = try decoder.unkeyedContainer()  // having no key
            self.restaurant = try container.decodeIfPresent(Product.self)
        } catch {
            Crashlytics.crashlytics().record(error: error)
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
            Crashlytics.crashlytics().record(error: error)
            throw error
        }
    }
}
