// EditorView.swift

import SwiftUI
import PhotosUI
import PencilKit

/// Основной экран редактора фото
struct EditorView: View {
    // 1) ViewModel + KeyboardObserver
    @StateObject private var vm: EditorViewModel
    @StateObject private var keyboard = KeyboardObserver()

    // 2) Callbacks
    let onShare:  () -> Void
    let onLogout: () -> Void

    // 3) Canvas state
    @State private var drawing   = PKDrawing()
    @State private var tool      = PKInkingTool(.pen, color: .black, width: 5)
    @State private var isErasing = false

    // 4) Image picker
    @State private var showSourceDialog = false
    @State private var showCameraPicker = false
    @State private var showLibraryPicker = false
    @State private var libraryItem: PhotosPickerItem?

    // 5) Filter preview cache
    @StateObject private var previewCache = FilterPreviewCache()
    let filters = FilterProviderImpl().allFilters()

    // 5) Init
    init(
        vm: EditorViewModel,
        onShare: @escaping () -> Void,
        onLogout: @escaping () -> Void
    ) {
        print("🚀 EditorView init")
        _vm = StateObject(wrappedValue: vm)
        self.onShare  = onShare
        self.onLogout = onLogout
    }

    var body: some View {
//        NavigationStack {
            VStack(spacing: 0) {
                // ─── Верхняя панель: Transform + выбор инструментов Draw/Text ───
                if vm.originalImage != nil {
                    TopToolsPanel(vm: vm)
                }

                // ─── Канва (PencilKit + TextOverlay) ───
                PreviewArea(
                    vm:        vm,
                    textVM:    vm.textVM,
                    drawing:   $drawing,
                    tool:      $tool,
                    isErasing: $isErasing,
                    showSourceDialog: $showSourceDialog
                )
                .coordinateSpace(name: "canvas")

                // ─── Панель инструментов снизу (DrawToolsPanel) ───
                ToolsPanel(
                    vm:       vm,
                    drawing:   $drawing,
                    tool:      $tool,
                    isErasing: $isErasing
                )

                // ─── Панель фильтров всегда доступна ───
                if vm.originalImage != nil {
                    FilterToolsPanel(
                        filters: filters,
                        selectedFilter: $vm.selectedFilter,
                        cache: previewCache
                    )
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)

            // ─── Toolbar сверху: Share/Save/Logout и кастомный TextToolbar ───
            .toolbar {
                // 1) Кнопки Share / Save / Logout
                EditorNavigationBar(
                    showSourceDialog: $showSourceDialog,
                    isShareEnabled: vm.previewImage != nil,
                    onShare: onShare,
                    isSaveEnabled: vm.previewImage != nil,
                    onSave: {
                        let overlay = drawing.dataRepresentation()
                        Task { try? await vm.exportFinalImage(drawingOverlay: overlay) }
                    },
                    onLogout: onLogout
                )

                if vm.markup == .text,
                   vm.textVM.items.contains(where: { $0.isEditing }) {
                    TextToolsToolbar(
                        vm:     vm.textVM,
                        onDone: vm.textVM.finishEditing
                    )
                }
            }

            // ─── Overlay для выбора нового изображения (камера / библиотека) ───
            .overlay {
                ImageSourcePicker(
                    showDialog:  $showSourceDialog,
                    showCamera:  $showCameraPicker,
                    showLibrary: $showLibraryPicker,
                    libraryItem: $libraryItem
                ) { data in
                    vm.inputData = data
                }
            }

            // ─── Подписываемся на высоту клавиатуры, чтобы VM получил h и мог передать в placeCentered() ───
            .onReceive(keyboard.$height) { newH in
                vm.updateKeyboard(h: newH)
            }

            // ─── Отдельно: при смене режима markup → если это "Text", то переходим в isPlacing mode ───
            .onChange(of: vm.markup) { old, new in
                if new == .text {
                    vm.textVM.enterPlacement()
                } else {
                    // из текстового режима ушли — закрываем все поля
                    vm.textVM.finishEditing()
                }
            }

            // ─── При смене изображения ───
            .onChange(of: vm.originalImage) { old, image in
                previewCache.preparePreviews(for: image, filters: filters)
                vm.textVM.reset()
            }

            .onAppear {
                if let image = vm.originalImage {
                    previewCache.preparePreviews(for: image, filters: filters)
                }
            }
//        }
    }
}
