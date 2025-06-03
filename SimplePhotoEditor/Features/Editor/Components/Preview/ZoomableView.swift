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
