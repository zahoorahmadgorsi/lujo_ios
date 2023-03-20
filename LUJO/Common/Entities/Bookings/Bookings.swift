//
//  Bookings.swift
//  LUJO
//
//  Created by Nemanja Djurisic on 10/22/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import Foundation
import FirebaseCrashlytics

struct Booking: Codable {
    let bookingId: String?
    let booking: String?
    let bookingType: String
    let bookingDate: Date?
    let bookingMessage: String?
    let bookingStatus: String?
    let bookingPersons: Int?
    let bookingQuote: Double?
    let bookingAviationType: String?
    let bookingAviation: AviationBooking?
    let bookingCreation: Date?
    
    enum CodingKeys: String, CodingKey {
        case bookingId = "booking_id"
        case booking
        case bookingType = "booking_type"
        case bookingDate = "booking_date"
        case bookingMessage = "booking_message"
        case bookingStatus = "booking_status"
        case bookingPersons = "booking_persons"
        case bookingQuote = "booking_quote"
        case bookingAviationType = "booking_aviation_type"
        case bookingAviation = "booking_aviation"
        case bookingCreation = "booking_creation"
    }
}

extension Booking {
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            
            bookingId = try values.decodeIfPresent(String.self, forKey: .bookingId)
            booking = try values.decodeIfPresent(String.self, forKey: .booking)
            bookingType = try values.decode(String.self, forKey: .bookingType)
            bookingMessage = try values.decodeIfPresent(String.self, forKey: .bookingMessage)
            bookingStatus = try values.decodeIfPresent(String.self, forKey: .bookingStatus)
            bookingPersons = try values.decodeIfPresent(Int.self, forKey: .bookingPersons)
            bookingQuote = try values.decodeIfPresent(Double.self, forKey: .bookingQuote)
            bookingAviationType = try values.decodeIfPresent(String.self, forKey: .bookingAviationType)
            bookingAviation = try values.decodeIfPresent(AviationBooking.self, forKey: .bookingAviation)
            
            do {
                if let intBookingDate = try values.decodeIfPresent(Int.self, forKey: .bookingDate) {
                    if intBookingDate >= 0 {
                        bookingDate = Date(timeIntervalSince1970: TimeInterval(intBookingDate))
                    } else {
                        bookingDate = nil
                    }
                } else {
                    bookingDate = nil
                }
            } catch {
                bookingDate = nil
            }
            
            do {
                if let intDate = try values.decodeIfPresent(Int.self, forKey: .bookingCreation) {
                    if intDate >= 0 {
                        bookingCreation = Date(timeIntervalSince1970: TimeInterval(intDate))
                    } else {
                        bookingCreation = nil
                    }
                } else {
                    bookingCreation = nil
                }
            } catch {
                bookingCreation = nil
            }
            
        } catch {
            Crashlytics.crashlytics().record(error: error)
            throw error
        }
    }
}
