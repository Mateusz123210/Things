import SwiftUI

struct LogoImageView: View{
    
    var opacity: Double?
    var padding: Float?
    
    var body: some View{
            
        VStack {
            Image("logo")
                .clipShape(Circle())
                .opacity(opacity ?? 1.0)
        }
    }
}
