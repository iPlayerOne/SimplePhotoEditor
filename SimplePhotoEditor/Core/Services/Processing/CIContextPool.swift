import CoreImage

enum CIContextPool {
    static let final: CIContext = {
        let opts: [CIContextOption: Any] = [.priorityRequestLow: false]
        return CIContext(options: opts)
    }()
    
    static let preview: CIContext = {
        let opts: [CIContextOption: Any] = [.priorityRequestLow: true, .cacheIntermediates: false]
        return CIContext(options: opts)
    }()
    
    static func clearFinalCaches() {
        final.clearCaches()
    }
    
    static func clearPreviewCaches() {
        preview.clearCaches()
    }
}
