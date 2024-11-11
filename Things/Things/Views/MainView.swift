import SwiftUI

struct MainView: View{
    
    @EnvironmentObject var router: Router
    
    var body: some View{
        //GeometryReader{ geometry in
            VStack{
                //var height = geometry.size.height
                //var width = geometry.size.width
                
                LogoImageView()
                
                Text("Things")
                    .bold()
                    .font(Font.system(size: 72))
                
                Text("Manage your things easier")
                    .font(Font.system(size: 20))
                
                    HStack{
                        Button("Sign in"){
                            router.navigate(destination: .login)
                        }   .fontWeight(.bold)
                            .font(Font.system(size: 32))
                            .foregroundStyle(.black)
                            .buttonStyle(.bordered)
                            .background(.lightBlueD6F1FF)
                            .cornerRadius(15)
                        
                        Button("Register"){
                            router.navigate(destination: .register)
                            
                        }   .fontWeight(.bold)
                            .font(Font.system(size: 32))
                            .foregroundStyle(.black)
                            .buttonStyle(.bordered)
                            .background(.lightBlueD6F1FF)
                            .cornerRadius(15)
                    }
                //}
            }.padding(16)
        //}
    }
    
}
