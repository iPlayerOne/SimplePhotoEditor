import Foundation

enum AuthError: Error, Identifiable {
    // MARK: - Email / Password
    case emailAlreadyInUse
    case invalidEmailFormat
    case userNotFound
    case wrongPassword
    case weakPassword
    case userDisabled
    case tooManyRequests
    case emailNotVerified   // NEW: требуем подтверждения email

    // MARK: Google
    case accountExistsWithDifferentCredential
    case credentialAlreadyInUse
    case invalidCredential
    case popupClosedByUser
    case operationNotAllowed

    case networkError(underlying: Error)
    case unknown

    var id: String { localizedDescription }

    var localizedDescription: String {
        switch self {
        case .emailAlreadyInUse:
            return String(localized: "auth.error.email_in_use")
        case .invalidEmailFormat:
            return String(localized: "auth.error.invalid_email")
        case .userNotFound:
            return String(localized: "auth.error.user_not_found")
        case .wrongPassword:
            return String(localized: "auth.error.wrong_password")
        case .weakPassword:
            return String(localized: "auth.error.weak_password")
        case .userDisabled:
            return String(localized: "auth.error.user_disabled")
        case .tooManyRequests:
            return String(localized: "auth.error.too_many_requests")
        case .emailNotVerified:
            return String(localized: "auth.error.email_not_verified") // NEW

        case .accountExistsWithDifferentCredential:
            return String(localized: "auth.error.account_exists_with_different_credential")
        case .credentialAlreadyInUse:
            return String(localized: "auth.error.credential_already_in_use")
        case .invalidCredential:
            return String(localized: "auth.error.invalid_credential")
        case .popupClosedByUser:
            return String(localized: "auth.error.popup_closed_by_user")
        case .operationNotAllowed:
            return String(localized: "auth.error.operation_not_allowed")

        case .networkError:
            return String(localized: "auth.error.network")
        case .unknown:
            return String(localized: "auth.error.unknown")
        }
    }
}

extension AuthError: LocalizedError {
    var errorDescription: String? { localizedDescription }
}
