import FirebaseCrashlytics
import Foundation

extension NSError {
    static func logLUJOError(for domain: String, description: String) {
        let error = NSError(domain: "Payments",
                            code: 1,
                            userInfo: [
                                NSLocalizedDescriptionKey: "Payment Session does not contain payment methods",
                            ])
        Crashlytics.crashlytics().record(error: error)
    }
}
