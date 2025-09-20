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
    
    private let cameraAccess: CameraAccess
    let filters = FilterProviderImpl().allFilters()
//    let onShare: () -> Void
    let onLogout: () -> Void
    
    init(
        vm: EditorViewModel,
        cameraAccess: CameraAccess,
//        onShare: @escaping () -> Void,
        onLogout: @escaping () -> Void
    ) {
        _vm = StateObject(wrappedValue: vm)
        self.cameraAccess = cameraAccess
//        self.onShare  = onShare
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
            drawing = PKDrawing()
            vm.textVM.reset()
            previewCache.preparePreviews(for: image, filters: filters)
            
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
