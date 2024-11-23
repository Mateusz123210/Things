import SwiftUI

struct CategoryView: View{
    
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
    @State private var categoriesFound: Bool = false
    private let validator = Validator()
    var categoryName: String
    
    let categoriesService = CategoriesService()
    
    func showAlert(message: String){
        alertMessage = message
        showAlert = true
    }
    
    func categoriesFetched(categories: [CategorySchema]){
        print("categories fetched")
        print(categories)
        //router.navigate(destination: .login)
    }
    
    func handleFetchError(message: String){
        print("handle fetch error" + message)
    }
    
    func handleCredentialsError(){
        print("handle credentials error")
    }
    
    func handleNoCategories(){
        print("No categories")
    }
    
    
    func fetchCategories(){
        DispatchQueue.global().async{
//            categoriesService.getAllCategories(loginStatus: loginStatus, viewRef: self)
        }
        
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
                    Text(categoryName)
                    Button("Action"){
                        fetchCategories()
                    }.buttonStyle(.bordered)
                    
                    .alert(isPresented: $showAlert){
                        Alert(title: Text("Error"), message: Text(alertMessage))
                    }
                }
            }
            
            
        }   //.navigationBarBackButtonHidden(true)
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

