import SwiftUI

struct Category: View {
    @Environment(\.colorScheme) var colorScheme
    var name: String
    var image: String?
    
    var body: some View {
        
        VStack{
            VStack{
                if image != nil {
                    if let imageConverted = ImageConverter.convertImage(base64String: image!){
                        imageConverted
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 120, height: 150)
                            .clipped()
                        
                    }else{
                        Image("NoImage")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 120, height: 150)
                            .clipped()
                    }
                }else{
                    Image("NoImage")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 150)
                        .clipped()
                }
                
                Text(name)
                    .fontWeight(.light)
                    .font(Font.system(size: 20))
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                
            }
            .padding(16)
            
        }
        .background(.lightBlueD6F1FF)
        .cornerRadius(15)
    }
}
