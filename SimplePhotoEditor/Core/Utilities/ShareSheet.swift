import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    var excluded: [UIActivity.ActivityType]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        vc.excludedActivityTypes = excluded
        return vc
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
