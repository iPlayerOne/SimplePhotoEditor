# SimplePhotoEditor — Полный README (актуально)

Этот файл объединяет актуальную структуру, флоу и ключевые исходники (код‑сниппеты) для SimplePhotoEditor. Он заменяет разрозненные дубли и ссылается на реальные файлы проекта.

— Быстрый старт, структура и ключевые секции сведены в одном месте.
— Код‑примеры синхронизированы с исходниками в `SimplePhotoEditor/`.

Если нужна подробная повествовательная версия по подсистемам, см. также: `README_Auth.md` и `README_Editor.md`.

---

## Требования и запуск

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+
- Firebase + GoogleSignIn

Быстрый старт:
1) Откройте `SimplePhotoEditor.xcodeproj` в Xcode.
2) Подтяните зависимости через SPM, если потребуется.
3) Добавьте `GoogleService-Info.plist` в таргет `SimplePhotoEditor/`.
4) Проверьте URL Schemes в `SimplePhotoEditor/App/Info.plist`.
5) Запустите на устройстве/симуляторе iOS 15+.

---

## Структура проекта (актуально)

```
SimplePhotoEditor/
├── App/
│   ├── AppDelegate.swift
│   ├── AppConfig.swift
│   ├── DependencyContainer.swift
│   ├── Info.plist
│   └── SimplePhotoEditorApp.swift
├── Assets.xcassets/
├── Core/
│   ├── Models/
│   │   ├── Filter.swift
│   │   ├── Photo.swift
│   │   ├── ShareItem.swift
│   │   ├── Stroke.swift
│   │   ├── TextItem.swift
│   │   └── User.swift
│   ├── Services/
│   │   ├── Auth/
│   │   │   ├── AuthError.swift
│   │   │   └── FirebaseAuthService.swift
│   │   ├── Camera/
│   │   │   └── CameraService.swift
│   │   ├── Export/
│   │   │   └── ExportService.swift
│   │   └── Processing/
│   │       ├── CIContextPool.swift
│   │       ├── CIHelpers.swift
│   │       ├── DrawService.swift
│   │       ├── FilterProvider.swift
│   │       ├── FilterService.swift
│   │       ├── ImageComposeService.swift
│   │       ├── ImageDecodeService.swift
│   │       ├── ImagePipeline.swift
│   │       ├── OverlayRenderService.swift
│   │       ├── PhotoProcessingService.swift
│   │       ├── PreviewRenderService.swift
│   │       ├── TextOverlay.swift
│   │       └── TransformService.swift
│   ├── State/
│   │   ├── AppState.swift
│   │   └── SessionStore.swift
│   └── Utilities/
│       ├── CanvasMetrics.swift
│       ├── Extensions/
│       │   ├── Color+UIColor.swift
│       │   ├── Image+Filter.swift
│       │   └── String+CamelCase.swift
│       ├── FilterWidthKey.swift
│       ├── GeometryHelper.swift
│       ├── KeyboardObserver.swift
│       ├── Modifiers/
│       │   ├── AlertModifier.swift
│       │   ├── Draggable.swift
│       │   ├── IconStyle.swift
│       │   ├── Liftable.swift
│       │   ├── PanelSurface.swift
│       │   ├── ShimmerModifier.swift
│       │   └── UnderlineModifier.swift
│       ├── ShareSheet.swift
│       └── UIImage+SafeDecode.swift
├── Features/
│   ├── Auth/
│   │   ├── Components/
│   │   │   ├── AuthButtonStyle.swift
│   │   │   ├── AuthFieldModifier.swift
│   │   │   ├── AuthTextField.swift
│   │   │   └── PrimaryActionButton.swift
│   │   ├── ViewModels/
│   │   │   ├── LoginViewModel.swift
│   │   │   ├── RegistrationViewModel.swift
│   │   │   └── ResetPasswordViewModel.swift
│   │   ├── AuthRoute.swift
│   │   ├── AuthRouter.swift
│   │   ├── AuthStackView.swift
│   │   ├── GoogleSignInCoordinator.swift
│   │   ├── LoginView.swift
│   │   ├── RegistrationView.swift
│   │   └── ResetPasswordView.swift
│   └── Editor/
│       ├── CameraPicker.swift
│       ├── Components/
│       │   ├── FilterTools/
│       │   │   ├── FilterPreviewCache.swift
│       │   │   └── FilterPreviewImage.swift
│       │   ├── KeyboardAccessory/
│       │   │   ├── AccessoryHostingController.swift
│       │   │   └── KeyboardAccessory.swift
│       │   ├── Preview/
│       │   │   ├── CanvasLayer.swift
│       │   │   ├── PencilCanvasView.swift
│       │   │   ├── PhotoLayer.swift
│       │   │   ├── PreviewArea.swift
│       │   │   ├── TextItemView.swift
│       │   │   ├── TextOverlayLayer.swift
│       │   │   └── ZoomableView.swift
│       │   ├── Tab/
│       │   │   ├── ModeButton.swift
│       │   │   └── ModeTabBar.swift
│       │   └── Tools/
│       │       ├── DrawToolsPanel.swift
│       │       ├── EditorTopBar.swift
│       │       ├── FilterToolsPanel.swift
│       │       ├── TextToolsToolbar.swift
│       │       ├── ToolsPanel.swift
│       │       └── TopToolControls.swift
│       ├── EditModeSelector.swift
│       ├── EditorNavigationBar.swift
│       ├── EditorStates.swift
│       ├── EditorView.swift
│       ├── ImageSourcePicker.swift
│       ├── Models/
│       │   └── EditorMode.swift
│       └── ViewModels/
│           ├── EditorViewModel.swift
│           └── TextOverlayViewModel.swift
├── Navigation/
│   └── RootView.swift
├── GoogleService-Info.plist
└── README.md
```

---

## Глобальный флоу

1) Приложение конфигурирует Firebase и собирает зависимости. 2) `SessionStore` определяет состояние авторизации. 3) `RootView` показывает `AuthStackView` или `EditorView` в зависимости от `session.isAuthenticated`.

Ключевые роли:
- Auth: вход по Email/Google, регистрация, сброс пароля.
- Editor: фильтры, рисование (PencilKit), текстовые слои, экспорт/шаринг.

---

## Статистика кода (без комментариев и пустых строк)

- Всего Swift LOC: 2922
- По модулям:
  - 99 строк (4 файла): `SimplePhotoEditor/App`
  - 1101 строк (43 файла): `SimplePhotoEditor/Core`
  - 462 строки (14 файлов): `SimplePhotoEditor/Features/Auth`
  - 1229 строк (28 файлов): `SimplePhotoEditor/Features/Editor`
  - 31 строка (1 файл): `SimplePhotoEditor/Navigation`

Примечание: считаются только строки кода, исключая пустые строки и однострочные комментарии `//...`.

---

## Обработка Изображений (CI)

- Ключевая стратегия против 1‑px шва: clamp → filter → crop → snap → render (.up). Реализовано во всех путях применения фильтров и предпросмотра.
- Быстрые ссылки на точки рендера и возможные артефакты:
  - SimplePhotoEditor/Core/Services/Processing/FilterService.swift:1
  - SimplePhotoEditor/Core/Services/Processing/PreviewRenderService.swift:1
  - SimplePhotoEditor/Core/Services/Processing/CIHelpers.swift:1
  - SimplePhotoEditor/Core/Services/Processing/CIContextPool.swift:1
  - SimplePhotoEditor/Features/Editor/Components/FilterTools/FilterPreviewCache.swift:1
  - SimplePhotoEditor/Features/Editor/Components/FilterTools/FilteredImageView.swift:1
  - SimplePhotoEditor/Core/Utilities/PixelSnap.swift:1
  - SimplePhotoEditor/Features/Editor/Components/Preview/PhotoLayer.swift:1

- Полный обзор с кодом всех CI‑точек: README_ImageProcessing.md

---

## CI/Processing — Полный Код (встроено)

### Core/Services/Processing/CIContextPool.swift
```swift
import CoreImage

enum CIContextPool {
    static let shared: CIContext = {
        let opts: [CIContextOption: Any] = [.priorityRequestLow: true]
        return CIContext(options: opts)
    }()
}
```

### Core/Services/Processing/CIHelpers.swift
```swift
import CoreImage

enum CIHelpers {
    static func lanczosScaled(_ ci: CIImage, scale: CGFloat) -> CIImage {
        guard scale < 0.999,
              let f = CIFilter(name: "CILanczosScaleTransform")
        else { return ci }
        
        let input = ci.clampedToExtent()
        f.setValue(input, forKey: kCIInputImageKey)
        f.setValue(scale, forKey: kCIInputScaleKey)
        f.setValue(1.0,   forKey: kCIInputAspectRatioKey)
        let out = f.outputImage ?? ci
        
        let scaledRect = ci.extent.applying(CGAffineTransform(scaleX: scale, y: scale))
        return out.cropped(to: scaledRect)
    }
}

extension CIImage {
    func snappedForDisplay() -> CIImage {
        let r = self.extent.integral
        let snapped = CGRect(
            x: floor(r.origin.x),
            y: floor(r.origin.y),
            width: round(r.size.width),
            height: round(r.size.height)
        )
        if snapped == r {
            return self.cropped(to: snapped)
        }
        return self
            .transformed(by: CGAffineTransform(translationX: -snapped.origin.x,
                                               y: -snapped.origin.y))
            .cropped(to: CGRect(origin: .zero, size: snapped.size))
    }
}
```

