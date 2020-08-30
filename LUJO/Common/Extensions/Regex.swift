import UIKit

struct Regex {
    let pattern: String
    let options: NSRegularExpression.Options

    private var matcher: NSRegularExpression {
        return try! NSRegularExpression(pattern: pattern, options: options)
    }

    init(pattern: String, options: NSRegularExpression.Options! = nil) {
        self.pattern = pattern
        self.options = options ?? []
    }

    func match(string: String, options: NSRegularExpression.MatchingOptions = []) -> Bool {
        let entireRange = NSRange(location: 0, length: string.count)
        let matches = matcher.numberOfMatches(in: string, options: options, range: entireRange)
        return matches > 0
    }
}

protocol RegularExpressionMatchable {
    func match(regex: Regex) -> Bool
}

extension String: RegularExpressionMatchable {
    func match(regex: Regex) -> Bool {
        return regex.match(string: self)
    }
}

func ~= <T: RegularExpressionMatchable>(pattern: Regex, matchable: T) -> Bool {
    return matchable.match(regex: pattern)
}
