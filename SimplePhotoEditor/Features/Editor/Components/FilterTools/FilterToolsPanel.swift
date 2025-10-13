import SwiftUI
import UIKit

struct FilterToolsPanel: View {
    let filters: [Filter]
    @Binding var selectedFilter: Filter?
    @ObservedObject var cache: FilterPreviewCache
    let panelHeight: CGFloat

    // Параметры верстки внутри панели
    private let verticalPadding: CGFloat = 8      // как в .padding(.vertical, 8)
    private let imageToTextSpacing: CGFloat = 6   // как во VStack(spacing: 6)

    // Динамический размер превью с учётом высоты панели и подписи
    private var previewSize: CGFloat {
        let contentHeight = panelHeight - verticalPadding * 2
        let captionLineHeight = UIFont.preferredFont(forTextStyle: .caption2).lineHeight
        // Оставляем место под текст и межстрочный отступ
        let size = contentHeight - imageToTextSpacing - captionLineHeight
        // Минимальный разумный размер, чтобы не схлопывалось на маленьких высотах
        return max(28, size.rounded(.down))
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(filters, id: \.id) { filter in
                    let preview = cache.previews[filter.id]
                    FilterPreviewImage(
                        image: preview,
                        name: filter.name,
                        isSelected: selectedFilter?.id == filter.id,
                        size: previewSize
                    )
                    .onTapGesture {
                        selectedFilter = filter.filterName.isEmpty ? nil : filter
                    }
                }
            }
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, 12) // внутренние поля контента
        }
        // На iOS 17+ можно так:
        // .contentMargins(.horizontal, 12, for: .scrollContent)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    let sampleFilters = [
        Filter(name: "Noir",    filterName: "CIPhotoEffectNoir"),
        Filter(name: "Chrome",  filterName: "CIPhotoEffectChrome"),
        Filter(name: "Fade",    filterName: "CIPhotoEffectFade"),
        Filter(name: "Instant", filterName: "CIPhotoEffectInstant"),
        Filter(name: "Process", filterName: "CIPhotoEffectProcess")
    ]
    FilterToolsPanel(
        filters: sampleFilters,
        selectedFilter: .constant(sampleFilters.first),
        cache: FilterPreviewCache(),
        panelHeight: 68
    )
    .padding()
}
