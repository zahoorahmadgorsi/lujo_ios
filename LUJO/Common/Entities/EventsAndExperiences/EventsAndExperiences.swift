import FirebaseCrashlytics
import Foundation

enum SalesforceRequestType:String{
    case CUSTOM = "custom"
    case GENERAL = "general"

}

struct SalesforceRequest {
    var productId: String
    var productType: String
    var productName: String
    var sfRequestType: SalesforceRequestType
    //dining
    var dingingRequestDate: String?
    var dingingRequestTime: String?
    var dingingRequestPersons: Int?
    //yacht
    var yacht_charter: String?
    var yacht_region: Int?
    var yacht_destination: String?
    var yacht_date_from: String?
    var yacht_date_to: String?
    var yacht_guests: Int?
    // villa
    var villa_check_in: String?
    var villa_check_out: String?
    var villa_guests: Int?
    //hotel
    var hotel_name: String?
    var hotel_neighborhood: String?
    var hotel_radius: Int?
    var hotel_check_in_date: String?
    var hotel_check_out_date: String?
    var hotel_guests: Int?
    var hotel_rooms: Int?
    var hotel_stars: Int?
    
    //event, experience and gift
    init(id:String, type:String, name:String = "", sfRequestType: SalesforceRequestType = .GENERAL){
        self.productId = id
        self.productType = type
        self.productName =  name
        self.sfRequestType = sfRequestType
    }
    
    //dining
    init(id:String, type:String, name:String = "", sfRequestType: SalesforceRequestType = .GENERAL, date:String? = nil , time:String? = nil , persons:Int? = nil){
        self.productId = id
        self.productType = type
        self.productName =  name
        self.sfRequestType = sfRequestType
        //below params are only going to use for dining request
        self.dingingRequestDate = date
        self.dingingRequestTime = time
        self.dingingRequestPersons =  persons
    }
    
    //yacht
    init(id:String, type:String, name:String = "", sfRequestType: SalesforceRequestType = .GENERAL, yacht_charter:String? = nil , yacht_destination:String? = nil, yacht_region:Int? = nil , yacht_date_from:String? = nil, yacht_date_to:String? = nil, yacht_guests:Int? = nil){
        self.productId = id
        self.productType = type
        self.productName =  name
        self.sfRequestType = sfRequestType
        //below params are only going to use for dining request
        self.yacht_charter = yacht_charter
        self.yacht_destination = yacht_destination
        self.yacht_region = yacht_region
        self.yacht_date_from =  yacht_date_from
        self.yacht_date_to = yacht_date_to
        self.yacht_guests = yacht_guests
    }
    
    //villa
    init(id:String, type:String, name:String = "", sfRequestType: SalesforceRequestType = .GENERAL, villa_check_in:String? = nil , villa_check_out:String? = nil , villa_guests:Int? = nil){
        self.productId = id
        self.productType = type
        self.productName =  name
        self.sfRequestType = sfRequestType
        //below params are only going to use for dining request
        self.villa_check_in = villa_check_in
        self.villa_check_out = villa_check_out
        self.villa_guests =  villa_guests
    }
    
    //hotel
    init(id:String, type:String, name:String = "", hotel_name:String? = nil, sfRequestType: SalesforceRequestType = .GENERAL , hotel_neighborhood:String? = nil , hotel_radius:Int? = nil, hotel_check_in_date:String? = nil,hotel_check_out_date:String? = nil, hotel_guests:Int? = nil, hotel_rooms:Int? = nil , hotel_stars:Int? = nil){
        self.productId = id
        self.productType = type
        self.productName =  name
        self.sfRequestType = sfRequestType
        //below params are only going to use for dining request
        self.hotel_name = hotel_name
        self.hotel_neighborhood = hotel_neighborhood
        self.hotel_radius =  hotel_radius
        self.hotel_check_in_date = hotel_check_in_date
        self.hotel_check_out_date = hotel_check_out_date
        self.hotel_guests = hotel_guests
        self.hotel_rooms = hotel_rooms
        self.hotel_stars = hotel_stars
    }
}

struct ReferralValidation: Codable {
    let status: Bool
    var discountEnum: String
    var discountPercentage: Int
    
