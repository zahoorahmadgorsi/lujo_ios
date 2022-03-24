//
//  DiningRouter.swift
//  LUJO
//
//  Created by Nemanja Djurisic on 8/12/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import Alamofire
import FirebaseCrashlytics
import Foundation
import UIKit

enum DiningRouter: URLRequestConvertible {
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

    case home(String)
    case search(String, String?, Int?, Double?, Double?)
//    case events(String, Bool)
//    case experiences(String)
    case salesforce(Int, String, String, Int, String)

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
        if let token = LujoSetup().getCurrentUser()?.token{
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        print("urlRequest:\(String(describing: urlRequest.url))")
        return urlRequest
    }

    func getHTTPMethod() -> HTTPMethod {
        switch self {
        case .home:
            return .get
        case .search:
            return .get
//        case .events:
//            return .get
//        case .experiences:
//            return .get
        case .salesforce:
            return .post
        }
    }

    fileprivate func getRequestURL() -> URL {
        var newURLComponents = URLComponents()
        newURLComponents.scheme = EERouter.scheme
        newURLComponents.host = EERouter.baseURLString
        newURLComponents.path = EERouter.apiVersion

        switch self {
        case let .home(token):
            newURLComponents.path.append("/dining")
            newURLComponents.queryItems = [
                URLQueryItem(name: "token", value: token)
            ]
        case let .search(token, term, cityId, latitude, longitude):
            newURLComponents.path.append("/restaurants")
            newURLComponents.queryItems = [
                URLQueryItem(name: "token", value: token)
            ]
            if let term = term {
                newURLComponents.queryItems?.append(URLQueryItem(name: "search", value: term))
            }
            if let cityId = cityId {
                newURLComponents.queryItems?.append(URLQueryItem(name: "location", value: "\(cityId)"))
            }
            if let latitude = latitude {
                newURLComponents.queryItems?.append(URLQueryItem(name: "latitude", value: "\(latitude)"))
            }
            if let longitude = longitude {
                newURLComponents.queryItems?.append(URLQueryItem(name: "longitude", value: "\(longitude)"))
            }

//        case let .events(token, past):
//            newURLComponents.path.append("/events")
//            newURLComponents.queryItems = [
//                URLQueryItem(name: "token", value: token),
//            ]
//            if past {
//                newURLComponents.queryItems?.append(URLQueryItem(name: "show_past", value: "true"))
//            }
//        case let .experiences(token):
//            newURLComponents.path.append("/experiences")
//            newURLComponents.queryItems = [
//                URLQueryItem(name: "token", value: token),
//            ]
        case .salesforce:
            newURLComponents.path.append("/request")
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
        case .home:
            return nil
        case .search:
            return nil
//        case .events:
//            return nil
//        case .experiences:
//            return nil
        case let .salesforce(itemId, date, time, persons, token):
            return getSalesforceDataAsJSONData(itemId: itemId, date: date, time: time, persons: persons, token: token)
        }
    }
    
    fileprivate func getSalesforceDataAsJSONData(itemId: Int, date:String, time:String, persons: Int, token: String) -> Data? {
        let body: [String: Any] = [
            "item_id": itemId,
            "date": date,
            "time": time,
            "persons": persons,
            "token": token
        ]
        
        return try? JSONSerialization.data(withJSONObject: body, options: [])
        
    }
}
