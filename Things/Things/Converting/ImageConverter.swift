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

import SwiftUI


extension UIImage {

    func resizeProportionally(toFit targetSize: CGSize) -> UIImage? {
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let scaleFactor = min(widthRatio, heightRatio)
        
        let newSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}