    enum CodingKeys: String, CodingKey {
        case status
        case discountEnum = "discount_enum"
        case discountPercentage = "discount_percentage"
    }
    
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            status = try values.decode(Bool.self, forKey: .status)
            discountEnum = try values.decode(String.self, forKey: .discountEnum)
            discountPercentage = try values.decode(Int.self, forKey: .discountPercentage)
        } catch {
            Crashlytics.crashlytics().record(error: error)
            throw error
        }
    }
}

struct ReferralType: Codable {
    let title: String
    var discountPercentageEnum: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case discountPercentageEnum = "discount_percentage"
    }
    
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            title = try values.decode(String.self, forKey: .title)
            discountPercentageEnum = try values.decode(String.self, forKey: .discountPercentageEnum)
        } catch {
            Crashlytics.crashlytics().record(error: error)
            throw error
        }
    }
}

struct ReferralCode: Codable {
    let referralCode: String
    
    enum CodingKeys: String, CodingKey {
        case referralCode = "referral_code"
    }
    
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            referralCode = try values.decode(String.self, forKey: .referralCode)
        } catch {
            Crashlytics.crashlytics().record(error: error)
            throw error
        }
    }
}
struct TaxonomyYachtRegion: Codable{
    let _id: String?
    let name: String?
    let description: String?
    let id: Int?
}

struct TaxonomyDocs: Codable{
    let docs: [Taxonomy]
}

struct TaxonomyCountry: Codable{
    let _id: String
    let name: String
}

struct Taxonomy: Codable {
    let termId: String
    let name: String
    
    var stateName: String?          //used in /restaurants/preferred_location/search
    var country: TaxonomyCountry?   //used in /restaurants/preferred_location/search
    var id: Int?    //in case if this taxonomy is a region then id would contain regionid, used in region filter
    var yachtRegion: TaxonomyYachtRegion?    //used in yacht country/region search
    var code: String?       //used in case of currency (code)
    var isSelected: Bool?
    var filterParameter: String?   //used in per city filters
    
    enum CodingKeys: String, CodingKey {
        case termId = "_id"
        case name
        case isSelected
        case filterParameter = "per_city_input_param"
        case code
        case stateName
        case country
        case yachtRegion = "yacht_region"
        case id
    }
    
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            
            name = try values.decode(String.self, forKey: .name)
            termId = try values.decode(String.self, forKey: .termId)
            //isSelected would never be sent from API
            isSelected = try values.decodeIfPresent(Bool.self, forKey: .isSelected) ?? false
            filterParameter = try values.decodeIfPresent(String.self, forKey: .filterParameter)
            code = try values.decodeIfPresent(String.self, forKey: .code)
            stateName = try values.decodeIfPresent(String.self, forKey: .stateName)
            country = try values.decodeIfPresent(TaxonomyCountry.self, forKey: .country)
            yachtRegion = try values.decodeIfPresent(TaxonomyYachtRegion.self, forKey: .yachtRegion)
            id = try values.decodeIfPresent(Int.self, forKey: .id)
        } catch {
            Crashlytics.crashlytics().record(error: error)
            throw error
        }
    }
    
    //This init is going to be used in preference for hardocoded values
    init(termId:String , name: String, isSelected:Bool? = false){
        self.termId = termId
        self.name = name
        self.isSelected = isSelected
    }
    
    //constructor in case of currency
    init(id:String , name: String, code:String){
        self.termId = id
        self.name = name
        self.code = code
    }
}

struct TaxonomyLocation: Codable {
    let city: Taxonomy?
    let country: Taxonomy
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
            Crashlytics.crashlytics().record(error: error)
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
    let mediaType: String?   //used for thumbnail
    let mediaUrl: String
    let thumbnail: String?  //thumbnail in case of the video

    enum CodingKeys: String, CodingKey {
        case type
        case mediaType = "media_type"
        case mediaUrl = "url"
        case thumbnail = "thumbnail"
    }
}

struct Location: Codable {
    let id: String
    let type: String
    let coordinates: [Double]
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case type
        case coordinates
    }
}

struct CityInfo: Codable {
    let topRated: [Product]
    let featuredProducts: DiscoverCityFeatured
    let restaurant: DiscoverCity
    let event: DiscoverCity
    let experience: DiscoverCity
    let specialEvent: DiscoverCity
    let yacht: DiscoverCity
    let property: DiscoverCity
    
