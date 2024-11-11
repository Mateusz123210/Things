import SwiftUI

struct MainView: View{
    
    @EnvironmentObject var router: Router
    @State private var logoOpacity = 0.2
    @State private var textScale = 0.6
    @State private var secondTextOpacity = 0.0
    @State private var buttonsOpacity = 0.0
    @State private var colorProgress = 0.0
    
    var body: some View{
        //GeometryReader{ geometry in
        VStack{
            //var height = geometry.size.height
            //var width = geometry.size.width
            
            LogoImageView(opacity: logoOpacity)
            
            Text("Things")
                .bold()
                .font(Font.system(size: 72))
                .scaleEffect(textScale)
                .foregroundStyle(animateColor(progress: colorProgress))
            
            
            Text("Manage your things easier")
                .font(Font.system(size: 20))
                .foregroundStyle(.lightBlack202C37)
                .opacity(secondTextOpacity)
            
            HStack{
                Button("Sign in"){
                    router.navigate(destination: .login)
                }   .fontWeight(.bold)
                    .font(Font.system(size: 32))
                    .foregroundStyle(.black)
                    .buttonStyle(.bordered)
                    .background(.lightBlueD6F1FF)
                    .cornerRadius(15)
                    .opacity(buttonsOpacity)
                
                Button("Register"){
                    router.navigate(destination: .register)
                    
                }   .fontWeight(.bold)
                    .font(Font.system(size: 32))
                    .foregroundStyle(.black)
                    .buttonStyle(.bordered)
                    .background(.lightBlueD6F1FF)
                    .cornerRadius(15)
                    .opacity(buttonsOpacity)
            }
            //}
        }   .padding(16)
            .onAppear(perform: {
                animate()})
        //}
    }
    
    func animate(){
            
            var counter = 0
            
            logoOpacity = 0.2
            textScale = 0.6
            secondTextOpacity = 0.0
            buttonsOpacity = 0.0
            colorProgress = 0.0
            
            withAnimation(.easeInOut(duration: 0.75)){
                logoOpacity += 0.8
            }
            
            withAnimation(.easeInOut(duration: 1.5)){
                textScale += 0.4
            }
        
            withAnimation(.easeInOut(duration: 2.0)){
                colorProgress += 1.0
            }
        
            Timer.scheduledTimer(withTimeInterval: 0.025, repeats: true){timer in
                
                if (counter > 62){
                    if(counter <= 82){
                        secondTextOpacity += 0.05
                    }else{
                        if (counter <= 90){
                            buttonsOpacity += 0.125
                        }
                        else{
                            timer.invalidate()
                        }
                        
                    }
                }
                
                counter += 1
            }
    }
    
    func animateColor(progress: Double) -> Color{
        let blue: Double = 1.0 - colorProgress * colorProgress * colorProgress
        return Color(red: 0.0, green: 0.0, blue: blue)
    }
}
