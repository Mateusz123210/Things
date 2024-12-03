import SwiftUI

struct LoginView: View{
    @ObservedObject var loginStatus: LoginStatus
    @EnvironmentObject var router: Router
    @Environment(\.colorScheme) var colorScheme
    @State private var screenHeight = UIScreen.main.bounds.height
    @State private var screenWidth = UIScreen.main.bounds.width
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @State private var orientation: UIDeviceOrientation = UIDevice.current.orientation
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    private let validator = Validator()
    
    let loginService = LoginService()
    
    func showAlert(message: String){
        alertMessage = message
        showAlert = true
    }
    
    func logged(tokens: TokensSchema){
 
        if(tokens.access_token.count != 151 || tokens.refresh_token.count != 151){
            showAlert(message: "Internal problem occurred")
            return
        }
        
        loginStatus.logged = true
        loginStatus.accessToken = tokens.access_token
        loginStatus.refreshToken = tokens.refresh_token
        loginStatus.email = email
        
        email = ""
        password = ""
        
        router.navPath.removeLast()
        router.navigate(destination: .categories)
    }
    
    func login(){
        if(validator.validateEmail(email: email) == false){
            showAlert(message: "Invalid email")
            return
        }
        
        if(validator.validatePassword(password: password) == false) {
            showAlert(message: "Password should contains of minimum 8 characters, including big letter, small letter, digit and special character")
            return
        }
        
        let schema = RegisterSchema(email: email, password: password)
        loginService.loginUser(data: schema, viewRef: self)
        
    }
    
    var body: some View{
        Group {
            if(orientation == UIDeviceOrientation.landscapeLeft || orientation == UIDeviceOrientation.landscapeRight){
                HStack {
                    VStack{
                        LogoImageView()
                    }.frame(width: 0.4 * screenWidth)
                    VStack{
                        Text("Sign in")
                            .fontWeight(.semibold)
                            .font(Font.system(size: screenHeight > 500 ? 40 : 32))
                            .padding(.bottom,(screenHeight > 500 ? (0.02 * screenHeight) : (0.001 * screenHeight)))
                        Text("Email")
                            .fontWeight(.light)
                            .font(Font.system(size: 28))
                            .foregroundStyle(.lightBlack202C37)
                            .padding(.bottom,(screenHeight > 500 ? (0.02 * screenHeight) : (0.001 * screenHeight)))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        VStack{
                            HStack{
                                TextField("", text: $email)
                                    .background(colorScheme == .dark ? .black : .white)
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                                    .font(Font.system(size: 24))
                                    .border(Color.gray, width: 1)
                                    .padding(.bottom,(screenHeight > 500 ? (0.02 *          screenHeight) : (0.001 * screenHeight)))
                                    .frame(maxWidth: 0.5 * screenWidth)
                                Spacer()
                            }.frame(maxWidth: .infinity, alignment: .leading)
                            Text("Password")
                            .fontWeight(.light)
                            .font(Font.system(size: 28))
                            .foregroundStyle(.lightBlack202C37)
                            .padding(.bottom,(screenHeight > 500 ? (0.02 * screenHeight) : (0.001 * screenHeight)))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                            HStack{
                                SecureField("", text: $password)
                                    .background(.white)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .font(Font.system(size: 24))
                                    .border(Color.gray, width: 1)
                                    .frame(maxWidth: 0.5 * screenWidth)
                             Spacer()
                            }.frame(maxWidth: .infinity, alignment: .leading)
                        }.padding(.bottom, screenHeight > 500 ? (0.01 * screenHeight) : 0.0)
                        HStack{
                            Button("Refresh password"){
                                router.navPath.removeLast()
                                router.navigate(destination: .refreshPass)
                                
                            }   .fontWeight(.bold)
                                .font(Font.system(size: 17))
                                .foregroundStyle(.darkGray787678)
                            Spacer()
                        }
                        
                        Button("Sign in"){
                            login()

                        }   .fontWeight(.bold)
                            .font(Font.system(size: 32))
                            .foregroundStyle(.black)
                            .buttonStyle(.bordered)
                            .background(.lightBlueD6F1FF)
                            .cornerRadius(15)
                            .padding(.bottom,(screenHeight > 500 ? (0.01 * screenHeight) : (0.001 * screenHeight)))
                        
                        Button("Don't have an account? Register"){
                            router.navPath.removeLast()
                            router.navigate(destination: .register)
                        }
                        .fontWeight(.bold)
                        .font(Font.system(size: 17))
                        .foregroundStyle(.lightBlue00A7FF)                    }
                    .padding(16)
                    .frame(width: 0.6 * screenWidth )
                    
                    .alert(isPresented: $showAlert){
                        Alert(title: Text("Error"), message: Text(alertMessage))
                    }
                }.frame(height: screenHeight)
            }else{
                VStack{
                    LogoImageView(padding: (screenHeight > 800 ? (0.07 * screenHeight) : (0.002 * screenHeight)), paddingTop: screenHeight > 800 ? 10.0 : 0.0)
                    
                    Text("Sign in")
                        .fontWeight(.semibold)
                        .font(Font.system(size: 40))
                        .padding(.bottom,(screenHeight > 800 ? (0.02 * screenHeight) : (0.003 * screenHeight)))
                    Text("Email")
                        .fontWeight(.light)
                        .font(Font.system(size: 28))
                        .foregroundStyle(.lightBlack202C37)
                        .padding(.bottom,(screenHeight > 800 ? (0.02 * screenHeight) : (0.003 * screenHeight)))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    VStack{
                        TextField("", text: $email)
                            .background(colorScheme == .dark ? .black : .white)
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                            .font(Font.system(size: 24))
                            .border(Color.gray, width: 1)
                    }.padding(.bottom,(screenHeight > 800 ? (0.02 * screenHeight) : (0.003 * screenHeight)))
                    Text("Password")
                        .fontWeight(.light)
                        .font(Font.system(size: 28))
                        .foregroundStyle(.lightBlack202C37)
                        .padding(.bottom,(screenHeight > 800 ? (0.02 * screenHeight) : (0.003 * screenHeight)))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    VStack{
                        SecureField("", text: $password)
                            .background(.white)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(Font.system(size: 24))
                            .border(Color.gray, width: 1)
                    }.padding(.bottom,(screenHeight > 800 ? (0.02 * screenHeight) : (0.003 * screenHeight)))
                    
                    HStack{
                        Button("Refresh password"){
                            router.navPath.removeLast()
                            router.navigate(destination: .refreshPass)
                            
                        }   .fontWeight(.bold)
                            .font(Font.system(size: 17))
                            .foregroundStyle(.darkGray787678)
                        Spacer()
                    }
                    
                    Button("Sign in"){
                        login()
                        
                    }   .fontWeight(.bold)
                        .font(Font.system(size: 32))
                        .foregroundStyle(.black)
                        .buttonStyle(.bordered)
                        .background(.lightBlueD6F1FF)
                        .cornerRadius(15)
                        .padding(.bottom,(screenHeight > 800 ? (0.01 * screenHeight) : (0.005 * screenHeight)))
                    
                    Button("Don't have an account? Register"){
                        router.navPath.removeLast()
                        router.navigate(destination: .register)
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
