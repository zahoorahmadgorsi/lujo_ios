import Foundation

enum BackendError: Error {
    case unhandledStatus
    case parsing(reason: String)
    case unexpectedCode(description: String)
}

extension BackendError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unhandledStatus:
            return NSLocalizedString("Unexpected Backend Status Code", comment: "")
        case let .parsing(reason):
            return NSLocalizedString(reason, comment: "")
        case let .unexpectedCode(description):
            return NSLocalizedString(description, comment: "")
        }
    }
}
