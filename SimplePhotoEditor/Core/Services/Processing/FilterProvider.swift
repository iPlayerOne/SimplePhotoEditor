import Foundation
import CoreImage

protocol FilterProvider {
    func allFilters() -> [Filter]
}

final class FilterProviderImpl: FilterProvider {

    private let builtIn: [Filter] = [
        Filter(name: "Нет",          filterName: ""),
        Filter(name: "Noir",         filterName: "CIPhotoEffectNoir"),
        Filter(name: "Chrome",       filterName: "CIPhotoEffectChrome"),
        Filter(name: "Fade",         filterName: "CIPhotoEffectFade"),
        Filter(name: "Instant",      filterName: "CIPhotoEffectInstant"),
        Filter(name: "Process",      filterName: "CIPhotoEffectProcess"),
        Filter(name: "Mono",         filterName: "CIPhotoEffectMono"),
        Filter(name: "Tonal",        filterName: "CIPhotoEffectTonal"),
        Filter(name: "Transfer",     filterName: "CIPhotoEffectTransfer")
    ]

    
    private let extra: [Filter]

    init(extraFilters: [Filter] = []) {
        self.extra = extraFilters
    }

    func allFilters() -> [Filter] {
        builtIn + extra
    }
}

