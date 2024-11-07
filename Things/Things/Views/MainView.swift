import SwiftUI

struct MainView: View{
    
    
    
    var body: some View{
        VStack{
            LogoImageView()
            
            Text("Things")
                .bold()
                .font(Font.system(size: 72))
            
            Text("Manage your things easier")
                .font(Font.system(size: 20))
            
            
            
            
        }
       
    }
    
}
