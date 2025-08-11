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
