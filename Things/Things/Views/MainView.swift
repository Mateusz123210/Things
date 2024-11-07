import SwiftUI

struct MainView: View{
    
    @EnvironmentObject var router: Router
    
    var body: some View{
        VStack{
            LogoImageView()
            
            Text("Things")
                .bold()
                .font(Font.system(size: 72))
            
            Text("Manage your things easier")
                .font(Font.system(size: 20))
            
            Button("** Go to register view **"){
                router.navigate(destination: .register)
            }
            
            Button("** Go to product view **"){
                router.navigate(destination: .product(productName: "A"))
            }
            
        }
       
    }
    
}
