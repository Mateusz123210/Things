import SwiftUI

struct RefreshTokenService {
    
    func refreshToken(loginStatus: LoginStatus, completion: @escaping (Result<FetchTokensSchema, Error>) ->Void) {

        let url = "https://things2024.azurewebsites.net/refresh-token"

        let parameters = ["refresh_token": loginStatus.refreshToken!,
                          "email": loginStatus.email!]
        
        let paramString = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        let fullURL = URL(string: "\(url)?\(paramString)")!

        var request = URLRequest(url: fullURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
 
            
        URLSession.shared.dataTask(with: request) {data, response, error in
            if let error = error {
                completion(.success(FetchTokensSchema(fetched: false, message: "Connection problem occured")))
                return
                
            }
            
            guard let data = data else {
                completion(.success(FetchTokensSchema(fetched: false, message: "Internal problem occured")))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                completion(.success(FetchTokensSchema(fetched: false, errorCode: statusCode)))
                return
            }
            
            do{
                let tokens = try JSONDecoder().decode(TokensSchema.self, from: data)
                completion(.success(FetchTokensSchema(tokens: tokens, fetched: true)))
            } catch let jsonError {
                completion(.success(FetchTokensSchema(fetched: false, message: "Internal problem occured")))
            }
        }.resume()
            
       
        
        return
    }
}
