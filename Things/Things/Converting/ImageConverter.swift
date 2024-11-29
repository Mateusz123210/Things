import SwiftUI

class ImageConverter{

    static func convertImage(base64String: String) -> Image? {
        if let data = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters),
           let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
        return nil
    }
    
    static func convertImageToBase64String(_ image: UIImage) -> String? {
            guard let imageData = image.jpegData(compressionQuality: 1.0) else { return nil }
            return imageData.base64EncodedString(options: .lineLength64Characters)
        }

}




