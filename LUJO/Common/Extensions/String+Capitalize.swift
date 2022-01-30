import UIKit

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + lowercased().dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = capitalizingFirstLetter()
    }

    func capitalizingAllFirstLetters() -> String {
        return split(separator: " ").map { String($0).capitalizingFirstLetter() }.joined(separator: " ")
    }

    mutating func capitalizeAllFirstLetters() {
        self = capitalizingAllFirstLetters()
    }
    
    func isHtml() -> Bool {
        let validateTest = NSPredicate(format:"SELF MATCHES %@", "<[a-z][\\s\\S]*>")
        return validateTest.evaluate(with: self)
    }
    
    func parseHTML() -> NSAttributedString{
        let data = self.data(using: .utf8)!
        if let attributedString = try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil){
            return attributedString.trailingNewlineChopped
        }
        return NSMutableAttributedString()
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = (self as NSString).boundingRect(with: constraintRect, options: .usesLineFragmentOrigin,
                                                          attributes: [.font: font],
                                                          context: nil)

        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)

        let boundingBox = (self as NSString).boundingRect(with: constraintRect, options: .usesLineFragmentOrigin,
                                                          attributes: [NSAttributedString.Key.font: font],
                                                          context: nil)

        return boundingBox.width
    }
}

extension String {
    func formatAsCreditCard() -> NSAttributedString {
        let formattedString = NSMutableAttributedString(string: "")
        var attribute: NSMutableAttributedString!
        let range = NSRange(location: 0, length: 1)
        let cleanString = replacingOccurrences(of: " ", with: "")

        for (index, char) in cleanString.unicodeScalars.enumerated() {
            attribute = NSMutableAttributedString(string: String(char))

            if CharacterSet.decimalDigits.contains(char) {
                attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: range)
            } else {
                attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: range)
            }
            formattedString.append(attribute)

            if (index + 1) % 4 == 0, index > 0, index < (cleanString.count - 1) {
                formattedString.append(NSAttributedString(string: " "))
            }
        }

        return NSAttributedString(attributedString: formattedString)
    }

    func isValidCreditCardNumber() -> Bool {
        func luhnCheck(_ cardNumber: String) -> Bool {
            let reversedCardNumberDigits = cardNumber.reversed().compactMap { Int(String($0)) }
            // swiftlint:disable variable_name
            var sum = 0
            for (index, digit) in reversedCardNumberDigits.enumerated() {
                let isOdd = index % 2 == 1

                switch (isOdd, digit) {
                case (true, 9):
                    sum += 9
                case (true, 0 ... 8):
                    sum += (digit * 2) % 9
                default:
                    sum += digit
                }
            }

            return sum % 10 == 0
        }

        let cleanString = replacingOccurrences(of: " ", with: "")

        guard cleanString.onlyContainsDigits() else { return false }
        guard 12 ... 16 ~= cleanString.count else { return false }

        return luhnCheck(cleanString)
    }

    func onlyContainsDigits() -> Bool {
        return unicodeScalars.reduce(true) { $0 && CharacterSet.decimalDigits.contains($1) }
    }
}

extension String {
    func slice(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom ..< endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom ..< substringTo])
            }
        }
    }
    
    //converting price 6000 to 6,000
    func withCommas() -> String {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            return numberFormatter.string(from: NSNumber(value:Int(self) ?? 0))!
        }
    
    //func time24To12(dateAsString:String) -> String {
    func time24To12() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"

        let date = dateFormatter.date(from: self)
        dateFormatter.dateFormat = "h:mm a"
        let Date12 = dateFormatter.string(from: date!)
        return Date12
    }
}

extension NSAttributedString {
    //truncating \n from the end
    var trailingNewlineChopped: NSAttributedString {
        if self.string.hasSuffix("\n") {
            return self.attributedSubstring(from: NSMakeRange(0, self.length - 1))
        } else {
            return self
        }
    }
}
