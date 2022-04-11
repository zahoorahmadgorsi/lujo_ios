//
//  Restaurants.swift
//  LUJO
//
//  Created by Nemanja Djurisic on 8/12/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import FirebaseCrashlytics
import UIKit

struct StarChef: Codable {
    let chefName: String
    let chefImage: String?
    let chefRestaurant: Product?

    enum CodingKeys: String, CodingKey {
        case chefName = "chef_name"
        case chefImage = "chef_image"
        case chefRestaurant = "chef_restaurant_id"  // actually it is "chef_restaurant"
    }
}

extension StarChef {
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)

            chefName = try values.decode(String.self, forKey: .chefName)
            chefImage = try values.decodeIfPresent(String.self, forKey: .chefImage)
            chefRestaurant = try values.decodeIfPresent(Product.self, forKey: .chefRestaurant)

        } catch {
            Crashlytics.crashlytics().record(error: error)
            throw error
        }
    }
}

struct Cuisine: Codable {
    let termId: Int
    let name: String
    let iconUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case termId = "term_id"
        case name
        case iconUrl = "icon"
    }
}

extension Cuisine {
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            
            termId = try values.decode(Int.self, forKey: .termId)
            name = try values.decode(String.self, forKey: .name)
            iconUrl = try values.decodeIfPresent(String.self, forKey: .iconUrl)
            
        } catch {
            Crashlytics.crashlytics().record(error: error)
            throw error
        }
    }
}

struct DiningCity: Codable {
    var termId: String
    var name: String
    let restaurantsNum: Int
    var restaurants: [Product]
    
    enum CodingKeys: String, CodingKey {
        case termId = "term_id"
        case name
        case restaurantsNum = "restaurants_num"
        case restaurants
    }
}

extension DiningCity {
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            
            termId = try values.decode(String.self, forKey: .termId)
            name = try values.decode(String.self, forKey: .name)
            restaurantsNum = try values.decode(Int.self, forKey: .restaurantsNum)
            restaurants = try values.decode([Product].self, forKey: .restaurants)
            
        } catch {
            Crashlytics.crashlytics().record(error: error)
            throw error
        }
    }
}

struct DiningHomeObjects: Codable {
    let slider: [Product]?
    let starChef: StarChef?
    let cuisines: [Cuisine]
    var cities: [DiningCity]

    
    enum CodingKeys: String, CodingKey {
        case slider
        case starChef = "star-chef"
        case cuisines
        case cities
    }

    func getFeaturedImages() -> [String] {
        var urlList = [String]()
        for feature in slider ?? [] {
            if feature.primaryMedia?.type == "image" {
                urlList.append(feature.primaryMedia?.mediaUrl ?? "")
            } else {
                urlList.append("")
            }
        }

        return urlList
    }

    func getFeaturedNames() -> [String] {
        var list = [String]()
        for feature in slider ?? [] {
            list.append(feature.name)
        }

        return list
    }

    func getFeaturedStars() -> [String] {
        var list = [String]()
        for feature in slider ?? [] {
            list.append(feature.michelinStar?.first?.name ?? "")
        }

        return list
    }

    func getFeaturedLocations() -> [String] {
        var list = [String]()
        for feature in slider ?? [] {
            list.append(feature.locations?.city?.name ?? "")
        }

        return list
    }
}

extension DiningHomeObjects {
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)

            slider = try values.decodeIfPresent([Product].self, forKey: .slider)
            starChef = try values.decodeIfPresent(StarChef.self, forKey: .starChef)
            cuisines = try values.decode([Cuisine].self, forKey: .cuisines)
            cities = try values.decode([DiningCity].self, forKey: .cities)

        } catch {
            Crashlytics.crashlytics().record(error: error)
            throw error
        }
    }
}
