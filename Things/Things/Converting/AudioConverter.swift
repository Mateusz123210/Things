import SwiftUI
import Foundation


class AudioConverter {
    static func convertBase64StringToAudio(_ base64String: String) -> URL? {
        guard let data = Data(base64Encoded: base64String) else {
            print("Error decoding Base64 string.")
            return nil
        }
        
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempFileURL = tempDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mp3")
        
        do {
            try data.write(to: tempFileURL)
            return tempFileURL
        } catch {
            print("Error writing audio data to file: \(error)")
            return nil
        }
    }
}
