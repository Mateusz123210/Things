import SwiftUI
import AVFoundation

struct Audio: View {
    @Binding var audioFileURL: URL?
    @Binding var audioFileName: String?
    @Binding var showDocumentPicker: Bool
    @Binding var audioPlayer: AVAudioPlayer?
    @Binding var isPlaying: Bool
    
    private func playAudio() {
        guard let url = audioFileURL else { return }
        
        if audioPlayer == nil {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
            } catch {
                print("Error initializing audio player: \(error.localizedDescription)")
            }
        }
        
        if let player = audioPlayer, !player.isPlaying {
            player.play()
            isPlaying = true
        } else {
            audioPlayer?.pause()
            isPlaying = false
        }
    }
    
    private func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
    }
    
    var body: some View {
        VStack(spacing: 20) {
           // Display selected file name
           if let fileName = audioFileName {
               Text("Uploaded File: \(fileName)")
                   .font(.headline)
                   .padding()
           } else {
               Text("No audio file selected")
                   .foregroundColor(.gray)
           }
           
           // Button to select audio file
           Button(action: {
               showDocumentPicker = true
           }) {
               Text("Upload Audio")
                   .foregroundColor(.white)
                   .padding()
                   .background(Color.blue)
                   .cornerRadius(10)
           }
           
           // Play and Pause Buttons
           if let _ = audioFileURL {
               HStack(spacing: 20) {
                   Button(action: playAudio) {
                       Text(isPlaying ? "Pause" : "Play")
                           .foregroundColor(.white)
                           .padding()
                           .background(isPlaying ? Color.red : Color.green)
                           .cornerRadius(10)
                   }
                   Button(action: stopAudio) {
                       Text("Stop")
                           .foregroundColor(.white)
                           .padding()
                           .background(Color.gray)
                           .cornerRadius(10)
                   }
               }
           }
       }
       .sheet(isPresented: $showDocumentPicker) {
           DocumentPicker(audioFileURL: $audioFileURL, audioFileName: $audioFileName)
       }
       .padding()
        
    }
}


