import SwiftUI


final class Router: ObservableObject {
    
    public enum Destination: Codable, Hashable {
        case register
        case login
        case refreshPassword
        case categories
        case categoryProducts(categoryName: String)
        case product(productName: String)
        case notes
        case note(noteName: String)
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
