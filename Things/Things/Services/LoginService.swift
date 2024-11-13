import SwiftUI

struct LoginService {
    
    func loginUser(data: RegisterSchema, viewRef: LoginView) {
        let url = URL(string: "https://things2024.azurewebsites.net/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do{
            let jsonData = try JSONEncoder().encode(data)
            request.httpBody = jsonData
            
            URLSession.shared.dataTask(with: request) {data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        viewRef.showAlert(message: "Connection problem occured")
                    }
                    return
                    
                }
                
                guard let data = data else {
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    
                    DispatchQueue.main.async {
                        //let msg = (response as? HTTPURLResponse)?.statusCode ?? 0
                        // viewRef.showAlert(message: "Failed with status code: \(msg)")
                        //let str1 = String(bytes: data, encoding: .utf8)
                        //viewRef.showAlert(message: str1!)
                        
                        do{
                            let detail = try JSONDecoder().decode(DetailSchema.self, from: data)
                            viewRef.showAlert(message: detail.detail)
                        } catch let jsonError {
                            viewRef.showAlert(message: "Internal problem occured")
                        }
                        
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    do{
                        var tokens = try JSONDecoder().decode(TokensSchema.self, from: data)
                        viewRef.logged(tokens: tokens)
                    } catch let jsonError {
                        viewRef.showAlert(message: "Internal problem occured")
                    }

                    

                   
                }
            }.resume()
            
        }catch {
            DispatchQueue.main.async {
                viewRef.showAlert(message: "Internal problem occured")            }
        }
        
        return
        
        
        
        
        
        
    }
    
    
    
}
