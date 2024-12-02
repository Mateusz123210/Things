import SwiftUI

struct Product: View{
    @Environment(\.colorScheme) var colorScheme
    var name: String
    var photo: String?
    var quantity: String
    var marked: Bool
    var markingEnabled: Bool
    var small: Bool = false
    
    var body: some View {

        if marked == false {
            
            HStack{
                if markingEnabled == true {
                    Image(systemName: "circle")
                        .font(.system(size: small == false ? 32 : 22))
                        .background(.white)
                        .clipShape(Circle())
                        .padding([.leading, .trailing, .top],16)
                        .padding(.bottom, small == false ? 16 : 8)
                }
                
                Text(name)
                    .fontWeight(.bold)
                    .font(Font.system(size: small == false ? 28 : 22))
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                    .padding(16)
                
                Spacer()
                
                VStack{
                    if photo != nil {
                        if let imageConverted = ImageConverter.convertImage(base64String: photo!){
                            imageConverted
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 75)
                                .clipped()
                            
                        }else{
                            Image("NoImage")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 75)
                                .clipped()
                        }
                    }else{
                        Image("NoImage")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 75)
                            .clipped()
                    }
                }
                .padding(16)
                
                Spacer()
                
                Text(quantity)
                    .fontWeight(.thin)
                    .font(Font.system(size: small == false ? 24 : 20))
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                    .padding(16)
                
            }
            .background(.lightBlueD6F1FF)
            .cornerRadius(15)
            .padding([.leading, .trailing], 16)
        } else {
                
            HStack{
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: small == false ? 32 : 22))
                    .background(.white)
                    .clipShape(Circle())
                    .padding([.leading, .bottom, .top],16)
                    .padding(.trailing, small == false ? 16 : 8)
            
                
                Text(name)
                    .fontWeight(.bold)
                    .font(Font.system(size: small == false ? 28 : 22))
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                    .padding(16)
                
                Spacer()
                
                VStack{
                    if photo != nil {
                        if let imageConverted = ImageConverter.convertImage(base64String: photo!){
                            imageConverted
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 75)
                                .clipped()
                            
                        }else{
                            Image("NoImage")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 75)
                                .clipped()
                        }
                    }else{
                        Image("NoImage")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 75)
                            .clipped()
                    }
                }
                .padding(16)
                
                Spacer()
                
                Text(quantity)
                    .fontWeight(.thin)
                    .font(Font.system(size: small == false ? 24 : 20))
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                    .padding(16)
                
            }
            .background(.lightBlueD6F1FF)
            .cornerRadius(15)
            .padding([.leading, .trailing], 16)
            .opacity(0.4)
                
        }
    }
}