### Core/Services/Processing/FilterService.swift
```swift
import UIKit
import CoreImage

protocol FilterService {
    func apply(filterName: String, to data: Data, downscaleFactor: CGFloat) throws -> Data
}

enum FilterError: Error { case invalidData, renderFailed }

final class FilterServiceImpl: FilterService {
    
    func apply(filterName: String, to data: Data, downscaleFactor: CGFloat = 1.0) throws -> Data {
        guard var ci = CIImage(data: data, options: [.applyOrientationProperty: true]) else {
            throw FilterError.invalidData
        }

        ci = CIHelpers.lanczosScaled(ci, scale: downscaleFactor)
        let srcExtent = ci.extent
        var out = ci.clampedToExtent()

        if !filterName.isEmpty, let fx = CIFilter(name: filterName) {
            fx.setValue(out, forKey: kCIInputImageKey)
            out = fx.outputImage ?? out
        }

        out = out.cropped(to: srcExtent).snappedForDisplay()
        let bg = ci.clampedToExtent().cropped(to: srcExtent).snappedForDisplay()
        out = out.composited(over: bg)

        let rect = out.extent.integral
        guard let cg = CIContextPool.shared.createCGImage(out, from: rect) else {
            throw FilterError.renderFailed
        }
        guard let jpeg = UIImage(cgImage: cg, scale: 1, orientation: .up)
            .jpegData(compressionQuality: 0.9) else {
            throw FilterError.renderFailed
        }
        return jpeg
    }
}
```

### Core/Services/Processing/PreviewRenderService.swift
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
  private let queue = DispatchQueue(
    label: "SimplePhotoEditor.Preview",
    qos:   .userInitiated
  )

  func renderPreview( data: Data, filterName: String?, downscaleFactor: Double ) throws -> UIImage {
    try queue.sync {
      guard var ci = CIImage(data: data, options: [.applyOrientationProperty: true]) else {
        throw NSError(domain: "PreviewRender", code: -10)
      }

      ci = CIHelpers.lanczosScaled(ci, scale: CGFloat(downscaleFactor))
      let srcExtent = ci.extent
      var out = ci.clampedToExtent()

      if let name = filterName, !name.isEmpty, let fx = CIFilter(name: name) {
        fx.setValue(out, forKey: kCIInputImageKey)
        out = fx.outputImage ?? out
      }

      out = out.cropped(to: srcExtent).snappedForDisplay()
      let bg = ci.clampedToExtent().cropped(to: srcExtent).snappedForDisplay()
      out = out.composited(over: bg)

      let rect = out.extent.integral
      guard let cg = CIContextPool.shared.createCGImage(out, from: rect) else {
        throw NSError(domain: "PreviewRender", code: -1)
      }
      return UIImage(cgImage: cg, scale: 1, orientation: .up)
    }
  }
}
```

### Core/Services/Processing/TransformService.swift
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
    private let ctx = CIContextPool.shared

    func rotate90(data: Data, times: Int) throws -> Data {
        guard let ci0 = CIImage(data: data, options: [.applyOrientationProperty: true])
        else { throw TransformError.invalidData }

        let angle = CGFloat(times % 4) * .pi / 2
        let rotated = ci0.transformed(by: .init(rotationAngle: angle))
                          .snappedForDisplay()

        return try render(ci: rotated)
    }

    func flipHorizontal(data: Data) throws -> Data {
        guard let ci0 = CIImage(data: data, options: [.applyOrientationProperty: true])
        else { throw TransformError.invalidData }

        let flipped = ci0
            .transformed(by: .init(scaleX: -1, y: 1))
            .transformed(by: .init(translationX: -ci0.extent.width, y: 0))
            .snappedForDisplay()

        return try render(ci: flipped)
    }

    private func render(ci: CIImage) throws -> Data {
        let rect = ci.extent.integral
        guard let cg = ctx.createCGImage(ci, from: rect) else {
            throw TransformError.renderFailed
        }
        guard let out = UIImage(cgImage: cg, scale: 1, orientation: .up)
                .jpegData(compressionQuality: 1) else {
            throw TransformError.encodeFailed
        }
        return out
    }
}
```

### Core/Services/Processing/ImageDecodeService.swift
```swift
import UIKit
import ImageIO

protocol ImageDecodeService {
    func decodeFull(_ data: Data)-> UIImage?
    func downsample(_ data: Data, maxDimension: CGFloat, _ scale: CGFloat)-> UIImage?
}

final class ImageDecodeServiceImpl: ImageDecodeService {
    func decodeFull(_ data: Data) -> UIImage? {
        guard let src = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }
        guard let cg = CGImageSourceCreateImageAtIndex(src, 0, nil) else {
            return nil
        }
        return UIImage(cgImage: cg, scale: UIScreen.main.scale, orientation: .up)
    }
    
    func downsample(_ data: Data, maxDimension: CGFloat, _ scale: CGFloat) -> UIImage? {
        let srcOpts: CFDictionary = [ kCGImageSourceShouldCache: false] as CFDictionary
        let maxPixel = maxDimension * scale
        guard let src = CGImageSourceCreateWithData(data as CFData, srcOpts) else {
            return nil
        }
        let downscaleOpts: CFDictionary = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixel
        ] as CFDictionary
        guard let cg = CGImageSourceCreateThumbnailAtIndex(src, 0, downscaleOpts) else {
            return nil
        }
        return UIImage(cgImage: cg, scale: scale, orientation: .up)
    }
}
```

### Core/Services/Processing/ImagePipeline.swift
```swift
import UIKit
import PencilKit

protocol ImagePipeline {
    func makePreview(from data: Data, filterName: String?, downscaleFactor: CGFloat) async -> UIImage?
    func makeFinalImage(
        from data: Data,
        filterName: String?,
        rotation: Int,
        isFlipped: Bool,
        drawing: PKDrawing?,
        texts: [TextItem]?,
        canvasSize: CGSize,
        imageSize: CGSize
    ) async throws -> Data
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

    func makePreview(from data: Data, filterName: String?, downscaleFactor: CGFloat) async -> UIImage? {
        let decode = self.decode
        let filter = self.filter

        return await Task.detached(priority: .userInitiated) {
            guard let preview = await decode.downsample(data, maxDimension: 600, UIScreen.main.scale) else {
                return nil
            }
            guard let name = filterName, !name.isEmpty else {
                return preview
            }
            guard
                let jpeg = preview.jpegData(compressionQuality: 0.9),
                let filteredData = try? filter.apply(filterName: name, to: jpeg, downscaleFactor: downscaleFactor),
                let filteredPreview = UIImage(data: filteredData)
            else {
                return preview
            }
            return filteredPreview
        }.value
    }

    func makeFinalImage(
        from data: Data,
        filterName: String?,
        rotation: Int,
        isFlipped: Bool,
        drawing: PKDrawing?,
        texts: [TextItem]?,
        canvasSize: CGSize,
        imageSize: CGSize
    ) async throws -> Data {
        let transform = self.transform
        let filter = self.filter
        let overlay = self.overlay

        return try await Task.detached(priority: .userInitiated) {
            var out = data

            if rotation != 0 {
                out = try transform.rotate90(data: out, times: rotation)
            }
            if isFlipped {
                out = try transform.flipHorizontal(data: out)
            }

            if let name = filterName, !name.isEmpty {
                out = try filter.apply(filterName: name, to: out, downscaleFactor: 1.0)
            }

            let hasTexts = !(texts?.isEmpty ?? true)
            if drawing != nil || hasTexts {
                out = try overlay.apply(
                    drawing: drawing,
                    texts: texts,
                    to: out,
                    canvasSize: canvasSize,
                    imageSize: imageSize
                )
            }

            return out
        }.value
    }
}
```

### Features/Editor/Components/FilterTools/FilterPreviewCache.swift
```swift
import UIKit
import Combine

final class FilterPreviewCache: ObservableObject {
    @Published private(set) var previews: [UUID: UIImage] = [:]
    
    private var generation = UUID()
    private var worker: Task<Void, Never>?
    
    private let previewMaxSide: CGFloat = 180
    
    func preparePreviews(for image: UIImage?, filters: [Filter]) {
        worker?.cancel()
        
        let gen = UUID()
        generation = gen
        
        guard let image = image else { return }
        
        let jobs = filters.map { (id: $0.id, name: $0.filterName) }
        let src = image
        
        let maxSide = max(src.size.width, src.size.height)
        let scale: CGFloat = maxSide > previewMaxSide ? (previewMaxSide / maxSide ) : 1
        
        worker = Task.detached(priority: .userInitiated) { [gen, jobs, src, scale] in
            var out: [UUID: UIImage] = [:]
            
            for (id, name) in jobs {
                if Task.isCancelled { return }
                if let ui = Self.apply(name, to: src, scale: scale) {
                    out[id] = ui
                }
            }
            
            let result = out
            
            await MainActor.run { [weak self] in
                guard let self,gen == self.generation else { return }
                self.previews = result
            }
        }
    }
    
    private static func apply(_ filterName: String, to image: UIImage, scale: CGFloat) -> UIImage? {
        guard var ci = CIImage(image: image, options: [.applyOrientationProperty: true]) else { return image }
        ci = CIHelpers.lanczosScaled(ci, scale: scale)
        let srcExtent = ci.extent
        var out = ci.clampedToExtent()

        if !filterName.isEmpty, let fx = CIFilter(name: filterName) {
            fx.setValue(out, forKey: kCIInputImageKey)
            out = fx.outputImage ?? out
        }

        out = out.cropped(to: srcExtent).snappedForDisplay()
        let bg = ci.clampedToExtent().cropped(to: srcExtent).snappedForDisplay()
        out = out.composited(over: bg)

        guard let cg = CIContextPool.shared.createCGImage(out, from: out.extent) else {
            return image
        }
        return UIImage(cgImage: cg, scale: image.scale, orientation: .up)
    }
}
```

