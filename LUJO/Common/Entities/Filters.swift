//
//  Filter.swift
//  LUJO
//
//  Created by iMac on 22/10/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import Crashlytics

struct Filters: Codable{
    var yachtTag : [Taxonomy]?
    var yachtType : [Taxonomy]?
    var yachtLengthInMeter : [Taxonomy]?
    var yachtLengthInFeet : [Taxonomy]?
    var yachtCharterType : [Taxonomy]?
    var yachtStatus : [Taxonomy]?
    
    enum CodingKeys: String,CodingKey{
        case yachtTag = "lujo_tag"
        case yachtType = "yacht_type"
        case yachtLengthInMeter = "length_meter"
        case yachtLengthInFeet = "length_feet"
        case yachtCharterType = "charter_type"
        case yachtStatus = "yacht_status"
    }
    
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            yachtTag = try values.decodeIfPresent([Taxonomy].self, forKey: .yachtTag)
            yachtType = try values.decodeIfPresent([Taxonomy].self, forKey: .yachtType)
            yachtLengthInMeter = try values.decodeIfPresent([Taxonomy].self, forKey: .yachtLengthInMeter)
            yachtLengthInFeet = try values.decodeIfPresent([Taxonomy].self, forKey: .yachtLengthInFeet)
            yachtCharterType = try values.decodeIfPresent([Taxonomy].self, forKey: .yachtCharterType)
            yachtStatus = try values.decodeIfPresent([Taxonomy].self, forKey: .yachtStatus)
            
        } catch {
            Crashlytics.sharedInstance().recordError(error)
            throw error
        }
    }
}


