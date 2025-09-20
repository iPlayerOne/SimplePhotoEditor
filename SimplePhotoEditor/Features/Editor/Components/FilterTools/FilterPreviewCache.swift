import UIKit
import Combine

final class FilterPreviewCache: ObservableObject {
    @Published private(set) var previews: [UUID: UIImage] = [:]
    
    private var generation = UUID()
    private var worker: Task<Void, Never>?
    
    private let previewMaxSide: CGFloat = 180
    
    func preparePreviews(for image: UIImage?, filters: [Filter]) {
        worker?.cancel()
        
        let gen = UUID()
        generation = gen
        
        guard let image = image else { return }
        
        let jobs = filters.map { (id: $0.id, name: $0.filterName) }
        let src = image
        
        let maxSide = max(src.size.width, src.size.height)
        let scale: CGFloat = maxSide > previewMaxSide ? (previewMaxSide / maxSide ) : 1
        
        worker = Task.detached(priority: .userInitiated) { [gen, jobs, src, scale] in
            print("🧩 Prepare start gen=\(gen) jobs=\(jobs.count) ")
            var out: [UUID: UIImage] = [:]
            
            for (id, name) in jobs {
                if Task.isCancelled { return }
                if let ui = Self.apply(name, to: src, scale: scale) {
                    out[id] = ui
                }
            }
            
            let result = out
            
            await MainActor.run { [weak self] in
                guard let self,gen == self.generation else { return }
                print("✅ Prepare done gen=\(gen) count=\(result.count)")
                self.previews = result
            }
        }
    }
    
    private static func apply(_ filterName: String, to image: UIImage, scale: CGFloat) -> UIImage? {
        guard var ci = CIImage(image: image) else { return image }
        ci = CIHelpers.lanczosScaled(ci, scale: scale)
        
        if !filterName.isEmpty, let fx = CIFilter(name: filterName) {
            fx.setValue(ci, forKey: kCIInputImageKey)
            ci = fx.outputImage ?? ci
        }
        
        ci = ci.snappedForDisplay()
        guard let cg = CIContextPool.shared.createCGImage(ci, from: ci.extent) else {
            return image
        }
        return UIImage(cgImage: cg, scale: image.scale, orientation: image.imageOrientation)
    }
}
