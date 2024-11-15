import SwiftUI


struct CategoriesService{
    private let refreshTokenService = RefreshTokenService()
    
    func handleRefreshToken(loginStatus: LoginStatus){
        refreshTokenService.refreshToken(loginStatus: loginStatus){ result in
            switch result {
            case .success(let fetchedTokens):
                print("AS")
                print(fetchedTokens)
            
            case .failure(let error):
                print("A")
                break
            }
        }
    }
    
    func getAllCategories(data: AccessTokenSchema, loginStatus: LoginStatus, viewRef: CategoriesView){
        
        let url = URL(string: "https://things2024.azurewebsites.net/category/all")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do{
            let jsonData = try JSONEncoder().encode(data)
            request.httpBody = jsonData
            
            URLSession.shared.dataTask(with: request) {data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
//                        viewRef.showAlert(message: "Connection problem occured")
                    }
                    return
                    
                }
                
                guard let data = data else {
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    
                    DispatchQueue.main.async {
  
//                        do{
//                            let detail = try JSONDecoder().decode(DetailSchema.self, from: data)
//                            viewRef.showAlert(message: detail.detail)
//                        } catch let jsonError {
//                            viewRef.showAlert(message: "Internal problem occured")
//                        }
                        
                    }
                    return
                }
                
//                DispatchQueue.main.async {
//                    do{
//                        var tokens = try JSONDecoder().decode(TokensSchema.self, from: data)
//                        viewRef.logged(tokens: tokens)
//                    } catch let jsonError {
//                        viewRef.showAlert(message: "Internal problem occured")
//                    }
//
//                    
//
//                   
//                }
            }.resume()
            
        }catch {
            DispatchQueue.main.async {
                //viewRef.showAlert(message: "Internal problem occured")
            }
        }
        
        return
        
        
        
        
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
