import UIKit
import Combine

final class FilterPreviewCache: ObservableObject {
    @Published private(set) var previews: [UUID: UIImage] = [:]

    func preparePreviews(for image: UIImage?, filters: [Filter]) {
        DispatchQueue.global(qos: .userInitiated).async {
            var newPreviews: [UUID: UIImage] = [:]
            for filter in filters {
                newPreviews[filter.id] = self.apply(filter.filterName, to: image)
            }
            DispatchQueue.main.async {
                self.previews = newPreviews
            }
        }
    }

    private func apply(_ filterName: String, to image: UIImage?) -> UIImage? {
        guard let image = image else { return nil }
        if filterName.isEmpty { return image }
        guard let ciImage = CIImage(image: image), let filter = CIFilter(name: filterName) else { return image }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        let context = CIContext()
        if let outputCIImage = filter.outputImage,
           let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) {
            return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
        } else {
            return image
        }
    }
} 