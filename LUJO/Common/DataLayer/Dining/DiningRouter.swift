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

    case home
    case search(String?, String?, Double?, Double?, String?)

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
        urlRequest.print()
        return urlRequest
    }

    func getHTTPMethod() -> HTTPMethod {
        switch self {
        case .home:
            return .get
        case .search:
            return .post
        }
    }

    fileprivate func getRequestURL() -> URL {
        var newURLComponents = URLComponents()
        newURLComponents.scheme = EERouter.scheme
        newURLComponents.host = EERouter.baseURLString
        newURLComponents.path = EERouter.apiVersion

        switch self {
        case .home:
            newURLComponents.path.append("/dining")
        case .search:
            newURLComponents.path.append("/restaurants/search")
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
        case let .search(search, location, latitude, longitude, cuisineCategoryId):
            return getSearchDataAsJSONData(search,location, latitude, longitude, cuisineCategoryId)
        }
    }
    
    fileprivate func getSearchDataAsJSONData(_ search: String?, _ location:String?, _ latitude:Double?, _ longitude: Double?,_ cuisineCategoryId:String?) -> Data? {
        var body: [String: Any] = [ "status": "Published" ]
        if let _location = location{
            body["location"] = _location
        }
        if let _search = search{
            body["search"] = _search
        }
        if let lat = latitude{
            body["latitude"] = lat
        }
        if let long = longitude {
            body["longitude"] = long
        }
        if let _cuisineCategoryId = cuisineCategoryId {
            let temp:[String] = [_cuisineCategoryId]
            body["cuisine_category_ids"] = temp
        }
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }

}
