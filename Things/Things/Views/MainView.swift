import SwiftUI

struct MainView: View{
    
    @EnvironmentObject var router: Router
    @State private var screenHeight = UIScreen.main.bounds.height
    @State private var screenWidth = UIScreen.main.bounds.width
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @State private var orientation: UIDeviceOrientation = UIDevice.current.orientation
    @State private var logoOpacity = 0.2
    @State private var textScale = 0.6
    @State private var secondTextOpacity = 0.0
    @State private var buttonsOpacity = 0.0
    @State private var colorProgress = 0.0

    var body: some View{
        Group {
            if(orientation == UIDeviceOrientation.landscapeLeft || orientation == UIDeviceOrientation.landscapeRight){
                HStack {
                    VStack{
                        LogoImageView(opacity: logoOpacity)
                    }.frame(width: screenWidth / 2)
                    VStack{
                        
                        Text("Things")
                            .bold()
                            .font(Font.system(size: 72))
                            .scaleEffect(textScale)
                            .foregroundStyle(animateColor(progress: colorProgress))
                            .padding(.bottom, 0.2 * screenHeight)
                        
                        
                        Text("Manage your things easier")
                            .font(Font.system(size: 20))
                            .foregroundStyle(.lightBlack202C37)
                            .opacity(secondTextOpacity)
                            .padding(.bottom, 0.05 * screenHeight)
                        
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
                    }   .padding(16)
                        .onAppear(perform: {
                            animate()
                        })
                        .frame(width: screenWidth / 2)
                }
            }else{
                VStack{
                    
                    LogoImageView(opacity: logoOpacity, padding: 0.1 * screenHeight)
                    
                    Text("Things")
                        .bold()
                        .font(Font.system(size: 72))
                        .scaleEffect(textScale)
                        .foregroundStyle(animateColor(progress: colorProgress))
                        .padding(.bottom, 0.2 * screenHeight)
                    
                    
                    Text("Manage your things easier")
                        .font(Font.system(size: 20))
                        .foregroundStyle(.lightBlack202C37)
                        .opacity(secondTextOpacity)
                        .padding(.bottom, 0.05 * screenHeight)
                    
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
                }   .padding(16)
                    .onAppear(perform: {
                        animate()
                    })
            }
            
        } .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in

            
            if (UIDevice.current.orientation != UIDeviceOrientation.portraitUpsideDown){
                orientation = UIDevice.current.orientation
            }
            
        }
        .onChange(of: horizontalSizeClass) {
            updateScreenSize()
        }
        .onChange(of: verticalSizeClass) {
            updateScreenSize()
        }

    }
    
    private func updateScreenSize() {
        screenHeight = UIScreen.main.bounds.height
        screenWidth = UIScreen.main.bounds.width
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
