import SwiftUI

struct RegisterView: View{
    
    @EnvironmentObject var router: Router
    @State private var screenHeight = UIScreen.main.bounds.height
    @State private var screenWidth = UIScreen.main.bounds.width
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @State private var orientation: UIDeviceOrientation = UIDevice.current.orientation
    @State private var email: String = "252808@student.pwr.edu.pl"
    @State private var password: String = "myPass123#"
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    let registerService = RegisterService()
    
    func showAlert(message: String){
        alertMessage = message
        showAlert = true
    }
    
    func registered(){
        //print("Registered")
        //showAlert(message: "registered")
        router.navigate(destination: .login)
    }
    
    func registerUser(){
        let schema = RegisterSchema(email: email, password: password)
        registerService.registerUser(data: schema, viewRef: self)
        
    }
    
    var body: some View{
        Group {
            if(orientation == UIDeviceOrientation.landscapeLeft || orientation == UIDeviceOrientation.landscapeRight){
                HStack {
                    VStack{
                        LogoImageView()
                    }.frame(width: screenWidth / 2)
                    VStack{
                        Text("Register")
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
                                .background(.white)
                                .font(Font.system(size: 24))
                                .border(Color.gray, width: 1)
                                .padding(.trailing, 50)
                        }.padding(.bottom,(screenHeight > 500 ? (0.02 * screenHeight) : (0.005 * screenHeight)))
                        Text("Password")
                            .fontWeight(.light)
                            .font(Font.system(size: 28))
                            .foregroundStyle(.lightBlack202C37)
                            .padding(.bottom,(screenHeight > 500 ? (0.02 * screenHeight) : (0.005 * screenHeight)))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        VStack{
                            SecureField("", text: $password)
                                .background(.white)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(Font.system(size: 24))
                                .border(Color.gray, width: 1)
                                .padding(.trailing, 50)
                        }.padding(.bottom,(screenHeight > 500 ? (0.02 * screenHeight) : (0.005 * screenHeight)))
                        Button("Register"){
                            registerUser()
                            
                        }   .fontWeight(.bold)
                            .font(Font.system(size: 32))
                            .foregroundStyle(.black)
                            .buttonStyle(.bordered)
                            .background(.lightBlueD6F1FF)
                            .cornerRadius(15)
                            .padding(.bottom,(screenHeight > 500 ? (0.01 * screenHeight) : (0.005 * screenHeight)))
                        
                        Button("Already have an account? Login"){
                            router.navigate(destination: .login)
                        }
                        .fontWeight(.bold)
                        .font(Font.system(size: 17))
                        .foregroundStyle(.lightBlue00A7FF)                    }
                    .padding(16)
                    .frame(width: screenWidth / 2)
                }.frame(height: screenHeight)
            }else{
                VStack{
                    LogoImageView(padding: (screenHeight > 800 ? (0.08 * screenHeight) : (0.01 * screenHeight)), width: 60)
                    
                    Text("Register")
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
                            .background(.white)
                            .font(Font.system(size: 24))
                            .border(Color.gray, width: 1)
                    }.padding(.bottom,(screenHeight > 800 ? (0.02 * screenHeight) : (0.01 * screenHeight)))
                    Text("Password")
                        .fontWeight(.light)
                        .font(Font.system(size: 28))
                        .foregroundStyle(.lightBlack202C37)
                        .padding(.bottom,(screenHeight > 800 ? (0.02 * screenHeight) : (0.01 * screenHeight)))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    VStack{
                        SecureField("", text: $password)
                            .background(.white)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(Font.system(size: 24))
                            .border(Color.gray, width: 1)
                    }.padding(.bottom,(screenHeight > 800 ? (0.02 * screenHeight) : (0.01 * screenHeight)))
                    
                        .alert(isPresented: $showAlert){
                            Alert(title: Text("Error"), message: Text(alertMessage))
                        }
                    
                    Button("Register"){
                        registerUser()
                        
                    }   .fontWeight(.bold)
                        .font(Font.system(size: 32))
                        .foregroundStyle(.black)
                        .buttonStyle(.bordered)
                        .background(.lightBlueD6F1FF)
                        .cornerRadius(15)
                        .padding(.bottom,(screenHeight > 800 ? (0.01 * screenHeight) : (0.005 * screenHeight)))
                    
                    Button("Already have an account? Sign in"){
                        router.navigate(destination: .login)
                    }
                    .fontWeight(.bold)
                    .font(Font.system(size: 17))
                    .foregroundStyle(.lightBlue00A7FF)
                    
                }
                .padding(16)
                .frame(height: screenHeight)
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


