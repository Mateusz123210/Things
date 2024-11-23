import SwiftUI

struct Category: View {
//    @Binding var name: String
//    @Binding var image: String
    var name: String
    var image: String
    
    var body: some View {
        
        VStack{
            
            if let imageConverted = ImageConverter.convertImage(base64String: image){
                imageConverted
                    .resizable()
                    .frame(width: 100, height: 100)
                
            }else{
                Text("No Image")
            }
            Text(name)
            
        }
    }
}
