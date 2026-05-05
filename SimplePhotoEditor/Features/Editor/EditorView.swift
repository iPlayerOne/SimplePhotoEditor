import SwiftUI
import PhotosUI
import PencilKit
import Observation


struct EditorView: View {
    @StateObject private var vm: EditorViewModel
    @StateObject private var keyboard = KeyboardObserver()
    @StateObject private var previewCache = FilterPreviewCache()
    @State private var drawing = PKDrawing()
    @State private var tool = PKInkingTool(.pen, color: .black, width: 5)
    @State private var isErasing = false
    @FocusState private var focusedItemID: UUID?
    @State private var imageSelectionToken = UUID()
    private let panelH: CGFloat = 96
    
    private let cameraAccess: CameraAccess
    let filters = FilterProviderImpl().allFilters()
    let onLogout: () -> Void
    @State private var isSourceSheetPresented = false
    @State private var armCamera: Bool = false
    @State private var armLibrary: Bool = false
    
    @State private var isCameraPresented: Bool = false
    @State private var isLibraryPresented: Bool = false
    @State private var showNoAccessAlert: Bool = false
    
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
            GeometryReader { _ in
                topTools
                    .padding(.horizontal, 8)
                    .zIndex(3)
            }
        }
        .toolbar { navBar }
        .fullScreenCover(isPresented: $isCameraPresented) {
            CameraPicker { uiImage in
                vm.handleCameraOutput(uiImage)
            }
            .ignoresSafeArea()
        }
        .photosPicker(
            isPresented: $isLibraryPresented,
            selection: Binding(
                get: { vm.libraryItem },
                set: { vm.libraryItem = $0 }
            ),
            matching: .images,
            photoLibrary: .shared()
        )
        .task(id: vm.libraryItem?.itemIdentifier) {
            vm.handleLibrarySelectionIfNeeded()
        }
        .sheet(isPresented: $isSourceSheetPresented, onDismiss: {
            if armCamera  { isCameraPresented  = true; armCamera  = false }
            if armLibrary { isLibraryPresented = true; armLibrary = false }
        }) {
            ImageSourcePicker(
                onCamera:  {
                    Task { @MainActor in
                        let result = await cameraAccess.authorizeIfNeeded()
                        switch result {
                            case .granted:
                                armCamera = true
                                isSourceSheetPresented = false
                            case .denied, .unavailable:
                                isSourceSheetPresented = false
                                showNoAccessAlert = true
                        }
                    }
                },
                onLibrary: {
                    armLibrary = true
                    isSourceSheetPresented = false
                },
                onDismiss: { isSourceSheetPresented = false }
            )
            .presentationDragIndicator(.hidden)
        }
        .sheet(item: $vm.shareItem, onDismiss: {
            vm.clearShareItem()
        }) { item in
            ShareSheet(items: [item.url])
        }
        .alert(
            String(localized: "editor.no_access_camera.title"),
            isPresented: $showNoAccessAlert
        ) {
            Button(String(localized: "common.settings")) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button(String(localized: "common.cancel"), role: .cancel) { }
        } message: {
            Text(String(localized: "editor.no_access_camera.message"))
        }
        .onReceive(keyboard.$height) { vm.updateKeyboard(h: $0) }
        .onChange(of: vm.mode) { old, new in
            if new == .text, old != .text { vm.textVM.enterPlacement(rotationQuarterTurns: vm.rotationCount) }
            if old == .text, new != .text { vm.textVM.finishEditing() }
        }
        .onChange(of: vm.inputData) { _, date in
            focusedItemID = nil
            drawing = PKDrawing()
            vm.resetForNewImage()
            previewCache.preparePreviews(for: date, filters: filters)
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
                isTextActive: vm.mode == .text,
                canTransformImage: vm.canTransformImage
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
            showSourceDialog: $isSourceSheetPresented,
            focus: $focusedItemID,
            bottomChromeHeight: panelH
        )
        .coordinateSpace(name: "canvas")
    }
    
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
                            if vm.textVM.activeID != nil {
                                TextToolsToolbar(
                                    vm: vm.textVM,
                                    onDone: {
                                        focusedItemID = nil
                                        vm.textVM.finishEditing()
                                        vm.textVM.clearSelection()
                                    }
                                )
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
            showSourceDialog: $isSourceSheetPresented,
            isShareEnabled: vm.previewImage != nil,
            onShareFormat: { format in
                vm.exportFormat = format
                vm.share(drawingOverlay: drawing)
            },
            onLogout: onLogout
        )
    }
}
