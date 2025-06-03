import SwiftUI

struct FilterToolsPanel: View {
    let filters: [Filter]
    @Binding var selectedFilter: Filter?

    @State private var maxFilterWidth: CGFloat = 0

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(filters) { filter in
                    let title = filter.name
                        .replacingOccurrences(of: "Photo Effect ", with: "")

                    Button {
                        selectedFilter = filter
                    } label: {
                        Text(title)
                            .font(.caption)
                            .fixedSize()
                            .foregroundColor(
                                selectedFilter?.filterName == filter.filterName
                                    ? .accentColor
                                    : .primary
                            )
                            .padding(.vertical, 8)
                            .background {
                                GeometryReader { geo in
                                    Color.clear
                                        .preference(
                                            key: FilterWidthKey.self,
                                            value: geo.size.width
                                        )
                                        
                                }
                            }
                    }
                    .frame(width: maxFilterWidth )
                    .buttonStyle(.plain)
                    .underline(
                        selected: selectedFilter?.filterName == filter.filterName,
                        color: .accentColor,
                        widthFraction: 1,
                        height: 2
                    )
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
        .onPreferenceChange(FilterWidthKey.self) { newValue in
            maxFilterWidth = newValue
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
        selectedFilter: .constant(sampleFilters.first)
    )
    .padding()
}