### Features/Editor/Components/FilterTools/FilteredImageView.swift
```swift
import UIKit
import SwiftUI

struct FilteredImageView: UIViewRepresentable {
    let baseImage: UIImage
    let filterName: String

    func makeUIView(context: Context) -> UIImageView {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        context.coordinator.task?.cancel()

        let input = baseImage
        let name  = filterName

        context.coordinator.task = Task {
            let output = await Self.renderFiltered(baseImage: input, filterName: name)
            guard !Task.isCancelled else { return }
            await MainActor.run { uiView.image = output }
        }
    }

    final class Coordinator {
        var task: Task<Void, Never>?
        deinit { task?.cancel() }
    }

    private static func renderFiltered(baseImage: UIImage, filterName: String) async -> UIImage {
        if filterName.isEmpty { return baseImage }

        return await Task.detached(priority: .userInitiated) { () -> UIImage in
            autoreleasepool {
                guard var ci = CIImage(image: baseImage, options: [.applyOrientationProperty: true]) else {
                    return baseImage
                }

                let srcExtent = ci.extent
                var out = ci.clampedToExtent()
                if let fx = CIFilter(name: filterName) {
                    fx.setValue(out, forKey: kCIInputImageKey)
                    out = fx.outputImage ?? out
                }
                out = out.cropped(to: srcExtent).snappedForDisplay()
                let bg = ci.clampedToExtent().cropped(to: srcExtent).snappedForDisplay()
                out = out.composited(over: bg)

                let ctx = CIContextPool.shared
                guard let cg = ctx.createCGImage(out, from: out.extent) else {
                    return baseImage
                }
                return UIImage(cgImage: cg, scale: baseImage.scale, orientation: .up)
            }
        }.value
    }
}
```

### Core/Utilities/UIImage+SafeDecode.swift
```swift
import UIKit
import CoreImage
import UniformTypeIdentifiers

@MainActor
func safeDecodeImage(from rawData: Data?) async -> UIImage? {
    guard let data = rawData, !data.isEmpty else { return nil }

    return await Task.detached(priority: .userInitiated) {
        guard let ci = CIImage(data: data) else { return nil }
        let snapped = ci.snappedForDisplay()
        let ctx = CIContextPool.shared
        guard let cg = ctx.createCGImage(snapped, from: ci.extent) else { return nil }
        return UIImage(cgImage: cg)
    }.value
}
```

### Core/Utilities/PixelSnap.swift
```swift
import UIKit
import SwiftUI

@inline(__always)
func snapToPixel(_ v: CGFloat, scale: CGFloat = UIScreen.main.scale) -> CGFloat {
    (v * scale).rounded() / scale
}

extension View {
    func hideHorizontalSeam() -> some View {
        let eps = 1 / UIScreen.main.scale
        return self.padding(.horizontal, -eps / 2)
    }
}
```

### Features/Editor/Components/Preview/PhotoLayer.swift
```swift
import SwiftUI

struct PhotoLayer: View {
    let image:   UIImage?
    let maxSize: CGSize
    let onAddImage: (() -> Void)?
    
    let contentMode: ContentMode
    let cornerRadius: CGFloat
    let placeholderBackground: Color
    let placeholderIconName: String
    let placeholderText: String
    
    init(
        image: UIImage?,
        maxSize: CGSize,
        onAddImage: (() -> Void)? = nil,
        contentMode: ContentMode = .fill,
        cornerRadius: CGFloat = 16,
        placeholderBackground: Color = .secondary.opacity(0.08),
        placeholderIconName: String = "photo.on.rectangle.angled",
        placeholderText: String = "Добавить изображение"
    ) {
        self.image = image
        self.maxSize = maxSize
        self.onAddImage = onAddImage
        self.contentMode = contentMode
        self.cornerRadius = cornerRadius
        self.placeholderBackground = placeholderBackground
        self.placeholderIconName = placeholderIconName
        self.placeholderText = placeholderText
    }
    
    var body: some View {
        content
            .frame(width: maxSize.width, height: maxSize.height, alignment: .center)
    }
    
    @ViewBuilder
    private var content: some View {
        if let ui = image {
            Image(uiImage: ui)
                .resizable()
                .aspectRatio(contentMode: contentMode)
                .frame(width: maxSize.width, height: maxSize.height)
                .clipped()
                .hideHorizontalSeam()
        } else if let onAddImage {
            Button(action: onAddImage) {
                placeholder
            }
            .buttonStyle(.plain)
        } else {
            placeholder
        }
    }
    
    private var placeholder: some View {
        VStack(spacing: 12) {
            Image(systemName: placeholderIconName)
                .resizable()
                .scaledToFit()
                .frame(width: 56, height: 56)
                .foregroundStyle(.tint)
            Text(placeholderText)
                .font(.headline)
                .foregroundStyle(.tint)
        }
        .frame(width: maxSize.width, height: maxSize.height)
        .background(placeholderBackground)
    }
    
}
```

## App: точка входа и DI

### AppDelegate.swift
```swift
import UIKit
import FirebaseCore
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Если инициализируете Firebase здесь — вызовите configure()
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

### DependencyContainer.swift (актуальная версия)
```swift
import Foundation

@MainActor
final class AppDependencyContainer {

    private let transformService = TransformServiceImpl()
    private let filterService    = FilterServiceImpl()
    private let overlayService   = OverlayRenderServiceImpl()
    private let decodeService    = ImageDecodeServiceImpl()
    private let previewService   = PreviewRenderServiceImpl()
    private let exportService    = ExportServiceImpl()

    private lazy var imagePipeline: ImagePipeline = {
        ImagePipelineImpl(
            decode:   decodeService,
            transform: transformService,
            filter:    filterService,
            overlay:   overlayService
        )
    }()

    let authService: AuthService
    let googleCoordinator: GoogleSignInCoordinator

    init(authService: AuthService = FirebaseAuthService()) {
        _ = CIContextPool.shared
        self.authService       = authService
        self.googleCoordinator = GoogleSignInCoordinatorImpl(
            clientID: AppConfig.googleClientID
        )
    }

    func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(
            authService:       authService,
            googleCoordinator: googleCoordinator
        )
    }

    func makeRegistrationViewModel() -> RegistrationViewModel {
        RegistrationViewModel(authService: authService)
    }

    func makeResetPasswordViewModel() -> ResetPasswordViewModel {
        ResetPasswordViewModel(authService: authService)
    }

    func makeEditorViewModel() -> EditorViewModel {
        EditorViewModel(
            pipeline:       imagePipeline,
            exportService:  exportService
        )
    }
}
```

### SimplePhotoEditorApp.swift
```swift
import SwiftUI
import FirebaseCore

