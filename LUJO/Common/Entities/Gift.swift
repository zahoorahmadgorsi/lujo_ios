//
//  Gift.swift
//  LUJO
//
//  Created by I MAC on 08/11/2020.
//  Copyright © 2020 Baroque Access. All rights reserved.
//

import FirebaseCrashlytics
import UIKit

struct Gift: Codable {
    let id: Int?
    let name: String?
    let description: String?
//    let price: String?
    let price: Price?
    let pdf_info: Bool?
    let thumbnail: Gallery?
    let gallery: [Gallery]?
    let gift_category : Taxonomy?
    let lujo_tag: [Taxonomy]?
    let location: [TaxonomyLocation]?
    var isFavourite: Bool?
    let giftSubCategory : Taxonomy?
    let giftBrand : Taxonomy?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case price
        case pdf_info
        case thumbnail
        case gallery
        case gift_category
        case lujo_tag
        case location
        case isFavourite = "is_favorite"
        case giftSubCategory = "gift_sub_category"
        case giftBrand = "gift_brand"
    }
}

extension Gift {
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decodeIfPresent(Int.self, forKey: .id)
            name = try values.decodeIfPresent(String.self, forKey: .name)
            description = try values.decodeIfPresent(String.self, forKey: .description)
            price = try values.decodeIfPresent(Price.self, forKey: .price)
            pdf_info = try values.decodeIfPresent(Bool.self, forKey: .pdf_info)
            thumbnail = try values.decodeIfPresent(Gallery.self, forKey: .thumbnail)
            gallery = try values.decodeIfPresent([Gallery].self, forKey: .gallery)
            gift_category = try values.decodeIfPresent(Taxonomy.self, forKey: .gift_category)
            lujo_tag = try values.decodeIfPresent([Taxonomy].self, forKey: .lujo_tag)
            location = try values.decodeIfPresent([TaxonomyLocation].self, forKey: .location)
            isFavourite = try values.decodeIfPresent(Bool.self, forKey: .isFavourite)
            giftSubCategory = try values.decodeIfPresent(Taxonomy.self, forKey: .giftSubCategory)
            giftBrand = try values.decodeIfPresent(Taxonomy.self, forKey: .giftBrand)
        } catch {
            Crashlytics.crashlytics().record(error: error)
            throw error
        }
    }
}
