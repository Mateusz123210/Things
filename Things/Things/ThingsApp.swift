import SwiftUI

@main
struct ThingsApp: App {
    @ObservedObject var router = Router()
    @StateObject var loginStatus: LoginStatus = LoginStatus()
        
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.navPath) {
                
                MainView()
                    .navigationDestination(for: Router.Destination.self) {
                        destination in switch destination {
                            
                        case .register:
                            RegisterView()
                        
                        case .login:
                            LoginView(loginStatus: loginStatus)
                        
                        case .refreshPass:
                            RefreshPasswordView()
                            
                        case .categories:
                            CategoriesView( loginStatus: loginStatus)
                            
                        case .categoryProducts(let categoryName):
                            CategoryView(loginStatus: loginStatus, categoryName: categoryName)
                            
                        case .product(let productName):
                            ProductView(loginStatus: loginStatus, productName: productName)
                            
                        case .notes:
                            NotesView( loginStatus: loginStatus)
                            
                        case .note(let noteName):
                            NoteView(loginStatus: loginStatus, noteName: noteName)
                            
                        case .account:
                            AccountView(loginStatus: loginStatus)
                        }
                        
                    }
                
            }
            .environmentObject(router)
        }
    }
}