@main
struct SimplePhotoEditorApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var session: SessionStore
    private let container: AppDependencyContainer

    init() {
        FirebaseApp.configure()

        let authService = FirebaseAuthService()
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

### Info.plist (фрагмент — фактический)
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
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

## Auth: сервисы, VM и экраны

### AuthError.swift
```swift
import Foundation

enum AuthError: Error, Identifiable {
    // MARK: - Email / Password
    case emailAlreadyInUse
    case invalidEmailFormat
    case userNotFound
    case wrongPassword
    case weakPassword
    case userDisabled
    case tooManyRequests
    
    // MARK: Google
    case accountExistsWithDifferentCredential
    case credentialAlreadyInUse
    case invalidCredential
    case popupClosedByUser
    case operationNotAllowed
    
    case networkError(underlying: Error)
    case unknown
    
    var id: String { localizedDescription }

    var localizedDescription: String {
        switch self {
        case .emailAlreadyInUse:
            return "Этот email уже зарегистрирован."
        case .invalidEmailFormat:
            return "Неверный формат email."
        case .userNotFound:
            return "Пользователь не найден."
        case .wrongPassword:
            return "Неверный пароль."
        case .weakPassword:
            return "Пароль слишком простой (минимум 6 символов)."
        case .userDisabled:
            return "Аккаунт отключён. Обратитесь в поддержку."
        case .tooManyRequests:
            return "Слишком много попыток. Попробуйте позже."
        case .accountExistsWithDifferentCredential:
            return "Этот email привязан к другому провайдеру."
        case .credentialAlreadyInUse:
            return "Учётные данные уже используются другим аккаунтом."
        case .invalidCredential:
            return "Неверные или устаревшие учётные данные."
        case .popupClosedByUser:
            return "Вход отменён пользователем."
        case .operationNotAllowed:
            return "Вход через Google отключён администратором."
        case .networkError:
            return "Проблемы с сетью. Проверьте подключение."
        case .unknown:
            return "Произошла неизвестная ошибка. Попробуйте снова."
        }
    }
}

extension AuthError: LocalizedError {
    var errorDescription: String? { localizedDescription }
}
```

### FirebaseAuthService.swift
```swift
import FirebaseAuth
import Combine

protocol AuthService {
  func signIn(email: String, password: String) async throws -> User
  func register(email: String, password: String) async throws -> User
  func resetPassword(email: String) async throws
  func signOut() throws
  func signInWithGoogle(idToken: String, accessToken: String) async throws -> User
  var authStatePublisher: AnyPublisher<User?, Never> { get }
}

final class FirebaseAuthService: AuthService {
    private let subject: CurrentValueSubject<User?, Never>
    var authStatePublisher: AnyPublisher<User?, Never> {
        subject.eraseToAnyPublisher()
    }

    private var authStateHandle: AuthStateDidChangeListenerHandle?

    init() {
        let initialUser: User? = {
            guard let fbUser = Auth.auth().currentUser,
                  let mail   = fbUser.email
            else { return nil }
            return User(uid: fbUser.uid, email: mail)
        }()

        subject = CurrentValueSubject<User?, Never>(initialUser)

        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, fbUser in
            let updated: User? = {
                guard let u = fbUser, let mail = u.email else { return nil }
                return User(uid: u.uid, email: mail)
            }()
            self?.subject.send(updated)
        }
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func signIn(email: String, password: String) async throws -> User {
        do {
            let result = try await Auth.auth().signIn(
                withEmail: email,
                password: password
            )
            guard let mail = result.user.email else {
                throw AuthError.unknown
            }
            return User(uid: result.user.uid, email: mail)
        } catch {
            let ns = error as NSError
            if let code = AuthErrorCode(rawValue: ns.code) {
                switch code {
                case .wrongPassword:
                    throw AuthError.wrongPassword
                case .userNotFound:
                    throw AuthError.userNotFound
                case .networkError:
                    throw AuthError.networkError(underlying: ns)
                default:
                    throw AuthError.networkError(underlying: ns)
                }
            }
            throw AuthError.networkError(underlying: ns)
        }
    }

    func register(email: String, password: String) async throws -> User {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            try await result.user.sendEmailVerification()
            guard let mail = result.user.email else {
                throw AuthError.unknown
            }
            return User(uid: result.user.uid, email: mail)
        } catch {
            let ns = error as NSError
            if let code = AuthErrorCode(rawValue: ns.code) {
                switch code {
                case .emailAlreadyInUse:
                    throw AuthError.emailAlreadyInUse
                case .invalidEmail:
                    throw AuthError.invalidEmailFormat
                case .weakPassword:
                    throw AuthError.weakPassword
                case .operationNotAllowed:
                    throw AuthError.operationNotAllowed
                default:
                    throw AuthError.networkError(underlying: ns)
                }
            }
            throw AuthError.networkError(underlying: ns)
        }
    }

    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func signInWithGoogle(idToken: String, accessToken: String) async throws -> User {
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: accessToken
        )
        let result = try await Auth.auth().signIn(with: credential)
        guard let mail = result.user.email else {
            throw AuthError.unknown
        }
        return User(uid: result.user.uid, email: mail)
    }
}
```

### SessionStore.swift
```swift
import Foundation
import Combine
import FirebaseAuth

@MainActor
final class SessionStore: ObservableObject {
    @Published var isAuthenticated: Bool
    @Published var didFinishChecking = false

    private let authService: AuthService
    private var cancellable: AnyCancellable?

    init(authService: AuthService = FirebaseAuthService()) {
        self.authService = authService
        let initial = Auth.auth().currentUser != nil
        self.isAuthenticated = initial

        cancellable = authService.authStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.isAuthenticated     = (user != nil)
                self?.didFinishChecking   = true
            }
    }

    func logout() {
        try? authService.signOut()
    }
}
```

### RootView.swift
```swift
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

### GoogleSignInCoordinator.swift
```swift
import Foundation
import GoogleSignIn

protocol GoogleSignInCoordinator {
    func signIn() async throws -> (idToken: String, accessToken: String)
}

@MainActor
final class GoogleSignInCoordinatorImpl: GoogleSignInCoordinator {
    init(clientID: String) {
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
    }

    func signIn() async throws -> (idToken: String, accessToken: String) {
        guard
            let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
            let presenter = scene.windows.first(where: \.isKeyWindow)?
                .rootViewController
        else {
            throw AuthError.unknown
        }

        let result = try await GIDSignIn.sharedInstance.signIn(
            withPresenting: presenter
        )

        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthError.popupClosedByUser
        }
        let accessToken = result.user.accessToken.tokenString
        return (idToken, accessToken)
    }
}
```

### LoginViewModel.swift
```swift
import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email      = ""
    @Published var password   = ""
    @Published var isLoading  = false
    @Published var error: AuthError?
    @Published private(set) var canSignIn = false

    private let authService: AuthService
    private let googleCoordinator: GoogleSignInCoordinator

    private var cancellables = Set<AnyCancellable>()

    init(
        authService: AuthService,
        googleCoordinator: GoogleSignInCoordinator
    ) {
        self.authService        = authService
        self.googleCoordinator  = googleCoordinator

        Publishers.CombineLatest($email, $password)
            .map { email, pass in email.contains("@") && pass.count >= 6 }
            .assign(to: &$canSignIn)
    }

    func login() async {
        guard canSignIn else { return }
        isLoading = true; defer { isLoading = false }

        do {
            _ = try await authService.signIn(email: email, password: password)
        } catch let err as AuthError {
            self.error = err
        } catch {
            self.error = .networkError(underlying: error)
        }
    }

    func loginWithGoogle(idToken: String, accessToken: String) async {
        isLoading = true; defer { isLoading = false }

        do {
            _ = try await authService.signInWithGoogle(
                idToken:     idToken,
                accessToken: accessToken
            )
        }
        catch AuthError.popupClosedByUser {
            return
        }
        catch let err as AuthError {
            self.error = err
        }
        catch {
            self.error = .networkError(underlying: error)
        }
    }
}
```

### Экраны Auth (фрагменты)

`SimplePhotoEditor/Features/Auth/LoginView.swift`, `RegistrationView.swift`, `ResetPasswordView.swift` — актуальны и соответствуют ViewModel‑ам выше.

---

## Editor: ключевые компоненты

Ниже — два основных файла редактора. Остальные части (инструменты, превью‑слои, аксессуары клавиатуры) перечислены в структуре и доступны в `Features/Editor/`.

### EditorView.swift
```swift
import SwiftUI
import PhotosUI
import PencilKit

struct EditorView: View {
    @StateObject private var vm: EditorViewModel
    @StateObject private var keyboard = KeyboardObserver()
    @StateObject private var previewCache = FilterPreviewCache()
    
    @State private var drawing = PKDrawing()
    @State private var tool = PKInkingTool(.pen, color: .black, width: 5)
    @State private var isErasing = false
    
    @State private var showSourceDialog = false
    @State private var showCameraPicker = false
    @State private var showLibraryPicker = false
    @State private var libraryItem: PhotosPickerItem?
    @State private var shareURL: URL?
    
    @FocusState private var focusedItemID: UUID?
    private let panelH: CGFloat = 96
    
    let filters = FilterProviderImpl().allFilters()
    let onShare: () -> Void
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
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                topTools
                canvasArea
            }
        }
        
        .safeAreaInset(edge: .bottom) {
            ToolsPanel(
                mode: vm.mode,
                hasImage: vm.originalImage != nil,
                filters: filters,
                selectedFilter: $vm.selectedFilter,
                cache: previewCache,
                drawing: $drawing,
                tool: $tool,
                isErasing: $isErasing
            )
            .frame(height: panelH)
            .background(.ultraThinMaterial.opacity(0.85))
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
        .onChange(of: vm.mode) { old, new in
            if new == .text, old != .text {
                vm.textVM.enterPlacement()
            }
            if old == .text, new != .text {
                vm.textVM.finishEditing()
            }
        }
        .onChange(of: vm.originalImage) { old, image in
            vm.selectedFilter = nil
            previewCache.preparePreviews(for: image, filters: filters)
            vm.textVM.reset()
        }
    }
}

extension EditorView {
    @ViewBuilder private var topTools: some View {
        if vm.originalImage != nil {
            EditorTopBar(
                rotationCount: $vm.rotationCount,
                isFlipped: $vm.isFlippedHorizontally,
                onDrawTap: { vm.startDraw() },
                onTextTap: { vm.startText() },
                isDrawActive: vm.mode == .draw,
                isTextActive: vm.mode == .text
            )
        }
    }
    
    @ViewBuilder private var canvasArea: some View {
        PreviewArea(
            vm:        vm,
            textVM:    vm.textVM,
            drawing:   $drawing,
            tool:      $tool,
            isErasing: $isErasing,
            showSourceDialog: $showSourceDialog,
            focus: $focusedItemID,
            bottomChromeHeight: panelH
        )
        .coordinateSpace(name: "canvas")
    }
    
    @ToolbarContentBuilder private var navBar: some ToolbarContent {
        EditorNavigationBar(
            showSourceDialog: $showSourceDialog,
            isShareEnabled: vm.previewImage != nil,
            onShare: { vm.share(drawingOverlay: drawing) },
            onLogout: onLogout
        )
    }
    
    @ToolbarContentBuilder private var textToolbar: some ToolbarContent {
        if vm.mode == .text,
           vm.keyboardHeight > 0,
           vm.textVM.activeID != nil,
           vm.textVM.items.first(where: { $0.id == vm.textVM.activeID })?.isEditing == true
        {
            TextToolsToolbar(
                vm:     vm.textVM,
                onDone: {
                    vm.textVM.finishEditing()
                    focusedItemID = nil
                }
            )
        }
    }
}
```

### EditorViewModel.swift
```swift
import SwiftUI
import Combine
import PencilKit

