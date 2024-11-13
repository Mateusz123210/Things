import SwiftUI

struct LogoImageView: View{
    
    var opacity: Double?
    var padding: CGFloat?
    var width: CGFloat?
    
    var body: some View{
            
        VStack {
            Image("logo")
                .clipShape(Circle())
                .opacity(opacity ?? 1.0)
                .padding(.bottom, padding ?? 0.0)
                .padding(.top, 10.0)
                .frame(width: width ?? 75)
                
        }
    }
}
