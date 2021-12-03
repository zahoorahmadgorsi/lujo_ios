//
//  CustomRequestRouter.swift
//  LUJO
//
//  Created by Nemanja Djurisic on 11/24/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import Alamofire
import FirebaseCrashlytics
import Foundation
import UIKit

enum CustomRequestRouter: URLRequestConvertible {
    // Obtain backend URL from configuration
    static let baseURLString: String = {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "BACKEND_URL") as? String else {
            return ""
        }
        return urlString
    }()
    
    static let apiVersion: String = {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "BACKEND_API_VERSION") as? String else {
            return ""
        }
        return "/" + urlString
    }()
    
    static let scheme: String = {
        guard let scheme = Bundle.main.object(forInfoDictionaryKey: "BACKEND_SCHEME") as? String else {
            return "https"
        }
        return scheme
    }()
    
    case requestYacht(String, String?, String, String?, String, String, Int, String)
    case requestVilla(String, String, Int,String, String,Int)
    case findHotel(String, String?, String, String, String, Int, Int, Int, String)
    
    
    func asURLRequest() throws -> URLRequest {
        var method: HTTPMethod {
            return getHTTPMethod()
        }
        
        let requestUrl: URL = {
            getRequestURL()
        }()
        
        let body: Data? = {
            getBodyData()
        }()
        
        var urlRequest = URLRequest(url: requestUrl)
        urlRequest.httpMethod = method.rawValue
        urlRequest.httpBody = body
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        return urlRequest
    }
    
    func getHTTPMethod() -> HTTPMethod {
        switch self {
        case .requestYacht: fallthrough
        case .requestVilla: fallthrough
        case .findHotel:
            return .post
        }
    }
    
    fileprivate func getRequestURL() -> URL {
        var newURLComponents = URLComponents()
        newURLComponents.scheme = EERouter.scheme
        newURLComponents.host = EERouter.baseURLString
        newURLComponents.path = EERouter.apiVersion
        
        switch self {
            case .requestYacht:
                newURLComponents.path.append("/custom-request/yacht")
            case .requestVilla:
                newURLComponents.path.append("/custom-request/villa")
            case .findHotel:
                newURLComponents.path.append("/custom-request/hotel")
        }
        
        do {
            let callURL = try newURLComponents.asURL()
            return callURL
        } catch {
            Crashlytics.crashlytics().record(error: error)
        }
        
        return URL(string: "https://\(EERouter.baseURLString)")!
    }
    
    fileprivate func getBodyData() -> Data? {
        switch self {
        case let .requestYacht(destination, yachtName, yachtCharter, yachtLenght, dateFrom, dateTo, guestsCount, token):
            return getYachtDataAsJSONData(destination: destination, yachtName: yachtName, yachtChareter: yachtCharter, yachtLenght: yachtLenght, dateFrom: dateFrom, dateTo: dateTo, guestsCount: guestsCount, token: token)
        case let .requestVilla(dateFrom, dateTo, guestsCount, villaName, token,villaRooms):
            return getVillaDataAsJSONData(dateFrom: dateFrom, dateTo: dateTo, guestsCount: guestsCount, villaName: villaName, token: token,villaRooms:villaRooms)
        case let .findHotel(cityName, hotelName, hotelRadius, checkInDate, checkOutDate, adultsCount, roomsCount, hotelStars, token):
            return getHotelDataAsJSONData(cityName: cityName, hotelName: hotelName, hotelRadius: hotelRadius, checkInDate: checkInDate, checkOutDate: checkOutDate, adultsCount: adultsCount, roomsCount: roomsCount, hotelStars: hotelStars, token: token)
        }
    }
    
    fileprivate func getYachtDataAsJSONData (destination: String, yachtName: String?, yachtChareter: String, yachtLenght: String?, dateFrom: String, dateTo: String, guestsCount: Int, token: String) -> Data? {
        var body: [String: Any] = [
            "yacht_destination": destination,
            "yacht_length": yachtLenght ?? "-100",
            "yacht_date_from": dateFrom,
            "yacht_date_to": dateTo,
            "yacht_guests": guestsCount,
            "token": token
            ,"yacht_charter": yachtChareter
            ,"yacht_budget" : "-123456"    //EmptyString
        ]
        
        if let yachtName = yachtName, !yachtName.isEmpty {
            body["yacht_name"] = yachtName
        }
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func getVillaDataAsJSONData ( dateFrom: String, dateTo: String, guestsCount: Int,villaName: String, token: String, villaRooms: Int) -> Data? {
        let body: [String: Any] = [
            "villa_check_in": dateFrom,
            "villa_check_out": dateTo,
            "villa_guests": guestsCount,
            "villa_name": villaName   //its villaname
            ,"villa_rooms": villaRooms
            ,"token": token
        ]
        
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func getHotelDataAsJSONData (cityName: String, hotelName: String?, hotelRadius: String, checkInDate: String, checkOutDate: String, adultsCount: Int, roomsCount: Int, hotelStars: Int, token: String) -> Data? {
        var body: [String: Any] = [
            "hotel_neighborhood": cityName,
            "hotel_check_in": checkInDate,
            "hotel_check_out": checkOutDate,
            "hotel_guests": adultsCount,
            "hotel_rooms": roomsCount,
            "hotel_stars": hotelStars,
            "hotel_radius": hotelRadius,
            "token": token
        ]
        
        if let hotelName = hotelName, !hotelName.isEmpty {
            body["hotel_name"] = hotelName
        }
        
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
}
