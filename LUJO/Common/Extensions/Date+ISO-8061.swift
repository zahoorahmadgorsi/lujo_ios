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
    
    static func dateFromUTC(utcTimeString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let date = dateFormatter.date(from: utcTimeString)
        return date
    }
    
    static func dateToString(date: Date, format: String = "yyyy-MM-dd-HH-mm-ss") -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = format
        let dateTimePrefix: String = formatter.string(from: date)
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
    
    //shown on chatviewcontroller
    func dateToDayWeekYear() -> String{
        let formatter = DateFormatter()
        switch true {
        case Calendar.current.isDateInToday(self) || Calendar.current.isDateInYesterday(self):
            formatter.doesRelativeDateFormatting = true
            formatter.dateStyle = .short
            formatter.timeStyle = .none
        case self.isInSevenDays():
            formatter.dateFormat = "EEEE"
        case Calendar.current.isDate(self, equalTo: Date(), toGranularity: .month):
            formatter.dateFormat = "E, d MMM"
        default:
            formatter.dateFormat = "MMM d, yyyy"
        }
        return formatter.string(from: self)
    }
    
    //Show on conversation list
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
        case self.isInSevenDays():
            formatter.dateFormat = "EEEE"
        case Calendar.current.isDate(self, equalTo: Date(), toGranularity: .month):
            formatter.dateFormat = "E, d MMM"
        default:
            formatter.dateFormat = "MMM d, yyyy"
        }
        return formatter.string(from: self)
    }
    
    func stripTime() -> Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        let date = Calendar.current.date(from: components)
        return date!
    }
    
    func isInSevenDays() -> Bool {
        let today = Date()
        guard let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: today) else { return false }
        return self >= sevenDaysAgo && self < today
    }
    
}