@MainActor
final class EditorViewModel: ObservableObject {
    @Published var mode: EditorMode = .filters
    @Published var inputData: Data?
    @Published private(set) var previewImage: UIImage? = nil
    @Published private(set) var originalImage: UIImage? = nil
    
    @Published var selectedFilter: Filter? = nil
    @Published var rotationCount: Int = 0
    @Published var isFlippedHorizontally: Bool = false
    
    @Published var keyboardHeight: CGFloat = 0
    @Published var canvasSize: CGSize = .zero
    
    @Published var shareItem: ShareItem?
    
    private var pipeline: ImagePipeline
    private let exportService: ExportService
    
    let textVM = TextOverlayViewModel()
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        pipeline: ImagePipeline,
        exportService:    ExportService
    ) {
        self.pipeline = pipeline
        self.exportService = exportService
        
        Publishers
            .CombineLatest($inputData, $selectedFilter)
            .debounce(for: .milliseconds(120), scheduler: RunLoop.main)
            .sink { [weak self] raw, fx in
                guard let self = self else { return }
                Task {
                    await self.updatePreview(raw: raw, filter: fx)
                }
            }
            .store(in: &cancellables)
        
        $inputData
            .sink { [weak self] data in
                guard let data = data else {
                    self?.originalImage = nil
                    return
                }
                self?.originalImage = UIImage(data: data)
            }
            .store(in: &cancellables)
    }
    
    func setMode(_ newMode: EditorMode) {
        guard newMode != mode else { return }
        applyMode(from: mode, to: newMode)
        mode = newMode
    }
    
    func toogleMode(_ target: EditorMode) {
        setMode(mode == target ? .filters : target)
    }
    
    func startDraw() {
        toogleMode(.draw)
    }
    
    func startText() {
        toogleMode(.text)
    }
    
    func finishMarkup() {
        setMode(.filters)
    }
    
    func updateKeyboard(h: CGFloat) {
        keyboardHeight = h
    }
    
    func exportFinalImage(drawingOverlay: PKDrawing? = nil) async throws {
        let data = try await makeFinalImage(drawingOverlay: drawingOverlay)
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
    
    private func applyMode(from old: EditorMode, to new: EditorMode) {
        if new == .text, old != .text {
            textVM.enterPlacement()
        }
        if old == .text, new != .text {
            textVM.finishEditing()
        }
    }
    
    private func updatePreview(raw: Data?, filter: Filter?) async {
        guard let data = raw else {
            previewImage = nil
            return
        }
        let t0 = CFAbsoluteTimeGetCurrent()
        previewImage = await pipeline.makePreview(
            from: data,
            filterName: filter?.filterName,
            downscaleFactor: 0.25
        )
        let dt = CFAbsoluteTimeGetCurrent() - t0
        print("⏱ Preview render time: \(dt) sec")
    }
    
    private func makeFinalImage(drawingOverlay: PKDrawing?) async throws -> Data {
        guard let data = inputData, let img = originalImage, canvasSize != .zero else {
            throw OverlayRenderError.invalidBase
        }
        return try await pipeline.makeFinalImage(
            from: data,
            filterName: selectedFilter?.filterName,
            rotation: rotationCount,
            isFlipped: isFlippedHorizontally,
            drawing: drawingOverlay,
            texts: textVM.items,
            canvasSize: canvasSize,
            imageSize: img.size
        )
    }
    
    private func makeShareItem(drawingOverlay: PKDrawing?) async throws -> ShareItem {
        let data = try await makeFinalImage(drawingOverlay: drawingOverlay)
        guard let ui = UIImage(data: data) else { throw OverlayRenderError.encodeFailed }
        return ShareItem(image: ui)
    }
}
```

---

## Editor: полный исходный код (все файлы)

Ниже собраны все файлы из `SimplePhotoEditor/Features/Editor/` в одном месте.

### Features/Editor/Models/EditorMode.swift
```swift
import SwiftUI

enum EditorMode: Equatable  {
    case filters
    case draw
    case text
    
}

```

### Features/Editor/ViewModels/EditorViewModel.swift
```swift
import SwiftUI
import Combine
import PencilKit

@MainActor
final class EditorViewModel: ObservableObject {
    @Published var mode: EditorMode = .filters
    @Published var inputData: Data?
    @Published private(set) var previewImage: UIImage? = nil
    @Published private(set) var originalImage: UIImage? = nil
    
    @Published var selectedFilter: Filter? = nil
    @Published var rotationCount: Int = 0
    @Published var isFlippedHorizontally: Bool = false
    
    @Published var keyboardHeight: CGFloat = 0
    @Published var canvasSize: CGSize = .zero
    
    @Published var shareItem: ShareItem?
    
    private var pipeline: ImagePipeline
    private let exportService: ExportService
    
    let textVM = TextOverlayViewModel()
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        pipeline: ImagePipeline,
        exportService:    ExportService
    ) {
        self.pipeline = pipeline
        self.exportService = exportService
        
        Publishers
            .CombineLatest($inputData, $selectedFilter)
            .debounce(for: .milliseconds(120), scheduler: RunLoop.main)
            .sink { [weak self] raw, fx in
                guard let self = self else { return }
                Task {
                    await self.updatePreview(raw: raw, filter: fx)
                }
            }
            .store(in: &cancellables)
        
        $inputData
            .sink { [weak self] data in
                guard let data = data else {
                    self?.originalImage = nil
                    return
                }
                self?.originalImage = UIImage(data: data)
            }
            .store(in: &cancellables)
    }
    
    func setMode(_ newMode: EditorMode) {
        guard newMode != mode else { return }
        applyMode(from: mode, to: newMode)
        mode = newMode
    }
    
    func toogleMode(_ target: EditorMode) {
        setMode(mode == target ? .filters : target)
    }
    
    func startDraw() {
        toogleMode(.draw)
    }
    
    func startText() {
        toogleMode(.text)
    }
    
    func finishMarkup() {
        setMode(.filters)
    }
    
    func updateKeyboard(h: CGFloat) {
        keyboardHeight = h
    }
    
    func exportFinalImage(drawingOverlay: PKDrawing? = nil) async throws {
        let data = try await makeFinalImage(drawingOverlay: drawingOverlay)
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
    
    private func applyMode(from old: EditorMode, to new: EditorMode) {
        if new == .text, old != .text {
            textVM.enterPlacement()
        }
        if old == .text, new != .text {
            textVM.finishEditing()
        }
    }
    
    private func updatePreview(raw: Data?, filter: Filter?) async {
        guard let data = raw else {
            previewImage = nil
            return
        }
        let t0 = CFAbsoluteTimeGetCurrent()
        previewImage = await pipeline.makePreview(
            from: data,
            filterName: filter?.filterName,
            downscaleFactor: 0.25
        )
        let dt = CFAbsoluteTimeGetCurrent() - t0
        print("⏱ Preview render time: \(dt) sec")
    }
    
    private func makeFinalImage(drawingOverlay: PKDrawing?) async throws -> Data {
        guard let data = inputData, let img = originalImage, canvasSize != .zero else {
            throw OverlayRenderError.invalidBase
        }
        return try await pipeline.makeFinalImage(
            from: data,
            filterName: selectedFilter?.filterName,
            rotation: rotationCount,
            isFlipped: isFlippedHorizontally,
            drawing: drawingOverlay,
            texts: textVM.items,
            canvasSize: canvasSize,
            imageSize: img.size
        )
    }
    
    private func makeShareItem(drawingOverlay: PKDrawing?) async throws -> ShareItem {
        let data = try await makeFinalImage(drawingOverlay: drawingOverlay)
        guard let ui = UIImage(data: data) else { throw OverlayRenderError.encodeFailed }
        return ShareItem(image: ui)
    }
}
```

### Features/Editor/ViewModels/TextOverlayViewModel.swift
```swift
import SwiftUI
import Combine

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
        let gapAboveKeyboard: CGFloat = 12
        
        let y: CGFloat
        
        if keyboardH > 0 {
            y = max(frame.minY, frame.maxY - gapAboveKeyboard)
        } else {
            y = frame.canvas.height / 2
        }
        
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
        print("🔤 finishEditing() — до: activeID=\(String(describing: activeID)), items=\(items.map { \"\($0.id):\($0.isEditing)\" })")
        mutateActive { $0.isEditing = false}
        activeID = nil
        isPlacing = true
        print("🔤 finishEditing() — после: activeID=\(String(describing: activeID)), items=\(items.map { \"\($0.id):\($0.isEditing)\" })")
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

fileprivate struct CanvasFrame {
    let canvas: CGSize
    let minY: CGFloat
    let maxY: CGFloat
    
    init(canvas: CGSize, keyboard: CGFloat, imageSize: CGSize?, textH: CGFloat = 44, margin: CGFloat = 8 ) {
        let canvasRect = CGRect(origin: .zero, size: canvas)
        let fit = aspectFitRect(aspect: imageSize ?? canvas, in: canvasRect)
        
        let vInset = fit.minY
        
        minY = vInset + textH/2 + margin
        maxY = canvas.height - vInset - textH/2 - margin - keyboard
        self.canvas = canvas
        
        print("🧮 CanvasFrame",
                     "canvas:", canvas,
                     "image:", imageSize ?? .zero,
                     "fit:", fit,
                     "vInset:", vInset.rounded(),
                     "kbd:", keyboard.rounded(),
                     "minY:", minY.rounded(),
                     "maxY:", maxY.rounded())
    }
    
}
```

### Features/Editor/EditorView.swift
```swift
import SwiftUI
import PhotosUI
import PencilKit

