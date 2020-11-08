//
//  Restaurants.swift
//  LUJO
//
//  Created by Nemanja Djurisic on 8/12/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import Crashlytics
import UIKit

struct Restaurants: Codable {
    let id: Int
    let name: String
    let description: String
    let tripadvisor: String?
    let address: String
    let phone: String?
    let zipCode: String?
    let email: String?
    let website: String?
    let primaryMedia: Gallery?
    let gallery: [Gallery]?

    let latitude: String?
    let longtitude: String?
    let starChief: String?

    let restaurantCategory: [Taxonomy]?
    let cuisineCategory: [Taxonomy]?
    let michelinStar: [Taxonomy]?
    let priceRange: [Taxonomy]?
    let location: [TaxonomyLocation]

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case tripadvisor
        case address
        case zipCode = "zip"
        case phone
        case email
        case website
        case primaryMedia = "featured_media"
        case gallery
        case latitude
        case longtitude
        case starChief = "star-chef"
        case restaurantCategory = "restaurant_category"
        case cuisineCategory = "cuisine_category"
        case michelinStar = "michelin_star"
        case priceRange = "price_range"
        case location
    }

    func getAllImagesURL() -> [String] {
        return gallery?.filter({ $0.type == "image" }).map({ $0.mediaUrl }) ?? []
    }
}

extension Restaurants {
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)

            id = try values.decode(Int.self, forKey: .id)
            name = try values.decode(String.self, forKey: .name)
            description = try values.decode(String.self, forKey: .description)
            tripadvisor = try values.decodeIfPresent(String.self, forKey: .tripadvisor)
            address = try values.decode(String.self, forKey: .address)
            phone = try values.decodeIfPresent(String.self, forKey: .phone)
            zipCode = try values.decodeIfPresent(String.self, forKey: .zipCode)
            email = try values.decodeIfPresent(String.self, forKey: .email)
            website = try values.decodeIfPresent(String.self, forKey: .website)

            primaryMedia = try values.decodeIfPresent(Gallery.self, forKey: .primaryMedia)
            gallery = try values.decodeIfPresent([Gallery].self, forKey: .gallery)

            latitude = try values.decodeIfPresent(String.self, forKey: .latitude)
            longtitude = try values.decodeIfPresent(String.self, forKey: .longtitude)
            starChief = try values.decodeIfPresent(String.self, forKey: .starChief)

            restaurantCategory = try values.decodeIfPresent([Taxonomy].self, forKey: .restaurantCategory)
            cuisineCategory = try values.decodeIfPresent([Taxonomy].self, forKey: .cuisineCategory)
            michelinStar = try values.decodeIfPresent([Taxonomy].self, forKey: .michelinStar)
            priceRange = try values.decodeIfPresent([Taxonomy].self, forKey: .priceRange)
            location = try values.decode([TaxonomyLocation].self, forKey: .location)
        } catch {
            Crashlytics.sharedInstance().recordError(error)
            throw error
        }
    }
}

struct StarChief: Codable {
    let chiefName: String
    let chiefImage: String?
    let chiefRestaurant: Restaurants

    enum CodingKeys: String, CodingKey {
        case chiefName = "chef_name"
        case chiefImage = "chef_image"
        case chiefRestaurant = "chef_restaurant"
    }
}

extension StarChief {
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)

            chiefName = try values.decode(String.self, forKey: .chiefName)
            chiefImage = try values.decodeIfPresent(String.self, forKey: .chiefImage)
            chiefRestaurant = try values.decode(Restaurants.self, forKey: .chiefRestaurant)

        } catch {
            Crashlytics.sharedInstance().recordError(error)
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
            Crashlytics.sharedInstance().recordError(error)
            throw error
        }
    }
}

struct DiningCity: Codable {
    let termId: Int
    let name: String
    let restaurantsNum: Int
    let restaurants: [Restaurants]
    
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
            
            termId = try values.decode(Int.self, forKey: .termId)
            name = try values.decode(String.self, forKey: .name)
            restaurantsNum = try values.decode(Int.self, forKey: .restaurantsNum)
            restaurants = try values.decode([Restaurants].self, forKey: .restaurants)
            
        } catch {
            Crashlytics.sharedInstance().recordError(error)
            throw error
        }
    }
}

struct DiningHomeObjects: Codable {
    let slider: [Restaurants]?
    let starChief: StarChief?
    let cuisines: [Cuisine]
    let cities: [DiningCity]

    enum CodingKeys: String, CodingKey {
        case slider
        case starChief = "star-chef"
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
            list.append(feature.location.first?.city?.name ?? "")
        }

        return list
    }
}

extension DiningHomeObjects {
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)

            slider = try values.decodeIfPresent([Restaurants].self, forKey: .slider)
            starChief = try values.decodeIfPresent(StarChief.self, forKey: .starChief)
            cuisines = try values.decode([Cuisine].self, forKey: .cuisines)
            cities = try values.decode([DiningCity].self, forKey: .cities)

        } catch {
            Crashlytics.sharedInstance().recordError(error)
            throw error
        }
    }
}
