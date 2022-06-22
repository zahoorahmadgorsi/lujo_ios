//
//  Card.swift
//  LUJO
//
//  Created by Zahoor Gorsi on 22/06/2022.
//  Copyright © 2022 Baroque Access. All rights reserved.
//

import Foundation

struct Address: Codable {
    let id: String
    let address: String
    let apartment: String
    let zip_code: String
    let city: Taxonomy
    let country: Taxonomy
    let address_type: String
    let default_address: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case address
        case apartment
        case zip_code
        case city
        case country
        case address_type
        case default_address
    }
    
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decode(String.self, forKey: .id)
            address = try values.decode(String.self, forKey: .address)
            apartment = try values.decode(String.self, forKey: .apartment)
            
            zip_code = try values.decode(String.self, forKey: .zip_code)
            city = try values.decode(Taxonomy.self, forKey: .city)
            country = try values.decode(Taxonomy.self, forKey: .country)
            
            address_type = try values.decode(String.self, forKey: .address_type)
            default_address = try values.decode(Bool.self, forKey: .default_address)

        } catch {
            throw error
        }
    }
}
