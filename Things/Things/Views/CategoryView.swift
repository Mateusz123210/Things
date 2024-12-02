import SwiftUI
import Foundation
import PhotosUI


struct CategoryView: View{
    
    @EnvironmentObject var router: Router
    @ObservedObject var loginStatus: LoginStatus
    var categoryName: String
    @Environment(\.colorScheme) var colorScheme
    @State private var screenHeight = UIScreen.main.bounds.height
    @State private var screenWidth = UIScreen.main.bounds.width
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @State private var orientation: UIDeviceOrientation = UIDevice.current.orientation
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertType: Int = 1
    @State private var productsFound: Bool = false
    @State private var categoryProducts: [ProductFetchSchema] = []
    @State private var fetched: Bool = false
    @State private var interfaceState: Modes = Modes.browse
    @State private var productsButtonsBlock: Bool = false
    @State private var lastBlockedName: String = ""
    @State private var addSchema: ProductAddSchema = ProductAddSchema(name: "", category_name: "", quantity: "", photo: nil, audio: nil, video: nil)
    @State private var editSchema: ProductEditSchema = ProductEditSchema(name: "", category_name: "", quantity: "", photo: nil, audio: nil, video: nil, old_name: "")
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var markingEnabled: Bool = false
    
    @State private var audioFileURL: URL? = nil
    @State private var audioFileName: String? = nil
    @State private var showDocumentPicker = false
    @State private var audioPlayer: AVAudioPlayer? = nil
    @State private var isPlaying = false



    let columns = [
        GridItem(.adaptive(minimum: 152, maximum: 182), spacing: 10)
    ]
    
    let categoriesService = CategoriesService()
    let productService = ProductService()
        
    func showAlert(message: String){
        alertMessage = message
        alertType = 1
        showAlert = true
    }
    
    func categoryProductsFetched(products: [ProductFetchSchema]){

        categoryProducts = products
        productsFound = true
        
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
        alertMessage = "Internal error occured. You will be logged out!"
        alertType = 3
        showAlert = true
    }
    
    func handleNoProducts(){
        if (fetched == false) {
            fetched = true
        }
        productsFound = false
        categoryProducts = []
    }
    
    
    func fetchCategoryProducts(){
        DispatchQueue.global().async{
            categoriesService.getCategory(categoryName: categoryName, loginStatus: loginStatus, viewRef: self)
        }
    }
       
    func addProduct(){
        interfaceState = Modes.add

    }
    
    func confirmAdd() {

        if addSchema.name.count == 0 {
            alertMessage = "Write name!"
            alertType = 1
            showAlert = true
            return
        }
        
        if addSchema.quantity.count == 0 {
            alertMessage = "Write product quantity!"
            alertType = 1
            showAlert = true
            return
        }
        
        addSchema.category_name = categoryName
        DispatchQueue.global().async{
            productService.addProduct(paramsData: addSchema, loginStatus: loginStatus, viewRef: self)
            
        }
        
    }
    
    func backToBrowse() {
        addSchema = ProductAddSchema(name: "", category_name: "", quantity: "", photo: nil, audio: nil, video: nil)
        interfaceState = Modes.browse
    }

    func loadImage() {
        guard let inputImage = inputImage else { return }

        if (inputImage.size.width > 120 || inputImage.size.height > 150){
            if let resizedImage = inputImage.resizeProportionally(toFit: CGSize(width: 120, height: 150)){
                if interfaceState == Modes.add {
                    addSchema.photo = ImageConverter.convertImageToBase64String(resizedImage)
                }else {
                    editSchema.photo = ImageConverter.convertImageToBase64String(resizedImage)
                }
            }
        }else{
            if interfaceState == Modes.add {
                addSchema.photo = ImageConverter.convertImageToBase64String(inputImage)
            }else {
                editSchema.photo = ImageConverter.convertImageToBase64String(inputImage)
            }
            
        }
    }
    
    func deleteProduct(){
        
        var marked = countMarked()
        
        if marked == 1 {
            alertMessage = "Are you sure, you want to delete this product?"
        } else {
            alertMessage = "Are you sure, you want to delete \(marked) products?"
        }
        alertType = 2
        showAlert = true
    
    }
    
    func deleteProductConfirmed() {
        interfaceState = Modes.browse
        fetched = false
        var toDelete: [String] = []
        
        for product in categoryProducts {
            if product.marked == true {
                toDelete.append(product.name)
                
            }
        }
        
        categoryProducts = []
        for (index, category) in toDelete.enumerated() {
            DispatchQueue.global().async{
                productService.deleteProduct(paramsData:  ProductDeleteSchema(name: category, category_name: categoryName), loginStatus: loginStatus, viewRef: self)
            }
        }
        
    }
    
