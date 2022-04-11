//
//  Hotel.swift
//  LUJO
//
//  Created by I MAC on 08/11/2020.
//  Copyright © 2020 Baroque Access. All rights reserved.
//

import FirebaseCrashlytics
import UIKit

struct Hotel: Codable {
    let id: String
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

    let hotelCategory: [Taxonomy]?
    let hotelAmenities: [Taxonomy]?
    let hotelFacilities: [Taxonomy]?
    let priceRange: [Taxonomy]?
    let hotelStar: [Taxonomy]?
    let locations: TaxonomyLocation
    var isFavourite: Bool?
    
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
        
        case hotelCategory = "hotel_category"
        case hotelAmenities = "hotel_amenities"
        case hotelFacilities = "hotel_facilities"
        case hotelStar = "hotel_star"
        case priceRange = "price_range"
        case locations
        case isFavourite = "is_favorite"
    }

    
}

extension Hotel {
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)

            id = try values.decode(String.self, forKey: .id)
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
            

            hotelCategory = try values.decodeIfPresent([Taxonomy].self, forKey: .hotelCategory)
            hotelAmenities = try values.decodeIfPresent([Taxonomy].self, forKey: .hotelAmenities)
            hotelFacilities = try values.decodeIfPresent([Taxonomy].self, forKey: .hotelFacilities)
            hotelStar = try values.decodeIfPresent([Taxonomy].self, forKey: .hotelStar)
            priceRange = try values.decodeIfPresent([Taxonomy].self, forKey: .priceRange)
            locations = try values.decode(TaxonomyLocation.self, forKey: .locations)
            isFavourite = try values.decodeIfPresent(Bool.self, forKey: .isFavourite)
        } catch {
            Crashlytics.crashlytics().record(error: error)
            throw error
        }
    }
}
