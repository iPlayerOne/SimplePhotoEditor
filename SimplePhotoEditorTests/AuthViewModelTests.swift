import Combine
import XCTest
@testable import SimplePhotoEditor

@MainActor
final class AuthViewModelTests: XCTestCase {

    func testEmailValidatorAcceptsValidEmail() {
        XCTAssertTrue(EmailValidator.isValid("user@example.com"))
        XCTAssertTrue(EmailValidator.isValid(" USER.NAME+tag@example.co "))
    }

    func testEmailValidatorRejectsInvalidEmail() {
        XCTAssertFalse(EmailValidator.isValid(""))
        XCTAssertFalse(EmailValidator.isValid("plain-address"))
        XCTAssertFalse(EmailValidator.isValid("user@example"))
        XCTAssertFalse(EmailValidator.isValid("user@.com"))
    }

    func testRegistrationRequiresValidEmailAndMatchingPassword() {
        let viewModel = RegistrationViewModel(authService: AuthServiceMock())

        viewModel.email = "wrong"
        viewModel.password = "123456"
        viewModel.confirmPassword = "123456"
        XCTAssertFalse(viewModel.canRegister)

        viewModel.email = "user@example.com"
        viewModel.confirmPassword = "654321"
        XCTAssertFalse(viewModel.canRegister)

        viewModel.confirmPassword = "123456"
        XCTAssertTrue(viewModel.canRegister)
    }

    func testRegistrationTrimsEmailBeforeSubmitting() async {
        let authService = AuthServiceMock()
        let viewModel = RegistrationViewModel(authService: authService)

        viewModel.email = " user@example.com "
        viewModel.password = "123456"
        viewModel.confirmPassword = "123456"

        await viewModel.register()

        XCTAssertEqual(authService.registeredEmail, "user@example.com")
        XCTAssertEqual(authService.registeredPassword, "123456")
        XCTAssertTrue(viewModel.didRegister)
        XCTAssertNil(viewModel.error)
    }

    func testLoginRequiresValidEmailAndPassword() {
        let viewModel = LoginViewModel(
            authService: AuthServiceMock(),
            googleCoordinator: GoogleSignInCoordinatorMock()
        )

        viewModel.email = "user@example.com"
        viewModel.password = "12345"
        XCTAssertFalse(viewModel.canSignIn)

        viewModel.password = "123456"
        XCTAssertTrue(viewModel.canSignIn)
    }

    func testLoginTrimsEmailBeforeSubmitting() async {
        let authService = AuthServiceMock()
        let viewModel = LoginViewModel(
            authService: authService,
            googleCoordinator: GoogleSignInCoordinatorMock()
        )

        viewModel.email = " user@example.com "
        viewModel.password = "123456"

        await viewModel.login()

        XCTAssertEqual(authService.signedInEmail, "user@example.com")
        XCTAssertEqual(authService.signedInPassword, "123456")
        XCTAssertNil(viewModel.error)
    }

    func testResetPasswordValidatesEmailBeforeSubmitting() async {
        let authService = AuthServiceMock()
        let viewModel = ResetPasswordViewModel(authService: authService)

        viewModel.email = "wrong"
        await viewModel.resetPassword()

        XCTAssertNil(authService.resetEmail)
        XCTAssertNotNil(viewModel.emailValidationMessage)
        XCTAssertFalse(viewModel.didSend)
    }

    func testResetPasswordTrimsEmailBeforeSubmitting() async {
        let authService = AuthServiceMock()
        let viewModel = ResetPasswordViewModel(authService: authService)

        viewModel.email = " user@example.com "
        await viewModel.resetPassword()

        XCTAssertEqual(authService.resetEmail, "user@example.com")
        XCTAssertTrue(viewModel.didSend)
        XCTAssertNil(viewModel.error)
    }
}

private final class AuthServiceMock: AuthService {
    private let subject = CurrentValueSubject<User?, Never>(nil)

    var authStatePublisher: AnyPublisher<User?, Never> {
        subject.eraseToAnyPublisher()
    }

    var signedInEmail: String?
    var signedInPassword: String?
    var registeredEmail: String?
    var registeredPassword: String?
    var resetEmail: String?

    func signIn(email: String, password: String) async throws -> User {
        signedInEmail = email
        signedInPassword = password
        return User(uid: "test-user", email: email)
    }

    func register(email: String, password: String) async throws -> User {
        registeredEmail = email
        registeredPassword = password
        return User(uid: "test-user", email: email)
    }

    func resetPassword(email: String) async throws {
        resetEmail = email
    }

    func signOut() throws {
        subject.send(nil)
    }

    func signInWithGoogle(idToken: String, accessToken: String) async throws -> User {
        User(uid: "google-user", email: "google@example.com")
    }
}

private struct GoogleSignInCoordinatorMock: GoogleSignInCoordinator {
    func signIn() async throws -> (idToken: String, accessToken: String) {
        ("id-token", "access-token")
    }
}
