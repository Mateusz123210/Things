import SwiftUI
import AVKit
import PhotosUI

// A wrapper for the PHPickerViewController to select videos
struct VideoPicker: UIViewControllerRepresentable {
    var onPick: (URL) -> Void

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: VideoPicker

        init(parent: VideoPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            if let result = results.first {
                // Extract the video URL from the selected asset
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: "public.movie") { url, error in
                    if let url = url {
                        // Pass the video URL to the parent
                        DispatchQueue.main.async {
                            self.parent.onPick(url)
                        }
                    }
                }
            }
            picker.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .videos // Only allow videos to be selected
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // No updates required for this simple example
    }
}

struct ContentView: View {
    var body: some View {
        VideoPlayerView()
    }
}

