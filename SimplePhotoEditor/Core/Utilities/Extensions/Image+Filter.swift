//import SwiftUI
//
//// ---------- iOS 17 и новее ----------
//@available(iOS 17.0, *)
//extension Image {
//    /// Накладывает Core Image-фильтр через новый API SwiftUI 17.
//    @ViewBuilder
//    func applyingFilter(_ name: String?) -> some View {
//        if let n = name, !n.isEmpty {
//            self.coreImageFilter(n)      // работает только на 17 +
//        } else {
//            self                         // без фильтра
//        }
//    }
//}
//
//// ---------- iOS 13–16 ----------
//@available(iOS, introduced: 13.0, obsoleted: 17.0)
//extension Image {
//    /// Для старых версий просто возвращаем исходник.
//    @ViewBuilder
//    func applyingFilter(_ name: String?) -> some View {
//        self
//    }
//}
