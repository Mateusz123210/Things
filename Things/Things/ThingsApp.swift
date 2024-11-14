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
                            CategoriesView()
                            
                        case .categoryProducts(let categoryName):
                            CategoryView(categoryName: categoryName)
                            
                        case .product(let productName):
                            ProductView(productName: productName)
                            
                        case .notes:
                            NotesView()
                            
                        case .note(let noteName):
                            NoteView(noteName: noteName)
                            
                        }
                        
                    }
                
            }
            .environmentObject(router)
        }
    }
}
