import Foundation

public extension Date {
    static func ISOStringFromDate(date: Date, locale: String = "en_US_POSIX", timezone: String = "UTC") -> String {
        let dateFormater = DateFormatter()
        dateFormater.locale = Locale(identifier: locale)
        dateFormater.timeZone = TimeZone(abbreviation: timezone)
        dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        return dateFormater.string(from: date).appending("Z")
    }

    static func dateFromISOString(string: String, locale: String = "en_US_POSIX") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: locale)
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

        return dateFormatter.date(from: string)
    }

    static func isoStringNow() -> String {
        return Date.ISOStringFromDate(date: Date())
    }

    func isInThePast() -> Bool {
        return compare(Date()) == .orderedDescending
    }

    func asDateAndTime() -> [String: String] {
        let calendar = Calendar.current
        let requestedComponents: Set<Calendar.Component> = [.month, .day, .year, .hour, .minute]
        let components = calendar.dateComponents(requestedComponents, from: self)
        return [
            "date": Date.ISOStringFromDate(date: self),
            "time": String(format: "%02d", components.hour!) + ":" + String(format: "%02d", components.minute!),
        ]
    }
}
