//
//  Filter.swift
//  LUJO
//
//  Created by iMac on 22/10/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import FirebaseCrashlytics

//struct Filters: Codable{
//    var yachtTag : [Taxonomy]?
//    var yachtType : [Taxonomy]?
//    var yachtLengthInMeter : [Taxonomy]?
//    var yachtLengthInFeet : [Taxonomy]?
//    var yachtCharterType : [Taxonomy]?
//    var yachtStatus : [Taxonomy]?
//    var quickFilters : [Taxonomy]?
//
//    enum CodingKeys: String,CodingKey{
//        case yachtTag = "lujo_tag"
//        case yachtType = "yacht_type"
//        case yachtLengthInMeter = "length_meter"
//        case yachtLengthInFeet = "length_feet"
//        case yachtCharterType = "charter_type"
//        case yachtStatus = "yacht_status"
//        case quickFilters = "quick_filters"
//    }
//
//    init(from decoder: Decoder) throws {
//        do {
//            let values = try decoder.container(keyedBy: CodingKeys.self)
//            yachtTag = try values.decodeIfPresent([Taxonomy].self, forKey: .yachtTag)
//            yachtType = try values.decodeIfPresent([Taxonomy].self, forKey: .yachtType)
//            yachtLengthInMeter = try values.decodeIfPresent([Taxonomy].self, forKey: .yachtLengthInMeter)
//            yachtLengthInFeet = try values.decodeIfPresent([Taxonomy].self, forKey: .yachtLengthInFeet)
//            yachtCharterType = try values.decodeIfPresent([Taxonomy].self, forKey: .yachtCharterType)
//            yachtStatus = try values.decodeIfPresent([Taxonomy].self, forKey: .yachtStatus)
//            quickFilters = try values.decodeIfPresent([Taxonomy].self, forKey: .quickFilters)
//        } catch {
//            Crashlytics.crashlytics().record(error: error)
//            throw error
//        }
//    }
//}

struct Filters:Codable{
    let name: String?
    let key: String?
    let options: [filterOption]?
}

struct filterOption:Codable{
    let name: String?
    let key: String?
    let value: String?
    var isSelected: Bool?   //ony used in filters
}

struct ApplyFilters{
    var eventExperienceFilters:EventExperienceFilters
}

struct EventExperienceFilters{
    var featuredCities:[String]
    var productName: String
    var selectedCountry: String?
    var categoryIds: [String]
    var price: ProductPrice?
    var tagIds: [String]
    
    init(featuredCities: [String], productName:String, selectedCountry:String?, categoryIds: [String], price:ProductPrice?, tagIds: [String]) {
        self.featuredCities = featuredCities
        self.productName = productName
        self.selectedCountry = selectedCountry
        self.categoryIds = categoryIds
        self.price = price
        self.tagIds = tagIds
    }
}

struct ProductPrice{
    var currencyCode:String
    var minPrice:String
    var maxMax:String
    
    init(currencyCode: String, minPrice: String, maxMax: String) {
        self.currencyCode = currencyCode
        self.minPrice = minPrice
        self.maxMax = maxMax
    }
}
