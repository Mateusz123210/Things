import SwiftUI
import Foundation

enum Modes {
    case browse
    case add
    case editOrDelete
    case edit
    case delete
}

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
    @State private var showAlert2 = false
    @State private var alertMessage2 = ""
    @State private var showAlert3 = false
    @State private var alertMessage3 = ""
    @State private var categoriesFound: Bool = false
    @State private var userCategories: [CategorySchema] = []
    @State private var fetched: Bool = false
    @State private var interfaceState: Modes = Modes.browse
    @State private var categoriesButtonsBlock: Bool = false
    @State private var lastBlockedName: String = ""
    
    private let validator = Validator()
    
    let columns = [
        GridItem(.adaptive(minimum: 152, maximum: 182), spacing: 10)
    ]
    
    let categoriesService = CategoriesService()
    
    func showAlert(message: String){
        alertMessage = message
        showAlert = true
    }
    
    func categoriesFetched(categories: [CategorySchema]){

        userCategories = categories
        categoriesFound = true
        
        if (fetched == false) {
            fetched = true
        }
    }
    
    func handleFetchError(message: String){
        showAlert(message: message)
    }
    
    func handleLogout() {
        loginStatus.handleLogout()
        router.navigateToRoot()
    }
    func handleCredentialsError(){
        alertMessage3 = "Internal error occured. You will be logged out!"
        showAlert3 = true
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
        print("Add")
        return
    }
    
    func editCategory(){
        print("Edit")
        return
    }
    
    func deleteCategory(){
        var marked = countMarked()
        
        if marked == 1 {
            alertMessage2 = "Are you sure, you want to delete this category?"
        } else {
            alertMessage2 = "Are you sure, you want to delete \(marked) categories?"
        }
        showAlert2 = true
    
    }
    
    func deleteCategoryConfirmed() {
        interfaceState = Modes.browse
        fetched = false
        var toDelete: [String] = []
        for category in userCategories {
            if category.marked == true {
                toDelete.append(category.name)
                
            }
        }
        userCategories = []
        for (index, category) in toDelete.enumerated() {
            DispatchQueue.global().async{
                categoriesService.deleteCategory(data:  CategoryDeleteSchema(name: category), loginStatus: loginStatus, viewRef: self)
                if index == toDelete.count - 1 {
                    categoriesService.getAllCategories(loginStatus: loginStatus, viewRef: self)
                }
            }
        }
        
    }
    
    func countMarked() -> Int {
        var counter: Int = 0
        for category in userCategories {
            if category.marked == true {
                counter += 1
            }
        }
        return counter
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
                                    router.navigate(destination: .notes)
                                }){
                                    Image(systemName: "list.bullet.clipboard")
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
                    Text("Categories")
                    
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
                        
                        VStack{
                            HStack{
                                Text("Categories")
                                    .fontWeight(.medium)
                                    .font(Font.system(size: 32))
                                    .foregroundStyle(colorScheme == .dark ? .white:
                                            .black)
                                Spacer()
                                if (interfaceState == Modes.browse) {
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
                                } else if (interfaceState == Modes.editOrDelete){
                                    Button("Edit"){
                                        editCategory()
                                    }
                                    .fontWeight(.semibold)
                                    .font(Font.system(size: 17))
                                    .foregroundStyle(.lightGray3C3C43)
                                    Button("Delete"){
                                        deleteCategory()
                                    }
                                    .fontWeight(.semibold)
                                    .font(Font.system(size: 17))
                                    .foregroundStyle(.redF62D00)
                                    
                                    
                                } else if (interfaceState == Modes.delete) {
                                    Button("Delete"){
                                        deleteCategory()
                                    }
                                    .fontWeight(.semibold)
                                    .font(Font.system(size: 17))
                                    .foregroundStyle(.redF62D00)
                                    
                                }
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
                                    ForEach(userCategories.indices, id: \.self) {index in
                                    
                                        Button(
                                            action: {
                                                if categoriesButtonsBlock == false || lastBlockedName != userCategories[index].name {
                                                    let marked = countMarked()
                                                    
                                                    if marked == 0 {
                                                        router.navigate(destination: .categoryProducts(categoryName: userCategories[index].name))
                                                        
                                                    } else if marked == 1 {
                                                        
                                                        if userCategories[index].marked == false {
                                                            userCategories[index].marked = true
                                                            interfaceState = Modes.delete
                                                            
                                                        }else{
                                                            userCategories[index].marked = false
                                                            interfaceState = Modes.browse
                                                        }
                            
                                                    } else if marked == 2 {
                                                        if userCategories[index].marked == false {
                                                            userCategories[index].marked = true
                                                        }else{
                                                            userCategories[index].marked = false
                                                            interfaceState = Modes.editOrDelete
                                                        }
                                                        
                                                    } else {
                                                        userCategories[index].marked = !userCategories[index].marked
                                                    }
                                                    
                                                }
                                                
                                                categoriesButtonsBlock = false
                                                
                                        }
                                        ){
                                            Category(name: userCategories[index].name, image: userCategories[index].photo, marked: userCategories[index].marked)
 

                                        }
                                        .simultaneousGesture(
                                            LongPressGesture(minimumDuration: 0.5)

                                                .onEnded { _ in
                                                    
                                                    if countMarked() == 0 {
                                                        userCategories[index].marked = true
                                                        categoriesButtonsBlock = true
                                                        lastBlockedName = userCategories[index].name
                                                        interfaceState = Modes.editOrDelete
                                                    }
                                                    
                                                }
                                        )
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
        .alert(alertMessage2, isPresented: $showAlert2){
            
            Button("Yes"){
                deleteCategoryConfirmed()
            }
            Button("No"){
                
            }
        }
        .alert(isPresented: $showAlert3){
            Alert(title: Text("Error"), message: Text(alertMessage3))
        }
        
    }
    
    private func updateScreenSize() {
        screenHeight = UIScreen.main.bounds.height
        screenWidth = UIScreen.main.bounds.width
    }
    
}