    func countMarked() -> Int {
        var counter: Int = 0
        for category in categoryProducts {
            if category.marked == true {
                counter += 1
            }
        }
        return counter
    }
    
    func getMarked() -> ProductFetchSchema? {
        for product in categoryProducts {
            if product.marked == true {
                return product
            }
        }
        return nil
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

                        VStack{
                            HStack{
                                Button(action: {
                                    router.navPath.removeLast()
                                }) {
                                    Image(systemName: "arrowshape.backward.circle")
                                        .font(.system(size: 32))
                                        .background(colorScheme == .dark ? .black : .white)
                                        .clipShape(Circle())
                                        .padding(16)
                                }
                                .padding(.trailing, 32)
                                Text(categoryName)
                                    .fontWeight(.medium)
                                    .font(Font.system(size: 28))
                                    .foregroundStyle(colorScheme == .dark ? .white:
                                            .black)
                                Spacer()
                                if (interfaceState == Modes.browse) {
                                    Button("Refresh"){
                                        fetchCategoryProducts()
                                    }
                                    .fontWeight(.semibold)
                                    .font(Font.system(size: 17))
                                    .foregroundStyle(.lightGray3C3C43)
                                    Button("Add"){
                                        addProduct()
                                    }
                                    .fontWeight(.semibold)
                                    .font(Font.system(size: 17))
                                    .foregroundStyle(.lightGray3C3C43)
                                } else if (interfaceState == Modes.delete) {
                                    Button("Delete"){
                                        deleteProduct()
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
                                
                                Text("Quantity:")
                                    .fontWeight(.light)
                                    .font(Font.system(size: 20))
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                                    .padding([.top, .leading, .trailing], 16)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                TextField("", text: $addSchema.quantity)
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
                                                .frame(width: (screenWidth - 64) * 0.5, height: (screenWidth - 64) * 0.5 * 5 / 4)
                                                .clipped()

                                        }else{
                                            Image("NoImage")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: (screenWidth - 64) * 0.5, height: (screenWidth - 64) * 0.5 * 5 / 4)
                                                .clipped()
                                        }
                                    } else {
                                        Image("NoImage")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: (screenWidth - 64) * 0.5, height: (screenWidth - 64) * 0.5 * 5 / 4)
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
                                
                                Audio(audioFileURL: $audioFileURL, audioFileName: $audioFileName, showDocumentPicker: $showDocumentPicker, audioPlayer: $audioPlayer, isPlaying: $isPlaying)


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
                    
                    else{
                        if(fetched == true){
                            if(productsFound == true) {
                                ScrollView{

                                    VStack {
                                        ForEach(categoryProducts.indices, id: \.self) {index in

                                            Button(
                                                action: {
                                                    if productsButtonsBlock == false || categoryProducts[index].name != lastBlockedName {
                                                        let marked = countMarked()
                                                        if marked > 1 {
                                                            categoryProducts[index].marked = !categoryProducts[index].marked
                                                        } else if marked == 1{
                                                            if categoryProducts[index].marked == true {
                                                                categoryProducts[index].marked = false
                                                                interfaceState = Modes.browse
                                                                                                                               markingEnabled = false
                                                            } else {
                                                                categoryProducts[index].marked = true
                                                                
                                                            }
                                                            
                                                        }else{
                                                            router.navigate(destination: .product(productName: categoryProducts[index].name, categoryName: categoryName))
                                                        }
                                                    }
                                                    productsButtonsBlock = false

                                                }
                                            ){
                                                Product(name: categoryProducts[index].name, photo: categoryProducts[index].photo ?? nil , quantity: categoryProducts[index].quantity, marked: categoryProducts[index].marked,
                                                        markingEnabled: markingEnabled)

                                            }
                                            .simultaneousGesture(
                                                LongPressGesture(minimumDuration: 0.5)

                                                .onEnded { _ in

                                                    if countMarked() == 0 {
                                                        markingEnabled = true
                                                        categoryProducts[index].marked = true
                                                        productsButtonsBlock = true
                                                        lastBlockedName = categoryProducts[index].name
                                                        interfaceState = Modes.delete
                                                    }

                                                }
                                            )
                                        }
                                    }
                                }
                            }
                            else{
                                VStack{
                                    Text("You don't have any products in this category yet!")
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
                   
                    HStack {
                        Button(action: {
                            router.navPath.removeLast()
                        }) {
                            Image(systemName: "arrowshape.backward.circle")
                                .font(.system(size: 32))
                                .background(colorScheme == .dark ? .black : .white)
                                .clipShape(Circle())
                                .padding(16)
                        }
                        .padding(.trailing, 16)
                        Text(categoryName)
                            .fontWeight(.medium)
                            .font(Font.system(size: 28))
                            .foregroundStyle(colorScheme == .dark ? .white:
                                    .black)
                        Spacer()
                        if (interfaceState == Modes.browse) {
                            Button("Refresh"){
                                fetchCategoryProducts()
                            }
                            .fontWeight(.semibold)
                            .font(Font.system(size: 17))
                            .foregroundStyle(.lightGray3C3C43)
                            Button("Add"){
                                addProduct()
                            }
                            .fontWeight(.semibold)
                            .font(Font.system(size: 17))
                            .foregroundStyle(.lightGray3C3C43)
                        } else if (interfaceState == Modes.delete) {
                            Button("Delete"){
                                deleteProduct()
                            }
                            .fontWeight(.semibold)
                            .font(Font.system(size: 17))
                            .foregroundStyle(.redF62D00)
                            
                        }
                    }
                    .padding(.trailing, 16)
                    
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
                                
                                Text("Quantity:")
                                    .fontWeight(.light)
                                    .font(Font.system(size: 20))
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                                    .padding([.top, .leading, .trailing], 16)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                TextField("", text: $addSchema.quantity)
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
                                                .frame(width: (screenWidth - 64) * 0.5, height: (screenWidth - 64) * 0.5 * 5 / 4)
                                                .clipped()

                                        }else{
                                            Image("NoImage")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: (screenWidth - 64) * 0.5, height: (screenWidth - 64) * 0.5 * 5 / 4)
                                                .clipped()
                                        }
                                    } else {
                                        Image("NoImage")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: (screenWidth - 64) * 0.5, height: (screenWidth - 64) * 0.5 * 5 / 4)
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
                                
                                Audio(audioFileURL: $audioFileURL, audioFileName: $audioFileName, showDocumentPicker: $showDocumentPicker, audioPlayer: $audioPlayer, isPlaying: $isPlaying)


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
                    
                    else{
                        if(fetched == true){
                            if(productsFound == true) {
                                ScrollView{

                                    VStack {
                                        ForEach(categoryProducts.indices, id: \.self) {index in

                                            Button(
                                                action: {
                                                    if productsButtonsBlock == false || categoryProducts[index].name != lastBlockedName {
                                                        let marked = countMarked()
                                                        if marked > 1 {
                                                            categoryProducts[index].marked = !categoryProducts[index].marked
                                                        } else if marked == 1{
                                                            if categoryProducts[index].marked == true {
                                                                categoryProducts[index].marked = false
                                                                interfaceState = Modes.browse
                                                                                                                               markingEnabled = false
                                                            } else {
                                                                categoryProducts[index].marked = true
                                                                
                                                            }
                                                            
                                                        }else{
                                                            router.navigate(destination: .product(productName: categoryProducts[index].name, categoryName: categoryName))
                                                        }
                                                    }
                                                    productsButtonsBlock = false

                                                }
                                            ){
                                                Product(name: categoryProducts[index].name, photo: categoryProducts[index].photo ?? nil , quantity: categoryProducts[index].quantity, marked: categoryProducts[index].marked,
                                                        markingEnabled: markingEnabled, small: true)

                                            }
                                            .simultaneousGesture(
                                                LongPressGesture(minimumDuration: 0.5)

                                                .onEnded { _ in

                                                    if countMarked() == 0 {
                                                        markingEnabled = true
                                                        categoryProducts[index].marked = true
                                                        productsButtonsBlock = true
                                                        lastBlockedName = categoryProducts[index].name
                                                        interfaceState = Modes.delete
                                                    }

                                                }
                                            )
                                        }
                                    }
                                }
                            }
                            else{
                                VStack{
                                    Text("You don't have any products in this category yet!")
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
            fetchCategoryProducts()
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

            if alertType == 1 {
                return Alert(title: Text("Error"), message: Text(alertMessage))
            }else if alertType == 2 {
                return Alert(title: Text(alertMessage),
                    primaryButton: .default(Text("Yes")) {
                        deleteProductConfirmed()
                    }, secondaryButton: .default(Text("No")) {

                    }
                        )

            }else {
                return Alert(title: Text("Error"), message: Text(alertMessage))
            }

        }
                
    }
    
    private func updateScreenSize() {
        screenHeight = UIScreen.main.bounds.height
        screenWidth = UIScreen.main.bounds.width
    }
    
}
