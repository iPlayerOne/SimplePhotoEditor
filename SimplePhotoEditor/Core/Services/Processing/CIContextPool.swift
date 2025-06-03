import CoreImage

enum CIContextPool {
    static let shared: CIContext = {
        let opts: [CIContextOption: Any] = [.priorityRequestLow: true]
        return CIContext(options: opts)
    }()
}
