import FirebaseAuth
import Combine

protocol AuthService {
  func signIn(email: String, password: String) async throws -> User
  func register(email: String, password: String) async throws -> User
  func resetPassword(email: String) async throws
  func signOut() throws
  func signInWithGoogle(idToken: String, accessToken: String) async throws -> User
  var authStatePublisher: AnyPublisher<User?, Never> { get }
}

final class FirebaseAuthService: AuthService {
    private let subject: CurrentValueSubject<User?, Never>
    var authStatePublisher: AnyPublisher<User?, Never> {
        subject.eraseToAnyPublisher()
    }

    private var authStateHandle: AuthStateDidChangeListenerHandle?

    init() {
        let initialUser: User? = {
            guard let fbUser = Auth.auth().currentUser,
                  let mail   = fbUser.email
            else { return nil }
            return User(uid: fbUser.uid, email: mail)
        }()

        subject = CurrentValueSubject<User?, Never>(initialUser)

        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, fbUser in
            let updated: User? = {
                guard let u = fbUser, let mail = u.email else { return nil }
                return User(uid: u.uid, email: mail)
            }()
            self?.subject.send(updated)
        }
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func signIn(email: String, password: String) async throws -> User {
        do {
            let result = try await Auth.auth().signIn(
                withEmail: email,
                password: password
            )
            guard let mail = result.user.email else {
                throw AuthError.unknown
            }
            return User(uid: result.user.uid, email: mail)
        } catch {
            let ns = error as NSError
            if let code = AuthErrorCode(rawValue: ns.code) {
                switch code {
                case .wrongPassword:
                    throw AuthError.wrongPassword
                case .userNotFound:
                    throw AuthError.userNotFound
                case .networkError:
                    throw AuthError.networkError(underlying: ns)
                default:
                    throw AuthError.networkError(underlying: ns)
                }
            }
            throw AuthError.networkError(underlying: ns)
        }
    }

    func register(email: String, password: String) async throws -> User {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            try await result.user.sendEmailVerification()
            guard let mail = result.user.email else {
                throw AuthError.unknown
            }
            return User(uid: result.user.uid, email: mail)
        } catch {
            let ns = error as NSError
            if let code = AuthErrorCode(rawValue: ns.code) {
                switch code {
                case .emailAlreadyInUse:
                    throw AuthError.emailAlreadyInUse
                case .invalidEmail:
                    throw AuthError.invalidEmailFormat
                case .weakPassword:
                    throw AuthError.weakPassword
                case .operationNotAllowed:
                    throw AuthError.operationNotAllowed
                default:
                    throw AuthError.networkError(underlying: ns)
                }
            }
            throw AuthError.networkError(underlying: ns)
        }
    }

    func resetPassword(email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            let ns = error as NSError
            if let code = AuthErrorCode(rawValue: ns.code) {
                switch code {
                case .invalidEmail:
                    throw AuthError.invalidEmailFormat
                case .userNotFound:
                    // Не раскрываем существование аккаунта — ведём себя как успех
                    return
                case .tooManyRequests:
                    throw AuthError.tooManyRequests
                case .networkError:
                    throw AuthError.networkError(underlying: ns)
                default:
                    throw AuthError.networkError(underlying: ns)
                }
            }
            throw AuthError.networkError(underlying: ns)
        }
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func signInWithGoogle(idToken: String, accessToken: String) async throws -> User {
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: accessToken
        )
        let result = try await Auth.auth().signIn(with: credential)
        guard let mail = result.user.email else {
            throw AuthError.unknown
        }
        return User(uid: result.user.uid, email: mail)
    }
}