struct EditorView: View {
    @StateObject private var vm: EditorViewModel
    @StateObject private var keyboard = KeyboardObserver()
    @StateObject private var previewCache = FilterPreviewCache()
    
    @State private var drawing = PKDrawing()
    @State private var tool = PKInkingTool(.pen, color: .black, width: 5)
    @State private var isErasing = false
    
    @State private var showSourceDialog = false
    @State private var showCameraPicker = false
    @State private var showLibraryPicker = false
    @State private var libraryItem: PhotosPickerItem?
    @State private var shareURL: URL?
    
    @FocusState private var focusedItemID: UUID?
    private let panelH: CGFloat = 96
    
    let filters = FilterProviderImpl().allFilters()
    let onShare: () -> Void
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
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                topTools
                canvasArea
            }
        }
        
        .safeAreaInset(edge: .bottom) {
            ToolsPanel(
                mode: vm.mode,
                hasImage: vm.originalImage != nil,
                filters: filters,
                selectedFilter: $vm.selectedFilter,
                cache: previewCache,
                drawing: $drawing,
                tool: $tool,
                isErasing: $isErasing
            )
            .frame(height: panelH)
            .background(.ultraThinMaterial.opacity(0.85))
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
        .onChange(of: vm.mode) { old, new in
            if new == .text, old != .text {
                vm.textVM.enterPlacement()
            }
            if old == .text, new != .text {
                vm.textVM.finishEditing()
            }
        }
        .onChange(of: vm.originalImage) { old, image in
            vm.selectedFilter = nil
            previewCache.preparePreviews(for: image, filters: filters)
            vm.textVM.reset()
        }
    }
}

extension EditorView {
    @ViewBuilder private var topTools: some View {
        if vm.originalImage != nil {
            EditorTopBar(
                rotationCount: $vm.rotationCount,
                isFlipped: $vm.isFlippedHorizontally,
                onDrawTap: { vm.startDraw() },
                onTextTap: { vm.startText() },
                isDrawActive: vm.mode == .draw,
                isTextActive: vm.mode == .text
            )
        }
    }
    
    @ViewBuilder private var canvasArea: some View {
        PreviewArea(
            vm:        vm,
            textVM:    vm.textVM,
            drawing:   $drawing,
            tool:      $tool,
            isErasing: $isErasing,
            showSourceDialog: $showSourceDialog,
            focus: $focusedItemID,
            bottomChromeHeight: panelH
        )
        .coordinateSpace(name: "canvas")
    }
    
    @ToolbarContentBuilder private var navBar: some ToolbarContent {
        EditorNavigationBar(
            showSourceDialog: $showSourceDialog,
            isShareEnabled: vm.previewImage != nil,
            onShare: { vm.share(drawingOverlay: drawing) },
            onLogout: onLogout
        )
    }
    
    @ToolbarContentBuilder private var textToolbar: some ToolbarContent {
        if vm.mode == .text,
           vm.keyboardHeight > 0,
           vm.textVM.activeID != nil,
           vm.textVM.items.first(where: { $0.id == vm.textVM.activeID })?.isEditing == true
        {
            TextToolsToolbar(
                vm:     vm.textVM,
                onDone: {
                    vm.textVM.finishEditing()
                    focusedItemID = nil
                }
            )
        }
    }
}
```

### Features/Editor/EditorNavigationBar.swift
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
        
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button(action: onShare) {
                Image(systemName: "square.and.arrow.up")
            }
            .disabled(!isShareEnabled)
            .labelStyle(.iconOnly)
            
            Button(role: .destructive, action: onLogout) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
            }
            .labelStyle(.iconOnly)
        }
    }
}
```

### Features/Editor/ImageSourcePicker.swift
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

### Features/Editor/CameraPicker.swift
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

### Features/Editor/Components/Tools/EditorTopBar.swift
```swift
import SwiftUI

struct EditorTopBar: View {
    @Binding var rotationCount: Int
    @Binding var isFlipped: Bool
    
    let onDrawTap: () -> Void
    let onTextTap: () -> Void
    let isDrawActive: Bool
    let isTextActive: Bool

    var body: some View {
        HStack(spacing: 16) {
            HStack(spacing: 12) {
                Button {
                    rotationCount += 1
                } label: {
                    Image(systemName: "rotate.right")
                }
                Button {
                    isFlipped.toggle()
                } label: {
                    Image(systemName: "arrow.left.and.right")
                }
            }

            Spacer(minLength: 0)

            HStack(spacing: 16) {
                Button(action: onDrawTap) {
                    Image(systemName: "scribble")
                }
                .tint(isDrawActive ? .accentColor : .secondary)
                
                Button(action: onTextTap) {
                    Image(systemName: "textformat")
                }
                .tint(isTextActive ? .accentColor : .secondary)
            }
        }
        .modifier(PanelSurface())
    }
}
```

### Features/Editor/Components/Tools/ToolsPanel.swift
```swift
import SwiftUI
import PencilKit

struct ToolsPanel: View {
//    @ObservedObject var vm: EditorViewModel
    let mode: EditorMode
    let hasImage: Bool
    
    let filters: [Filter]
    @Binding var selectedFilter: Filter?
    @ObservedObject var cache: FilterPreviewCache

    @Binding var drawing: PKDrawing
    @Binding var tool: PKInkingTool
    @Binding var isErasing: Bool
    
    private let panelHeight: CGFloat = 68
    
    var body: some View {
        Group {
            if  mode == .draw {
                DrawToolsPanel(
                    selectedTool: $tool,
                    isErasing: $isErasing,
                    drawing: $drawing
                )
            } else if hasImage && mode == .filters {
                FilterToolsPanel(
                    filters: filters,
                    selectedFilter: $selectedFilter,
                    cache: cache
                )
            } else {
                Color.clear.frame(height: panelHeight)
            }
        }
        .frame(height: panelHeight)
        .frame(maxWidth: .infinity)
    }
}
```

### Features/Editor/Components/Tools/DrawToolsPanel.swift
```swift
import SwiftUI
import PencilKit

struct DrawToolsPanel: View {
    @Binding var selectedTool: PKInkingTool
    @Binding var isErasing: Bool
    @Binding var drawing: PKDrawing

    var body: some View {
        HStack(spacing: 16) {
            Button { isErasing = false } label: { Image(systemName: "pencil.tip") }
                .toolIcon(active: !isErasing)
            Button { isErasing = true }  label: { Image(systemName: "eraser") }
                .toolIcon(active: isErasing)
            
            ColorPicker("", selection: Binding(
                get: { Color(selectedTool.color) },
                set: { selectedTool = PKInkingTool(selectedTool.inkType,
                                                   color: UIColor($0),
                                                   width: selectedTool.width) }
            ))
            .labelsHidden()
            .frame(width: 44, height: 44)

            Slider(value: Binding(
                get: { Double(selectedTool.width) },
                set: { selectedTool = PKInkingTool(selectedTool.inkType,
                                                   color: selectedTool.color,
                                                   width: CGFloat($0)) }
            ), in: 1...30)
            .frame(maxWidth: 120)

            Spacer()

            Button(role: .destructive) { drawing = PKDrawing() } label: {
                Image(systemName: "trash")
            }
            .destructiveIcon()
        }
        .padding(.horizontal, 16)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    @Previewable @State var selectedTool = PKInkingTool(.pen, color: .black, width: 5)
    @Previewable @State var isErasing = false
    @Previewable @State var drawing = PKDrawing()
    DrawToolsPanel(
        selectedTool: $selectedTool,
        isErasing:    $isErasing,
        drawing:      $drawing
    )
    .padding()
}
```

### Features/Editor/Components/Tools/TextToolsToolbar.swift
```swift
import SwiftUI

struct TextToolsToolbar: ToolbarContent {
    @ObservedObject var vm: TextOverlayViewModel
    let onDone: () -> Void
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            ColorPicker("", selection: $vm.currentColor)
                .labelsHidden()
                .controlSize(.small)
            
            HStack(spacing: 8) {
                Image(systemName: "textformat.size.smaller")
                Slider(value: $vm.currentSize, in: 10...72, step: 1)
                    .frame(width: 140) // фиксируем ширину
                Image(systemName: "textformat.size.larger")
            }
            
            Spacer(minLength: 8)
            
            if let id = vm.activeID {
                Button(role: .destructive) {
                    vm.remove(id: id)
                } label: { Image(systemName: "trash") }
                    .controlSize(.small)
            }
            
            Button("Готово", action: onDone)
                .controlSize(.small)
        }
    }
}
```

### Features/Editor/Components/FilterTools/FilterToolsPanel.swift
```swift
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
```

