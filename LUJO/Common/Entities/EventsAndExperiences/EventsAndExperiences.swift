import Crashlytics
import Foundation

struct Taxonomy: Codable {
    let termId: Int
    let name: String

    enum CodingKeys: String, CodingKey {
        case termId = "term_id"
        case name
    }
    
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            
            name = try values.decode(String.self, forKey: .name)
            termId = try values.decode(Int.self, forKey: .termId)
        } catch {
            Crashlytics.sharedInstance().recordError(error)
            throw error
        }
    }
    
    //This init is going to be used in preference for hardocoded values
    init(termId:Int , name: String){
        self.termId = termId
        self.name = name
    }
}

struct TaxonomyLocation: Codable {
    let city: Taxonomy?
    let country: Taxonomy
}

struct TaxonomyBaroqueAviation: Codable {
    let message: String
    let title: String
    let state: String
    let data: [BaroqueAviationCategory]

    enum CodingKeys: String, CodingKey {
        case message
        case title
        case state
        case data
    }
    
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            
            message = try values.decode(String.self, forKey: .message)
            title = try values.decode(String.self, forKey: .title)
            state = try values.decode(String.self, forKey: .state)
            data = try values.decode([BaroqueAviationCategory].self, forKey: .data)
        } catch {
            Crashlytics.sharedInstance().recordError(error)
            throw error
        }
    }
}

struct BaroqueAviationCategory: Codable {
    let id: Int
    var name: String


    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
    
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decode(Int.self, forKey: .id)
            name = try values.decode(String.self, forKey: .name)

        } catch {
            Crashlytics.sharedInstance().recordError(error)
            throw error
        }
    }
    
    //This init is going to be used in preference for hardocoded values
    init(id:Int , name: String){
        self.id = id
        self.name = name
    }
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
    let items: [Product]
}

struct EventExperienceCity: Codable {
    let num: Int
    let items: [Product]
}

//enum QuantumValue: Decodable {
//
//    case int(Int), string(String)
//
//    init(from decoder: Decoder) throws {
//        if let int = try? decoder.singleValueContainer().decode(Int.self) {
//            self = .int(int)
//            return
//        }
//
//        if let string = try? decoder.singleValueContainer().decode(String.self) {
//            self = .string(string)
//            return
//        }
//
//        throw QuantumError.missingValue
//    }
//
//    enum QuantumError:Error {
//        case missingValue
//    }
//}

