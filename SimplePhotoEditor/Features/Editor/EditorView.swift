import SwiftUI
import PhotosUI
import PencilKit
import Observation
import CoreImage

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
    
    // NEW: диалог выбора формата шаринга
    @State private var showShareFormatDialog = false
    
    @FocusState private var focusedItemID: UUID?
    @State private var imageSelectionToken = UUID()
    private let panelH: CGFloat = 96
    
    private let cameraAccess: CameraAccess
    let filters = FilterProviderImpl().allFilters()
    let onLogout: () -> Void
    
    init(
        vm: EditorViewModel,
        cameraAccess: CameraAccess,
        onLogout: @escaping () -> Void
    ) {
        _vm = StateObject(wrappedValue: vm)
        self.cameraAccess = cameraAccess
        self.onLogout = onLogout
    }
    
    var body: some View {
        ZStack {
            canvasArea
                .id(imageSelectionToken)
                .ignoresSafeArea(.keyboard, edges: .bottom)

            bottomTools
                .zIndex(2)
        }
        .overlay(alignment: .top) {
            GeometryReader { geo in
                topTools
                    .padding(.horizontal, 8)
//                    .padding(.top, geo.safeAreaInsets.top - 12)
                    .zIndex(3)
            }
        }
        .toolbar {
            navBar
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
        // NEW: диалог выбора формата при каждом Share
        .confirmationDialog(
            String(localized: "Выберите формат"),
            isPresented: $showShareFormatDialog
        ) {
            Button("Поделиться как PNG") {
                vm.exportAsPNG = true
                vm.share(drawingOverlay: drawing)
            }
            Button("Поделиться как JPEG") {
                vm.exportAsPNG = false
                vm.share(drawingOverlay: drawing)
            }
            Button(String(localized: "common.cancel"), role: .cancel) { }
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
            focusedItemID = nil
            vm.textVM.finishEditing()
            vm.selectedFilter = nil
            drawing = PKDrawing()
            vm.textVM.reset()
            previewCache.preparePreviews(for: image, filters: filters)
            imageSelectionToken = UUID()
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
    
//    @ViewBuilder private var bottomTools: some View {
//        GeometryReader { geo in
//            Color.clear
//                .overlay(alignment: .bottom) {
//                    
//                    switch vm.mode {
//                    case .draw, .filters:
//                        ToolsPanel(
//                            mode: vm.mode,
//                            hasImage: vm.originalImage != nil,
//                            filters: filters,
//                            selectedFilter: $vm.selectedFilter,
//                            cache: previewCache,
//                            drawing: $drawing,
//                            tool: $tool,
//                            isErasing: $isErasing
//                        )
//                        .frame(maxWidth: .infinity)
//                        .padding(.horizontal, 12)
//                        .padding(.bottom, geo.safeAreaInsets.bottom + 12)
//                        .transition(.move(edge: .bottom).combined(with: .opacity))
//
//                    case .text:
//                        if vm.textVM.activeID != nil,
//                           vm.textVM.items.first(where: { $0.id == vm.textVM.activeID })?.isEditing == true
//                        {
//                            Rectangle()
//                                .fill(Color.red.opacity(0.2))
//                                .frame(height: 2)
//                                .overlay(Text("kb=\(Int(vm.keyboardHeight))  sa=\(Int(geo.safeAreaInsets.bottom))").font(.caption2))
//
//                            // И разовый принт:
//                            Color.clear
//                                .frame(width: 0, height: 0)
//                                .task {
//                                    print("kb=\(vm.keyboardHeight), sa=\(geo.safeAreaInsets.bottom)")
//                                }
//
//                            TextToolsToolbar(
//                                vm: vm.textVM,
//                                onDone: {
//                                    vm.textVM.finishEditing()
//                                    focusedItemID = nil
//                                }
//                            )
//                            .padding(.horizontal, 12)
//                            .padding(.bottom, vm.keyboardHeight + geo.safeAreaInsets.bottom + 8)
//                            .transition(.move(edge: .bottom).combined(with: .opacity))
//                        }
//                    }
//                }
//        }
//        .animation(.snappy, value: vm.mode)
//        .animation(.snappy, value: vm.keyboardHeight)
//    }
    
    @ViewBuilder private var bottomTools: some View {
        Color.clear
            .safeAreaInset(edge: .bottom) {
                Group {
                    switch vm.mode {
                    case .draw, .filters:
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
                        .padding(.horizontal, 12)

                    case .text:
                        if vm.keyboardHeight > 0 {
                            TextToolsToolbar(
                                vm: vm.textVM,
                                onDone: {
                                    vm.textVM.finishEditing()
                                    focusedItemID = nil
                                }
                            )
//                            .padding(.horizontal, 12)
//                            .padding(.bottom, 8)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                }
            }
            .animation(.snappy, value: vm.mode)
            .animation(.snappy, value: vm.keyboardHeight)
    }
    
    @ToolbarContentBuilder private var navBar: some ToolbarContent {
        EditorNavigationBar(
            showSourceDialog: $showSourceDialog,
            isShareEnabled: vm.previewImage != nil,
            onShare: {
                // вместо прямого vm.share — показываем диалог выбора формата
                showShareFormatDialog = true
            },
            onLogout: onLogout
        )
    }
    
    //    @ToolbarContentBuilder private var textToolbar: some ToolbarContent {
    //        if vm.mode == .text,
    //           vm.keyboardHeight > 0,
    //           vm.textVM.activeID != nil,
    //           vm.textVM.items.first(where: { $0.id == vm.textVM.activeID })?.isEditing == true
    //        {
    //            TextToolsToolbar(
    //                vm:     vm.textVM,
    //                onDone: {
    //                    vm.textVM.finishEditing()
    //                    focusedItemID = nil
    //                }
    //            )
    //        }
    //    }
}

// MARK: - Previews and preview-only helpers

// Приватная заглушка доступа к камере для превью
private struct PreviewCameraAccess: CameraAccess {
    func authorizeIfNeeded() async -> CameraGateResult { .granted }
}

// Приватная заглушка экспорт-сервиса для превью
private final class DummyExportService: ExportService {
    func makeShareURL(from data: Data) throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".jpg")
        try data.write(to: url, options: .atomic)
        return url
    }
    // NEW: реализуем PNG-перегрузку, чтобы соответствовать протоколу
    func makeShareURL(from data: Data, asPNG: Bool) throws -> URL {
        if asPNG {
            guard let ui = UIImage(data: data),
                  let png = ui.pngData()
            else { throw ExportError.encodeFailed }
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("png")
            try png.write(to: url, options: .atomic)
            return url
        } else {
            return try makeShareURL(from: data)
        }
    }
    func saveToPhotos(_ data: Data) async throws {
        // В превью ничего не делаем
    }
}

// Приватный, упрощённый пайплайн для превью
private final class DummyPipeline: ImagePipeline {
    private let overlay = OverlayRenderServiceImpl()
    private let ciContext = CIContext(options: [.priorityRequestLow: true])

    func makePreview(from data: Data, filterName: String?, downscaleFactor: CGFloat) async -> UIImage? {
        await Task.detached(priority: .userInitiated) {
            guard let ui = UIImage(data: data) else { return nil }
            return self.apply(filterName: filterName, to: ui, downscale: downscaleFactor) ?? ui
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
        try await Task.detached(priority: .userInitiated) {
            guard var ui = UIImage(data: data) else { throw OverlayRenderError.invalidBase }

            // Поворот и отражение (упрощённо)
            if rotation != 0 { ui = self.rotate90(ui, times: rotation) }
            if isFlipped { ui = self.flipHorizontal(ui) }

            // Фильтр (если задан)
            if let filtered = self.apply(filterName: filterName, to: ui, downscale: 1.0) {
                ui = filtered
            }

            guard let jpeg = ui.jpegData(compressionQuality: 0.9) else {
                throw OverlayRenderError.encodeFailed
            }

            let hasTexts = !(texts?.isEmpty ?? true)
            if drawing != nil || hasTexts {
                return try self.overlay.apply(
                    drawing: drawing,
                    texts: texts,
                    to: jpeg,
                    canvasSize: canvasSize,
                    imageSize: imageSize
                )
            } else {
                return jpeg
            }
        }.value
    }

    // MARK: - Helpers

    private func apply(filterName: String?, to ui: UIImage, downscale: CGFloat) -> UIImage? {
        guard var ci = CIImage(image: ui) else { return nil }

        if downscale < 0.999 {
            ci = CIHelpers.lanczosScaled(ci, scale: downscale)
        }

        if let name = filterName, !name.isEmpty, let fx = CIFilter(name: name) {
            fx.setValue(ci, forKey: kCIInputImageKey)
            ci = fx.outputImage ?? ci
        }

        let snapped = ci.snappedForDisplay()
        guard let cg = ciContext.createCGImage(snapped, from: snapped.extent) else { return nil }
        return UIImage(cgImage: cg, scale: ui.scale, orientation: ui.imageOrientation)
    }

    private func rotate90(_ ui: UIImage, times: Int) -> UIImage {
        let t = ((times % 4) + 4) % 4
        guard t != 0 else { return ui }
        var image = ui
        for _ in 0..<t {
            let size = CGSize(width: image.size.height, height: image.size.width)
            let format = UIGraphicsImageRendererFormat()
            format.scale = image.scale
            format.opaque = true
            let renderer = UIGraphicsImageRenderer(size: size, format: format)
            image = renderer.image { ctx in
                ctx.cgContext.translateBy(x: size.width / 2, y: size.height / 2)
                ctx.cgContext.rotate(by: .pi / 2)
                image.draw(in: CGRect(x: -image.size.width/2, y: -image.size.height/2, width: image.size.width, height: image.size.height))
            }
        }
        return image
    }

    private func flipHorizontal(_ ui: UIImage) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = ui.scale
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: ui.size, format: format)
        return renderer.image { ctx in
            ctx.cgContext.translateBy(x: ui.size.width, y: 0)
            ctx.cgContext.scaleBy(x: -1, y: 1)
            ui.draw(in: CGRect(origin: .zero, size: ui.size))
        }
    }
}

// Быстрый генератор однотонной картинки для превью
private func previewImageData(
    _ color: UIColor = .systemBlue,
    size: CGSize = .init(width: 1200, height: 1800),
    scale: CGFloat = 2
) -> Data {
    let format = UIGraphicsImageRendererFormat()
    format.scale = scale
    let img = UIGraphicsImageRenderer(size: size, format: format).image { ctx in
        color.setFill()
        ctx.fill(CGRect(origin: .zero, size: size))
    }
    return img.jpegData(compressionQuality: 0.9) ?? Data()
}

// MARK: - Previews

#Preview("Editor • Filters") {
    let vm = EditorViewModel(
        pipeline: DummyPipeline(),
        exportService: DummyExportService()
    )
    vm.inputData = previewImageData(.systemBlue)
    vm.mode = .filters

    return EditorView(
        vm: vm,
        cameraAccess: PreviewCameraAccess(),
        onLogout: {}
    )
}

#Preview("Editor • Draw") {
    let vm = EditorViewModel(
        pipeline: DummyPipeline(),
        exportService: DummyExportService()
    )
    vm.inputData = previewImageData(.systemTeal)
    vm.mode = .draw

    return EditorView(
        vm: vm,
        cameraAccess: PreviewCameraAccess(),
        onLogout: {}
    )
}

#Preview("Editor • Text") {
    let vm = EditorViewModel(
        pipeline: DummyPipeline(),
        exportService: DummyExportService()
    )
    vm.inputData = previewImageData(.systemIndigo)
    vm.mode = .text
    vm.updateKeyboard(h: 280) // имитация клавиатуры

    let item = TextItem(
        text: "Hello, Vanya!",
        font: .system,
        fontSize: 24,
        color: .white,
        position: CGPoint(x: 200, y: 300),
        isEditing: true
    )
    vm.textVM.items = [item]
    vm.textVM.activeID = item.id

    return EditorView(
        vm: vm,
        cameraAccess: PreviewCameraAccess(),
        onLogout: {}
    )
}
