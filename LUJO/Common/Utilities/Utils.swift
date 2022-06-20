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
        if let user = LujoSetup().getLujoUser(), user.id > 0 {
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
            It's my pleasure to invite you to join Lujo our new ultimate lifestyle management platform filled with curated content that brings the world's best experiences to your fingertips. Download Lujo for iPhone https://apps.apple.com/us/app/lujo/id1233843327 and become a member to enjoy the finest that the world has to offer. Mmbership awaits you with a unique code \(referralCode).
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
}