    enum CodingKeys: String, CodingKey {
        case topRated = "top-rated"
        case featuredProducts = "featured_products"
        case restaurant
        case event
        case experience
        case specialEvent = "special_event"
        case yacht
        case property = "villa"
    }
    
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            
            topRated = try values.decode([Product].self, forKey: .topRated)
            featuredProducts = try values.decode(DiscoverCityFeatured.self, forKey: .featuredProducts)
            restaurant = try values.decode(DiscoverCity.self, forKey: .restaurant)
            event = try values.decode(DiscoverCity.self, forKey: .event)
            experience = try values.decode(DiscoverCity.self, forKey: .experience)
            specialEvent = try values.decode(DiscoverCity.self, forKey: .specialEvent)
            yacht = try values.decode(DiscoverCity.self, forKey: .yacht)
            property = try values.decode(DiscoverCity.self, forKey: .property)
        }catch {
            print(error)
            Crashlytics.crashlytics().record(error: error)
            throw error
        }
    }
    
}
struct DiscoverCityFeatured: Codable{
    let restaurant: [Product]
    let event: [Product]
    let experience: [Product]
}

struct DiscoverCity: Codable {
    let num: Int
    let items: [Product]
}

struct DiscoverSearchResponse:Codable{
    let docs: [Product]
}
//it could be an event, experience, gift, villa or yacht
struct Product: Codable {
    var type: String
    var id: String
    var name: String
    var description: String
    var price: Price?
    var link: String?
    var isFeatured: Bool?
    var startDate: Date?
    var endDate: Date?
    var timezone: String?
    var thumbnail: Gallery?
    var gallery: [Gallery]?
    var eventCategory: Taxonomy?
    var experienceCategory: Taxonomy?
    var tags: [Taxonomy]?
    var eventVenue: [Taxonomy]?
    var priceRange: [Taxonomy]?
    var locations: TaxonomyLocation?  //city country
    var isFavourite: Bool?
    var address: String?
    var streetAddress: String?
    var locationText: String?
    //Gifts related
    var giftCategory: Taxonomy?
    var giftSubCategory : Taxonomy?
    var giftBrand : Taxonomy?
    //Villas related
    var headline: String?
    var numberOfBedrooms: Int?
    var numberOfBathrooms: Int?
    var numberOfGuests: Int?
    var rentPricePerWeekLowSeason: String?
    var rentPricePerWeekHighSeason: String?
    var priceOnRequest: Bool?
    var location: Location?     //latitude longitude
    var villaAmenities: [String]?
    //Yachts related
    var guestsNumber: String?
    var cabinNumber: String?
    var crewNumber: String?
    var builderName: String?
    var interiorDesigner: String?
    var exteriorDesigner: String?
    var buildYear: Int?
    var refitYear: String?
    var lengthM: String?
    var beamM: String?
    var draftM: String?
    var grossTonnage: String?
    var cruisingSpeedKnot: String?
    var topSpeedKnot: String?
    var charterPriceLowSeasonPerWeek: Price?
    var charterPriceHighSeasonPerWeek: Price?
    var yachtType: String?
    var yachtStatus: String?
    var yachtExtras: [Taxonomy]?
    var charterPriceLowSeasonPerDay: Price?
    var charterPriceHighSeasonPerDay: Price?
//    Restaurant related
    var tripadvisor: String?
    var website: [String]?
    var cuisineCategory: [Taxonomy]?
    
    enum CodingKeys: String, CodingKey {
        case type
        case id = "_id"
        case name
        case description
        case price //= "usd_price"
        case link
        case isFeatured = "is_featured"
        case startDate = "start_date"
        case endDate = "end_date"
        case timezone
        case thumbnail
        case gallery
        case eventCategory = "event_category"
        case experienceCategory = "experience_category"
        case tags = "lujo_tag"
        case eventVenue = "event_venue"
        case priceRange = "price_range"
        case locations
        case isFavourite = "is_favorite"
        case streetAddress = "street_address"
        case locationText = "location_text"
        case address
        //Gifts related
        case giftCategory = "gift_category"
        //Villas related
        case headline
        case numberOfBedrooms = "no_of_bedrooms"
        case numberOfBathrooms = "no_of_bathrooms"
        case numberOfGuests = "no_of_guests"
        case rentPricePerWeekLowSeason = "rent_price_per_week_low_season"
        case rentPricePerWeekHighSeason = "rent_price_per_week_high_season"
        case priceOnRequest = "price_on_request"
        case location
        case villaAmenities = "amenities"
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
        case website
        case cuisineCategory = "cuisine_category"
        //gift
        case giftSubCategory = "gift_sub_category"
        case giftBrand = "gift_brand"
    }

