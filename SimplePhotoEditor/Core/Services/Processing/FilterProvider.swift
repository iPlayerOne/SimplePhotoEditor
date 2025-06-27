import Foundation
import CoreImage


/// Поставщик предустановленных фильтров
protocol FilterProvider {
    /// Возвращает массив поддерживаемых эффектов
    func allFilters() -> [Filter]
}

/// Реализация – статичный список + возможность расширения
final class FilterProviderImpl: FilterProvider {
    /// Базовый набор (можно расширять)
    /// Порядок в массиве – порядок вывода в UI
    private let builtIn: [Filter] = [
        Filter(name: "Нет",          filterName: ""),                       // «Оригинал»
        Filter(name: "Noir",         filterName: "CIPhotoEffectNoir"),
        Filter(name: "Chrome",       filterName: "CIPhotoEffectChrome"),
        Filter(name: "Fade",         filterName: "CIPhotoEffectFade"),
        Filter(name: "Instant",      filterName: "CIPhotoEffectInstant"),
        Filter(name: "Process",      filterName: "CIPhotoEffectProcess"),
        Filter(name: "Mono",         filterName: "CIPhotoEffectMono"),
        Filter(name: "Tonal",        filterName: "CIPhotoEffectTonal"),
        Filter(name: "Transfer",     filterName: "CIPhotoEffectTransfer")
    ]

    /// Дополнительные фильтры можно подкинуть через init
    private let extra: [Filter]

    init(extraFilters: [Filter] = []) {
        self.extra = extraFilters
    }

    func allFilters() -> [Filter] {
        builtIn + extra
    }
}

