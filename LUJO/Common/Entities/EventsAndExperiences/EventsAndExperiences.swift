import Crashlytics
import Foundation

struct Taxonomy: Codable {
    let termId: Int
    let name: String

    enum CodingKeys: String, CodingKey {
        case termId = "term_id"
        case name
    }
}

struct TaxonomyLocation: Codable {
    let city: Taxonomy?
    let country: Taxonomy
}

struct Gallery: Codable {
    let type: String
    let mediaUrl: String
    let thumbnail: String?

    enum CodingKeys: String, CodingKey {
        case type
        case mediaUrl = "url"
        case thumbnail
    }
}

struct City: Codable {
    let cityName: String
    let placeId: String
    
    enum CodingKeys: String, CodingKey {
        case cityName = "city_name"
        case placeId = "place_id"
    }
    
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            
            cityName = try values.decode(String.self, forKey: .cityName)
            placeId = try values.decode(String.self, forKey: .placeId)
            
        } catch {
            Crashlytics.sharedInstance().recordError(error)
            throw error
        }
    }
}

struct CityInfo: Codable {
    let restaurant: RestaurantCity
    let event: EventExperienceCity
    let experience: EventExperienceCity
}

struct RestaurantCity: Codable {
    let num: Int
    let items: [Restaurant]
}

struct EventExperienceCity: Codable {
    let num: Int
    let items: [Product]
}

//it could be an event, experience, gift, villa or yacht
struct Product: Codable {
    let type: String
    let id: Int
    let name: String
    let description: String
    let price: Double?
    let link: String?
    let isFeatured: Bool?
    let startDate: Date?
    let endDate: Date?
    let timezone: String?
    let primaryMedia: Gallery?
    let gallery: [Gallery]?
    let eventCategory: [Taxonomy]?
    let experienceCategory: [Taxonomy]?
    let tags: [Taxonomy]?
    let eventVenue: [Taxonomy]?
    let priceRange: [Taxonomy]?
    let location: [TaxonomyLocation]?
    var isFavourite: Bool?
    //Gifts related
    let giftCategory: [Taxonomy]?
    //Villas related
    let headline: String?
    let numberOfBedrooms: String?
    let numberOfBathrooms: String?
    let numberOfGuests: String?
    let rentPricePerWeekLowSeason: String?
    let rentPricePerWeekHighSeason: String?
    let salePrice: String?
    let latitude: String?
    let longtitude: String?
    let villaAmenities: [Taxonomy]?
    let villaFacilities: [Taxonomy]?
    let villaStyle: [Taxonomy]?
    let villaStatus: [Taxonomy]?
    
    
    enum CodingKeys: String, CodingKey {
        case type
        case id
        case name
        case description
        case price
        case link
        case isFeatured = "is_featured"
        case startDate = "start_date"
        case endDate = "end_date"
        case timezone
        case primaryMedia = "featured_media"
        case gallery
        case eventCategory = "event_category"
        case experienceCategory = "experience_category"
        case tags = "lujo_tag"
        case eventVenue = "event_venue"
        case priceRange = "price_range"
        case location
        case isFavourite = "is_favorite"
        //Gifts related
        case giftCategory = "gift_category"
        //Villas related
        case headline
        case numberOfBedrooms = "number_of_bedrooms"
        case numberOfBathrooms = "number_of_bathrooms"
        case numberOfGuests = "number_of_guests"
        case rentPricePerWeekLowSeason = "rent_price_per_week_low_season"
        case rentPricePerWeekHighSeason = "rent_price_per_week_high_season"
        case salePrice = "sale_price"
        case latitude
        case longtitude
        case villaAmenities = "villa_amenities"
        case villaFacilities = "villa_facilities"
        case villaStyle = "villa_style"
        case villaStatus = "villa_status"
    }

    func getGalleryImagesURL() -> [String] {
        return gallery?.filter({ $0.type == "image" }).map({ $0.mediaUrl }) ?? []
    }
}