    func getGalleryImagesURL() -> [String] {
        return gallery?.filter({ $0.type == "image" }).map({ $0.mediaUrl }) ?? []
    }
    
    func getCompleteAddress() -> String{
        var completeAddress = streetAddress ?? ""
        if type == "gift"{  //gift don't have address
            return ""
        }else if type == "villa" || type == "yacht"{    //villa and yacht dont have street address
            completeAddress += getCityCountry()
        }else {
            //if let add = address, add.count > 0{
            if let add = locationText, add.count > 0{
                completeAddress = completeAddress.count > 0 ? "\(completeAddress) - \(add)" : "\(add)"
            }
        }
        print("locationText: \(completeAddress)")
        return completeAddress
    }
    
    func getCityCountry() ->String{
        var locationText = ""
        if let cityName = locations?.city?.name {
            locationText = "\(cityName), "
        }
        locationText += locations?.country.name ?? ""
        return locationText
    }
}



extension Product {
    
    init(id:String, type:String, name:String = ""){
        self.id = id
        self.type = type
        self.name =  name
        self.description =  ""
    }
    
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)

            id = try values.decode(String.self, forKey: .id)
            print("productid: \(id)")   // 627b518f4ae3b8001d834048, 627a0018d340c1001b0a717e
            if id == "63526fbaf199da001bc4fd11"{
                print("crashing")
            }
            type = try values.decode(String.self, forKey: .type)
            name = try values.decode(String.self, forKey: .name)
            description = try values.decode(String.self, forKey: .description)
            price = try values.decodeIfPresent(Price.self, forKey: .price)
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
            thumbnail = try values.decodeIfPresent(Gallery.self, forKey: .thumbnail)
            gallery = try values.decodeIfPresent([Gallery].self, forKey: .gallery)
            address = try values.decodeIfPresent(String.self, forKey: .address)
            streetAddress = try values.decodeIfPresent(String.self, forKey: .streetAddress)
            locationText = try values.decodeIfPresent(String.self, forKey: .locationText)
