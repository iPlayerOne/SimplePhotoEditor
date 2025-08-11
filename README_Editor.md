# SimplePhotoEditor — Редактор изображений

## Описание
Данный документ описывает структуру, основные компоненты и flow, связанные с редактором изображений в приложении SimplePhotoEditor. Также приведён обзор ключевых файлов ядра (Core) и приложения (App), необходимых для работы всех фич.

---

## Структура проекта (релевантная часть)

```
SimplePhotoEditor/
├── App/
│   ├── AppDelegate.swift
│   ├── AppConfig.swift
│   ├── DependencyContainer.swift
│   └── SimplePhotoEditorApp.swift
├── Core/
│   ├── Models/
│   │   ├── Photo.swift
│   │   ├── Filter.swift
│   │   ├── Stroke.swift
│   │   ├── TextItem.swift
│   │   └── ...
│   ├── Services/
│   │   ├── Processing/
│   │   ├── Camera/
│   │   ├── Export/
│   │   └── ...
├── Features/
│   └── Editor/
│       ├── Components/
│       ├── Models/
│       ├── ViewModels/
│       ├── EditorView.swift
│       └── ...
├── Navigation/
│   └── RootView.swift
├── Info.plist
└── GoogleService-Info.plist
```

---

## Flow работы редактора

1. Пользователь выбирает или делает фото (через `CameraPicker` или `ImageSourcePicker`)
2. Открывается редактор (`EditorView`)
3. Доступны инструменты:
    - Рисование (PencilKit)
    - Добавление и редактирование текста
    - Применение фильтров и трансформаций
    - Экспорт и сохранение результата
4. Все изменения применяются к модели фото и отображаются в preview

---

## Ключевые файлы

### App/
- **AppDelegate.swift** — делегат приложения, инициализация сервисов (Firebase, GoogleSignIn)
- **AppConfig.swift** — конфигурация приложения
- **DependencyContainer.swift** — DI-контейнер, собирает зависимости для фич
- **SimplePhotoEditorApp.swift** — точка входа, инициализация сессии и зависимостей
- **Info.plist** — настройки приложения

### Core/Models/
- **Photo.swift** — модель фотографии
- **Filter.swift** — модель фильтра
- **Stroke.swift** — модель линии для рисования
- **TextItem.swift** — модель текстового слоя
- ... (другие модели, если используются в редакторе)

### Core/Services/Processing/
- **DrawService.swift** — сервис для рисования
- **FilterService.swift** — сервис для применения фильтров
- **ImageComposeService.swift** — сервис для компоновки изображений
- **PhotoProcessingService.swift** — основной сервис обработки фото
- ... (другие сервисы обработки)

### Core/Services/Camera/
- **CameraService.swift** — сервис работы с камерой

### Core/Services/Export/
- **ExportService.swift** — сервис экспорта изображений

