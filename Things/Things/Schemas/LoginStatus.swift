import SwiftUI

class LoginStatus: ObservableObject {
    @Published var logged: Bool = false
    @Published var accessToken: String? = nil
    @Published var refreshToken: String? = nil
    @Published var email: String? = nil
    
    func handleLogout(){
        logged = false
        accessToken = nil
        refreshToken = nil
        email = nil
    }
}

