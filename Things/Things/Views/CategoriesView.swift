import SwiftUI

struct CategoriesView: View{
    
    @EnvironmentObject var router: Router
    @ObservedObject var loginStatus: LoginStatus
    @Environment(\.colorScheme) var colorScheme
    @State private var screenHeight = UIScreen.main.bounds.height
    @State private var screenWidth = UIScreen.main.bounds.width
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @State private var orientation: UIDeviceOrientation = UIDevice.current.orientation
    @State private var showAlert = false
    @State private var alertMessage = ""
    private let validator = Validator()
    
    let categoriesService = CategoriesService()
    
    func showAlert(message: String){
        alertMessage = message
        showAlert = true
    }
    
    func categoriesFetched(){

        //router.navigate(destination: .login)
    }
    
    func fetchCategories(){
        
        //let schema = AccessTokenSchema(email: email, password: password)
        //registerService.registerUser(data: schema, viewRef: self)
        
    }
    
    
    var body: some View{
        Group {
            if(orientation == UIDeviceOrientation.landscapeLeft || orientation == UIDeviceOrientation.landscapeRight){
                HStack {
                    Text("A")
                    
                    
                    
                    .alert(isPresented: $showAlert){
                        Alert(title: Text("Error"), message: Text(alertMessage))
                    }
                }.frame(height: screenHeight)
            }else{
                VStack{
                    Text("A")
                    Button("Action"){
                        
                    }
                    .buttonStyle(.bordered)
                    
                    .alert(isPresented: $showAlert){
                        Alert(title: Text("Error"), message: Text(alertMessage))
                    }
                }
            }
            
            
        }   .navigationBarBackButtonHidden(true)
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            
            
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