### Features/Editor/Components/FilterTools/FilterPreviewCache.swift
```swift
import UIKit
import Combine

final class FilterPreviewCache: ObservableObject {
    @Published private(set) var previews: [UUID: UIImage] = [:]
    
    private var generation = UUID()
    private var worker: Task<Void, Never>?
    
    private let previewMaxSide: CGFloat = 180
    
    func preparePreviews(for image: UIImage?, filters: [Filter]) {
        worker?.cancel()
        
        let gen = UUID()
        generation = gen
        
        guard let image = image else { return }
        
        let jobs = filters.map { (id: $0.id, name: $0.filterName) }
        let src = image
        
        let maxSide = max(src.size.width, src.size.height)
        let scale: CGFloat = maxSide > previewMaxSide ? (previewMaxSide / maxSide ) : 1
        
        worker = Task.detached(priority: .userInitiated) { [gen, jobs, src, scale] in
            print("🧩 Prepare start gen=\(gen) jobs=\(jobs.count) ")
            var out: [UUID: UIImage] = [:]
            
            for (id, name) in jobs {
                if Task.isCancelled { return }
                if let ui = Self.apply(name, to: src, scale: scale) {
                    out[id] = ui
                }
            }
            
            let result = out
            
            await MainActor.run { [weak self] in
                guard let self,gen == self.generation else { return }
                print("✅ Prepare done gen=\(gen) count=\(result.count)")
                self.previews = result
            }
        }
    }
    
    private static func apply(_ filterName: String, to image: UIImage, scale: CGFloat) -> UIImage? {
        guard var ci = CIImage(image: image) else { return image }
        ci = CIHelpers.lanczosScaled(ci, scale: scale)
        
        if !filterName.isEmpty, let fx = CIFilter(name: filterName) {
            fx.setValue(ci, forKey: kCIInputImageKey)
            ci = fx.outputImage ?? ci
        }
        let rect = ci.extent.integral
        guard let cg = CIContextPool.shared.createCGImage(ci, from: rect) else {
            return image
        }
        return UIImage(cgImage: cg, scale: image.scale, orientation: image.imageOrientation)
    }
}
```

### Features/Editor/Components/FilterTools/FilterPreviewImage.swift
```swift
import SwiftUI

struct FilterPreviewImage: View, Equatable {
    let image: UIImage?
    let name: String
    let isSelected: Bool
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.image === rhs.image && lhs.isSelected == rhs.isSelected && lhs.name == rhs.name
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Image(uiImage: image ?? UIImage())
                .resizable()
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? .blue : .clear, lineWidth: 2)
                )
            Text(name)
                .font(.caption2)
                .foregroundColor(isSelected ? .accentColor : .primary)
                .lineLimit(1)
                .frame(width: 56)
        }
    }
}

struct FilteredImage: View {
    let baseImage: UIImage?
    let filterName: String
    
    var body: some View {
        if let baseImage {
            FilteredImageView(baseImage: baseImage, filterName: filterName)
        } else {
            Color.gray.opacity(0.2)
        }
    }
}

struct FilteredImageView: UIViewRepresentable {
    let baseImage: UIImage
    let filterName: String
    
    func makeUIView(context: Context) -> UIImageView {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }
    
    func updateUIView(_ uiView: UIImageView, context: Context) {
        DispatchQueue.global(qos: .userInitiated).async {
            let outputImage: UIImage
            if filterName.isEmpty {
                outputImage = baseImage
            } else if let ciImage = CIImage(image: baseImage),
                      let filter = CIFilter(name: filterName) {
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                let context = CIContextPool.shared
                if let outputCIImage = filter.outputImage,
                   let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) {
                    outputImage = UIImage(cgImage: cgImage, scale: baseImage.scale, orientation: baseImage.imageOrientation)
                } else {
                    outputImage = baseImage // fallback
                }
            } else {
                outputImage = baseImage // fallback
            }
            DispatchQueue.main.async {
                uiView.image = outputImage
            }
        }
    }
}
```

### Features/Editor/Components/Preview/PreviewArea.swift
```swift
import SwiftUI
import PencilKit

struct PreviewArea: View {
    @ObservedObject var vm: EditorViewModel
    @ObservedObject var textVM: TextOverlayViewModel

    @Binding var drawing: PKDrawing
    @Binding var tool: PKInkingTool
    @Binding var isErasing: Bool
    @Binding var showSourceDialog: Bool
    
    let focus: FocusState<UUID?>.Binding

    var bottomChromeHeight: CGFloat = 0
    private let heightRatio: CGFloat = 0.6

    var body: some View {
        GeometryReader { geo in
            let baseImage = vm.previewImage ?? vm.originalImage
            let metrics   = CanvasMetrics(
                geo: geo,
                baseImage: baseImage,
                bottomChrome: bottomChromeHeight,
                heightRatio: heightRatio
            )
            


            VStack(spacing: 0) {
                Spacer(minLength: 0)
                CanvasStack(
                    metrics: metrics,
                    vm: vm,
                    textVM: textVM,
                    drawing: $drawing,
                    tool: $tool,
                    isErasing: $isErasing,
                    showSourceDialog: $showSourceDialog,
                    focus: focus,
                    bottomChromeHeight: bottomChromeHeight
                )
                Spacer(minLength: 0)
            }
            .frame(width: metrics.w, height: geo.size.height)
            .padding(.top, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .modifier(CanvasSync(geo: geo,
                                 metrics: metrics,
                                 bottomChromeHeight: bottomChromeHeight,
                                 vm: vm,
                                 textVM: textVM,
                                 baseImage: baseImage))
        }
    }
}
```

### Features/Editor/Components/Preview/CanvasStack.swift
```swift
import SwiftUI
import PencilKit

struct CanvasStack: View {
    let metrics: CanvasMetrics
    @ObservedObject var vm: EditorViewModel
    @ObservedObject var textVM: TextOverlayViewModel

    @Binding var drawing: PKDrawing
    @Binding var tool: PKInkingTool
    @Binding var isErasing: Bool
    @Binding var showSourceDialog: Bool

    let focus: FocusState<UUID?>.Binding
    let bottomChromeHeight: CGFloat

    @State private var scale: CGFloat = 1
    @GestureState private var pinch: CGFloat = 1

    var body: some View {
        let w = metrics.w
        let h = metrics.h
        let baseImage = vm.previewImage ?? vm.originalImage

        let pinchGesture = MagnifyGesture()
            .updating($pinch) { value, state, _ in state = value.magnification }
            .onEnded { value in scale *= value.magnification }

        ZStack {
            PhotoLayer(
                image: baseImage,
                maxSize: metrics.canvasSize,
                onAddImage: { vm.originalImage == nil ? (showSourceDialog = true) : () }
            )
            .rotationEffect(.degrees(Double(vm.rotationCount) * 90))
            .scaleEffect(x: vm.isFlippedHorizontally ? -1 : 1, y: 1)
            .animation(.easeInOut(duration: 0.3), value: vm.rotationCount)
            .animation(.easeInOut(duration: 0.3), value: vm.isFlippedHorizontally)

            if baseImage != nil {
                PencilCanvasView(drawing: $drawing, tool: tool, isErasing: isErasing)
                    .frame(width: w, height: h)
                    .allowsHitTesting(vm.mode == .draw)

                TextOverlayLayer(textVM: textVM, enabled: vm.mode == .text, focus: focus)
                    .frame(width: w, height: h)
            }

            if vm.mode == .text && textVM.isPlacing && textVM.items.isEmpty {
                Color.black.opacity(0.4).frame(width: w, height: h)
                Text("Нажмите, чтобы добавить текст")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                    .frame(width: w, height: h, alignment: .center)
            }
        }
        .frame(width: w, height: h)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .contentShape(Rectangle())
        .scaleEffect(scale * pinch)
        .clipped()
        .simultaneousGesture(pinchGesture)
    }
}
```

### Features/Editor/Components/Preview/PhotoLayer.swift
```swift
import SwiftUI

struct PhotoLayer: View {
    let image:   UIImage?
    let maxSize: CGSize
    let onAddImage: (() -> Void)?
    
    let contentMode: ContentMode
    let cornerRadius: CGFloat
    let placeholderBackground: Color
    let placeholderIconName: String
    let placeholderText: String
    
    init(
        image: UIImage?,
        maxSize: CGSize,
        onAddImage: (() -> Void)? = nil,
        contentMode: ContentMode = .fill,
        cornerRadius: CGFloat = 16,
        placeholderBackground: Color = .secondary.opacity(0.08),
        placeholderIconName: String = "photo.on.rectangle.angled",
        placeholderText: String = "Добавить изображение"
    ) {
        self.image = image
        self.maxSize = maxSize
        self.onAddImage = onAddImage
        self.contentMode = contentMode
        self.cornerRadius = cornerRadius
        self.placeholderBackground = placeholderBackground
        self.placeholderIconName = placeholderIconName
        self.placeholderText = placeholderText
    }
    
    var body: some View {
        content
            .frame(width: maxSize.width, height: maxSize.height, alignment: .center)
    }
    
    @ViewBuilder
    private var content: some View {
        if let ui = image {
            Image(uiImage: ui)
                .resizable()
                .aspectRatio(contentMode: contentMode)
                .frame(width: maxSize.width, height: maxSize.height)
                .clipped()
        } else if let onAddImage {
            Button(action: onAddImage) {
                placeholder
            }
            .buttonStyle(.plain)
        } else {
            placeholder
        }
    }
    
    private var placeholder: some View {
        VStack(spacing: 12) {
            Image(systemName: placeholderIconName)
                .resizable()
                .scaledToFit()
                .frame(width: 56, height: 56)
                .foregroundStyle(.tint)
            Text(placeholderText)
                .font(.headline)
                .foregroundStyle(.tint)
        }
        .frame(width: maxSize.width, height: maxSize.height)
        .background(placeholderBackground)
    }
    
}
```

### Features/Editor/Components/Preview/TextOverlayLayer.swift
```swift
import SwiftUI

struct TextOverlayLayer: View {
    @ObservedObject var textVM: TextOverlayViewModel
    let enabled: Bool
    let focus: FocusState<UUID?>.Binding
    

    var body: some View {
        ZStack {
            ForEach($textVM.items, id: \.id) { $item in
                TextItemView(
                    item:    $item,
                    vm:  textVM,
                    focus: focus
                )
            }
        }
    }
}
```

