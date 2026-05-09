import SwiftUI
import Combine

@MainActor
final class KeyboardObserver: ObservableObject {
    @Published var height: CGFloat = 0
    private var cancellables = Set<AnyCancellable>()

    init() {
            let willShow = NotificationCenter.default.publisher(
                for: UIResponder.keyboardWillShowNotification
            )
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .map(\.height)

            let willHide = NotificationCenter.default.publisher(
                for: UIResponder.keyboardWillHideNotification
            )
            .map { _ in CGFloat(0) }

            Publishers.Merge(willShow, willHide)
                .receive(on: RunLoop.main)
                .sink { [weak self] height in
                    self?.height = height
                }
                .store(in: &cancellables)
        }
}
