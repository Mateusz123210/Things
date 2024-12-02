import SwiftUI
import Foundation
import PhotosUI

struct ProductView: View{
    
    @EnvironmentObject var router: Router
    @ObservedObject var loginStatus: LoginStatus
    
    var productName: String
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
    @State private var product: ProductFetchSchema = ProductFetchSchema(name: "", categoryName: "", quantity: "", photo: nil, audio: nil, video: nil)
    @State private var editSchema: ProductEditSchema = ProductEditSchema(name: "", category_name: "", quantity: "", photo: nil, audio: nil, video: nil, old_name: "")
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var markingEnabled: Bool = false
    
    @State private var audioFileURL: URL? = nil
    @State private var audioFileName: String? = nil
    @State private var showDocumentPicker = false
    @State private var audioPlayer: AVAudioPlayer? = nil
    @State private var isPlaying = false

    let productService = ProductService()
        
    func showAlert(message: String){
        alertMessage = message
        alertType = 1
        showAlert = true
    }
    
    func productFetched(product: ProductFetchSchema){

        self.product = product
        editSchema = ProductEditSchema(name: product.name, category_name: product.categoryName, quantity: product.quantity, old_name: product.name)

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
        alertMessage = "Internal error occured. You will be logged out!"
        alertType = 3
        showAlert = true
    }
    
    func handleNoProduct(){
        backToBrowse()
    }
    
    func fetchProduct(){
        DispatchQueue.global().async{
            productService.getProduct(productName: productName, categoryName: categoryName, loginStatus: loginStatus, viewRef: self)
        }
    }
       
    func editProduct(){
        if editSchema.name.count == 0 {
            alertMessage = "Write name!"
            alertType = 1
            showAlert = true
            return
        }
        
        if editSchema.quantity.count == 0 {
            alertMessage = "Write product quantity!"
            alertType = 1
            showAlert = true
            return
        }
        
        editSchema.category_name = categoryName
        
        DispatchQueue.global().async{
            productService.editProduct(paramsData: editSchema, loginStatus: loginStatus, viewRef: self)
        }
    }
    
    func backToBrowse() {
        print("Back")
        router.navPath.removeLast()
    }

    func loadImage() {
        guard let inputImage = inputImage else { return }

        if (inputImage.size.width > 120 || inputImage.size.height > 150){
            if let resizedImage = inputImage.resizeProportionally(toFit: CGSize(width: 120, height: 150)){
                
                editSchema.photo = ImageConverter.convertImageToBase64String(resizedImage)
                
            }
        }else{
            
            editSchema.photo = ImageConverter.convertImageToBase64String(inputImage)
            
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
                                
                                Text(productName)
                                    .fontWeight(.medium)
                                    .font(Font.system(size: 28))
                                    .foregroundStyle(colorScheme == .dark ? .white:
                                            .black)
                                Spacer()
                                
                            }
                            .padding(.leading, 16)
                            .padding(.trailing, 16)
                            .padding(.top, 2)
                        }
                        .padding(.bottom,(screenHeight > 500 ? (0.02 * screenHeight) : (0.005 * screenHeight)))

                    }
                    .frame(alignment: .topLeading)

                    Spacer()

                   
                    ScrollView {
                        VStack {
                            HStack {
                                Button("Back"){
                                    backToBrowse()
                                }
                                .fontWeight(.bold)
                                .font(Font.system(size: 24))
                                .foregroundStyle(.lightBlue00A7FF)

                                Spacer()

                                Button("Save"){
                                    editProduct()
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

                            TextField("", text: $editSchema.name)
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

                            TextField("", text: $editSchema.quantity)
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
                                if editSchema.photo != nil{

                                    if let imageConverted = ImageConverter.convertImage(base64String: editSchema.photo!){
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
                                    editSchema.photo = ""

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
                        
                        Text(productName)
                            .fontWeight(.medium)
                            .font(Font.system(size: 28))
                            .foregroundStyle(colorScheme == .dark ? .white:
                                    .black)
                            
                        Spacer()
                    }
                    .padding(16)
                    
                    }
                    .frame(alignment: .topLeading)
                    Spacer()
                    

                    ScrollView {
                        VStack {
                            HStack {
                                Button("Back"){
                                    backToBrowse()
                                }
                                .fontWeight(.bold)
                                .font(Font.system(size: 24))
                                .foregroundStyle(.lightBlue00A7FF)

                                Spacer()

                                Button("Save"){
                                    editProduct()
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

                            TextField("", text: $editSchema.name)
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

                            TextField("", text: $editSchema.quantity)
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
                                if editSchema.photo != nil{

                                    if let imageConverted = ImageConverter.convertImage(base64String: editSchema.photo!){
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
                                    editSchema.photo = ""

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
            fetchProduct()
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