//it could be an event, experience, gift, villa or yacht
struct Product: Codable {
//struct Product: Decodable {
    var type: String
    var id: Int
    var name: String
    var description: String
    var price: Double?
    var link: String?
    var isFeatured: Bool?
    var startDate: Date?
    var endDate: Date?
    var timezone: String?
    var primaryMedia: Gallery?
    var gallery: [Gallery]?
    var eventCategory: [Taxonomy]?
    var experienceCategory: [Taxonomy]?
    var tags: [Taxonomy]?
    var eventVenue: [Taxonomy]?
    var priceRange: [Taxonomy]?
    var location: [TaxonomyLocation]?
    var isFavourite: Bool?
    //Gifts related
    var giftCategory: [Taxonomy]?
    //Villas related
    var headline: String?
    var numberOfBedrooms: String?
    var numberOfBathrooms: String?
    var numberOfGuests: String?
    var rentPricePerWeekLowSeason: String?
    var rentPricePerWeekHighSeason: String?
    var salePrice: String?
    var latitude: String?
    var longitude: String?
    var villaAmenities: [Taxonomy]?
    var villaFacilities: [Taxonomy]?
    var villaStyle: [Taxonomy]?
    var villaStatus: [Taxonomy]?
    //Yachts related
    var guestsNumber: String?
    var cabinNumber: String?
    var crewNumber: String?
    var builderName: String?
    var interiorDesigner: String?
    var exteriorDesigner: String?
    var buildYear: String?
    var refitYear: String?
    var lengthM: String?
    var beamM: String?
    var draftM: String?
    var grossTonnage: String?
    var cruisingSpeedKnot: String?
    var topSpeedKnot: String?
    var charterPriceLowSeasonPerWeek: String?
    var charterPriceHighSeasonPerWeek: String?
    var yachtType: [Taxonomy]?
    var yachtStatus: [Taxonomy]?
    var yachtExtras: [Taxonomy]?
    var charterPriceLowSeasonPerDay: String?
    var charterPriceHighSeasonPerDay: String?
//    Restaurant related
    var tripadvisor: String?
    var address: String?
    var phone: String?
    var zipCode: String?
    var email: String?
    var website: String?
    var starChief: String?
    var restaurantCategory: [Taxonomy]?
    var cuisineCategory: [Taxonomy]?
    var michelinStar: [Taxonomy]?
    
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
        case longitude = "longtitude"
        case villaAmenities = "villa_amenities"
        case villaFacilities = "villa_facilities"
        case villaStyle = "villa_style"
        case villaStatus = "villa_status"
        //Yachts related
        case guestsNumber = "guests_number"
        case cabinNumber = "cabin_number"
        case crewNumber = "crew_number"
        case builderName = "builder_name"
        case interiorDesigner = "interior_designer"
        case exteriorDesigner = "exterior_designer"
        case buildYear = "build_year"
        case refitYear = "refit_year"
        case lengthM = "length_m"
        case beamM = "beam_m"
        case draftM = "draft_m"
        case grossTonnage = "gross_tonnage"
        case cruisingSpeedKnot = "cruising_speed_knot"
        case topSpeedKnot = "top_speed_knot"
        case charterPriceLowSeasonPerWeek = "charter_price_low_season_per_week"
        case charterPriceHighSeasonPerWeek = "charter_price_high_season_per_week"
        case yachtType = "yacht_type"
        case yachtStatus = "yacht_status"
        case yachtExtras = "yacht_extras"
        case charterPriceLowSeasonPerDay = "charter_price_low_season_per_day"
        case charterPriceHighSeasonPerDay = "charter_price_high_season_per_day"
        //    Restaurant related
        case tripadvisor
        case address
        case phone
        case zipCode = "zip"
        case email
        case website
        case starChief = "star-chef"
        case restaurantCategory = "restaurant_category"
        case cuisineCategory = "cuisine_category"
        case michelinStar = "michelin_star"
    }

    func getGalleryImagesURL() -> [String] {
        return gallery?.filter({ $0.type == "image" }).map({ $0.mediaUrl }) ?? []
    }
}



extension Product {
    
    init(id:Int, type:String, name:String = ""){
        self.id = id
        self.type = type
        self.name =  name
        self.description =  ""
    }
    
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
            // First check for a string
            do {
                latitude = try values.decodeIfPresent(String.self, forKey: .latitude)
            } catch {
                // then second time assuming that its going to be a double
                let lati:Double = try values.decodeIfPresent(Double.self, forKey: .latitude) ?? 0.0
                latitude = String(format: "%f", lati)
                print("id:\(id)","latitude:\(lati)"  )
            }
            do {
                longitude = try values.decodeIfPresent(String.self, forKey: .longitude)
            } catch {
                let longi:Double = try values.decodeIfPresent(Double.self, forKey: .longitude) ?? 0.0
                longitude = String(format: "%f", longi)
                print("id:\(id)", "longitude:\(longi)"  )
            }
            
