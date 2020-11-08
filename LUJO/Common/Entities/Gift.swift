//
//  Gift.swift
//  LUJO
//
//  Created by I MAC on 08/11/2020.
//  Copyright © 2020 Baroque Access. All rights reserved.
//

import Crashlytics
import UIKit

struct Gift: Codable {
    let id: Int?
    let name: String?
    let description: String?
    let price: String?
    let pdf_info: Bool?
    let primaryMedia: Gallery?
    let gallery: [Gallery]?
    let gift_category : [Taxonomy]?
    let lujo_tag: [Taxonomy]?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case price
        case pdf_info
        case primaryMedia
        case gallery
        case gift_category
        case lujo_tag
    }
}

extension Gift {
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decodeIfPresent(Int.self, forKey: .id)
            name = try values.decodeIfPresent(String.self, forKey: .name)
            description = try values.decodeIfPresent(String.self, forKey: .description)
            price = try values.decodeIfPresent(String.self, forKey: .price)
            pdf_info = try values.decodeIfPresent(Bool.self, forKey: .pdf_info)
            primaryMedia = try values.decodeIfPresent(Gallery.self, forKey: .primaryMedia)
            gallery = try values.decodeIfPresent([Gallery].self, forKey: .gallery)
            gift_category = try values.decodeIfPresent([Taxonomy].self, forKey: .gift_category)
            lujo_tag = try values.decodeIfPresent([Taxonomy].self, forKey: .lujo_tag)
        } catch {
            Crashlytics.sharedInstance().recordError(error)
            throw error
        }
    }
}