//            print("locationText: \(locationText)")
            eventCategory = try values.decodeIfPresent(Taxonomy.self, forKey: .eventCategory)
            experienceCategory = try values.decodeIfPresent(Taxonomy.self, forKey: .experienceCategory)
            giftCategory = try values.decodeIfPresent(Taxonomy.self, forKey: .giftCategory)
            giftSubCategory = try values.decodeIfPresent(Taxonomy.self, forKey: .giftSubCategory)
            giftBrand = try values.decodeIfPresent(Taxonomy.self, forKey: .giftBrand)
            tags = try values.decodeIfPresent([Taxonomy].self, forKey: .tags)
            eventVenue = try values.decodeIfPresent([Taxonomy].self, forKey: .eventVenue)
            priceRange = try values.decodeIfPresent([Taxonomy].self, forKey: .priceRange)
            locations = try values.decodeIfPresent(TaxonomyLocation.self, forKey: .locations)
            isFavourite = try values.decodeIfPresent(Bool.self, forKey: .isFavourite)
            //Villas related
            headline = try values.decodeIfPresent(String.self, forKey: .headline)
            numberOfBedrooms = try values.decodeIfPresent(Int.self, forKey: .numberOfBedrooms)
            numberOfBathrooms = try values.decodeIfPresent(Int.self, forKey: .numberOfBathrooms)
            numberOfGuests = try values.decodeIfPresent(Int.self, forKey: .numberOfGuests)
            rentPricePerWeekLowSeason = try values.decodeIfPresent(String.self, forKey: .rentPricePerWeekLowSeason)
            rentPricePerWeekHighSeason = try values.decodeIfPresent(String.self, forKey: .rentPricePerWeekHighSeason)
            priceOnRequest = try values.decodeIfPresent(Bool.self, forKey: .priceOnRequest)
            location = try values.decodeIfPresent(Location.self, forKey: .location)
            villaAmenities = try values.decodeIfPresent([String].self, forKey: .villaAmenities)
            //Yachts related
            guestsNumber = try values.decodeIfPresent(String.self, forKey: .guestsNumber)
            cabinNumber = try values.decodeIfPresent(String.self, forKey: .cabinNumber)
            crewNumber = try values.decodeIfPresent(String.self, forKey: .crewNumber)
            builderName = try values.decodeIfPresent(String.self, forKey: .builderName)
            interiorDesigner = try values.decodeIfPresent(String.self, forKey: .interiorDesigner)
            exteriorDesigner = try values.decodeIfPresent(String.self, forKey: .exteriorDesigner)
            buildYear = try values.decodeIfPresent(Int.self, forKey: .buildYear)
            refitYear = try values.decodeIfPresent(String.self, forKey: .refitYear)
            lengthM = try values.decodeIfPresent(String.self, forKey: .lengthM)
            beamM = try values.decodeIfPresent(String.self, forKey: .beamM)
            draftM = try values.decodeIfPresent(String.self, forKey: .draftM)
            grossTonnage = try values.decodeIfPresent(String.self, forKey: .grossTonnage)
            cruisingSpeedKnot = try values.decodeIfPresent(String.self, forKey: .cruisingSpeedKnot)
            topSpeedKnot = try values.decodeIfPresent(String.self, forKey: .topSpeedKnot)
            charterPriceLowSeasonPerWeek = try values.decodeIfPresent(Price.self, forKey: .charterPriceLowSeasonPerWeek)
            charterPriceHighSeasonPerWeek = try values.decodeIfPresent(Price.self, forKey: .charterPriceHighSeasonPerWeek)
            yachtType = try values.decodeIfPresent(String.self, forKey: .yachtType)
            yachtStatus = try values.decodeIfPresent(String.self, forKey: .yachtStatus)
            yachtExtras = try values.decodeIfPresent([Taxonomy].self, forKey: .yachtExtras)
            charterPriceLowSeasonPerDay = try values.decodeIfPresent(Price.self, forKey: .charterPriceLowSeasonPerDay)
            charterPriceHighSeasonPerDay = try values.decodeIfPresent(Price.self, forKey: .charterPriceHighSeasonPerDay)
            //    Restaurant related
            tripadvisor = try values.decodeIfPresent(String.self, forKey: .tripadvisor)
            website = try values.decodeIfPresent([String].self, forKey: .website)
            cuisineCategory = try values.decodeIfPresent([Taxonomy].self, forKey: .cuisineCategory)
        }catch {
            print(error)
            Crashlytics.crashlytics().record(error: error)
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
            if feature.thumbnail?.mediaType == "image" {
                urlList.append(feature.thumbnail?.mediaUrl ?? "")
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
    
    var termId: String?
    var name: String?
    var itemsNum : Int?
    var items:[Product]?
    var latitude: Double?
    var longitude: Double?
    
    enum CodingKeys: String,CodingKey{
        case termId = "_id"
        case name
        case itemsNum = "items_num"
        case items
        case latitude
        case longitude
    }
    
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            
            termId = try values.decodeIfPresent(String.self, forKey: .termId)
            name = try values.decodeIfPresent(String.self, forKey: .name)
            itemsNum = try values.decodeIfPresent(Int.self, forKey: .itemsNum)
            items = try values.decodeIfPresent([Product].self, forKey: .items)
            latitude = try values.decodeIfPresent(Double.self, forKey: .latitude)
            longitude = try values.decodeIfPresent(Double.self, forKey: .longitude)
            
        } catch {
            Crashlytics.crashlytics().record(error: error)
            throw error
        }
    }
    
    internal init(termId: String? = nil, name: String? = nil, itemsNum: Int? = nil, items: [Product]? = nil, latitude: Double? = nil, longitude: Double? = nil) {
        self.termId = termId
        self.name = name
        self.itemsNum = itemsNum
        self.items = items
        self.latitude = latitude
        self.longitude = longitude
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
