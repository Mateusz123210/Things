import SwiftUI


final class Router: ObservableObject {
    
    public enum Destination: Codable, Hashable {
        case register
        case login
        case refreshPass
        case categories
        case categoryProducts(categoryName: String)
        case product(productName: String, categoryName: String)
        case notes
        case note(noteName: String)
        case account
    }
    
    @Published var navPath = NavigationPath()
    
    func navigate(destination: Destination) {
        navPath.append(destination)
    }
    
    func navigateBack() {
        navPath.removeLast()
    }
    
    func navigateToRoot() {
        navPath.removeLast(navPath.count)
    }
    
}
