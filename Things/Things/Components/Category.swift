import SwiftUI

struct Category: View{
    @Environment(\.colorScheme) var colorScheme
    var name: String
    var image: String?
    var marked: Bool = false
    
    var body: some View {
        
        VStack{
            VStack{
                if marked == false {
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
                }else{
                    ZStack {
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
                        .opacity(0.4)
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 32))
                            .background(.lightBlue00A7FF)
                            .clipShape(Circle())
                        
                        
                    }
                }
                
            }
            .padding(16)
            
        }
        .background(.lightBlueD6F1FF)
        .cornerRadius(15)
    }
}