### Features/Editor/
- **Components/** — UI-компоненты редактора (Preview, Tools, Tab и др.)
- **Models/** — модели, специфичные для редактора
- **ViewModels/** — view model'и для редактора и текстовых слоёв
- **EditorView.swift** — основной экран редактора
- **CameraPicker.swift** — выбор камеры
- **ImageSourcePicker.swift** — выбор источника изображения
- ... (другие файлы редактора)

### Navigation/
- **RootView.swift** — корневой view приложения, переключает между auth/editor flows

---

## Пример сценария

- Пользователь выбирает фото или делает снимок
- Переходит в редактор
- Рисует, добавляет текст, применяет фильтры
- Сохраняет или экспортирует результат

---

## Требования
- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+
- PencilKit, CoreImage

---

## Исходный код файлов App

### AppDelegate.swift
```swift
import UIKit
import FirebaseCore
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    // добавили этот метод
    func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Если вы хотите инициализировать Firebase здесь, то не забудьте вызвать configure()
        // FirebaseApp.configure()
        return true
    }

    func application(
      _ app: UIApplication,
      open url: URL,
      options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        GIDSignIn.sharedInstance.handle(url)
    }
}
```

### AppConfig.swift
```swift
import FirebaseCore

enum AppConfig {
    static func setupFirebase() {
        FirebaseApp.configure()
    }

    static var googleClientID: String {
        guard let id = FirebaseApp.app()?.options.clientID else {
            preconditionFailure("GoogleClientID не настроен в GoogleService‑Info.plist")
        }
        return id
    }
}
```

### DependencyContainer.swift
```swift
// AppDependencyContainer.swift
import Foundation

@MainActor
final class AppDependencyContainer {
    private let authService: AuthService

    init(authService: AuthService = FirebaseAuthService()) {
        self.authService = authService
    }

    func makeGoogleSignInCoordinator() -> GoogleSignInCoordinator {
        GoogleSignInCoordinatorImpl(clientID: AppConfig.googleClientID)
    }

    func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(
            authService: authService,
            googleCoordinator: makeGoogleSignInCoordinator()
        )
    }

    func makeRegistrationViewModel() -> RegistrationViewModel {
        RegistrationViewModel(authService: authService)
    }

    func makeResetPasswordViewModel() -> ResetPasswordViewModel {
        ResetPasswordViewModel(authService: authService)
    }

    func makeEditorViewModel() -> EditorViewModel {
        let transformService      = TransformServiceImpl()
        let filterService         = FilterServiceImpl()
        let overlayService        = OverlayRenderServiceImpl()
        let imageDecodeService    = ImageDecodeServiceImpl()
        let previewService        = PreviewRenderServiceImpl()
        let exportService         = ExportServiceImpl()

        return EditorViewModel(
            transformService:   transformService,
            filterService:      filterService,
            exportService:      exportService,
            overlayService:     overlayService,
            previewService:     previewService
        )
    }
}
```

### SimplePhotoEditorApp.swift
```swift
// App/SimplePhotoEditorApp.swift

import SwiftUI
import FirebaseCore

@main
struct SimplePhotoEditorApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var session: SessionStore
    private let container: AppDependencyContainer

    init() {
        // --- ОБЯЗАТЕЛЬНО первым делом на старте ---
        FirebaseApp.configure()

        // Создаём единый инстанс AuthService
        let authService = FirebaseAuthService()
        // Передаём его и в SessionStore, и в DI-контейнер
        let sessionStore = SessionStore(authService: authService)
        _session = StateObject(wrappedValue: sessionStore)
        container = AppDependencyContainer(authService: authService)
    }

    var body: some Scene {
        WindowGroup {
            RootView(
                container: container,
                onLogout:  { session.logout() }
            )
            .environmentObject(session)
        }
    }
}
```

### Info.plist
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>

    <key>NSCameraUsageDescription</key>
    <string>Нужен доступ к камере, чтобы делать снимки</string>
    <key>NSPhotoLibraryAddUsageDescription</key>
    <string>Приложение сохраняет отредактированные фото в вашу фотоплёнку.</string>
    <key>NSPhotoLibraryUsageDescription</key>
    <string>Приложение использует фотогалерею, чтобы вы могли выбрать изображение для редактирования.</string>

    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLName</key>
            <string>GoogleSignIn</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>com.googleusercontent.apps.410428643138-pm5fh2l966m0mnl21145cpnqcjb7gtac</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
```

---

## Исходный код Core/Models

### Photo.swift
```swift
import Foundation

struct Photo: Identifiable {
    let id: UUID = UUID()
    let imageData: Data
    let creationDate: Date
}
```

### Filter.swift
```swift
import Foundation

struct Filter: Identifiable, Equatable {
    let id: UUID
    let name: String
    let filterName: String

    static var none: Filter {
        Filter(id: UUID(), name: "Нет", filterName: "")
    }
    var isNone: Bool { filterName.isEmpty }

    init(id: UUID = UUID(), name: String, filterName: String) {
        self.id = id
        self.name = name
        self.filterName = filterName
    }
}
```

### Stroke.swift
```swift
import SwiftUI

struct Stroke: Identifiable {
    let id: UUID = UUID()
    var points: [CGPoint]
    let lineWidth: CGFloat
    let color: Color
}
```

### TextItem.swift
```swift
import SwiftUI

struct TextItem: Identifiable {
    let id = UUID()

    var text:      String
    var fontName:  String
    var fontSize:  CGFloat
    var color:     Color
    var position:  CGPoint
    var parkedPosition: CGPoint?

    var isEditing  = false
}
```

### ShareItem.swift
```swift
import UniformTypeIdentifiers
import SwiftUI

struct ShareItem: Identifiable, Equatable {
    let id: UUID = UUID()
    let image: UIImage
    static func == (lhs: ShareItem, rhs: ShareItem) -> Bool {
        lhs.id == rhs.id
    }
}
```

### User.swift
```swift
struct User {
    let uid: String
    let email: String
}
```

---

## Исходный код Core/Services/Processing

### OverlayRenderService.swift
```swift
import UIKit
import PencilKit
import UniformTypeIdentifiers
import ImageIO

protocol OverlayRenderService {
    func apply(drawing: PKDrawing?, text: [TextItem]?, to data: Data) throws -> Data
}

enum OverlayRenderError: Error {
    case invalidBase
    case encodeFailed
}

final class OverlayRenderServiceImpl: OverlayRenderService {
    
    func apply(drawing: PKDrawing?, text: [TextItem]?, to data: Data) throws -> Data {
        guard let base = UIImage(data: data) else {
            throw OverlayRenderError.invalidBase
        }
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = base.scale
        format.opaque = true
        
        let size = base.size
        let rect = CGRect(origin: .zero, size: size)
        
        let rendered = UIGraphicsImageRenderer(size: size, format: format).image { _ in
            base.draw(in: rect)
            
            if let drawing = drawing {
                let overlay = drawing.image(from: rect, scale: base.scale)
                overlay.draw(in: rect)
            }
            
            if let items = text {
                for item in items {
                    let attrs: [NSAttributedString.Key: Any] = [
                        .font : UIFont(name: item.fontName, size: item.fontSize)
                        ?? .systemFont(ofSize: item.fontSize),
                        .foregroundColor: item.color.uiColor
                    ]
                    
//                    let ns = NSString(string: item.text)
//                    let ts = ns.size(withAttributes: attrs)
//                    let origin = CGPoint(x: item.position.x - ts.width / 2,
//                                         y: item.position.y - ts.height / 2)
//                    ns.draw(at: origin, withAttributes: attrs)
                    
                    (item.text as NSString).draw(
                        at: CGPoint(x: item.position.x, y: item.position.y),
                        withAttributes: attrs
                    )
                }
            }
        }
        
        guard let mergedCG = rendered.cgImage else {
            throw OverlayRenderError.encodeFailed
        }
        
        let out = NSMutableData()
        guard let dst = CGImageDestinationCreateWithData(
            out,
            UTType.jpeg.identifier as CFString,
            1,
            nil
        ) else {
            throw OverlayRenderError.encodeFailed
        }
        let opts = [kCGImageDestinationLossyCompressionQuality: 0.9] as CFDictionary
        CGImageDestinationAddImage(dst, mergedCG, opts)
        CGImageDestinationFinalize(dst)
        return out as Data
    }
}
```

### ImagePipeline.swift
```swift
import UIKit
import PencilKit

protocol ImagePipeline {
    func makePreview(from data: Data, filterName: String?, downscaleFactor: CGFloat) -> UIImage?
    func makeFinalImage(
        from data: Data,
        filterName: String?,
        rotation: Int,
        isFlipped: Bool,
        drawing: PKDrawing?,
        texts: [TextItem]?) throws -> Data
}

final class ImagePipelineImpl: ImagePipeline {
    private let decode: ImageDecodeService
    private let transform: TransformService
    private let filter: FilterService
    private let overlay: OverlayRenderService
    
    init(decode: ImageDecodeService, transform: TransformService, filter: FilterService, overlay: OverlayRenderService) {
        self.decode = decode
        self.transform = transform
        self.filter = filter
        self.overlay = overlay
    }
    
    func makePreview(from data: Data, filterName: String?, downscaleFactor: CGFloat) -> UIImage? {
        guard let preview = decode.downsample(data, maxDimension: 600, UIScreen.main.scale) else {
            return nil
        }
        
        guard let name = filterName, !name.isEmpty else {
            return preview
        }
        guard let jpeg = preview.jpegData(compressionQuality: 0.9),
              let filteredData = try? filter.apply(filterName: name, to: jpeg, downscaleFactor: downscaleFactor),
        let filteredPreview = UIImage(data: filteredData) else {
            return preview
        }
        
        return filteredPreview
            
    }
    
    func makeFinalImage(from data: Data, filterName: String?, rotation: Int, isFlipped: Bool, drawing: PKDrawing?, texts: [TextItem]?) throws -> Data {
        var data = data
        if let name = filterName, !name.isEmpty {
            data = try filter.apply(filterName: name, to: data, downscaleFactor: 1.0)
        }
        if rotation != 0 {
            data = try transform.rotate90(data: data, times: rotation)
        }
        if isFlipped {
            data = try transform.flipHorizontal(data: data)
        }
        return data
    }
}
```

### FilterService.swift
```swift
import UIKit
import CoreImage

protocol FilterService {
    func apply(filterName: String, to data: Data, downscaleFactor: CGFloat) throws -> Data
}

enum FilterError: Error { case invalidData, renderFailed }

final class FilterServiceImpl: FilterService {

    func apply(filterName: String, to data: Data, downscaleFactor: CGFloat = 1.0) throws -> Data {

        guard var ci = CIImage(data: data) else { throw FilterError.invalidData }

        if downscaleFactor < 0.999,
           let lanczos = CIFilter(name: "CILanczosScaleTransform") {
            lanczos.setValue(ci,                forKey: kCIInputImageKey)
            lanczos.setValue(downscaleFactor,   forKey: kCIInputScaleKey)
            lanczos.setValue(1.0,               forKey: kCIInputAspectRatioKey)
            ci = lanczos.outputImage ?? ci
        }

        if !filterName.isEmpty,
           let fx = CIFilter(name: filterName) {
            fx.setValue(ci, forKey: kCIInputImageKey)
            ci = fx.outputImage ?? ci
        }

        
        guard let cg = CIContextPool.shared.createCGImage(ci, from: ci.extent)
        else { throw FilterError.renderFailed }
        
        guard let jpeg = UIImage(cgImage: cg).jpegData(compressionQuality: 0.9) else {
            throw FilterError.renderFailed
        }
        return jpeg
    }
}
```

### FilterProvider.swift
```swift
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
```

### PreviewRenderService.swift
```swift
import UIKit
import CoreImage

protocol PreviewRenderService {
  func renderPreview(
    data:            Data,
    filterName:      String?,
    downscaleFactor: Double
  ) throws -> UIImage
}

final class PreviewRenderServiceImpl: PreviewRenderService {
  private let ctx = CIContext(options: [.cacheIntermediates: false])
  private let queue = DispatchQueue(
    label: "SimplePhotoEditor.Preview",
    qos:   .userInitiated
  )

  func renderPreview(
    data: Data,
    filterName: String?,
    downscaleFactor: Double
  ) throws -> UIImage {
    return try queue.sync {
      print("🖼️ [Preview] renderPreview begin: bytes=\(data.count), filter=\(filterName ?? "nil"), scale=\(downscaleFactor)")

      guard var ci = CIImage(data: data, options: [.applyOrientationProperty: true]) else {
        print("❌ [Preview] CIImage(data:) failed")
        throw NSError(domain: "PreviewRender", code: -10)
      }
      print("🖼️ [Preview] input extent: \(ci.extent)")

      if let name = filterName, !name.isEmpty, let fx = CIFilter(name: name) {
        fx.setValue(ci, forKey: kCIInputImageKey)
        if let out = fx.outputImage {
          ci = out
          print("🖼️ [Preview] filter \(name) applied, extent: \(ci.extent)")
        } else {
          print("⚠️ [Preview] filter \(name) produced nil output — skipping")
        }
      }

      if downscaleFactor < 0.999, let lanczos = CIFilter(name: "CILanczosScaleTransform") {
        lanczos.setValue(ci,              forKey: kCIInputImageKey)
        lanczos.setValue(downscaleFactor, forKey: kCIInputScaleKey)
        lanczos.setValue(1.0,             forKey: kCIInputAspectRatioKey)
        if let out = lanczos.outputImage {
          ci = out
          print("🖼️ [Preview] downscaled by \(downscaleFactor), extent: \(ci.extent)")
        } else {
          print("⚠️ [Preview] lanczos produced nil output — skipping")
        }
      }

      guard let cg = ctx.createCGImage(ci, from: ci.extent) else {
        print("❌ [Preview] ctx.createCGImage failed")
        throw NSError(domain: "PreviewRender", code: -1)
      }
      print("✅ [Preview] success cg: \(cg.width)x\(cg.height)")
      return UIImage(cgImage: cg)
    }
  }
}
```

### ImageDecodeService.swift
```swift
import UIKit
import ImageIO

protocol ImageDecodeService {
    func decodeFull(_ data: Data)-> UIImage?
    func downsample(_ data: Data, maxDimension: CGFloat, _ scale: CGFloat)-> UIImage?
}

final class ImageDecodeServiceImpl: ImageDecodeService {
    func decodeFull(_ data: Data) -> UIImage? {
        print("🧩 [ImageDecode] decodeFull: bytes=\(data.count)")
        guard let src = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("❌ [ImageDecode] CGImageSourceCreateWithData failed")
            return nil
        }
        let type = CGImageSourceGetType(src) as String?
        let count = CGImageSourceGetCount(src)
        if let props = CGImageSourceCopyPropertiesAtIndex(src, 0, nil) as? [CFString: Any] {
            let orient = (props[kCGImagePropertyOrientation] as? NSNumber)?.intValue
            print("🧩 [ImageDecode] type=\(type ?? "nil"), frames=\(count), exifOrientation=\(orient ?? -1)")
        } else {
            print("⚠️ [ImageDecode] no properties for index 0")
        }
        guard let cg = CGImageSourceCreateImageAtIndex(src, 0, nil) else {
            print("❌ [ImageDecode] CGImageSourceCreateImageAtIndex failed")
            return nil
        }
        print("🧩 [ImageDecode] cg.size=\(cg.width)x\(cg.height)")
        return UIImage(cgImage: cg, scale: UIScreen.main.scale, orientation: .up)
    }
    
    func downsample(_ data: Data, maxDimension: CGFloat, _ scale: CGFloat) -> UIImage? {
        let srcOpts: CFDictionary = [ kCGImageSourceShouldCache: false] as CFDictionary
        let maxPixel = maxDimension * scale
        print("🧩 [ImageDecode] downsample: bytes=\(data.count), maxDimension=\(maxDimension), scale=\(scale), maxPixel=\(maxPixel)")
        guard let src = CGImageSourceCreateWithData(data as CFData, srcOpts) else {
            print("❌ [ImageDecode] CGImageSourceCreateWithData failed")
            return nil
        }
        let downscaleOpts: CFDictionary = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixel
        ] as CFDictionary
        guard let cg = CGImageSourceCreateThumbnailAtIndex(src, 0, downscaleOpts) else {
            print("❌ [ImageDecode] CGImageSourceCreateThumbnailAtIndex failed")
            return nil
        }
        print("🧩 [ImageDecode] thumb.size=\(cg.width)x\(cg.height)")
        return UIImage(cgImage: cg, scale: scale, orientation: .up)
    }
}
```

### ImageComposeService.swift
```swift
//import Foundation
//import CoreGraphics
//import ImageIO
//import UniformTypeIdentifiers
//
//protocol ImageComposeService {
//    func merge(base: Data, overlayPNG: Data) throws -> Data
//}
//
//enum ImageComposeError: Error { case decode, render, encode }
//
//final class ImageComposeServiceImpl: ImageComposeService {
//    func merge(base: Data, overlayPNG: Data) throws -> Data {
//        guard
//            let baseSource = CGImageSourceCreateWithData(base as CFData, nil),
//            let baseCG     = CGImageSourceCreateImageAtIndex(baseSource, 0, nil),
//            let overlaySource = CGImageSourceCreateWithData(overlayPNG as CFData, nil),
//            let overlayCG     = CGImageSourceCreateImageAtIndex(overlaySource, 0, nil)
//        else { throw ImageComposeError.decode }
//
//        let width  = baseCG.width
//        let height = baseCG.height
//        guard
//            let ctx = CGContext(
//                data: nil,
//                width: width,
//                height: height,
//                bitsPerComponent: 8,
//                bytesPerRow: width * 4,
//                space: CGColorSpaceCreateDeviceRGB(),
//                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
//            )
//        else { throw ImageComposeError.render }
//
//        ctx.draw(baseCG, in: CGRect(x: 0, y: 0, width: width, height: height))
//        ctx.draw(overlayCG, in: CGRect(x: 0, y: 0, width: width, height: height))
//
//        guard let outCG = ctx.makeImage() else { throw ImageComposeError.render }
//
//        let out = CFDataCreateMutable(nil, 0)!
//        guard let dst = CGImageDestinationCreateWithData(
//            out, UTType.jpeg.identifier as CFString, 1, nil)
//        else { throw ImageComposeError.encode }
//
//        CGImageDestinationAddImage(dst, outCG, nil)
//        guard CGImageDestinationFinalize(dst) else { throw ImageComposeError.encode }
//
//        return out as Data
//    }
//}
```

### PhotoProcessingService.swift
```swift
import Foundation
import PencilKit

protocol PhotoProcessingService {
    func makePreview(
        from data: Data,
        selectedFilter: Filter?,
        rotation: Int,
        isFlipped: Bool,
        crop: CGFloat
    ) throws -> Data

    func makeFinalImage(
        from data: Data,
        selectedFilter: Filter?,
        rotation: Int,
        isFlipped: Bool,
        crop: CGFloat,
        drawing: PKDrawing?,
        textItems: [TextItem]
    ) throws -> Data
}

final class PhotoProcessingServiceImpl: PhotoProcessingService {
    private let transform: TransformService
    private let filter:    FilterService
    private let overlay:   OverlayRenderService

    init(transform: TransformService,
         filter:    FilterService,
         overlay: OverlayRenderService
    ) {
        self.transform = transform
        self.filter    = filter
        self.overlay   = overlay
    }

    func makePreview(
        from data: Data,
        selectedFilter: Filter?,
        rotation: Int,
        isFlipped: Bool,
        crop: CGFloat
    ) throws -> Data {
        var out = try transform.rotate90(data: data, times: rotation)
        if isFlipped { out = try transform.flipHorizontal(data: out) }

        out = try filter.apply(
            filterName: selectedFilter?.filterName ?? "",
            to: out,
            downscaleFactor: 0.25
        )
        return out
    }

    func makeFinalImage(
        from data: Data,
        selectedFilter: Filter?,
        rotation: Int,
        isFlipped: Bool,
        crop: CGFloat,
        drawing: PKDrawing?,
        textItems: [TextItem]
    ) throws -> Data {
        var result = data
        if drawing != nil || !textItems.isEmpty {
            result = try overlay.apply(drawing: drawing, text: textItems, to: result)
        }
        if rotation != 0 { result = try transform.rotate90(data: result, times: rotation) }
        if isFlipped { result = try transform.flipHorizontal(data: result) }

        result = try filter.apply(
            filterName: selectedFilter?.filterName ?? "",
            to: result,
            downscaleFactor: 1.0
        )
        return result
    }
}
```

### DrawService.swift
```swift
import PencilKit
import UIKit

enum DrawingServiceError: Error {
    case invalidDrawing
    case invalidBaseImage
    case renderFailed
}

protocol DrawingService {
  func draw(drawing: PKDrawing, on baseData: Data) throws -> Data
}

final class DrawingServiceImpl: DrawingService {
    func draw(drawing: PKDrawing, on baseData: Data) throws -> Data {
        guard let base = UIImage(data: baseData) else {
            throw DrawingServiceError.invalidBaseImage
        }
        
        let size  = CGSize(width: base.size.width  * base.scale,
                           height: base.size.height * base.scale)
        let rect  = CGRect(origin: .zero, size: size)
        
        let overlay = drawing.image(from: rect, scale: base.scale)
        
        let renderer = UIGraphicsImageRenderer(size: size)
        let combined = renderer.jpegData(withCompressionQuality: 0.95) { ctx in
            base.draw(in: rect)
            overlay.draw(in: rect)
        }
        return combined
    }
}
```

### TransformService.swift
```swift
import UIKit
import CoreImage
import CoreGraphics

protocol TransformService {
    func rotate90(data: Data, times: Int) throws -> Data
    func flipHorizontal(data: Data) throws -> Data
}

enum TransformError: Error {
    case invalidData, renderFailed, encodeFailed
}


final class TransformServiceImpl: TransformService {
    private let ctx = CIContext()

    func rotate90(data: Data, times: Int) throws -> Data {
        guard let ci = CIImage(data: data) else { throw TransformError.invalidData }
        let angle = CGFloat(times % 4) * .pi/2
        let rotated = ci.transformed(by: .init(rotationAngle: angle))
        return try render(ci: rotated)
    }

    func flipHorizontal(data: Data) throws -> Data {
        guard let ci = CIImage(data: data) else { throw TransformError.invalidData }
        let flipped = ci
            .transformed(by: .init(scaleX: -1, y: 1))
            .transformed(by: .init(translationX: -ci.extent.width, y: 0))
        return try render(ci: flipped)
    }

    // helper
    private func render(ci: CIImage) throws -> Data {
        guard let cg = ctx.createCGImage(ci, from: ci.extent),
              let out = UIImage(cgImage: cg).jpegData(compressionQuality: 1)
        else { throw TransformError.renderFailed }
        return out
    }
}
```

### TextOverlay.swift
```swift
import Foundation

protocol TextOverlayService {
    func overlay(
        items: [TextItem],
        on data: Data
    ) throws -> Data
}

enum TextOverlayError: Error {
    case invalidData, contextFailed, encodeFailed
}

import Foundation
import UIKit

final class TextOverlayServiceImpl: TextOverlayService {
    func overlay(items: [TextItem], on data: Data) throws -> Data {
        guard let baseImage = UIImage(data: data) else {
            throw TextOverlayError.invalidData
        }
        let size = baseImage.size
        UIGraphicsBeginImageContextWithOptions(size, false, baseImage.scale)
        defer { UIGraphicsEndImageContext() }

        // Рисуем фон
        baseImage.draw(at: .zero)

        // Рисуем каждый текст
        for item in items {
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: item.fontName, size: item.fontSize)
                        ?? UIFont.systemFont(ofSize: item.fontSize),
                .foregroundColor: item.color
            ]
            let ns = NSString(string: item.text)
            let textSize = ns.size(withAttributes: attrs)
            let origin = CGPoint(
                x: item.position.x - textSize.width/2,
                y: item.position.y - textSize.height/2
            )
            ns.draw(at: origin, withAttributes: attrs)
        }

        guard let combined = UIGraphicsGetImageFromCurrentImageContext(),
              let pngData  = combined.pngData() else {
            throw TextOverlayError.encodeFailed
        }
        return pngData
    }
}
```

### CIContextPool.swift
```swift
import CoreImage

enum CIContextPool {
    static let shared: CIContext = {
        let opts: [CIContextOption: Any] = [.priorityRequestLow: true]
        return CIContext(options: opts)
    }()
}
```

---

## Исходный код Core/Services/Camera

### CameraService.swift
```swift
//import AVFoundation
//
//final class CameraService: NSObject, ObservableObject {
//    private let session: AVCaptureSession = AVCaptureSession()
//    @Published var isRunning: Bool = false
//    @Published var authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
//    
//    func requestPermissionIfNeeded(completion: @escaping (Bool) -> Void) {
//        switch authorizationStatus {
//            case .notDetermined:
//                AVCaptureDevice.requestAccess(for: .video) { granted in
//                    DispatchQueue.main.async {
//                        self.authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
//                        completion(granted)
//                    }
//                }
//            case .authorized:
//                completion(true)
//            default:
//                completion(false)
//        }
//    }
//    
//    func startSession() {
//        guard authorizationStatus == .authorized else { return }
//        
//        if session.inputs.isEmpty {
//            if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
//               let input = try? AVCaptureDeviceInput(device: device),
//               session.canAddInput(input) {
//                session.addInput(input)
//            }
//        }
//        session.startRunning()
//        isRunning = true
//    }
//    
//    func stopSession() {
//        session.stopRunning()
//        isRunning = false
//    }
//}
```

---

## Исходный код Core/Services/Export

### ExportService.swift
```swift
import PhotosUI

protocol ExportService {
    func makeShareURL(from data: Data) throws -> URL
    func saveToPhotos(_ data: Data) async throws
}

enum ExportError: Error {
    case permissionDenied
    case writeFailed
}

final class ExportServiceImpl: ExportService {

    func makeShareURL(from data: Data) throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".jpg")
        do {
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            throw ExportError.writeFailed
        }
    }

    func saveToPhotos(_ data: Data) async throws {
        guard try await requestAddOnlyPermission() else {
            throw ExportError.permissionDenied
        }
        
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetCreationRequest.forAsset()
                .addResource(with: .photo, data: data, options: nil)
        }
    }

    private func requestAddOnlyPermission() async throws -> Bool {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        if status == .authorized { return true }
        let next = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        return next == .authorized
    }
}
```

---

## Исходный код Features/Editor

### EditorView.swift
```swift
import SwiftUI
import PhotosUI
import PencilKit

struct EditorView: View {
    @StateObject private var vm: EditorViewModel
    @StateObject private var keyboard = KeyboardObserver()
    @StateObject private var previewCache = FilterPreviewCache()

    @State private var drawing   = PKDrawing()
    @State private var tool      = PKInkingTool(.pen, color: .black, width: 5)
    @State private var isErasing = false

    @State private var showSourceDialog = false
    @State private var showCameraPicker = false
    @State private var showLibraryPicker = false
    @State private var libraryItem: PhotosPickerItem?
    @State private var shareURL: URL?
    
    @FocusState private var focusedItemID: UUID?

    let filters = FilterProviderImpl().allFilters()
    let onShare:  () -> Void
    let onLogout: () -> Void

    init(
        vm: EditorViewModel,
        onShare: @escaping () -> Void,
        onLogout: @escaping () -> Void
    ) {
        _vm = StateObject(wrappedValue: vm)
        self.onShare  = onShare
        self.onLogout = onLogout
    }

    var body: some View {
            VStack(spacing: 0) {
                topTools
                canvasArea
                bottomTools
                filtersBar
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .toolbar {
                navBar
                textToolbar
            }
            .overlay {
                ImageSourcePicker(
                    showDialog:  $showSourceDialog,
                    showCamera:  $showCameraPicker,
                    showLibrary: $showLibraryPicker,
                    libraryItem: $libraryItem
                ) { data in
                    if let img = UIImage(data: data) {
                        print("📐 Got image orientation rawValue:", img.imageOrientation.rawValue)
                        print("📐 Got image orientation description:", img.imageOrientation)
                     }
                    vm.inputData = data
                }
            }
            .sheet(item: $vm.shareItem, onDismiss: vm.clearShareItem) { item in
                ShareSheet(items: [item.image])
            }
            .onReceive(keyboard.$height) { newH in
                vm.updateKeyboard(h: newH)
            }
            .onChange(of: vm.markup) { old, new in
                if new == .text {
                    vm.textVM.enterPlacement()
                } else {
                    vm.textVM.finishEditing()
                }
            }
            .onChange(of: vm.originalImage) { old, image in
                previewCache.preparePreviews(for: image, filters: filters)
                vm.textVM.reset()
            }
            .onAppear {
                if let image = vm.originalImage {
                    previewCache.preparePreviews(for: image, filters: filters)
                }
            }
    }
}

extension EditorView {
    @ViewBuilder private var topTools: some View {
        if vm.originalImage != nil {
            TopToolsPanel(vm: vm)
        }
    }
    
    @ViewBuilder private var canvasArea: some View {
        PreviewArea(
            vm:        vm,
            textVM:    vm.textVM,
            drawing:   $drawing,
            tool:      $tool,
            isErasing: $isErasing,
            showSourceDialog: $showSourceDialog
        )
        .coordinateSpace(name: "canvas")
    }
    
    @ViewBuilder private var bottomTools: some View {
        ToolsPanel(
            vm:       vm,
            drawing:   $drawing,
            tool:      $tool,
            isErasing: $isErasing
        )
    }
    
    @ViewBuilder private var filtersBar: some View {
        if vm.originalImage != nil {
            FilterToolsPanel(
                filters: filters,
                selectedFilter: $vm.selectedFilter,
                cache: previewCache
            )
        }
    }
    
    @ToolbarContentBuilder private var navBar: some ToolbarContent {
        EditorNavigationBar(
            showSourceDialog: $showSourceDialog,
            isShareEnabled: vm.previewImage != nil,
            onShare: {
//                print("➡️ share tapped")
//                let uiImage = drawing.image(from: drawing.bounds, scale: UIScreen.main.scale)
//                if let overlay = uiImage.pngData() {
//                    vm.share(drawingOverlay: overlay)
//                } else {
//                    vm.share(drawingOverlay: nil)
//                }
                vm.share(drawingOverlay: drawing)
            },
            onLogout: onLogout
        )
    }
    
    @ToolbarContentBuilder private var textToolbar: some ToolbarContent {
        if vm.markup == .text,
           vm.textVM.activeID != nil,
           vm.textVM.items.first(where: { $0.id == vm.textVM.activeID })?.isEditing == true
        {
            TextToolsToolbar(
                vm:     vm.textVM,
                onDone: vm.textVM.finishEditing
            )
        }
    }
}
```

### CameraPicker.swift
```swift
import SwiftUI
import UIKit

struct CameraPicker: UIViewControllerRepresentable {
    var onImagePicked: (UIImage) -> Void
    @Environment(\.presentationMode) private var presentationMode

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(
      context: Context
    ) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.modalPresentationStyle = .fullScreen
        picker.delegate   = context.coordinator
        return picker
    }

    func updateUIViewController(
      _ uiViewController: UIImagePickerController,
      context: Context
    ) {}

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraPicker
        init(_ parent: CameraPicker) { self.parent = parent }

        func imagePickerController(
          _ picker: UIImagePickerController,
          didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            if let img = info[.originalImage] as? UIImage {
                parent.onImagePicked(img)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
```

### ImageSourcePicker.swift
```swift
import SwiftUI
import PhotosUI

struct ImageSourcePicker: View {
    @Binding var showDialog: Bool
    @Binding var showCamera: Bool
    @Binding var showLibrary: Bool
    @Binding var libraryItem: PhotosPickerItem?
    let onImagePicked: (Data) -> Void
    
    @State private var showPermissionAlert: Bool = false
    
    var body: some View {
        Color.clear
            .confirmationDialog("Источник изображения",
                                isPresented: $showDialog) {
                Button("Камера")  { openCamera() }
                Button("Галерея") { showLibrary = true }
                Button("Отмена", role: .cancel) { }
            }
                                .fullScreenCover(isPresented: $showCamera) {
                                    CameraPicker { uiImage in
                                        if let data = uiImage.jpegData(compressionQuality: 1.0) {
                                            onImagePicked(data)
                                        }
                                        showCamera = false
                                    }
                                    .ignoresSafeArea()
                                }
                                .photosPicker(isPresented: $showLibrary,
                                              selection:    $libraryItem,
                                              matching:     .images,
                                              photoLibrary: .shared())
                                .onChange(of: libraryItem) { oldItem, newItem in
                                    guard let item = newItem else { return }
                                    Task {
                                        if let data = try? await item.loadTransferable(type: Data.self) {
                                            onImagePicked(data)
                                        }
                                        libraryItem = nil
                                        showLibrary = false
                                    }
                                }
                                .alert("Нет доступа к камере",
                                       isPresented: $showPermissionAlert) {
                                    Button("Настройки") {
                                        if let url = URL(string: UIApplication.openSettingsURLString) {
                                            UIApplication.shared.open(url)
                                        }
                                    }
                                    Button("Отмена", role: .cancel) { }
                                } message: {
                                    Text("Разрешите доступ к камере в настройках устройства.")
                                }
    }
    
    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showPermissionAlert = true
            return
        }
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                showCamera = true
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        DispatchQueue.main.async {
                            granted ? (showCamera = true) : (showPermissionAlert = true)
                        }
                    }
                }
            case .denied, .restricted:
                showPermissionAlert = true
            default: break
        }
    }
}
```

### EditorNavigationBar.swift
```swift
import SwiftUI

struct EditorNavigationBar: ToolbarContent {
    @Binding var showSourceDialog: Bool
    
    let isShareEnabled: Bool
    let onShare: () -> Void
    let onLogout: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button { showSourceDialog = true } label: {
                Image(systemName: "plus")
            }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: onShare) {
                Image(systemName: "square.and.arrow.up")
            }
            .disabled(!isShareEnabled)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(role: .destructive, action: onLogout) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
            }
        }
    }
}
```

### EditorStates.swift
```swift
import Foundation

enum MarkupTool: CaseIterable, Identifiable {
    case none
    case draw
    case text

    var id: Self { self }

    var iconName: String {
        switch self {
        case .none:
            return ""
        case .draw:
            return "pencil.tip"
        case .text:
            return "textformat"
        }
    }
}
```

### EditModeSelector.swift
```swift
//import SwiftUI
//
//struct EditModeSelector: View {
//    @Binding var current: EditMode
//
//    var body: some View {
//        HStack(spacing: 24) {
//            ModeButton(current: $current, target: .draw, systemName: "pencil")
//            ModeButton(current: $current, target: .text, systemName: "textformat")
//        }
//        .padding(.top, 6)
//    }
//}
```

---

## Исходный код Navigation

### RootView.swift
```swift
// Navigation/RootView.swift

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var session: SessionStore
    let container:             AppDependencyContainer
    let onLogout:              () -> Void

    init(container: AppDependencyContainer, onLogout: @escaping () -> Void) {
        self.container = container
        self.onLogout  = onLogout
    }

    var body: some View {
        NavigationStack {
            if !session.didFinishChecking {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            else if session.isAuthenticated {
                EditorView(
                    vm:       container.makeEditorViewModel(),
                    onShare:  { Task { try? await container.makeEditorViewModel().exportFinalImage() } },
                    onLogout: onLogout
                )
            }
            else {
                AuthStackView(
                    container: container,
                    onLogin:   { /* после логина обновится session.isAuthenticated */ }
                )
            }
        }
        .environmentObject(session)
    }
}
```

---

## Исходный код Features/Editor/ViewModels

### EditorViewModel.swift
```swift
import SwiftUI
import Combine
import PencilKit

