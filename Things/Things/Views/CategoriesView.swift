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
    @State private var categoriesFound: Bool = false
    @State private var userCategories: [CategorySchema] = []
    @State private var fetched: Bool = false
    private let validator = Validator()
    
    let categoriesService = CategoriesService()
    
    func showAlert(message: String){
        alertMessage = message
        showAlert = true
    }
    
    func categoriesFetched(categories: [CategorySchema]){
        print("C")
        userCategories = categories
        categoriesFound = true
        if (fetched == false) {
            fetched = true
        }
    }
    
    func handleFetchError(message: String){
        print("handle fetch error" + message)
    }
    
    func handleCredentialsError(){
        print("handle credentials error")
    }
    
    func handleNoCategories(){
        if (fetched == false) {
            fetched = true
        }
        categoriesFound = false
        userCategories = []
    }
    
    
    func fetchCategories(){
        DispatchQueue.global().async{
            categoriesService.getAllCategories(loginStatus: loginStatus, viewRef: self)
        }
    }
    
    func addCategory(){
        return
    }
    
    let columns = [
        GridItem(.adaptive(minimum: 90, maximum: 160), spacing: 10)
    ]
    
    var body: some View{
        Group {
            if(orientation == UIDeviceOrientation.landscapeLeft || orientation == UIDeviceOrientation.landscapeRight){
                HStack {
                    Text("A")
                    
                    
                    
                    
                }.frame(height: screenHeight)
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
                        
                        VStack{
                            HStack{
                                Text("Categories")
                                    .fontWeight(.medium)
                                    .font(Font.system(size: 32))
                                    .foregroundStyle(colorScheme == .dark ? .white:
                                            .black)
                                Spacer()
                                Button("Refresh"){
                                    fetchCategories()
                                }
                                .fontWeight(.semibold)
                                .font(Font.system(size: 17))
                                .foregroundStyle(.lightGray3C3C43)
                                Button("Add"){
                                    addCategory()
                                }
                                .fontWeight(.semibold)
                                .font(Font.system(size: 17))
                                .foregroundStyle(.lightGray3C3C43)
                            }
                            .padding(.leading, 16)
                            .padding(.trailing, 16)
                            .padding(.top, 2)
                        }
                        .padding(.bottom,(screenHeight > 500 ? (0.02 * screenHeight) : (0.005 * screenHeight)))
                        
                        
                    }
                    .frame(alignment: .topLeading)
                    
                    Spacer()
                    if(fetched == true){
                        if(categoriesFound == true) {
                            ScrollView{
                                LazyVGrid(columns: columns, spacing: 10){
                                    ForEach(userCategories, id: \.self) {category in
                                        Category(name: category.name, image: category.photo)
//                                        Text("AS")
//                                        Image(category.photo)
                                        
                                        
                                        
                                    }
                                    
                                    
                                }
                                
                                
                                
                            }
                        }
                        else{
                            VStack{
                                Text("You don't have any categories yet!")
                                    .fontWeight(.medium)
                                    .font(Font.system(size: 28))
                                    .foregroundStyle(colorScheme == .dark ? .white:
                                            .black)
                                    .multilineTextAlignment(.center)
                                    .padding()
                                
                                
                                
                            }
                            .frame(alignment: .center)
                            Spacer()
                        }
                    }
                    
                    VStack{
                        HStack{

                            Image(systemName: "house")
                                .font(.system(size: 32))
                                .foregroundStyle(.iconF1F1F1)
                                .padding()
                                .frame(width: screenWidth / 3)
                            
                            Button(action: {
                                router.navigate(destination: .notes)
                            }){
                                Image(systemName: "list.bullet.clipboard")
                                    .font(.system(size: 32))
                                    .foregroundStyle(.darkBlue341943)
                            }
                            .padding()
                            .frame(width: screenWidth / 3)
                            Button(action: {
//                                router.navigate(destination: .notes)
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
            
            
        }   .onAppear {
                fetchCategories()
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
