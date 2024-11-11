import SwiftUI

struct RegisterView: View{
    
    @EnvironmentObject var router: Router
    
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
        GeometryReader{ geometry in
            VStack{
                var height = geometry.size.height
                VStack{
                LogoImageView()
                
                Text("Register")
                    .fontWeight(.semibold)
                    .font(Font.system(size: 32))
                Text("Email")
                    .fontWeight(.light)
                    .font(Font.system(size: 28))
                    .foregroundStyle(.lightBlack202C37)
                TextField("", text: $email)
                    .background(.white)
                Text("Password")
                    .fontWeight(.light)
                    .font(Font.system(size: 28))
                    .foregroundStyle(.lightBlack202C37)
                SecureField("", text: $password)
                    .background(.white)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
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
                
                    Button("Already have an account? Login"){
                        router.navigate(destination: .login)
                    }
                    .fontWeight(.bold)
                    .font(Font.system(size: 17))
                    .foregroundStyle(.lightBlue00A7FF)
            }   .padding(16)
                .background(.backgroundF7F7F7)
            }
        }
    }
}
