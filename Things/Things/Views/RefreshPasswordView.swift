import SwiftUI

struct RefreshPasswordView: View{
    
    @EnvironmentObject var router: Router
    @Environment(\.colorScheme) var colorScheme
    @State private var screenHeight = UIScreen.main.bounds.height
    @State private var screenWidth = UIScreen.main.bounds.width
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @State private var orientation: UIDeviceOrientation = UIDevice.current.orientation
    @State private var email: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    private let validator = Validator()
    
    let refreshPasswordService = RefreshPasswordService()
    
    func showAlert(message: String){
        alertMessage = message
        showAlert = true
    }
    
    func refreshed(){
        email = ""
        router.navPath.removeLast()
        router.navigate(destination: .login)
    }
    
    func refreshPassword(){
        if(validator.validateEmail(email: email) == false){
            showAlert(message: "Invalid email")
            return
        }
        
        let schema = EmailSchema(email: email)
        refreshPasswordService.refreshPassword(data: schema, viewRef: self)
        
    }
    
    var body: some View{
        Group {
            if(orientation == UIDeviceOrientation.landscapeLeft || orientation == UIDeviceOrientation.landscapeRight){
                HStack {
                    VStack{
                        LogoImageView()
                    }.frame(width: 0.4 * screenWidth)
                    VStack{
                        Text("Refresh password")
                            .fontWeight(.semibold)
                            .font(Font.system(size: 40))
                            .padding(.bottom,(screenHeight > 500 ? (0.02 * screenHeight) : (0.01 * screenHeight)))
                        Text("Email")
                            .fontWeight(.light)
                            .font(Font.system(size: 28))
                            .foregroundStyle(.lightBlack202C37)
                            .padding(.bottom,(screenHeight > 500 ? (0.02 * screenHeight) : (0.005 * screenHeight)))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        VStack{
                            TextField("", text: $email)
                                .background(colorScheme == .dark ? .black : .white)
                                .foregroundStyle(colorScheme == .dark ? .white : .black)
                                .font(Font.system(size: 24))
                                .border(Color.gray, width: 1)
                                .padding(.trailing, 50)
                        }.padding(.bottom,(screenHeight > 500 ? (0.02 * screenHeight) : (0.005 * screenHeight)))
                        
                        Button("Refresh"){
                            refreshPassword()

                        }   .fontWeight(.bold)
                            .font(Font.system(size: 32))
                            .foregroundStyle(.black)
                            .buttonStyle(.bordered)
                            .background(.lightBlueD6F1FF)
                            .cornerRadius(15)
                            .padding(.bottom,(screenHeight > 500 ? (0.01 * screenHeight) : (0.005 * screenHeight)))
                        
                        Button("Back to login"){
                            router.navPath.removeLast()
                            router.navigate(destination: .login)
                        }
                        .fontWeight(.bold)
                        .font(Font.system(size: 17))
                        .foregroundStyle(.lightBlue00A7FF)                    }
                    .padding(16)
                    .frame(width: 0.6 * screenWidth)
                    
                    .alert(isPresented: $showAlert){
                        Alert(title: Text("Error"), message: Text(alertMessage))
                    }
                }
                .frame(height: screenHeight)

            }else{
                VStack{
                    LogoImageView(padding: (screenHeight > 800 ? (0.07 * screenHeight) : (0.03 * screenHeight)), paddingTop: screenHeight > 800 ? 10.0 : 0.0)
                    
                    Text("Refresh password")
                        .fontWeight(.semibold)
                        .font(Font.system(size: 40))
                        .padding(.bottom,(screenHeight > 800 ? (0.02 * screenHeight) : (0.005 * screenHeight)))
                    Text("Email")
                        .fontWeight(.light)
                        .font(Font.system(size: 28))
                        .foregroundStyle(.lightBlack202C37)
                        .padding(.bottom,(screenHeight > 800 ? (0.02 * screenHeight) : (0.01 * screenHeight)))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    VStack{
                        TextField("", text: $email)
                            .autocapitalization(.none)
                            .background(colorScheme == .dark ? .black : .white)
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                            .font(Font.system(size: 24))
                            .border(Color.gray, width: 1)
                    }.padding(.bottom,(screenHeight > 800 ? (0.02 * screenHeight) : (0.01 * screenHeight)))
                    
                    Button("Refresh"){
                        refreshPassword()
                        
                    }   .fontWeight(.bold)
                        .font(Font.system(size: 32))
                        .foregroundStyle(.black)
                        .buttonStyle(.bordered)
                        .background(.lightBlueD6F1FF)
                        .cornerRadius(15)
                        .padding(.bottom,(screenHeight > 800 ? (0.01 * screenHeight) : (0.005 * screenHeight)))
                    
                    Button("Back to login"){
                        router.navPath.removeLast()
                        router.navigate(destination: .login)
                    }
                    .fontWeight(.bold)
                    .font(Font.system(size: 17))
                    .foregroundStyle(.lightBlue00A7FF)
                    
                }
                .padding(16)
                .frame(height: screenHeight)
                
                .alert(isPresented: $showAlert){
                    Alert(title: Text("Error"), message: Text(alertMessage))
                }
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
    
    
    
}

