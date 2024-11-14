import SwiftUI

struct LogoImageView: View{
    
    var opacity: Double?
    var padding: CGFloat?
    var paddingTop: CGFloat?
    
    var body: some View{
            
        VStack {
            Image("logo")
                .clipShape(Circle())
                .opacity(opacity ?? 1.0)
                .padding(.bottom, padding ?? 0.0)
                .padding(.top, paddingTop ?? 10.0)
                
        }
    }
}
