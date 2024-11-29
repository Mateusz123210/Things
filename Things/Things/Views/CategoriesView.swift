import SwiftUI
import Foundation
import PhotosUI

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
    @State private var addSchema: CategoryAddSchema = CategoryAddSchema(name: "", photo: nil)
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    


    
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
        print(message)
        showAlert(message: message)
    }
    
    func handleLogout() {
        loginStatus.handleLogout()
        router.navigateToRoot()
    }
    func handleCredentialsError(){
        print("cre eroor")
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
        interfaceState = Modes.add

    }
    
    func confirmAdd() {
        print("confirm")
        if addSchema.name.count == 0 {
            print("A")
            alertMessage = "Write name!"
            showAlert = true
            return
        }
        
        DispatchQueue.global().async{
//            categoriesService.addCategory(data: addSchema, loginStatus: loginStatus, viewRef: self)
//            backToBrowse()
            
        }
        
    }
    
    func backToBrowse() {
        addSchema = CategoryAddSchema(name: "", photo: nil)
        interfaceState = Modes.browse
    }
    
    func editCategory(){
        interfaceState = Modes.edit
        return
    }

    func loadImage() {
        guard let inputImage = inputImage else { return }
        addSchema.photo = ImageConverter.convertImageToBase64String(inputImage)
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
                    if (interfaceState == Modes.add){
                        ScrollView {
                            VStack {
                                HStack {
                                    Button("Cancel"){
                                        backToBrowse()
                                    }
                                    .fontWeight(.bold)
                                    .font(Font.system(size: 24))
                                    .foregroundStyle(.lightBlue00A7FF)
                                    
                                    Spacer()
                                    
                                    Button("Add"){
                                        confirmAdd()
                                    }
                                    .fontWeight(.bold)
                                    .font(Font.system(size: 24))
                                    .foregroundStyle(.lightGray3C3C43)
                                    
                                    
                                }
                                .padding(16)
                                
                                Text("Name:")
                                    .fontWeight(.light)
                                    .font(Font.system(size: 20))
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                                    .padding([.top, .leading, .trailing], 16)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                TextField("", text: $addSchema.name)
                                    .background(colorScheme == .dark ? .black : .white)
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                                    .font(Font.system(size: 24))
                                    .border(Color.gray, width: 1)
                                    .padding([.leading, .trailing, .bottom], 16)
                                
                                Text("Photo:")
                                    .fontWeight(.light)
                                    .font(Font.system(size: 20))
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                                    .padding([.top, .leading, .trailing], 16)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                VStack {
                                    if addSchema.photo != nil{
                                        
                                        if let imageConverted = ImageConverter.convertImage(base64String: addSchema.photo!){
                                            imageConverted
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: (screenWidth - 64) * 0.9, height: (screenWidth - 64) * 0.9 * 5 / 4)
                                                .clipped()
                                            
                                        }else{
                                            Image("NoImage")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: (screenWidth - 64) * 0.9, height: (screenWidth - 64) * 0.9 * 5 / 4)
                                                .clipped()
                                        }
                                    } else {
                                        Image("NoImage")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: (screenWidth - 64) * 0.9, height: (screenWidth - 64) * 0.9 * 5 / 4)
                                            .clipped()
                                    }
                                    
                                }
                                .padding(.bottom, 8)
                           
                                HStack{
                                    Button("Clear photo"){
                                        addSchema.photo = ""
                                        
                                    }   .fontWeight(.bold)
                                        .font(Font.system(size: 17))
                                        .foregroundStyle(.darkGray787678)
                                        .padding(.leading, 16)
                                    Spacer()
                                }
                                .padding(.bottom, 16)

                                Button("Upload photo"){
                                    showingImagePicker = true
                                    
                                }   .fontWeight(.bold)
                                    .font(Font.system(size: 32))
                                    .foregroundStyle(.black)
                                    .buttonStyle(.bordered)
                                    .background(.lightBlue00A7FF)
                                    .cornerRadius(15)
                                    .padding(.bottom, 16)
                                
                                .sheet(isPresented: $showingImagePicker) {
                                    ImagePicker(image: $inputImage)
                                }
                                
                                
                                
                            }
                            
                            .background(.lightBlueD6F1FF)
                            .cornerRadius(15)
                            .padding(16)
                            
                        }

                        .onChange(of: inputImage) { _ in loadImage() }
                    }
                    else if (interfaceState == Modes.edit){
                        
                    }
                    else{
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
            
            
        }
        .onAppear {
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
