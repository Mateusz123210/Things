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
                        viewRef.showAlert(message: "Connection error")
                    }
                    return
                    
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                   
                    DispatchQueue.main.async {
                        let msg = (response as? HTTPURLResponse)?.statusCode ?? 0
                        viewRef.showAlert(message: "Failed with status code: \(msg)")
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    viewRef.showAlert(message: "Registered")
                }
            }.resume()
            
        }catch {
            DispatchQueue.main.async {
                viewRef.showAlert(message: "Connection error")            }
        }
        
        return
    }
}
