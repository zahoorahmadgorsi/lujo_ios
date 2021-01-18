//
//  Yacht.swift
//  LUJO
//
//  Created by I MAC on 08/11/2020.
//  Copyright © 2020 Baroque Access. All rights reserved.
//

import Crashlytics
import UIKit

struct Yacht: Codable {
    let id: Int?
    let name: String?
    let description: String?
    let pdf_info: Bool?
    let headline: String?
    let guests_number: String?
    let cabin_number: String?
    let crew_number : String?
    let builder_name : String?
    let interior_designer : String?
    let exterior_designer : String?
    let build_year : String?
    let refit_year : String?
    let length_m : String?
    let beam_m : String?
    let draft_m : String?
    let gross_tonnage : String?
    let cruising_speed_knot : String?
    let top_speed_knot : String?
    let charter_price_low_season_per_week : String?
    let charter_price_high_season_per_week : String?
    let sale_price : String?
    let primaryMedia: Gallery?
    let gallery: [Gallery]?
    let lujo_tag: [Taxonomy]?
    let yacht_type : [Taxonomy]?
    let yacht_status : [Taxonomy]?
    let yacht_extras : [Taxonomy]?
    let location: [TaxonomyLocation]?
    let priceRange: [Taxonomy]?
    var isFavourite: Bool?
    let charter_price_low_season_per_day : String?
    let charter_price_high_season_per_day : String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case pdf_info
        case headline
        case guests_number
        case cabin_number
        case crew_number
        case builder_name
        case interior_designer
        case exterior_designer
        case build_year
        case refit_year
        case length_m
        case beam_m
        case draft_m
        case gross_tonnage
        case cruising_speed_knot
        case top_speed_knot
        case charter_price_low_season_per_week
        case charter_price_high_season_per_week
        case sale_price
        case primaryMedia
        case gallery
        case lujo_tag
        case yacht_type
        case yacht_status
        case yacht_extras
        case location
        case priceRange
        case isFavourite = "is_favorite"
        case charter_price_low_season_per_day
        case charter_price_high_season_per_day
    }

    
}

extension Yacht {
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decodeIfPresent(Int.self, forKey: .id)
            name = try values.decodeIfPresent(String.self, forKey: .name)
            description = try values.decodeIfPresent(String.self, forKey: .description)
            pdf_info = try values.decodeIfPresent(Bool.self, forKey: .pdf_info)
            headline = try values.decodeIfPresent(String.self, forKey: .headline)
            guests_number = try values.decodeIfPresent(String.self, forKey: .guests_number)
            cabin_number = try values.decodeIfPresent(String.self, forKey: .cabin_number)
            crew_number = try values.decodeIfPresent(String.self, forKey: .crew_number)
            builder_name = try values.decodeIfPresent(String.self, forKey: .builder_name)
            interior_designer = try values.decodeIfPresent(String.self, forKey: .interior_designer)
            exterior_designer = try values.decodeIfPresent(String.self, forKey: .exterior_designer)
            build_year = try values.decodeIfPresent(String.self, forKey: .build_year)
            refit_year = try values.decodeIfPresent(String.self, forKey: .refit_year)
            length_m = try values.decodeIfPresent(String.self, forKey: .length_m)
            beam_m = try values.decodeIfPresent(String.self, forKey: .beam_m)
            draft_m = try values.decodeIfPresent(String.self, forKey: .draft_m)
            gross_tonnage = try values.decodeIfPresent(String.self, forKey: .gross_tonnage)
            cruising_speed_knot = try values.decodeIfPresent(String.self, forKey: .cruising_speed_knot)
            top_speed_knot = try values.decodeIfPresent(String.self, forKey: .top_speed_knot)
            charter_price_low_season_per_week = try values.decodeIfPresent(String.self, forKey: .charter_price_low_season_per_week)
            charter_price_high_season_per_week = try values.decodeIfPresent(String.self, forKey: .charter_price_high_season_per_week)
            sale_price = try values.decodeIfPresent(String.self, forKey: .sale_price)
            primaryMedia = try values.decodeIfPresent(Gallery.self, forKey: .primaryMedia)
            gallery = try values.decodeIfPresent([Gallery].self, forKey: .gallery)
            lujo_tag = try values.decodeIfPresent([Taxonomy].self, forKey: .lujo_tag)
            yacht_type = try values.decodeIfPresent([Taxonomy].self, forKey: .yacht_type)
            yacht_status = try values.decodeIfPresent([Taxonomy].self, forKey: .yacht_status)
            yacht_extras = try values.decodeIfPresent([Taxonomy].self, forKey: .yacht_extras)
            location = try values.decodeIfPresent([TaxonomyLocation].self, forKey: .location)
            priceRange = try values.decodeIfPresent([Taxonomy].self, forKey: .priceRange)
            isFavourite = try values.decodeIfPresent(Bool.self, forKey: .isFavourite)
            charter_price_low_season_per_day = try values.decodeIfPresent(String.self, forKey: .charter_price_low_season_per_day)
            charter_price_high_season_per_day = try values.decodeIfPresent(String.self, forKey: .charter_price_high_season_per_day)
        } catch {
            Crashlytics.sharedInstance().recordError(error)
            throw error
        }
    }
}
