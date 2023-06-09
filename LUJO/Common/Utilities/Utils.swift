//
//  Utils.swift
//
//  Copyright © 2016 Twilio. All rights reserved.
//
import Foundation
import CoreTelephony
import MessageUI

// Helper to determine if we're running on simulator or device
struct PlatformUtils {
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif
        return isSim
    }()
}

struct TokenUtils {

    static func retrieveToken(url: String, completion: @escaping (String?, String?, Error?) -> Void) {
        if let requestURL = URL(string: url) {
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let task = session.dataTask(with: requestURL, completionHandler: { (data, _, error) in
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        if let tokenData = json as? [String: String] {
                            let token = tokenData["token"]
                            let identity = tokenData["identity"]
                            completion(token, identity, error)
                        } else {
                            completion(nil, nil, nil)
                        }
                    } catch let error as NSError {
                        completion(nil, nil, error)
                    }
                } else {
                    completion(nil, nil, error)
                }
            })
            task.resume()
        }
    }
}

struct Utility
{
    static func getAppBuild() -> String {
        if let dictionary = Bundle.main.infoDictionary{
            if let strBuild = dictionary["CFBundleVersion"] as? String{
                return  strBuild
            }
        }
        return ""
    }
    
    static func getAppVersion() -> String {
        if let dictionary = Bundle.main.infoDictionary{
            if let strVersion = dictionary["CFBundleShortVersionString"] as? String{
                return strVersion
            }
        }
        return ""
    }
    
    static func getAttributes(onlyRelatedToUser:Bool) -> Dictionary<String,Any>{
        var attribute = Dictionary<String,Any>()
        if let user = LujoSetup().getLujoUser(), user.id.count > 0 {
            attribute["profile_picture"] = user.avatar
            attribute["customer_name"] = user.firstName + " " + user.lastName
            attribute["customer_email"] = user.email
            attribute["customer_phone"] = user.phoneNumber.readableNumber
            attribute["customer_sfid"] = user.sfid
            if let plan = user.membershipPlan?.plan{
                attribute["customer_membership"] = plan
            }else{
                attribute["customer_membership"] = "Free"
            }
            if (onlyRelatedToUser == false){
                attribute["app_version"] = getAppVersion()
                attribute["app_build"] = getAppBuild()
                
                attribute["device_name"] = UIDevice.modelName
                attribute["device_ios_version"] = UIDevice.current.systemVersion
                attribute["device_language"] = Locale.current.languageCode
                if let carrier = CTTelephonyNetworkInfo().serviceSubscriberCellularProviders?.first?.value{
                    attribute["device_carrier_name"] = carrier.carrierName
                    
                }
                attribute["device_timezone"] = TimeZone.current.abbreviation()
                if let network = CTTelephonyNetworkInfo().serviceCurrentRadioAccessTechnology?.first?.value {
                    attribute["device_connection"] = network.localizedLowercase
                }
            }
        }
        return attribute
    }
    
    static func inviteFriend(_ referralCode : String){
        let activityViewController = UIActivityViewController(
            activityItems: ["""
            It's my pleasure to invite you to join Lujo our new ultimate lifestyle management platform filled with curated content that brings the world's best experiences to your fingertips. Download Lujo for iPhone https://apps.apple.com/us/app/lujo/id1233843327 and become a member to enjoy the finest that the world has to offer. Membership awaits you with a unique code \(referralCode).
            """],
            applicationActivities: nil
        )
        UIApplication.topViewController()?.present(activityViewController, animated: true, completion: nil)
    }
    
    static func getVerticalType(_ productType : String ) -> String{
        var verticalType = "access"
        if productType == "aviation"{
            verticalType = "aviation"
        }else if productType == "yacht"{
            verticalType = "yachts"
        }else if productType == "villa"{
            verticalType = "villas"
        }
        return verticalType
    }
    
    static func isUserAMember() -> Bool{
        let lujoUser = LujoSetup().getLujoUser()
        print(lujoUser as Any)
        let membershipPlan = lujoUser?.membershipPlan?.accessTo
        var hasMembership = false
        if (membershipPlan?.contains(where: {$0.caseInsensitiveCompare("dining") == .orderedSame}) == true ||
             membershipPlan?.contains(where: {$0.caseInsensitiveCompare("all") == .orderedSame}) == true){
            hasMembership = true
        }
        return hasMembership
    }
    
    // If user mobile has One SIM. If it has more than 1 SIM then randomly first SIM would be picked. And used its ISO Country Code
    // If mobile don't have SIM then device locale would be used.
//    ["0000000100000002": CTCarrier (0x282efa3a0) {
//        Carrier name: [du]
//        Mobile Country Code: [424]
//        Mobile Network Code:[03]  // because i am on roaming
//        ISO Country Code:[ae]
//        Allows VOIP? [YES]
//    }
//    , "0000000100000001": CTCarrier (0x282e54f30) {
//        Carrier name: [Ufone]
//        Mobile Country Code: [410]
//        Mobile Network Code:[03]
//        ISO Country Code:[pk]
//        Allows VOIP? [YES]
//    }
//    ]
    static func getCountryCode() -> PhoneCountryCode{
        var hardCodedCountryCode = PhoneCountryCode(
                                                    alpha2Code: "US",
                                                    phonePrefix: "+1",
                                                    country: TaxonomyCountry( _id : "238" , name: "United States of America"),
                                                    flag: "https://bit.ly/2Vrjgrk")
        
        print("Cellular ISO country code :\(CTTelephonyNetworkInfo().serviceSubscriberCellularProviders)" , "Locale region code:\(Locale.current.regionCode)")
        
        if let networkOrLocaleCountryCode = CTTelephonyNetworkInfo().serviceSubscriberCellularProviders?.first?.value.isoCountryCode{//} ?? Locale.current.regionCode{
            if let countryCodes = LujoSetup().getCountryCodes(), countryCodes.count > 0{
                if let countryCode = countryCodes.first(where: ({$0.alpha2Code.lowercased() == networkOrLocaleCountryCode.lowercased()})){
                    hardCodedCountryCode = PhoneCountryCode(
                        alpha2Code: countryCode.alpha2Code,
                        phonePrefix: countryCode.phonePrefix,
                        country: TaxonomyCountry( _id : "238asdf" , name: countryCode.alpha2Code),
                        flag: "https://bit.ly/2Vrjgrk")
                }
            }
        }
        
        return hardCodedCountryCode
    }
    
    static func getCityStateCountryName(from taxonomy: Taxonomy) -> String{
        var destinationName = taxonomy.name
        if let country = taxonomy.country{
            if let state = taxonomy.stateName{
                destinationName +=  ", " + state + ", " + country.name
            }else{
                destinationName +=   ", " + country.name
            }
        }
        return destinationName
    }
}
