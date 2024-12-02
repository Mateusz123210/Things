import SwiftUI
import AVKit
import PhotosUI

// SwiftUI View to display the video player
struct VideoPlayerView: View {
    @State private var showPicker = false
    @State private var selectedVideoURL: URL?
    @State private var player: AVPlayer?

    var body: some View {
        VStack {
            if let videoURL = selectedVideoURL {
                // Show the AVPlayerViewController when a video is selected
                VideoPlayer(player: player)
                    .frame(height: 300)
                    .onAppear {
                        // Ensure player is set up and starts playing
                        if let videoURL = selectedVideoURL {
                            player = AVPlayer(url: videoURL)
                            player?.play()
                        }
                    }
            } else {
                Button("Select Video from Photos") {
                    showPicker.toggle()
                }
                .sheet(isPresented: $showPicker) {
                    // Show the PHPickerViewController
                    PhotoPicker { url in
                        self.selectedVideoURL = url
                    }
                }
            }
        }
        .padding()
    }
}

// A wrapper for the PHPickerViewController to select videos
struct PhotoPicker: UIViewControllerRepresentable {
    var onPick: (URL) -> Void

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: PhotoPicker

        init(parent: PhotoPicker) {
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
                    } else {
                        print("Failed to load video file: \(error?.localizedDescription ?? "Unknown error")")
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




