//
//  PreferencesAPIManager.swift
//  LUJO
//
//  Created by iMac on 08/05/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import Alamofire
import FirebaseCrashlytics
import UIKit
import CoreLocation
import Mixpanel

extension GoLujoAPIManager  {
    
    func getAllPreferences(completion: @escaping (Preferences?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.getAllPreferences)
            .responseJSON { response in
                print("Request URL: \(String(describing: response.request)) \nRequest Body: \(String(data: response.request?.httpBody ?? Data(), encoding: .utf8)!) \nResponse Body: \(String(data: response.data ?? Data(), encoding: .utf8)!)")
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<Preferences>.self, from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func getGiftHabbits( completion: @escaping ([Taxonomy]?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.getGiftHabits)
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<TaxonomyResponse>.self,
                                                                 from: response.data!)
                            
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content.docs, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }

    func getGiftCategories( completion: @escaping ([Taxonomy]?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.getGiftCategories)
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<TaxonomyResponse>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content.docs, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func getGiftPreferences( completion: @escaping ([Taxonomy]?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.getGiftPreferences)
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<TaxonomyResponse>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content.docs, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func setGiftHabbits(commaSeparatedString:String, completion: @escaping (String?, Error?) -> Void){
        Alamofire.request(PreferencesRouter.setGiftHabits(commaSeparatedString ))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }

    func setGiftCategories(commaSeparatedString:String, completion: @escaping (String?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.setGiftCategories(commaSeparatedString))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func setGiftPreferences( commaSeparatedString:String, completion: @escaping (String?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.setGiftPreferences(commaSeparatedString))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func setAviationHaveCharteredBefore( commaSeparatedString:String, completion: @escaping (String?, Error?) -> Void){
        Alamofire.request(PreferencesRouter.setAviationHaveCharteredBefore( commaSeparatedString))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }

    func setAviationInterestedIn(commaSeparatedString:String, completion: @escaping (String?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.setAviationInterestedIn(commaSeparatedString))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func setAviationPreferredDestinations( commaSeparatedString:String, completion: @escaping (String?, Error?) -> Void){
        Alamofire.request(PreferencesRouter.setAviationPreferredDestinations( commaSeparatedString))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func setYachtPreferredRegions( commaSeparatedString:String, completion: @escaping (String?, Error?) -> Void){
        Alamofire.request(PreferencesRouter.setYachtPreferredRegions( commaSeparatedString))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func setAviationPreferredAirports( commaSeparatedString:String, completion: @escaping (String?, Error?) -> Void){
        Alamofire.request(PreferencesRouter.setAviationPreferredAirports( commaSeparatedString))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func setAviationAircraftCategory(commaSeparatedString:String, completion: @escaping (String?, Error?) -> Void){
        Alamofire.request(PreferencesRouter.setAviationAircraftCategory( commaSeparatedString))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func setYachtLength(commaSeparatedString:String, completion: @escaping (String?, Error?) -> Void){
        Alamofire.request(PreferencesRouter.setYachtLength(commaSeparatedString))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func getCuisines( completion: @escaping ([Taxonomy]?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.getCuisines)
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<TaxonomyResponse>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content.docs, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func getAviationBeverages( completion: @escaping ([Taxonomy]?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.getAviationBeverages)
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<TaxonomyResponse>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content.docs, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func getOtherInterests( completion: @escaping ([Taxonomy]?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.getOtherInterests)
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<[Taxonomy]>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func setAviationCharterFrequency(corporateFrequency:Int, leisureFrequency:Int, completion: @escaping (String?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.setAviationCharterFrequency(corporateFrequency, leisureFrequency))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func setYachtCharterFrequency(corporateFrequency:Int, leisureFrequency:Int, completion: @escaping (String?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.setYachtCharterFrequency(corporateFrequency, leisureFrequency))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func setAviationPreferredCharter(commaSeparatedString:String, completion: @escaping (String?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.setAviationPreferredCharter(commaSeparatedString))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func setAviationPreferredCuisines( commaSeparatedString:String, completion: @escaping (String?, Error?) -> Void){
        Alamofire.request(PreferencesRouter.setAviationPreferredCuisines( commaSeparatedString))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }

    func setYachtPreferredCuisines( commaSeparatedString:String, completion: @escaping (String?, Error?) -> Void){
        Alamofire.request(PreferencesRouter.setYachtPreferredCuisines( commaSeparatedString))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func setAviationPreferredBeverages( commaSeparatedString:String, completion: @escaping (String?, Error?) -> Void){
        Alamofire.request(PreferencesRouter.setAviationPreferredBevereges( commaSeparatedString))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func getAviationCategories( completion: @escaping ([BaroqueAviationCategory]?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.getAviationCategories)
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<[BaroqueAviationCategory]>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func searchDestination(strToSearch:String, completion: @escaping ([Taxonomy]?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.searchDestination(strToSearch))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<[Taxonomy]>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func searchRegions(strToSearch:String, completion: @escaping ([Taxonomy]?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.searchRegions(strToSearch))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<[Taxonomy]>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func searchCurrencies(strToSearch:String, completion: @escaping ([Taxonomy]?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.searchCurrencies(strToSearch))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<TaxonomyResponse>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content.docs, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    
    func setYachtHaveCharteredBefore(yesOrNo:String, completion: @escaping (String?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.setYachtHaveCharteredBefore(yesOrNo))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }

    func setYachtInterestedIn(charterPurchaseOrBoth:String, completion: @escaping (String?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.setYachtInterestedIn(charterPurchaseOrBoth))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func setYachtType(motorSailOrBoth:String, completion: @escaping (String?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.setYachtType(motorSailOrBoth))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func setYachtStyle(modernClassicOrBoth:String, completion: @escaping (String?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.setYachtStyle(modernClassicOrBoth))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func setYachtOtherInterests(commaSeparatedString:String, completion: @escaping (String?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.setYachtOtherInterests(commaSeparatedString))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func getDiningCuisines( completion: @escaping ([Taxonomy]?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.getDiningCuisines)
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<TaxonomyResponse>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content.docs, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func getDiningAllergies( completion: @escaping ([Taxonomy]?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.getDiningAllergies)
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<TaxonomyResponse>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content.docs, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func getDiningPreferences( completion: @escaping ([Taxonomy]?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.getDiningPreferences)
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<TaxonomyResponse>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content.docs, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func getDiningTimings( completion: @escaping ([Taxonomy]?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.getDiningTimings)
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<TaxonomyResponse>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content.docs, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func getDiningBeverages( completion: @escaping ([Taxonomy]?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.getDiningBeverages)
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<TaxonomyResponse>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content.docs, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func getDiningSeatings( completion: @escaping ([Taxonomy]?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.getDiningSeatings)
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<TaxonomyResponse>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content.docs, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func setDiningCuisines( commaSeparatedString:String, completion: @escaping (String?, Error?) -> Void){
        Alamofire.request(PreferencesRouter.setDiningCuisines( commaSeparatedString))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func setDiningPreferences( commaSeparatedString:String, completion: @escaping (String?, Error?) -> Void){
        Alamofire.request(PreferencesRouter.setDiningPreferences( commaSeparatedString))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func setDiningBeverages( commaSeparatedString:String, completion: @escaping (String?, Error?) -> Void){
        Alamofire.request(PreferencesRouter.setDiningBeverages( commaSeparatedString))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func setDiningAllergies(commaSeparatedString:String, completion: @escaping (String?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.setDiningAllergies(commaSeparatedString))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func setDiningTimings(commaSeparatedString:String, completion: @escaping (String?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.setDiningTimings(commaSeparatedString))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func setDiningSeatings(commaSeparatedString:String, completion: @escaping (String?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.setDiningSeatings(commaSeparatedString))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func getExperienceCategory( completion: @escaping ([Taxonomy]?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.getExperienceCategory)
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<TaxonomyResponse>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content.docs, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func getExperienceTags( completion: @escaping ([Taxonomy]?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.getExperienceTags)
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<TaxonomyResponse>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content.docs, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func getEventCategory( completion: @escaping ([Taxonomy]?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.getEventCategory)
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<TaxonomyResponse>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content.docs, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func getEventTags( completion: @escaping ([Taxonomy]?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.getEventTags)
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<TaxonomyResponse>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content.docs, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func getEventLocation( completion: @escaping ([Taxonomy]?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.getEventLocation)
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<[Taxonomy]>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func setEventCategory( commaSeparatedString:String,  completion: @escaping (String?, Error?) -> Void){
        Alamofire.request(PreferencesRouter.setEventCategory( commaSeparatedString))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func setEventLocation( commaSeparatedString:String, completion: @escaping (String?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.setEventLocation(commaSeparatedString))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    //******************************************************
    func setTravelFrequency(corporateFrequency:Int, leisureFrequency:Int, completion: @escaping (String?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.setTravelFrequency(corporateFrequency, leisureFrequency))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func setTravelDestinations(commaSeparatedString:String, completion: @escaping (String?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.setTravelDestinations(commaSeparatedString))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func setTravelHotelRating(businessStarRating:Int, leisureStarRating:Int, completion: @escaping (String?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.setTravelHotelRating(businessStarRating, leisureStarRating))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func setTravelDestinationType(commaSeparatedString:String, completion: @escaping (String?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.setTravelDestinationType(commaSeparatedString))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func setTravelHotelGroups(commaSeparatedString:String, completion: @escaping (String?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.setTravelHotelGroups(commaSeparatedString))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func setTravelAmenities( commaSeparatedString:String, completion: @escaping (String?, Error?) -> Void){
        Alamofire.request(PreferencesRouter.setTravelAmenities( commaSeparatedString))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func setTravelActivities(commaSeparatedString:String, completion: @escaping (String?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.setTravelActivities(commaSeparatedString))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func setTravelAirlines(commaSeparatedString:String, completion: @escaping (String?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.setTravelAirlines(commaSeparatedString))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func setTravelAirplaneSeat(airplaneSeat:String, completion: @escaping (String?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.setTravelAirplaneSeat(airplaneSeat))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func setTravelCabinClass( cabinClass:Int, leisureClass:Int, completion: @escaping (String?, Error?) -> Void){
        Alamofire.request(PreferencesRouter.setTravelCabinClass( cabinClass, leisureClass))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func setTravelMeals(commaSeparatedString:String, completion: @escaping (String?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.setTravelMeals(commaSeparatedString))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func setTravelMedicalMeals( commaSeparatedString:String, completion: @escaping (String?, Error?) -> Void){
        Alamofire.request(PreferencesRouter.setTravelMedicalMeals( commaSeparatedString))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func setTravelHotelStyles(commaSeparatedString:String, completion: @escaping (String?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.setTravelHotelStyles(commaSeparatedString))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func setTravelAllergies( commaSeparatedString:String, completion: @escaping (String?, Error?) -> Void){
        Alamofire.request(PreferencesRouter.setTravelAllergies( commaSeparatedString))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func getTravelHotelGroups( completion: @escaping ([String]?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.getTravelHotelGroups)
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<[String]>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func getTravelMedicalMeals( completion: @escaping ([String]?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.getTravelMedicalMeals)
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<[String]>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func getTravelActivities( completion: @escaping ([String]?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.getTravelActivities)
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<[String]>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func getTravelAmenities( completion: @escaping ([String]?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.getTravelAmenities)
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<[String]>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func getVillaAmenities( completion: @escaping ([String]?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.getVillaAmenities)
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<[String]>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func getVillaAccomodation( completion: @escaping ([String]?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.getVillaAccomodation)
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<[String]>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func setVillaDestinations(commaSeparatedString:String, completion: @escaping (String?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.setVillaDestinations(commaSeparatedString))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func setVillaAmenities( commaSeparatedString:String, completion: @escaping (String?, Error?) -> Void){
        Alamofire.request(PreferencesRouter.setVillaAmenities( commaSeparatedString))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func setVillaAccomodation( commaSeparatedString:String, completion: @escaping (String?, Error?) -> Void){
        Alamofire.request(PreferencesRouter.setVillaAccomodation( commaSeparatedString))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self,
                                                                 from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    func setProfilePreferences(commaSeparatedString:String, completion: @escaping (String?, Error?) -> Void) {
        Alamofire.request(PreferencesRouter.setProfilePreferences(commaSeparatedString))
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(nil, response.result.error!)
                    return
                }

                // Special case where status code is not received, should never happen
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, BackendError.unhandledStatus)
                    return
                }

                switch statusCode {
                case 1 ... 199: // Transfer protoco-level information: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 200 ... 299: // Success
                    guard let result = try? JSONDecoder().decode(LujoServerResponse<String>.self, from: response.data!)
                    else {
                        completion(nil, BackendError.parsing(reason: "Unable to parse response"))
                        return
                    }
                    completion(result.content, nil)
                    return
                case 300 ... 399: // Redirection: Unexpected
                    completion(nil, self.handleError(response, statusCode))
                case 400 ... 499: // Client Error
                    completion(nil, self.handleError(response, statusCode))
                default: // 500 or bigger, Server Error
                    completion(nil, self.handleError(response, statusCode))
                }
            }
    }
    
    fileprivate func handleError(_ response: DataResponse<Any>,
                                 _ statusCode: Int) -> Error {
        var serverError: String!
        do {
            let errorResult = try JSONDecoder().decode(LujoServerResponse<String>.self, from: response.data!)
            serverError = errorResult.content
        } catch {
            serverError = "Unknown server error"
        }
        reportError(statusCode, response)
        return BackendError.unexpectedCode(description: serverError)
    }

    fileprivate func reportError(_ statusCode: Int, _ response: DataResponse<Any>) {
        let sourceURL = String(describing: response.request?.url)
        let error = NSError(domain: NSURLErrorDomain,
                            code: NSURLErrorBadServerResponse,
                            userInfo: [
                                NSLocalizedDescriptionKey: "Unexpected \(statusCode) received on \(sourceURL)",
                                NSLocalizedFailureReasonErrorKey: "Expected code 20X, 40X or 50X",
                            ])
        Crashlytics.crashlytics().record(error: error)
    }
    
    
}
