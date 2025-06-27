import SwiftUI

struct FilterToolsPanel: View {
    let filters: [Filter]
    @Binding var selectedFilter: Filter?
    @ObservedObject var cache: FilterPreviewCache
    
    // Для хранения времени старта shimmer для каждого фильтра
    @State private var shimmerStartTimes: [UUID: Date] = [:]
    let minShimmerDuration: TimeInterval = 0.5

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(filters, id: \.id) { filter in
                    let preview = cache.previews[filter.id]
                    let now = Date()
                    let shimmerStart = shimmerStartTimes[filter.id] ?? now
                    let shimmerShouldShow: Bool = {
                        if preview == nil {
                            // Если превью ещё нет — запоминаем время старта shimmer
                            if shimmerStartTimes[filter.id] == nil {
                                DispatchQueue.main.async {
                                    shimmerStartTimes[filter.id] = now
                                }
                            }
                            return true
                        } else {
                            // Если превью появилось — проверяем, прошло ли minShimmerDuration
                            let elapsed = now.timeIntervalSince(shimmerStart)
                            return elapsed < minShimmerDuration
                        }
                    }()
                    ZStack {
                        if let preview = preview, !shimmerShouldShow {
                            FilterPreviewImage(
                                image: preview,
                                name: filter.name,
                                isSelected: selectedFilter?.id == filter.id
                            )
                            .equatable()
                            .onTapGesture {
                                selectedFilter = filter.filterName.isEmpty ? nil : filter
                            }
                            .transition(.opacity)
                        } else {
                            // Плейсхолдер с shimmer
                            VStack(spacing: 4) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 48, height: 48)
                                    .shimmer()
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(selectedFilter?.id == filter.id ? .blue : .clear, lineWidth: 2)
                                    )
                                Text(filter.name)
                                    .font(.caption2)
                                    .foregroundColor(selectedFilter?.id == filter.id ? .accentColor : .primary)
                                    .lineLimit(1)
                                    .frame(width: 56)
                            }
                            .onTapGesture {
                                selectedFilter = filter.filterName.isEmpty ? nil : filter
                            }
                            .transition(.opacity)
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .animation(.easeInOut(duration: 0.25), value: cache.previews)
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    let sampleFilters = [
        Filter(name: "Noir", filterName: "CIPhotoEffectNoir"),
        Filter(name: "Chrome", filterName: "CIPhotoEffectChrome"),
        Filter(name: "Fade", filterName: "CIPhotoEffectFade"),
        Filter(name: "Instant", filterName: "CIPhotoEffectInstant"),
        Filter(name: "Process", filterName: "CIPhotoEffectProcess")
    ]
    FilterToolsPanel(
        filters: sampleFilters,
        selectedFilter: .constant(sampleFilters.first),
        cache: FilterPreviewCache()
    )
    .padding()
}
