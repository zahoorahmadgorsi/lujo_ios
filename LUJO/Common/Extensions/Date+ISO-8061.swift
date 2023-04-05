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
//        print(dateFormatter.date(from: string))
        return dateFormatter.date(from: string)
    }
    
    static func dateFromUTCString(string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let localDate = formatter.date(from: string)
//        print(localDate as Any)
        return localDate
    }

    static func dateToString(date: Date, format: String = "yyyy-MM-dd-HH-mm-ss") -> String {
        print(date)
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = format
        let dateTimePrefix: String = formatter.string(from: date)
        print(dateTimePrefix)
        return dateTimePrefix
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
    
    func dateToDayWeekYear() -> String{
        let formatter = DateFormatter()
        switch true {
        case Calendar.current.isDateInToday(self) || Calendar.current.isDateInYesterday(self):
            formatter.doesRelativeDateFormatting = true
            formatter.dateStyle = .short
            formatter.timeStyle = .none
        case Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear):
            formatter.dateFormat = "EEEE"
        case Calendar.current.isDate(self, equalTo: Date(), toGranularity: .year):
            formatter.dateFormat = "E, d MMM"
        default:
            formatter.dateFormat = "MMM d, yyyy"
        }
//        print(formatter.string(from: self))
        return formatter.string(from: self)
    }
    
    func whatsAppTimeFormat() -> String{
        let formatter = DateFormatter()
        switch true {
        case Calendar.current.isDateInToday(self) :
            formatter.doesRelativeDateFormatting = true
            formatter.dateStyle = .none
            formatter.timeStyle = .short
        case Calendar.current.isDateInYesterday(self):
            formatter.doesRelativeDateFormatting = true
            formatter.dateStyle = .short
            formatter.timeStyle = .none
        case Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear):
            formatter.dateFormat = "EEEE"
        case Calendar.current.isDate(self, equalTo: Date(), toGranularity: .year):
            formatter.dateFormat = "E, d MMM"
        default:
            formatter.dateFormat = "MMM d, yyyy"
        }
//        print(formatter.string(from: self))
        return formatter.string(from: self)
    }
    
    func stripTime() -> Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        let date = Calendar.current.date(from: components)
        return date!
    }

    
}
