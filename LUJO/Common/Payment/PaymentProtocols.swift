import UIKit

public typealias Completion<T> = (T) -> Void

extension UITableViewDataSource {
    func element(at indexpath: IndexPath) -> Any? {
        fatalError("Needs to be implemented at class")
    }
}

protocol PaymentControllerDelegate: AnyObject {
    func requestPaymentSession(withToken token: String,
                               for paymentController: PaymentController,
                               responseHandler: @escaping Completion<String>)

    func startNewPaymentSession(selectionHandler: @escaping Completion<PaymentMethod<CreditCardInfo>>)

    func added(payment method: PaymentMethod<CreditCardInfo>, to session: PaymentSession?)
    func selectPaymentMethod(from paymentMethods: [PaymentMethod<CreditCardInfo>],
                             for paymentController: PaymentController,
                             selectionHandler: @escaping Completion<PaymentMethod<CreditCardInfo>>)

    func didFinish(with result: ResultPayment<PaymentResult>, for paymentController: PaymentController)
    func show(_ error: String)
}

extension PaymentControllerDelegate {
    func requestPaymentSession(withToken token: String,
                               for paymentController: PaymentController,
                               responseHandler: @escaping Completion<String>) {}
    func startNewPaymentSession(selectionHandler: @escaping Completion<PaymentMethod<CreditCardInfo>>) {}
    func selectPaymentMethod(from paymentMethods: [PaymentMethod<CreditCardInfo>],
                             for paymentController: PaymentController,
                             selectionHandler: @escaping Completion<PaymentMethod<CreditCardInfo>>) {}
}

protocol PaymentAPIManager {
    func requestSession(for token: String, with payment: PaymentData, completion: @escaping (PaymentSession?, Error?) -> Void)
    func encodeCard(number: String, completion: @escaping (String?, Error?) -> Void)
    func authorize(_ session: PaymentSession?, using method: PaymentMethod<CreditCardInfo>, amount: Double,
                   completion: @escaping (ResultPayment<CCAuthorizationResult>) -> Void)
    func add(_ card: PaymentMethod<CreditCardInfo>, to session: PaymentSession, completion: @escaping (Error?) -> Void)
}