extension Product {
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)

            type = try values.decode(String.self, forKey: .type)
            id = try values.decode(Int.self, forKey: .id)
            name = try values.decode(String.self, forKey: .name)
            description = try values.decode(String.self, forKey: .description)
            let priceStr = try values.decodeIfPresent(String.self, forKey: .price)
            price = Double(priceStr ?? "0") ?? 0.0
            link = try values.decodeIfPresent(String.self, forKey: .link)
            isFeatured = try values.decodeIfPresent(Bool.self, forKey: .isFeatured)

            do {
                if let intStartDate = try values.decodeIfPresent(Int.self, forKey: .startDate) {
                    if intStartDate >= 0 {
                        startDate = Date(timeIntervalSince1970: TimeInterval(intStartDate))
                    } else {
                        startDate = nil
                    }
                } else {
                    startDate = nil
                }
            } catch {
                startDate = nil
            }

            do {
                if let intEndDate = try values.decodeIfPresent(Int.self, forKey: .endDate) {
                    if intEndDate >= 0 {
                        endDate = Date(timeIntervalSince1970: TimeInterval(intEndDate))
                    } else {
                        endDate = nil
                    }
                } else {
                    endDate = nil
                }
            } catch {
                endDate = nil
            }
            
            timezone = try values.decodeIfPresent(String.self, forKey: .timezone)
            primaryMedia = try values.decodeIfPresent(Gallery.self, forKey: .primaryMedia)
            gallery = try values.decodeIfPresent([Gallery].self, forKey: .gallery)
            eventCategory = try values.decodeIfPresent([Taxonomy].self, forKey: .eventCategory)
            experienceCategory = try values.decodeIfPresent([Taxonomy].self, forKey: .experienceCategory)
            giftCategory = try values.decodeIfPresent([Taxonomy].self, forKey: .giftCategory)
            tags = try values.decodeIfPresent([Taxonomy].self, forKey: .tags)
            eventVenue = try values.decodeIfPresent([Taxonomy].self, forKey: .eventVenue)
            priceRange = try values.decodeIfPresent([Taxonomy].self, forKey: .priceRange)
            location = try values.decodeIfPresent([TaxonomyLocation].self, forKey: .location)
            isFavourite = try values.decodeIfPresent(Bool.self, forKey: .isFavourite)
            //Villas related
            headline = try values.decodeIfPresent(String.self, forKey: .headline)
            numberOfBedrooms = try values.decodeIfPresent(String.self, forKey: .numberOfBedrooms)
            numberOfBathrooms = try values.decodeIfPresent(String.self, forKey: .numberOfBathrooms)
            numberOfGuests = try values.decodeIfPresent(String.self, forKey: .numberOfGuests)
            rentPricePerWeekLowSeason = try values.decodeIfPresent(String.self, forKey: .rentPricePerWeekLowSeason)
            rentPricePerWeekHighSeason = try values.decodeIfPresent(String.self, forKey: .rentPricePerWeekHighSeason)
            salePrice = try values.decodeIfPresent(String.self, forKey: .salePrice)
            latitude = try values.decodeIfPresent(String.self, forKey: .latitude)
            longtitude = try values.decodeIfPresent(String.self, forKey: .longtitude)
            villaAmenities = try values.decodeIfPresent([Taxonomy].self, forKey: .villaAmenities)
            villaFacilities = try values.decodeIfPresent([Taxonomy].self, forKey: .villaFacilities)
            villaStyle = try values.decodeIfPresent([Taxonomy].self, forKey: .villaStyle)
            villaStatus = try values.decodeIfPresent([Taxonomy].self, forKey: .villaStatus)
            
        } catch {
            Crashlytics.sharedInstance().recordError(error)
            throw error
        }
    }
}

struct HomeObjects: Codable {
    let slider: [Product]
    var events: [Product]
    let experiences: [Product]
    var specialEvents: [Product]

    enum CodingKeys: String, CodingKey {
        case slider
        case events
        case experiences
        case specialEvents = "special-events"
    }

    func getFeaturedImages() -> [String] {
        var urlList = [String]()
        for feature in slider {
            if feature.primaryMedia?.type == "image" {
                urlList.append(feature.primaryMedia?.mediaUrl ?? "")
            } else {
                urlList.append("")
            }
        }

        return urlList
    }

    func getFeaturedTypes() -> [String] {
        var list = [String]()
        for feature in slider {
            list.append(feature.type.capitalizingFirstLetter())
        }

        return list
    }

    func getFeaturedNames() -> [String] {
        var list = [String]()
        for feature in slider {
            list.append(feature.name)
        }

        return list
    }

    func getFeaturedTags() -> [String] {
        var list = [String]()
        for feature in slider {
            if feature.tags?.count ?? 0 > 0, let tagText = feature.tags?[0].name {
                list.append(tagText)
            } else {
                list.append("")
            }
        }

        return list
    }
}
