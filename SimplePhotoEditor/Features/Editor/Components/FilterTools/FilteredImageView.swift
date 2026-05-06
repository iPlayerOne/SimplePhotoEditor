//import UIKit
//import SwiftUI
//
//struct FilteredImageView: UIViewRepresentable {
//    let baseImage: UIImage
//    let filterName: String
//    
//    func makeUIView(context: Context) -> UIImageView {
//        let iv = UIImageView()
//        iv.contentMode = .scaleAspectFill
//        iv.clipsToBounds = true
//        return iv
//    }
//    
//    func makeCoordinator() -> Coordinator { Coordinator() }
//    
//    func updateUIView(_ uiView: UIImageView, context: Context) {
//        context.coordinator.task?.cancel()
//        
//        let input = baseImage
//        let name  = filterName
//        
//        context.coordinator.task = Task {
//            let output = await Self.renderFiltered(baseImage: input, filterName: name)
//            guard !Task.isCancelled else { return }
//            await MainActor.run { uiView.image = output }
//        }
//    }
//    
//    final class Coordinator {
//        var task: Task<Void, Never>?
//        deinit { task?.cancel() }
//    }
//    
//    private static func renderFiltered(baseImage: UIImage, filterName: String) async -> UIImage {
//        if filterName.isEmpty { return baseImage }
//        
//        return await Task.detached(priority: .userInitiated) { () -> UIImage in
//            autoreleasepool {
//                guard let ci0 = CIImage(image: baseImage, options: [.applyOrientationProperty: true]) else {
//                    return baseImage
//                }
//                let originalExtent = ci0.extent.integral
//                
//                let clamped = ci0.clampedToExtent()
//                
//                let outCI: CIImage = {
//                    guard let fx = CIFilter(name: filterName) else { return ci0 }
//                    fx.setValue(clamped, forKey: kCIInputImageKey)
//                    return fx.outputImage ?? ci0
//                }()
//                
//                let cropped = outCI.cropped(to: originalExtent)
//                
//                let ctx = CIContextPool.preview
//                guard let cg = ctx.createCGImage(cropped, from: originalExtent) else {
//                    return baseImage
//                }
//                return UIImage(cgImage: cg, scale: baseImage.scale, orientation: .up)
//            }
//        }.value
//    }
//}
