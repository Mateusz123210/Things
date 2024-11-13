import SwiftUI

struct CategoriesView: View{
    
    @EnvironmentObject var router: Router
    
    var body: some View{
        VStack{
            Text("All categories")
        }.navigationBarBackButtonHidden(true)
        
        
    }
}
