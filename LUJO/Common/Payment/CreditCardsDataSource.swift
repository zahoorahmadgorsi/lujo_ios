import UIKit

class CreditCardsDataSource: NSObject, UITableViewDataSource {
    static let cellID = "CreditCardCellID"
    var creditCards: [PaymentMethod<CreditCardInfo>]?

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let paymentMethods = creditCards else { return 0 }
        return paymentMethods.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: CreditCardsDataSource.cellID) as! CreditCardCell

        guard let creditCard = element(at: indexPath) else {
            fatalError("Requested unexisting credit card")
        }

        cell.creditCardBrandName.text = creditCard.displayName
        cell.creditCardEndNumber.text = "Ending with " + creditCard.methodInfo.cardNumber.suffix(4)
        cell.creditCardImage.image = UIImage(named: creditCard.methodInfo.cardType)
        return cell
    }

    func element(at indexpath: IndexPath) -> PaymentMethod<CreditCardInfo>? {
        guard let creditCards = creditCards else { return nil }
        guard indexpath.row < creditCards.count else { return nil }

        return creditCards[indexpath.row]
    }
}
