// swiftlint:disable identifier_name
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
    var id: Int
    var title: UserTitle?
    var firstName: String
    var lastName: String
    var email: String
    var phoneNumber: PhoneNumber
    var password: String
    var avatar: String
    var token: String
    var approved: String
    var referralCode: String
    var points: Int
    var membershipPlan: Membership?

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
    }

    func getLoginUser() -> LoginUser {
        return LoginUser(prefix: phoneNumber.countryCode,
                         phone: phoneNumber.number,
                         token: token,
                         tokenExpiration: LujoSetup().getCurrentUser()?.tokenExpiration,
                         approved: approved == "yes")
    }
    
    init(id: Int, title: UserTitle?, firstName: String, lastName: String, email: String, phoneNumber: PhoneNumber, password: String, avatar: String, token: String, approved: String, referralCode: String, points: Int, membershipPlan: Membership?) {
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
    }
    
    static func == (lhs: LujoUser, rhs: LujoUser) -> Bool {
        return lhs.id == rhs.id
    }
}

struct LujoUserProfile: Codable {
    let id: Int
    let baroque_id: String
    let title: String? = nil
    let firstname: String
    let lastname: String
    let email: String
    let phone_prefix: String
    let phone: String
    let avatar: String?
    let approved: String
    let referralCode: String
    let points: Int
    let membershipPlan: Membership?

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
    let flag: String

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
    let id: Int
    let plan: String
    let price: String
    let target: String
    let expiration: String?
    let discount: Int?
    
    init(data: [String : Any]) {
        self.id = data["id"] as? Int ?? -1
        self.plan = data["plan"] as? String ?? ""
        self.price =  data["price"] as? String ?? ""
        self.target =  data["target"] as? String ?? ""
        self.expiration = data["expiration"] as? String ?? ""
        self.discount = Int(data["discount"] as? String ?? "") ?? 0
    }
}
