import SwiftUI

struct RegisterView: View{
    
    @EnvironmentObject var router: Router
    
    @State private var email: String = ""
    @State private var password: String = ""
       
    
    var body: some View{
        LogoImageView()
        
        Text("Register")
        Text("Email")
        TextField("", text: $email)
        Text("Password")
        TextField("", text: $password)
        Button("Register"){
            
        }
        Text("Already have an account? Login")
            
        
        
    }
}
