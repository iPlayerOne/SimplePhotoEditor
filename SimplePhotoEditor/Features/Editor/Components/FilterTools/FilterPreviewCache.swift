import UIKit
import Combine

final class FilterPreviewCache: ObservableObject {
    @Published private(set) var previews: [UUID: UIImage] = [:]

    private let decode: ImageDecodeService
    private let filter: FilterService

    private var generation = UUID()
    private var worker: Task<Void, Never>?

    private let previewMaxSide: CGFloat = 180
    private let previewScale: CGFloat

    init(
        decode: ImageDecodeService = ImageDecodeServiceImpl(),
        filter: FilterService = FilterServiceImpl(),
        previewScale: CGFloat = UIScreen.main.scale
    ) {
        self.decode = decode
        self.filter = filter
        self.previewScale = previewScale
    }

    func preparePreviews(for data: Data?, filters: [Filter]) {
        worker?.cancel()

        let gen = UUID()
        generation = gen

        guard let data else {
            previews = [:]
            return
        }

        let jobs = filters.map { (id: $0.id, name: $0.filterName) }

        worker = Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else { return }

            var accumulator: [UUID: UIImage] = [:]

            for (id, name) in jobs {
                if Task.isCancelled { return }

                autoreleasepool {
                    if let img = self.makePreview(from: data, filterName: name) {
                        accumulator[id] = img
                    }
                }
            }
            
            let result = accumulator

            await MainActor.run { [weak self, result] in
                guard let self, gen == self.generation else { return }
                self.previews = result
            }
        }
    }

    func clear() {
        worker?.cancel()
        previews = [:]
    }

    private func makePreview(from data: Data, filterName: String) -> UIImage? {
        guard let thumb = decode.downsample(data, maxDimension: previewMaxSide, previewScale) else {
            return nil
        }
        
        print("thumb:", Int(thumb.size.width), "x", Int(thumb.size.height),
                  "scale:", thumb.scale,
                  "px:", Int(thumb.size.width * thumb.scale), "x", Int(thumb.size.height * thumb.scale))

        guard !filterName.isEmpty else {
            return thumb
        }

        guard
            let thumbData = thumb.jpegData(compressionQuality: 0.9),
            let filteredData = try? filter.apply(filterName: filterName, to: thumbData, downscaleFactor: 1.0),
            let filtered = UIImage(data: filteredData)
        else {
            return thumb
        }

        return filtered
    }
}
