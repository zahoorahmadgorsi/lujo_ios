//
//  Card.swift
//  LUJO
//
//  Created by Zahoor Gorsi on 22/06/2022.
//  Copyright © 2022 Baroque Access. All rights reserved.
//

import Foundation

struct Card: Codable {
    var id: String
    let card_holder_name: String
    let masked_card_number: String
    let card_expiry: CardExpiry
    let cvv: Int?
    var default_card: Bool
    
    var expiryDate: String {
        return String(card_expiry.month) + "/" + String(card_expiry.year)
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case card_holder_name
        case masked_card_number
        case card_expiry
        case cvv
        case default_card
    }
    
    init(_ id:String? ,_ nameOnCard:String,_ card_number:String ,_ cvv:Int,_ month:Int,_ year:Int,_ default_card:Bool){
        self.id = id ?? ""
        self.card_holder_name = nameOnCard
        self.masked_card_number = card_number
        self.card_expiry = CardExpiry("", month, year)
        self.cvv = cvv
        self.default_card = default_card
    }
    
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decode(String.self, forKey: .id)
//            print(id)
            card_holder_name = try values.decode(String.self, forKey: .card_holder_name)
            masked_card_number = try values.decode(String.self, forKey: .masked_card_number)
            card_expiry = try values.decode(CardExpiry.self, forKey: .card_expiry)
            cvv = try values.decodeIfPresent(Int.self, forKey: .cvv)
            default_card = try values.decode(Bool.self, forKey: .default_card)

        } catch {
            print(error)
            throw error
        }
    }

}

struct CardExpiry: Codable {
    let id: String
    let month: Int
    let year: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case month
        case year
    }
    
    init(_ id:String? = "" ,_ month:Int,_ year:Int){
        self.id = id ?? ""
        self.month = month
        self.year = year
    }
    
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decode(String.self, forKey: .id)
//            print(id)
            month = try values.decode(Int.self, forKey: .month)
            year = try values.decode(Int.self, forKey: .year)
        } catch {
            print(error)
            throw error
        }
    }
    
}

struct CardResponse:Codable {
    let id: String
    let message: String
}
