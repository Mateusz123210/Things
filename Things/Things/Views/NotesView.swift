import SwiftUI

struct NotesView: View{
    
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
//    @State private var categoriesFound: Bool = false
    private let validator = Validator()
    
//    let categoriesService = CategoriesService()
    
    func showAlert(message: String){
        alertMessage = message
        showAlert = true
    }
    
//    func categoriesFetched(categories: [CategorySchema]){
//        print("categories fetched")
//        print(categories)
//        //router.navigate(destination: .login)
//    }
//    
//    func handleFetchError(message: String){
//        print("handle fetch error" + message)
//    }
//    
//    func handleCredentialsError(){
//        print("handle credentials error")
//    }
//    
//    func handleNoCategories(){
//        print("No categories")
//    }
//    
//    
    func fetchNotes(){
        DispatchQueue.global().async{
//            categoriesService.getAllCategories(loginStatus: loginStatus, viewRef: self)
        }
        
    }
    
    
    var body: some View{
        Group {
            if(orientation == UIDeviceOrientation.landscapeLeft || orientation == UIDeviceOrientation.landscapeRight){
                VStack{
                    VStack{
                        HStack{
                            Text("Things")
                                .fontWeight(.bold)
                                .font(Font.system(size: 40))
                                .foregroundStyle(.darkBlue341943)
                                .padding(.bottom, 5)
                                .padding(.leading, 16)
                            Spacer()
                            HStack{
                                Button(action: {
                                    router.navPath.removeLast()
                                    router.navigate(destination: .categories)
                                }){
                                    Image(systemName: "house")
                                        .font(.system(size: 32))
                                        .foregroundStyle(.darkBlue341943)
                                }
                                .padding()
                                
                                Button(action: {
                                    router.navPath.removeLast()
                                    router.navigate(destination: .account)
                                }){
                                    Image(systemName: "person.crop.circle")
                                        .font(.system(size: 32))
                                        .foregroundStyle(.darkBlue341943)
                                }
                                .padding(.trailing, 16)
                            }
                            .frame(alignment: .bottomTrailing)
                        }

                        .background(colorScheme == .dark ? .black : .blue5AC8FA)
                        .padding(.bottom, 16)
                        
                    }
                    .frame(alignment: .topLeading)
                    
                    Spacer()
                    Text("Notes")
                    
                }
            }else{
                VStack{
                    VStack{
                        VStack{
                            Text("Things")
                                .fontWeight(.bold)
                                .font(Font.system(size: 40))
                                .foregroundStyle(.darkBlue341943)
                                .padding(.bottom, 5)
                        }
                        .frame(width: screenWidth)
                        .background(colorScheme == .dark ? .black : .blue5AC8FA)
                        
                        
                        
                        
                    }
                    .frame(alignment: .topLeading)
                    
                    Spacer()
                    
                    VStack{
                        HStack{
                            Button(action: {
                                router.navigate(destination: .categories)
                            }){
                                Image(systemName: "house")
                                    .font(.system(size: 32))
                                    .foregroundStyle(.darkBlue341943)
                            }
                            .padding()
                            .frame(width: screenWidth / 3)

                            Image(systemName: "list.bullet.clipboard")
                                .font(.system(size: 32))
                                .foregroundStyle(.iconF1F1F1)
                                .padding()
                                .frame(width: screenWidth / 3)
                            
                            Button(action: {
                                router.navigate(destination: .account)
                            }){
                                Image(systemName: "person.crop.circle")
                                    .font(.system(size: 32))
                                    .foregroundStyle(.darkBlue341943)
                            }
                            .padding()
                            .frame(width: screenWidth / 3)
                           
                        }
                        .frame(width: screenWidth)
                        .background(colorScheme == .dark ? .black : .blue5AC8FA)
                        
                    }
                    .frame(alignment: .bottomTrailing)

                }
            }
            
            
        }
        .onAppear {
                fetchNotes()
        }
        .navigationBarBackButtonHidden(true)
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
        .alert(isPresented: $showAlert){
            Alert(title: Text("Error"), message: Text(alertMessage))
        }
        
    }
    
    private func updateScreenSize() {
        screenHeight = UIScreen.main.bounds.height
        screenWidth = UIScreen.main.bounds.width
    }
    
}
