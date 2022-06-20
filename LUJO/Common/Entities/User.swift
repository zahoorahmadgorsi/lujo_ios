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
    var referralCode: String
    var points: Int
    var membershipPlan: Membership?
    var sfid: String

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
    }

    func getLoginUser() -> LoginUser {
        return LoginUser(prefix: phoneNumber.countryCode,
                         phone: phoneNumber.number,
                         token: token,
                         tokenExpiration: LujoSetup().getCurrentUser()?.tokenExpiration,
                         approved: approved == true)
    }
    
    init(id: String, title: UserTitle?, firstName: String, lastName: String, email: String, phoneNumber: PhoneNumber, password: String, avatar: String, token: String, approved: Bool, referralCode: String, points: Int, membershipPlan: Membership?, sfid:String) {
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
    let referralCode: String
    let points: Int
    let membershipPlan: Membership?
    var sfid: String
    
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

struct Membership: Codable {
    let id: String
    let plan: String
    let price: Int
    let target: String
    let expiration: Int?
    let discount: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case plan
        case price
        case target
        case expiration
        case discount
    }
    
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decode(String.self, forKey: .id)
            plan = try values.decode(String.self, forKey: .plan)
            price = try values.decode(Int.self, forKey: .price)
            target = try values.decode(String.self, forKey: .target)
            //expiration will throw an error if member_ship plan has been updated using dummy api /users/membership_plan, please use * /purchase/membership to update the membership, only then expiration would have a valid value
            expiration = try values.decodeIfPresent(Int.self, forKey: .expiration)
//            expiration = 123456
            discount = try values.decodeIfPresent(Int.self, forKey: .discount)
            
        } catch {
            throw error
        }
    }
    
    init(data: [String : Any]) {
        self.id = data["_id"] as? String ?? "-1"
        self.plan = (data["plan"] as? String ?? "").lowercased()
        self.price =  data["price"] as? Int ?? -1
        self.target =  data["target"] as? String ?? ""
        self.expiration = data["expiration"] as? Int ?? -1
        self.discount = data["discount"] as? Int ?? -1
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
