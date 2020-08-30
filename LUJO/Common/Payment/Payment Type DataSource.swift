import UIKit

struct PaymentChannel: Equatable, ExpressibleByStringLiteral {
    typealias StringLiteralType = String

    var rawValue: String {
        return "\(name),\(image),\(comment)"
    }

    typealias RawValue = String

    init(stringLiteral rawValue: String) {
        let components = rawValue.split(separator: ",")

        id = 0
        name = ""
        image = ""
        comment = ""

        if !components.isEmpty {
            if let paymentId = Int(components[0]) { id = paymentId }
        }
        if components.count > 1 { name = String(components[1]).trimmingCharacters(in: .whitespaces) }
        if components.count > 2 { image = String(components[2]).trimmingCharacters(in: .whitespaces) }
        if components.count > 3 { comment = String(components[3]).trimmingCharacters(in: .whitespaces) }
    }

    var id: Int
    var name: String
    var image: String
    var comment: String
}

enum PaymentType: PaymentChannel {
    typealias RawValue = PaymentChannel
    // swiftlint:disable line_length
    case creditCard = "1, Credit Card, Credit Card Payment Type, *subject to a 4% merchant processing fee"
    case wireTransfer = "2, Wire Transfer, Wire Transfer Payment Type, *Bank charges on wire payments are the clients responsibility."

    static let allCases = [creditCard, wireTransfer]
}

class PaymentTypeDataSource: NSObject, UITableViewDataSource {
    static let cellID = "PaymentTypeCellID"

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PaymentType.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: PaymentTypeDataSource.cellID) as! PaymentTypeCell

        let paymentType = PaymentType.allCases[indexPath.row]
        cell.paymentTypeName.text = paymentType.rawValue.name
        cell.paymentTypeImage.image = UIImage(named: paymentType.rawValue.image)
        cell.paymentTypeComment.text = paymentType.rawValue.comment

        return cell
    }

    func element(at indexpath: IndexPath) -> Any? {
        guard indexpath.row < PaymentType.allCases.count else { return nil }
        return PaymentType.allCases[indexpath.row]
    }
}
