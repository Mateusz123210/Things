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
    
    
    func registerUser(){
        let schema = RegisterSchema(email: email, password: password)
        registerService.registerUser(data: schema, viewRef: self)
    }
    
    var body: some View{
        //GeometryReader{ geometry in
            VStack{
                //let width90 = geometry.size.width * 0.9
                LogoImageView()
                VStack{
                    Text("Register")
                    Text("Email")
                    TextField("", text: $email)
                    //.frame(width: width90)
                        .background(Color.green)
                    Text("Password")
                    TextField("", text: $password)
                    //.frame(width:width90)
                        .background(Color.green)
                }
                .alert(isPresented: $showAlert){
                    Alert(title: Text("Important message"), message: Text(alertMessage))
                }
                
                Button("Register"){
                    registerUser()
                }
                Text("Already have an account? Login")
            }.padding(16)
        //}
    }
}