@MainActor
final class EditorViewModel: ObservableObject {
    @Published var markup: MarkupTool = .none
    
    @Published var keyboardHeight: CGFloat = 0
    @Published var inputData: Data?
    @Published var selectedFilter: Filter? = nil
    @Published private(set) var previewImage: UIImage? = nil
    @Published var canvasSize: CGSize = .zero
    @Published var rotationCount = 0
    @Published var isFlippedHorizontally = false
    @Published private(set) var originalImage: UIImage? = nil
    @Published var shareItem: ShareItem?
    
    let textVM = TextOverlayViewModel()
    
    private let transformService: TransformService
    private let filterService:    FilterService
    private let exportService:    ExportService
    private let overlayService:   OverlayRenderService
    private let previewService:   PreviewRenderService
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        transformService: TransformService,
        filterService:    FilterService,
        exportService:    ExportService,
        overlayService:   OverlayRenderService,
        previewService:   PreviewRenderService = PreviewRenderServiceImpl()
    ) {
        self.transformService = transformService
        self.filterService    = filterService
        self.exportService    = exportService
        self.overlayService   = overlayService
        self.previewService   = previewService
        
        Publishers
            .CombineLatest($inputData, $selectedFilter)
            .debounce(for: .milliseconds(120), scheduler: RunLoop.main)
            .sink { [weak self] raw, fx in
                self?.updatePreview(raw: raw, filter: fx)
            }
            .store(in: &cancellables)
        
        $inputData
            .sink { [weak self] data in
                guard let data else { self?.originalImage = nil; return }
                self?.originalImage = UIImage(data: data)
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest($originalImage, $selectedFilter)
            .sink { [weak self] image, filter in
                guard let self = self else { return }
                self.previewImage = self.apply(filter: filter, to: image)
            }
            .store(in: &cancellables)
    }
    
    private func updatePreview(raw: Data?, filter: Filter?) {
        guard let data = raw else {
            previewImage = nil
            return
        }
        Task.detached(priority: .userInitiated) { [previewService] in
            let ui = try? previewService.renderPreview(
                data: data,
                filterName: filter?.filterName,
                downscaleFactor: 0.25
            )
            await MainActor.run { self.previewImage = ui }
        }
    }
    
    func startDraw() {
        markup = .draw
        textVM.finishEditing()
    }
    
    func startText() {
        markup = .text
        textVM.enterPlacement()
    }
    
    func finishMarkup() {
        markup = .none
        textVM.finishEditing()
    }
    
    func updateKeyboard(h: CGFloat) {
        keyboardHeight = h
    }
    
    func exportFinalImage(drawingOverlay: PKDrawing? = nil) async throws {
        let data = try await renderFinalImage(drawingOverlay: drawingOverlay)
        try await exportService.saveToPhotos(data)
    }
    
    func share(drawingOverlay: PKDrawing?) {
        Task { @MainActor in
            print("🛠 share started")
            do {
                let item = try await makeShareItem(drawingOverlay: drawingOverlay)
                shareItem = item
            } catch {
                print("❌ share error:", error.localizedDescription)
            }
        }
    }
    
    func clearShareItem() {
        shareItem = nil
    }
    
    
    private func renderFinalImage(drawingOverlay: PKDrawing?) async throws -> Data {
        guard let raw = inputData else {
            throw TransformError.invalidData
        }
        var img = raw
        
        img = try filterService.apply(
            filterName: selectedFilter?.filterName ?? "",
            to: img,
            downscaleFactor: 1.0
        )
        
        if drawingOverlay != nil || !textVM.items.isEmpty {
            img = try overlayService.apply(
                drawing: drawingOverlay,
                text: textVM.items,
                to: img
            )
        }
        
        if rotationCount != 0 {
            img = try transformService.rotate90(data: img, times: rotationCount)
        }
        
        if isFlippedHorizontally {
            img = try transformService.flipHorizontal(data: img)
        }
        

        

        


        return img
    }

    private func apply(filter: Filter?, to image: UIImage?) -> UIImage? {
        guard let image = image else { return nil }
        guard let filter = filter, !filter.filterName.isEmpty else { return image }
        guard let ciImage = CIImage(image: image), let fx = CIFilter(name: filter.filterName) else { return image }
        fx.setValue(ciImage, forKey: kCIInputImageKey)
        let context = CIContext()
        if let outputCIImage = fx.outputImage,
           let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) {
            return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
        } else {
            return image
        }
    }

    private func makeShareItem(drawingOverlay: PKDrawing?) async throws -> ShareItem {
        let data = try await renderFinalImage(drawingOverlay: drawingOverlay)
        guard let ui = UIImage(data: data) else { throw OverlayRenderError.encodeFailed }
        return ShareItem(image: ui)
    }
}
```

### TextOverlayViewModel.swift
```swift
import SwiftUI
import Combine