### Features/Editor/Components/Preview/TextItemView.swift
```swift
import SwiftUI

struct TextItemView: View {
    @Binding var item: TextItem
    let vm: TextOverlayViewModel

    let focus: FocusState<UUID?>.Binding
    @GestureState private var dragOffset: CGSize = .zero

    private var drag: some Gesture {
        DragGesture()
            .updating($dragOffset) { value, state, _ in
                guard !item.isEditing else { return }
                state = value.translation
            }
            .onEnded { value in
                guard !item.isEditing else { return }
                item.position.x += value.translation.width
                item.position.y += value.translation.height
            }
    }

    var body: some View {
        TextField("", text: $item.text)
            .id(item.id)
            .focused(focus, equals: item.id)
            .padding(6)
            .background(item.isEditing ? Color.black.opacity(0.3) : Color.clear)
            .font(.system(size: item.fontSize))
            .foregroundColor(item.color)
            .multilineTextAlignment(.center)
            .fixedSize()
            .submitLabel(.done)
            .position(x: item.position.x + dragOffset.width,
                      y: item.position.y + dragOffset.height)
            .animation(.spring(response: 0.35, dampingFraction: 0.85),
                       value: item.position)
            .simultaneousGesture(drag)
            .onTapGesture {
                if item.id == vm.activeID {
                    vm.setActive(id: item.id, editing: true)
                    focus.wrappedValue = item.id
                } else {
                    vm.setActive(id: item.id)
                }
            }
            .onAppear {
                if item.isEditing {
                    focus.wrappedValue = item.id
                }
            }
            .onSubmit {
                focus.wrappedValue = nil
                vm.finishEditing()
            }
            .onChange(of: focus.wrappedValue) {
                if focus.wrappedValue == item.id {
                    vm.setActive(id: item.id, editing: true)
                } else if item.isEditing {
                    // потеряли фокус (тап вне поля и т.п.) — завершаем
                    vm.finishEditing()
                }
            }
    }
}
```

### Features/Editor/Components/Preview/PencilCanvasView.swift
```swift
import SwiftUI
import PencilKit

struct PencilCanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    var tool: PKInkingTool
    var isErasing: Bool

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.delegate      = context.coordinator
        canvas.drawingPolicy = .anyInput
        canvas.backgroundColor = .clear
        return canvas
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        let needEraser = isErasing
        let currentEraser = uiView.tool is PKEraserTool

        if needEraser != currentEraser {
            uiView.tool = needEraser ? PKEraserTool(.bitmap) : tool
        } else if !needEraser, let ink = uiView.tool as? PKInkingTool {
            if ink.color != tool.color || ink.width != tool.width || ink.inkType != tool.inkType {
                uiView.tool = tool
            }
        }

        if uiView.drawing != drawing { uiView.drawing = drawing }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, PKCanvasViewDelegate {
        private let parent: PencilCanvasView
        init(_ parent: PencilCanvasView) { self.parent = parent }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.drawing = canvasView.drawing     // уже на Main
        }
    }
}
```

### Features/Editor/Components/KeyboardAccessory/AccessoryHostingController.swift
```swift
import SwiftUI
import UIKit

/// Контроллер, который выставляет SwiftUI‐вью как inputAccessoryView
class AccessoryHostingController<Content: View>: UIHostingController<Content> {
    override var canBecomeFirstResponder: Bool { true }
    override var inputAccessoryView: UIView? { view }
}
```

### Features/Editor/Components/KeyboardAccessory/KeyboardAccessory.swift
```swift
import SwiftUI
import UIKit

/// SwiftUI‐обёртка для InputAccessory
struct KeyboardAccessory<Content: View>: UIViewControllerRepresentable {
    let content: Content

    func makeUIViewController(context: Context) -> AccessoryHostingController<Content> {
        AccessoryHostingController(rootView: content)
    }

    func updateUIViewController(_ vc: AccessoryHostingController<Content>, context: Context) {
        vc.rootView = content
    }
}
```

### Дополнительно: файлы‑заглушки/неиспользуемые (содержимое закомментировано или пусто)

В репозитории также присутствуют файлы в редакторе, которые сейчас не используются либо закомментированы. Они включены здесь для полноты:

#### Features/Editor/EditModeSelector.swift
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

#### Features/Editor/EditorStates.swift
```swift
//import Foundation
//
//enum MarkupTool: CaseIterable, Identifiable {
//    case none
//    case draw
//    case text
//
//    var id: Self { self }
//
//    var iconName: String {
//        switch self {
//        case .none:
//            return ""
//        case .draw:
//            return "pencil.tip"
//        case .text:
//            return "textformat"
//        }
//    }
//}
```

#### Features/Editor/Components/Tab/ModeTabBar.swift
```swift

```

#### Features/Editor/Components/Tab/ModeButton.swift
```swift
import SwiftUI

struct ModeButton<Mode: Hashable>: View {
    @Binding var current: Mode
    let target: Mode
    let systemName: String
    let title: String?
    let widthFraction: CGFloat

    init(
        current: Binding<Mode>,
        target: Mode,
        systemName: String,
        title: String? = nil,
        widthFraction: CGFloat = 1.0
    ) {
        self._current = current
        self.target = target
        self.systemName = systemName
        self.title = title
        self.widthFraction = widthFraction
    }

    var body: some View {
        Button {
            current = target
        } label: {
            VStack(spacing: title == nil ? 0 : 4) {
                Image(systemName: systemName)
                    .font(.title2)
                if let title = title {
                    Text(title)
                        .font(.footnote)
                }
            }
            .foregroundColor(current == target ? .accentColor : .secondary)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .underline(
                selected: current == target,
                color: .accentColor,
                widthFraction: widthFraction,
                height: 2
            )
        }
        .buttonStyle(.plain)
    }
}
```

#### Features/Editor/Components/Preview/CanvasLayer.swift
```swift
//import SwiftUI
//import PencilKit
//
//struct CanvasLayer: View {
//    @Binding var drawing: PKDrawing
//    let tool: PKInkingTool
//    let isErasing: Bool
//    let enabled: Bool
//
//    var body: some View {
//        PencilCanvasView(drawing: $drawing,
//                         tool: tool,
//                         isErasing: isErasing)
//        .allowsHitTesting(enabled)
//    }
//}
```

#### Features/Editor/Components/Preview/ZoomableView.swift
```swift
//import SwiftUI
//
//struct ZoomableView<Content: View>: UIViewRepresentable {
//    let content: Content
//    init(@ViewBuilder _ content: () -> Content) { self.content = content() }
//    
//    func makeUIView(context: Context) -> UIScrollView {
//        let scroll = UIScrollView()
//        scroll.minimumZoomScale = 1
//        scroll.maximumZoomScale = 4
//        scroll.delegate = context.coordinator
//        
//        let host = UIHostingController(rootView: content).view!
//        host.translatesAutoresizingMaskIntoConstraints = false
//        scroll.addSubview(host)
//        
//        NSLayoutConstraint.activate([
//            host.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
//            host.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
//            host.topAnchor.constraint(equalTo: scroll.topAnchor),
//            host.bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
//            host.widthAnchor.constraint(equalTo: scroll.widthAnchor),
//            host.heightAnchor.constraint(equalTo: scroll.heightAnchor)
//        ])
//        return scroll
//    }
//    
//    func updateUIView(_ uiView: UIScrollView, context: Context) { }
//    
//    func makeCoordinator() -> Coordinator { Coordinator() }
//    final class Coordinator: NSObject, UIScrollViewDelegate {
//        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//            scrollView.subviews.first   // наш Hosting‑вью
//        }
//    }
//}
```

#### Features/Editor/Components/Tools/TopToolControls.swift
```swift
//import SwiftUI
//
//struct LeadingControls: View {
//    @Binding var rotationCount: Int
//    @Binding var isFlippedHorizontally: Bool
//
//    var body: some View {
//        HStack(spacing: 12) {
//            Button {
//                rotationCount += 1
//            } label: {
//                Image(systemName: "rotate.right")
//                    .font(.title2)
//                    .frame(width: 32, height: 32)
//            }
//
//            Button {
//                isFlippedHorizontally.toggle()
//            } label: {
//                Image(systemName: "arrow.left.and.right.righttriangle.left.righttriangle.right")
//                    .font(.title2)
//                    .frame(width: 32, height: 32)
//            }
//        }
//    }
//}
//
//struct TrailingControls: View {
//    @Binding var markup: MarkupTool
//    let onDrawTap: () -> Void
//    let onTextTap: () -> Void
//
//    var body: some View {
//        HStack(spacing: 16) {
//            // Кнопка Draw
//            Button(action: onDrawTap) {
//                Image(systemName: MarkupTool.draw.iconName)
//                    .font(.title2)
//                    .frame(width: 32, height: 32)
//                    .foregroundColor(markup == .draw ? .accentColor : .secondary)
//            }
//
//            // Кнопка Text
//            Button(action: onTextTap) {
//                Image(systemName: MarkupTool.text.iconName)
//                    .font(.title2)
//                    .frame(width: 32, height: 32)
//                    .foregroundColor(markup == .text ? .accentColor : .secondary)
//            }
//        }
//        .controlSize(.large)
//        .padding(.horizontal, 8)   
//    }
//}
```

## Примечания

- Этот README создан как единая актуальная точка входа: он очищен от дублей, соответствует исходникам и содержит ключевые код‑фрагменты. За полными деталями отдельных подсистем смотрите соответствующие файлы в дереве проекта.
