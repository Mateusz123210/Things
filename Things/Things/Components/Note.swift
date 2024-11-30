import SwiftUI

struct Note: View{
    @Environment(\.colorScheme) var colorScheme
    var name: String
    var text: String
    
    var body: some View {
        
        HStack{
                    
            Text(name)
                .fontWeight(.bold)
                .font(Font.system(size: 24))
                .foregroundStyle(colorScheme == .dark ? .white : .black)
                .padding(16)
            
            Spacer()
            
            Text(text)
                .fontWeight(.thin)
                .font(Font.system(size: 16))
                .foregroundStyle(colorScheme == .dark ? .white : .black)
                .padding(16)
    
        }
        .background(.lightBlueD6F1FF)
        .cornerRadius(15)
        .padding([.leading, .trailing], 16)
    }
}