fileprivate struct CanvasFrame {
    let canvas: CGSize
    let minY: CGFloat
    let maxY: CGFloat
    
    init(canvas: CGSize, keyboard: CGFloat, imageSize: CGSize?, textH: CGFloat = 44, margin: CGFloat = 8 ) {
        let imgW = imageSize?.width  ?? canvas.width
        let imgH = imageSize?.height ?? canvas.height
        
        let dispH = imgW / imgH > canvas.width / canvas.height
        ? canvas.width  / (imgW / imgH)
        : canvas.height
        
        let vInset = (canvas.height - dispH) / 2
        minY = vInset + textH/2 + margin
        maxY = canvas.height - vInset - textH/2 - margin - keyboard
        self.canvas = canvas
    }
    
}

@MainActor
final class TextOverlayViewModel: ObservableObject {
    
    @Published var items: [TextItem] = []
    @Published var activeID: UUID?
    @Published var isPlacing  = false
    
    @Published var currentColor: Color   = .white {
        didSet { apply(.color(currentColor)) }
    }
    
    @Published var currentSize:  CGFloat = 24 {
        didSet { apply(.size(currentSize)) }
    }
    
    private var waitForKeyboard: Bool = false
    
    func enterPlacement() {
        isPlacing = true
        activeID  = nil
        waitForKeyboard = true
    }
    
    
    func placeText(in canvas: CGSize, keyboardH: CGFloat, imageSize: CGSize?) {
        let frame = CanvasFrame(canvas: canvas, keyboard: keyboardH, imageSize: imageSize)
        let y = (frame.minY + frame.maxY) / 2
        let p = CGPoint(x: canvas.width / 2, y: y)
        
        let item = TextItem(text: "Текст",
                            fontName: "System",
                            fontSize: currentSize,
                            color: currentColor,
                            position: p,
                            isEditing: true
        )
        items.append(item)
        activeID = item.id
        isPlacing = false
        waitForKeyboard = false
        
    }
    
