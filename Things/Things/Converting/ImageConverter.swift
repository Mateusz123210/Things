import SwiftUI

class ImageConverter{

    static func convertImage(base64String: String) -> Image? {
        if let data = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters),
           let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
        return nil
    }
}