            villaAmenities = try values.decodeIfPresent([Taxonomy].self, forKey: .villaAmenities)
            villaFacilities = try values.decodeIfPresent([Taxonomy].self, forKey: .villaFacilities)
            villaStyle = try values.decodeIfPresent([Taxonomy].self, forKey: .villaStyle)
            villaStatus = try values.decodeIfPresent([Taxonomy].self, forKey: .villaStatus)
            //Yachts related
            guestsNumber = try values.decodeIfPresent(String.self, forKey: .guestsNumber)
            cabinNumber = try values.decodeIfPresent(String.self, forKey: .cabinNumber)
            crewNumber = try values.decodeIfPresent(String.self, forKey: .crewNumber)
            builderName = try values.decodeIfPresent(String.self, forKey: .builderName)
            interiorDesigner = try values.decodeIfPresent(String.self, forKey: .interiorDesigner)
            exteriorDesigner = try values.decodeIfPresent(String.self, forKey: .exteriorDesigner)
            buildYear = try values.decodeIfPresent(String.self, forKey: .buildYear)
            refitYear = try values.decodeIfPresent(String.self, forKey: .refitYear)
            lengthM = try values.decodeIfPresent(String.self, forKey: .lengthM)
            beamM = try values.decodeIfPresent(String.self, forKey: .beamM)
            draftM = try values.decodeIfPresent(String.self, forKey: .draftM)
            grossTonnage = try values.decodeIfPresent(String.self, forKey: .grossTonnage)
            cruisingSpeedKnot = try values.decodeIfPresent(String.self, forKey: .cruisingSpeedKnot)
            topSpeedKnot = try values.decodeIfPresent(String.self, forKey: .topSpeedKnot)
            charterPriceLowSeasonPerWeek = try values.decodeIfPresent(String.self, forKey: .charterPriceLowSeasonPerWeek)
            charterPriceHighSeasonPerWeek = try values.decodeIfPresent(String.self, forKey: .charterPriceHighSeasonPerWeek)
            yachtType = try values.decodeIfPresent([Taxonomy].self, forKey: .yachtType)
            yachtStatus = try values.decodeIfPresent([Taxonomy].self, forKey: .yachtStatus)
            yachtExtras = try values.decodeIfPresent([Taxonomy].self, forKey: .yachtExtras)
            charterPriceLowSeasonPerDay = try values.decodeIfPresent(String.self, forKey: .charterPriceLowSeasonPerDay)
            charterPriceHighSeasonPerDay = try values.decodeIfPresent(String.self, forKey: .charterPriceHighSeasonPerDay)
            //    Restaurant related
            tripadvisor = try values.decodeIfPresent(String.self, forKey: .tripadvisor)
            address = try values.decodeIfPresent(String.self, forKey: .address)
            phone = try values.decodeIfPresent(String.self, forKey: .phone)
            zipCode = try values.decodeIfPresent(String.self, forKey: .zipCode)
            email = try values.decodeIfPresent(String.self, forKey: .email)
            website = try values.decodeIfPresent(String.self, forKey: .website)
            starChief = try values.decodeIfPresent(String.self, forKey: .starChief)
            restaurantCategory = try values.decodeIfPresent([Taxonomy].self, forKey: .restaurantCategory)
            cuisineCategory = try values.decodeIfPresent([Taxonomy].self, forKey: .cuisineCategory)
            michelinStar = try values.decodeIfPresent([Taxonomy].self, forKey: .michelinStar)
        } catch {
            Crashlytics.sharedInstance().recordError(error)
            throw error
        }
    }
}

struct HomeObjects: Codable {
    let slider: [Product]
    var events: [Product]
    var experiences: [Product]
    var specialEvents: [Product]
    var recent: [Product]
    var topRated: [Product]
    var gifts: [Product]
    var villas: [Product]
    var yachts: [Product]
    
    enum CodingKeys: String, CodingKey {
        case slider
        case events
        case experiences
        case specialEvents = "special-events"
        case recent
        case topRated = "top-rated"
        case gifts
        case villas
        case yachts
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

// it is used in /per-city
struct Cities: Codable{
    var name: String?
    var termId: Int?
    var itemsNum : Int?
    var items:[Product]?
    
    enum CodingKeys: String,CodingKey{
        case name
        case termId = "term_id"
        case itemsNum = "items_num"
        case items
    }
    
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            
            name = try values.decodeIfPresent(String.self, forKey: .name)
            termId = try values.decodeIfPresent(Int.self, forKey: .termId)
            itemsNum = try values.decodeIfPresent(Int.self, forKey: .itemsNum)
            items = try values.decodeIfPresent([Product].self, forKey: .items)
            
        } catch {
            Crashlytics.sharedInstance().recordError(error)
            throw error
        }
    }
}

struct PerCityObjects: Codable {
    var topRated: [Product]
    var cities:[Cities]?
    var categories:[Cities]?
    
    enum CodingKeys: String, CodingKey {
        case topRated = "top-rated"
        case cities
        case categories
    }

    
}

struct CustomBookingResponse: Codable {
    let salesforceId: String
    let message: String

    enum CodingKeys: String, CodingKey {
        case salesforceId = "salesforce_id"
        case message
    }
}
