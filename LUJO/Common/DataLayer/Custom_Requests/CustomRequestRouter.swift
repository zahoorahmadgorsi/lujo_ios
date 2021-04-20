//
//  CustomRequestRouter.swift
//  LUJO
//
//  Created by Nemanja Djurisic on 11/24/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import Alamofire
import Crashlytics
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
    
    case getTable(String, String?, Cuisine?, String, String, Int, String)
    case tickets(String, Int, String)
    case goods(String, Bool, String)
    case requestYacht(String, String?, String?, String, String, String, Int, String)
    case requestVilla(String, String, Int,String, String)
    case findHotel(String, String?, String, String, String, Int, Int, Int, String)
    case cuisineCategories(String)
    
    
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
        case .getTable: fallthrough
        case .tickets: fallthrough
        case .goods: fallthrough
        case .requestYacht: fallthrough
        case .requestVilla: fallthrough
        case .findHotel:
            return .post
        case .cuisineCategories:
            return .get
        }
    }
    
    fileprivate func getRequestURL() -> URL {
        var newURLComponents = URLComponents()
        newURLComponents.scheme = EERouter.scheme
        newURLComponents.host = EERouter.baseURLString
        newURLComponents.path = EERouter.apiVersion
        
        switch self {
        case .getTable:
            newURLComponents.path.append("/custom-request/dining")
        case .tickets:
            newURLComponents.path.append("/custom-request/tickets")
        case .goods:
            newURLComponents.path.append("/custom-request/goods")
        case .requestYacht:
            newURLComponents.path.append("/custom-request/yacht")
        case .requestVilla:
            newURLComponents.path.append("/custom-request/villa")
        case .findHotel:
            newURLComponents.path.append("/custom-request/hotel")
        case let .cuisineCategories(token):
            newURLComponents.path.append("/taxonomies")
            newURLComponents.queryItems = [
                URLQueryItem(name: "token", value: token),
                URLQueryItem(name: "taxonomy", value: "cuisine_category")
            ]
        }
        
        do {
            let callURL = try newURLComponents.asURL()
            return callURL
        } catch {
            Crashlytics.sharedInstance().recordError(error)
        }
        
        return URL(string: "https://\(EERouter.baseURLString)")!
    }
    
    fileprivate func getBodyData() -> Data? {
        switch self {
        case let .getTable(location, restaurantName, cuisine, date, time, guestsCount, token):
            return getTableDataAsJSONData(location: location, restaurantName: restaurantName, cuisine: cuisine, date: date, time: time, guestsCount: guestsCount, token: token)
        case let .tickets(desc, count, token):
            return getTicketsDataAsJSONData(desc: desc, count: count, token: token)
        case let .goods(desc, isGift, token):
            return getGoodsDataAsJSONData(desc: desc, isGift: isGift, token: token)
        case let .requestYacht(destination, yachtName, yachtType, yachtLenght, dateFrom, dateTo, guestsCount, token):
            return getYachtDataAsJSONData(destination: destination, yachtName: yachtName, yachtType: yachtType, yachtLenght: yachtLenght, dateFrom: dateFrom, dateTo: dateTo, guestsCount: guestsCount, token: token)
        case let .requestVilla(dateFrom, dateTo, guestsCount, villaName, token):
            return getVillaDataAsJSONData(dateFrom: dateFrom, dateTo: dateTo, guestsCount: guestsCount, villaName: villaName, token: token)
        case let .findHotel(cityName, hotelName, hotelRadius, checkInDate, checkOutDate, adultsCount, roomsCount, hotelStars, token):
            return getHotelDataAsJSONData(cityName: cityName, hotelName: hotelName, hotelRadius: hotelRadius, checkInDate: checkInDate, checkOutDate: checkOutDate, adultsCount: adultsCount, roomsCount: roomsCount, hotelStars: hotelStars, token: token)
        case .cuisineCategories:
            return nil
        }
    }
    
    fileprivate func getTicketsDataAsJSONData(desc: String, count: Int, token: String) -> Data? {
        let body: [String: Any] = [
            "ticket_description": desc,
            "tickets_num": count,
            "token": token
        ]
        
        return try? JSONSerialization.data(withJSONObject: body, options: [])
        
    }
    
    fileprivate func getGoodsDataAsJSONData(desc: String, isGift: Bool, token: String) -> Data? {
        let body: [String: Any] = [
            "good_description": desc,
            "good_is_gift": isGift,
            "token": token
        ]
        
        return try? JSONSerialization.data(withJSONObject: body, options: [])
        
    }
    
    fileprivate func getTableDataAsJSONData (location: String, restaurantName: String?, cuisine: Cuisine?, date: String, time: String, guestsCount: Int, token: String) -> Data? {
        var body: [String: Any] = [
            "dining_neighborhood": location,
            "dining_date": date,
            "dining_time": time,
            "dining_guests": guestsCount,
            "token": token
        ]
        
        if let restaurantName = restaurantName, !restaurantName.isEmpty {
            body["dining_name"] = restaurantName
        }
        
        if let cuisine = cuisine {
            body["dining_cuisine"] = cuisine.termId
        }
        
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func getYachtDataAsJSONData (destination: String, yachtName: String?, yachtType: String?, yachtLenght: String, dateFrom: String, dateTo: String, guestsCount: Int, token: String) -> Data? {
        var body: [String: Any] = [
            "yacht_destination": destination,
            "yacht_length": yachtLenght,
            "yacht_date_from": dateFrom,
            "yacht_date_to": dateTo,
            "yacht_guests": guestsCount,
            "token": token
        ]
        
        if let yachtName = yachtName, !yachtName.isEmpty {
            body["yacht_name"] = yachtName
        }
        
        if let yachtType = yachtType, !yachtType.isEmpty {
            body["yacht_type"] = yachtType
        }
        
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func getVillaDataAsJSONData ( dateFrom: String, dateTo: String, guestsCount: Int,villaName: String, token: String) -> Data? {
        let body: [String: Any] = [
            "villa_check_in": dateFrom,
            "villa_check_out": dateTo,
            "villa_guests": guestsCount,
            "villa_name": villaName,   //its villaname
            "token": token
        ]
        
//        if let yachtName = yachtName, !yachtName.isEmpty {
//            body["yacht_name"] = yachtName
//        }
//
//        if let yachtType = yachtType, !yachtType.isEmpty {
//            body["yacht_type"] = yachtType
//        }
        
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
