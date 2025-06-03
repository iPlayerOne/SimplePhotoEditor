import Foundation
import CoreImage

/// Поставщик списка фильтров для редактора
struct FilterProvider {
    /// Фильтры фото-эффектов (аналог Instagram)의 CIPhotoEffect*
    static var photoEffects: [Filter] {
        // Берём все встроенные CIFilter и оставляем только те, что начинаются с "CIPhotoEffect"
        let rawNames = CIFilter.filterNames(inCategories: nil)
            .filter { $0.hasPrefix("CIPhotoEffect") }

        return rawNames.map { raw in
            // Пытаемся получить читаемое название, иначе конвертим из CamelCase
            let displayName = (CIFilter(name: raw)?
                .attributes[kCIAttributeFilterDisplayName] as? String)
                ?? raw.camelCaseToWords(removing: "CIPhotoEffect")

            return Filter(name: displayName, filterName: raw)
        }
    }
}
