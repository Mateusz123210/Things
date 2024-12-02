import SwiftUI

struct RegisterService {
    
    func registerUser(data: RegisterSchema, viewRef: RegisterView){
        
        let url = URL(string: "https://things2024.azurewebsites.net/register")!
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
                    viewRef.registered()
                }
            }.resume()
            
        }catch {
            DispatchQueue.main.async {
                viewRef.showAlert(message: "Internal problem occured")
            }
        }
        
        return
    }
}
