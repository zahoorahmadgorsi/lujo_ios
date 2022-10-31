// swiftlint:disable identifier_name
import UIKit

enum UserTitle: String, Codable, CaseIterable {
    case mr = "Mr."
    case mrs = "Mrs."
    case miss = "Miss"
    case ms = "Ms."
}

enum UserStatus {
    case noUser
    case unverified
    case verified
    case approved
    case other
}

struct PhoneNumber: Equatable, Codable {
    let countryCode: String
    let number: String

    var isEmpty: Bool {
        return number.isEmpty
    }

    var readableNumber: String {
//        return "+\(countryCode) \(number)"
        return "\(countryCode)\(number)"
    }
}

struct LoginUser: Equatable, Codable {
    var prefix: String
    var phone: String
    var token: String?
    var tokenExpiration: TimeInterval?
    var approved: Bool
}

class LujoUser: Equatable, Codable {
    //var id: Int
    var id: String
    var title: UserTitle?
    var firstName: String
    var lastName: String
    var email: String
    var phoneNumber: PhoneNumber
    var password: String
    var avatar: String
    var token: String
//    var approved: String
    var approved: Bool
    var referralCode: [String]
    var points: Int
    var membershipPlan: Membership?
    var sfid: String
    var membershipPlanExpiration: Int

    enum CodingKeys: String, CodingKey {
        case id = "customer_id"
        case firstName = "firstname"
        case lastName = "lastname"
        case email
        case phoneNumber = "phone"
        case password
        case avatar
        case token
        case approved
        case referralCode = "referral_code"
        case points
        case membershipPlan = "membership_plan"
        case sfid
        case membershipPlanExpiration = "membership_plan_expiration"
    }

    func getLoginUser() -> LoginUser {
        return LoginUser(prefix: phoneNumber.countryCode,
                         phone: phoneNumber.number,
                         token: token,
                         tokenExpiration: LujoSetup().getCurrentUser()?.tokenExpiration,
                         approved: approved == true)
    }
    
    init(id: String, title: UserTitle?, firstName: String, lastName: String, email: String, phoneNumber: PhoneNumber, password: String, avatar: String, token: String, approved: Bool, referralCode: [String], points: Int, membershipPlan: Membership?, sfid:String, membershipPlanExpiration:Int) {
        self.id = id
        self.title = title
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phoneNumber = phoneNumber
        self.password = password
        self.avatar = avatar
        self.token = token
        self.approved = approved
        self.referralCode = referralCode
        self.points = points
        self.membershipPlan = membershipPlan
        self.sfid = sfid
        self.membershipPlanExpiration = membershipPlanExpiration
    }
    
    static func == (lhs: LujoUser, rhs: LujoUser) -> Bool {
        return lhs.id == rhs.id
    }
}

struct LujoUserProfile: Codable {
    let id: String
    let baroque_id: Int
    let title: String? = nil
    let firstname: String
    let lastname: String
    let email: String
    let phone_prefix: String
    let phone: String
    let avatar: String?
    let approved: Bool
    let referralCode: [String]
    let points: Int
    let membershipPlan: Membership?
    var sfid: String
    let membershipPlanExpiration: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "customer_id"
        case baroque_id
        case firstname
        case lastname
        case email
        case phone_prefix
        case phone
        case avatar
        case approved
        case referralCode = "referral_code"
        case points
        case membershipPlan = "membership_plan"
        case sfid
        case membershipPlanExpiration = "membership_plan_expiration"
    }
}

struct UserProfileResponse: Codable {
    let code: Int
    let type: String
    let content: LujoUserProfile
}

struct LujoServerResponse<T: Codable>: Codable {
    let code: Int
    let type: String
    let content: T
}

struct PhoneCountryCode: Codable {
    let id: Int
    let alpha2Code: String
    let phonePrefix: String
    let nationality: String
    let country: String
    let flag: String?

    enum CodingKeys: String, CodingKey {
        case id
        case alpha2Code
        case phonePrefix
        case nationality
        case country
        case flag = "image"
    }
}

struct CurrencyType: Codable{
    let id: String
    let name: String
    let code: String
    let symbolRight: String
    let symbolLeft: String
    let value: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case code
        case symbolRight = "symbol_right"
        case symbolLeft = "symbol_left"
        case value
    }
    
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decode(String.self, forKey: .id)
            name = try values.decode(String.self, forKey: .name)
            code = try values.decode(String.self, forKey: .code)
            symbolRight = try values.decode(String.self, forKey: .symbolRight)
            symbolLeft = try values.decode(String.self, forKey: .symbolLeft)
            value = try values.decode(Int.self, forKey: .value)
        } catch {
            throw error
        }
    }
    
    //For storing and loading into user defaults
    init(data: [String : Any]) {
        self.id = data["_id"] as? String ?? "-1"
        self.name =  data["name"] as? String ?? ""
        self.code =  data["code"] as? String ?? ""
        self.symbolRight =  data["symbol_right"] as? String ?? ""
        self.symbolLeft =  data["symbol_left"] as? String ?? ""
        self.value =  data["value"] as? Int ?? -1
    }
    
    
}

struct Price: Codable {
    let _id: String
    let amount: String
    let currencyType: CurrencyType?
    
    //For storing and loading into user defaults
    init(data: [String : Any]) {
        self._id = data["_id"] as? String ?? "-1"
        self.amount =  data["amount"] as? String ?? ""
        if let currencyTypeData = data["currencyType"] as? [String : Any]{
            let currenceType = CurrencyType(data: currencyTypeData)
            self.currencyType = currenceType
        }else{
            self.currencyType = nil
        }
    }
}

struct Membership: Codable {
    let id: String
    let plan: String
    let price: Price?
    let accessTo: [String]
    let discount: Int?

    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case plan
        case price
        case accessTo = "access_to"
//        case expiration
        case discount
    }
    
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decode(String.self, forKey: .id)
            plan = try values.decode(String.self, forKey: .plan)
            price = try values.decodeIfPresent(Price.self, forKey: .price)
            accessTo = try values.decode([String].self, forKey: .accessTo)
            discount = try values.decodeIfPresent(Int.self, forKey: .discount)
            
        } catch {
            throw error
        }
    }
    //when storing/loading from userdefault
    
    init(data: [String : Any]) {
        self.id = data["_id"] as? String ?? "-1"
        self.plan = (data["plan"] as? String ?? "").lowercased()
        self.accessTo =  data["access_to"] as? [String] ?? []
        self.discount = data["discount"] as? Int ?? -1
        if let priceData = data["price"] as? [String : Any]{
            let price = Price(data: priceData)
            self.price = price
        }else{
            self.price = nil
        }
    }
}

struct Participant: Codable {
    let id: String
    let username: String
    let email: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
    }
    
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decode(String.self, forKey: .id)
            username = try values.decode(String.self, forKey: .username)
            email = try values.decode(String.self, forKey: .email)
        } catch {
            throw error
        }
    }

}
