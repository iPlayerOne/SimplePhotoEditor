import SwiftUI

struct FilterToolsPanel: View {
    let filters: [Filter]
    @Binding var selectedFilter: Filter?
    @ObservedObject var cache: FilterPreviewCache
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(filters, id: \.id) { filter in
                    let preview = cache.previews[filter.id]
                    
                    ZStack {
                        if let preview = preview {
                            FilterPreviewImage(
                                image: preview,
                                name: filter.name,
                                isSelected: selectedFilter?.id == filter.id
                            )
                            .equatable()
                            .transition(.opacity)
                            .onTapGesture {
                                selectedFilter = filter.filterName.isEmpty ? nil : filter
                            }
                            
                        } else {
                            VStack(spacing: 4) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 48, height: 48)
                                    .shimmer()
                                    .mask(RoundedRectangle(cornerRadius: 8)
                                        .frame(width: 48, height: 48))
                                        .clipped()
                                        .compositingGroup()
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
