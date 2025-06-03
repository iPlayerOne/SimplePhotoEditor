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
            return "Этот email уже зарегистрирован."
        case .invalidEmailFormat:
            return "Неверный формат email."
        case .userNotFound:
            return "Пользователь не найден."
        case .wrongPassword:
            return "Неверный пароль."
        case .weakPassword:
            return "Пароль слишком простой (минимум 6 символов)."
        case .userDisabled:
            return "Аккаунт отключён. Обратитесь в поддержку."
        case .tooManyRequests:
            return "Слишком много попыток. Попробуйте позже."
                
        case .accountExistsWithDifferentCredential:
            return "Этот email привязан к другому провайдеру."
        case .credentialAlreadyInUse:
            return "Учётные данные уже используются другим аккаунтом."
        case .invalidCredential:
            return "Неверные или устаревшие учётные данные."
        case .popupClosedByUser:
            return "Вход отменён пользователем."
        case .operationNotAllowed:
            return "Вход через Google отключён администратором."


        case .networkError:
            return "Проблемы с сетью. Проверьте подключение."
        case .unknown:
            return "Произошла неизвестная ошибка. Попробуйте снова."
        }
    }
}

extension AuthError: LocalizedError {
    var errorDescription: String? { localizedDescription }
}
