import Foundation

public enum ResultPayment<T> {
    /// Indicates a successful result.
    case success(T)

    /// Indicates a failure.
    case failure(Error)
}