    func setActive(id: UUID, editing: Bool = false) {
        print("🔤 setActive(id: \(id), editing: \(editing))")
        activeID = id
        isPlacing = false
        if editing { mutateActive { $0.isEditing = true } }
    }
    
    func finishEditing() {
        print("🔤 finishEditing() — до: activeID=\(String(describing: activeID)), items=\(items.map { "\($0.id):\($0.isEditing)" })")
        mutateActive { $0.isEditing = false}
        activeID = nil
        isPlacing = true
        print("🔤 finishEditing() — после: activeID=\(String(describing: activeID)), items=\(items.map { "\($0.id):\($0.isEditing)" })")
    }
    
    func apply(_ edit: Edit) {
        mutateActive {
            switch edit {
                case .size(let s): $0.fontSize = s
                case .color(let c): $0.color = c
            }
        }
    }
    
    func remove(id: UUID) {
        items.removeAll { $0.id == id }
        finishEditing()
    }
    
    func reset() {
        items.removeAll()
        activeID = nil
        isPlacing = false
        waitForKeyboard = false
    }
    
    func keyboardDidChange(_ h: CGFloat, canvas: CGSize, imageSize: CGSize?) {
        if waitForKeyboard, h > 0 {
            placeText(in: canvas, keyboardH: h, imageSize: imageSize)
            return
        }
        if h == 0 {
            for i in items.indices {
                if let saved = items[i].parkedPosition {
                    items[i].position        = saved
                    items[i].parkedPosition  = nil
                }
            }
        }
        adjustPosition(canvas: canvas, keyboardH: h, imageSize: imageSize)
    }
    
    private func adjustPosition(canvas: CGSize, keyboardH: CGFloat, imageSize: CGSize?) {
        guard keyboardH > 0 else { return }
        
        let frame = CanvasFrame(canvas: canvas, keyboard: keyboardH, imageSize: imageSize)
        
        mutateActive { item in
            guard item.isEditing else { return }
            if item.parkedPosition == nil {
                item.parkedPosition = item.position
            }
            
            let y = min(max(item.position.y, frame.minY), frame.maxY)
            item.position = CGPoint(x: frame.canvas.width / 2, y: y)
        }
    }
    
    private func mutateActive(_ block: (inout TextItem) -> Void) {
        guard let id = activeID, let idx = items.firstIndex(where: {$0.id == id}) else { return }
        block(&items[idx])
    }
}

extension TextOverlayViewModel {
    enum Edit {
        case size(CGFloat)
        case color(Color)
    }
}
```