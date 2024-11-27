import SwiftUI

struct AccountView: View{
    
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
    @State private var showButton: Bool = false

    
    let accountService = AccountService()
    
    func showAlert(message: String){
        alertMessage = message
        showAlert = true
    }
    
    func handleLogout(){
        print("Logged out")
    }
    
    func handleDeleteAccount(){
        print("Account deleted")
    }
    
    func handleError(message: String){
        print("handle fetch error" + message)
    }
    
    func handleCredentialsError(){
        print("handle credentials error")
    }
    
    func logout(){
        DispatchQueue.global().async{
            accountService.logout(loginStatus: loginStatus, viewRef: self)
        }
        
    }
    
    func deleteAccount(){
        DispatchQueue.global().async{
           // accountService.deleteAccount(loginStatus: loginStatus, viewRef: self)
        }
        
    }
    
    func showOrHideDeleteButton(){
        if showButton == false{
            showButton = true
        }else{
            showButton = false
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
                                    router.navigate(destination: .notes)
                                }){
                                    Image(systemName: "list.bullet.clipboard")
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
                    ScrollView ([.horizontal, .vertical]) {
                        HStack {
                            VStack {
                                VStack {
                                    Text("Logged as: ")
                                        .fontWeight(.semibold)
                                        .font(Font.system(size: 28))
                                        .foregroundStyle(.lightGray3C3C43)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.bottom, 8)
                                    
                                    Text(loginStatus.email!)
                                        .fontWeight(.semibold)
                                        .font(Font.system(size: 28))
                                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.bottom, 16)
                                    
                                }
                                
                                HStack{
                                    Button (action: {
                                        showOrHideDeleteButton()
                                    }) {
                                        Text("Advanced")
                                            .fontWeight(.bold)
                                            .font(Font.system(size: 24))
                                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                                            .underline(showButton == true, color: colorScheme == .dark ? .white : .black)
                                        
                                        
                                        Image(systemName: "gearshape.2")
                                            .font(.system(size: 24))
                                            .foregroundStyle(.darkBlue341943)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.bottom, 16)
                                .frame(maxWidth: .infinity)
                                if showButton == true {
                                    HStack {
                                        Button("Delete account"){
                                            deleteAccount()
                                            
                                        }   .fontWeight(.bold)
                                            .font(Font.system(size: 36))
                                            .foregroundStyle(.black)
                                            .buttonStyle(.bordered)
                                            .background(.redF62D00)
                                            .cornerRadius(15)
                                        
                                        Spacer()
                                    }
                                    .frame(maxWidth: .infinity, alignment: .topLeading)
                                }
                                
                            }
                            .padding(16)
                            .frame(maxWidth: screenWidth > 700 ? 0.7 * screenWidth : .infinity ,alignment: .center)
                            Button("Logout"){
                                logout()
                                
                            }   .fontWeight(.bold)
                                .font(Font.system(size: 46))
                                .foregroundStyle(.black)
                                .buttonStyle(.bordered)
                                .background(.lightBlueD6F1FF)
                                .cornerRadius(15)
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
                        
                    }
                    .frame(alignment: .topLeading)
                    
                    Spacer()
                        
                    VStack{
                        Text("Logged as: ")
                            .fontWeight(.semibold)
                            .font(Font.system(size: screenWidth > 500 ? 28 : 24))
                            .foregroundStyle(.lightGray3C3C43)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 16)
                        
                        Text(loginStatus.email!)
                            .fontWeight(.semibold)
                            .font(Font.system(size: screenWidth > 500 ? 28 : 24))
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 16)
                        
                        Button("Logout"){
                            logout()

                        }   .fontWeight(.bold)
                            .font(Font.system(size: screenWidth > 500 ? 46 : 36))
                            .foregroundStyle(.black)
                            .buttonStyle(.bordered)
                            .background(.lightBlueD6F1FF)
                            .cornerRadius(15)
                            .padding(.bottom, 64)
                        
                        HStack{
                            
                            Button (action: {
                                showOrHideDeleteButton()
                            }) {
                                Text("Advanced")
                                    .fontWeight(.bold)
                                    .font(Font.system(size: screenWidth > 500 ? 24 : 20))
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                                    .underline(showButton == true, color: colorScheme == .dark ? .white : .black)
                                    .padding(.trailing, 2)
                                
                                Image(systemName: "gearshape.2")
                                    .font(.system(size: screenWidth > 500 ? 24 : 20))
                                    .foregroundStyle(.darkBlue341943)
                            }
                            
                            Spacer()
                        }
                        .padding(.bottom, 16)
                        .frame(maxWidth: .infinity)
                        if showButton == true {
                            Button("Delete account"){
                                deleteAccount()

                            }   .fontWeight(.bold)
                                .font(Font.system(size: screenWidth > 500 ? 36 : 26))
                                .foregroundStyle(.black)
                                .buttonStyle(.bordered)
                                .background(.redF62D00)
                                .cornerRadius(15)
                                .padding(.bottom, 64)
                        }
                        
                    }
                    .padding(16)
                    .frame(maxWidth: screenWidth > 700 ? 0.7 * screenWidth : .infinity ,alignment: .center)
                    Spacer()
                        
                    VStack{
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
                            .frame(width: screenWidth / 3)
                            
                            Button(action: {
                                router.navPath.removeLast()
                                router.navigate(destination: .notes)
                            }){
                                Image(systemName: "list.bullet.clipboard")
                                    .font(.system(size: 32))
                                    .foregroundStyle(.darkBlue341943)
                            }
                            .padding()
                            .frame(width: screenWidth / 3)
                            
                            Image(systemName: "person.crop.circle")
                                .font(.system(size: 32))
                                .foregroundStyle(.iconF1F1F1)
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
        print(screenWidth)
        print(screenHeight)
    }
    
}
