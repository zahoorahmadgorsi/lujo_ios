//
//  Villa.swift
//  LUJO
//
//  Created by I MAC on 08/11/2020.
//  Copyright © 2020 Baroque Access. All rights reserved.
//

import FirebaseCrashlytics
import UIKit

struct Villa: Codable {
    let id: Int?
    let name: String?
    let description: String?
    let pdf_info: Bool?
    let headline: String?
    let number_of_bedrooms: String?
    let number_of_bathrooms: String?
    let number_of_guests : String?
    let rent_price_per_week_low_season : String?
    let rent_price_per_week_high_season : String?
    let sale_price : String?
    let primaryMedia: Gallery?
    let gallery: [Gallery]?
    let latitude : String?
    let longtitude : String?
    let lujo_tag: [Taxonomy]?
    let villa_amenities : [Taxonomy]?
    let villa_facilities : [Taxonomy]?
    let villa_style : [Taxonomy]?
    let villa_status  : [Taxonomy]?
    let priceRange: [Taxonomy]?
    let location: [TaxonomyLocation]?    
    var isFavourite: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case pdf_info
        case headline
        case number_of_bedrooms
        case number_of_bathrooms
        case number_of_guests
        case rent_price_per_week_low_season
        case rent_price_per_week_high_season
        case sale_price
//        case primaryMedia
        case primaryMedia = "thumbnail"
        case gallery
        case latitude
        case longtitude
        case lujo_tag
        case villa_amenities
        case villa_facilities
        case villa_style
        case villa_status
        case location
        case priceRange
        case isFavourite = "is_favorite"
    }
}

extension Villa {
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decodeIfPresent(Int.self, forKey: .id)
            name = try values.decodeIfPresent(String.self, forKey: .name)
            description = try values.decodeIfPresent(String.self, forKey: .description)
            pdf_info = try values.decodeIfPresent(Bool.self, forKey: .pdf_info)
            headline = try values.decodeIfPresent(String.self, forKey: .headline)
            number_of_bedrooms = try values.decodeIfPresent(String.self, forKey: .number_of_bedrooms)
            number_of_bathrooms = try values.decodeIfPresent(String.self, forKey: .number_of_bathrooms)
            number_of_guests = try values.decodeIfPresent(String.self, forKey: .number_of_guests)
            rent_price_per_week_low_season = try values.decodeIfPresent(String.self, forKey: .rent_price_per_week_low_season)
            rent_price_per_week_high_season = try values.decodeIfPresent(String.self, forKey: .rent_price_per_week_high_season)
            sale_price = try values.decodeIfPresent(String.self, forKey: .sale_price)
            primaryMedia = try values.decodeIfPresent(Gallery.self, forKey: .primaryMedia)
            gallery = try values.decodeIfPresent([Gallery].self, forKey: .gallery)
            latitude = try values.decodeIfPresent(String.self, forKey: .latitude)
            longtitude = try values.decodeIfPresent(String.self, forKey: .longtitude)
            lujo_tag = try values.decodeIfPresent([Taxonomy].self, forKey: .lujo_tag)
            villa_amenities = try values.decodeIfPresent([Taxonomy].self, forKey: .villa_amenities)
            villa_facilities = try values.decodeIfPresent([Taxonomy].self, forKey: .villa_facilities)
            villa_style = try values.decodeIfPresent([Taxonomy].self, forKey: .villa_style)
            villa_status = try values.decodeIfPresent([Taxonomy].self, forKey: .villa_status)
            location = try values.decodeIfPresent([TaxonomyLocation].self, forKey: .location)
            priceRange = try values.decodeIfPresent([Taxonomy].self, forKey: .priceRange)
            isFavourite = try values.decodeIfPresent(Bool.self, forKey: .isFavourite)
            
        } catch {
            Crashlytics.crashlytics().record(error: error)
            throw error
        }
    }
}
