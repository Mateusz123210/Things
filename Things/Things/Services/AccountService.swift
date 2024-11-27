import SwiftUI

struct AccountService{
    private let refreshTokenService = RefreshTokenService()
        
    func logout(loginStatus: LoginStatus, viewRef: AccountView, enableRefreshToken: Bool = true, tokensCopy: TokensSchema? = nil){
        
        let url = "https://things2024.azurewebsites.net/logout"
        
        var parameters: [String: String] = [:]
        
        if(tokensCopy == nil){
            parameters = ["access_token": loginStatus.accessToken!,
                          "email": loginStatus.email!]
        }else{
            parameters = ["access_token": tokensCopy!.access_token,
                          "email": loginStatus.email!]
        }
        
        let paramString = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        let fullURL = URL(string: "\(url)?\(paramString)")!

        var request = URLRequest(url: fullURL)

        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
            URLSession.shared.dataTask(with: request) {data, response, error in
                if let error = error {
                    
                        viewRef.handleError(message: "Connection problem occured")
                    
                    return
                    
                }
                
                guard let data = data else {
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    
                    do{
                        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                        if (statusCode == 401){
                            if(enableRefreshToken == true){
                                refreshTokenService.refreshToken(loginStatus: loginStatus){ result in
                                    switch result {
                                    case .success(let fetchedTokens):
                                        if(fetchedTokens.fetched == true){
                                            
                                            let accessToken = fetchedTokens.tokens!.access_token
                                            let refreshToken = fetchedTokens.tokens!.refresh_token
                                            
                                            
                                            if(accessToken.count != 151 || refreshToken.count != 151){
                                                viewRef.handleError(message: "Internal problem occured")
                                                return
                                            }
                                            DispatchQueue.main.async{
                                                loginStatus.accessToken = accessToken
                                                loginStatus.refreshToken = refreshToken
                                            }
                                            return logout(loginStatus: loginStatus, viewRef: viewRef, enableRefreshToken: false, tokensCopy: TokensSchema(access_token: accessToken, refresh_token: refreshToken))
                                            
                                        }else{
                                            if(fetchedTokens.message != nil){
                                                let message = fetchedTokens.message!
            
                                                viewRef.handleError(message: message)
                                                
                                            }else{
                                                if(fetchedTokens.errorCode! == 401 || fetchedTokens.errorCode! == 403){
                                                    viewRef.handleCredentialsError()
                                                }else{
                                                    viewRef.handleError(message: "Internal problem occured")
                                                }
                                            }
                                            
                                        }
                                    case .failure(_):
                                        viewRef.handleError(message: "Internal problem occured")
                                    }
                                }
                            }else{
                                viewRef.handleCredentialsError()
                            }
                            
                        } else if (statusCode == 403){
                            viewRef.handleCredentialsError()
                        }else{
                            let detail = try JSONDecoder().decode(DetailSchema.self, from: data)
                            viewRef.handleError(message: detail.detail)
                
                        }
                        
                    } catch let jsonError {
                        viewRef.handleError(message: "Internal problem occured")
                    }
                        
                    return
                }
                
                viewRef.handleLogout()
                
            }.resume()
        return
    }
    
    func deleteAccount(loginStatus: LoginStatus, viewRef: AccountView, enableRefreshToken: Bool = true, tokensCopy: TokensSchema? = nil){
        
        let url = "https://things2024.azurewebsites.net/account"
        
        var parameters: [String: String] = [:]
        
        if(tokensCopy == nil){
            parameters = ["access_token": loginStatus.accessToken!,
                          "email": loginStatus.email!]
        }else{
            parameters = ["access_token": tokensCopy!.access_token,
                          "email": loginStatus.email!]
        }
        
        let paramString = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        let fullURL = URL(string: "\(url)?\(paramString)")!

        var request = URLRequest(url: fullURL)

        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
            URLSession.shared.dataTask(with: request) {data, response, error in
                if let error = error {
                    
                        viewRef.handleError(message: "Connection problem occured")
                    
                    return
                    
                }
                
                guard let data = data else {
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    
                    do{
                        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                        if (statusCode == 401){
                            if(enableRefreshToken == true){
                                refreshTokenService.refreshToken(loginStatus: loginStatus){ result in
                                    switch result {
                                    case .success(let fetchedTokens):
                                        if(fetchedTokens.fetched == true){
                                            
                                            let accessToken = fetchedTokens.tokens!.access_token
                                            let refreshToken = fetchedTokens.tokens!.refresh_token
                                            
                                            
                                            if(accessToken.count != 151 || refreshToken.count != 151){
                                                viewRef.handleError(message: "Internal problem occured")
                                                return
                                            }
                                            DispatchQueue.main.async{
                                                loginStatus.accessToken = accessToken
                                                loginStatus.refreshToken = refreshToken
                                            }
                                            return logout(loginStatus: loginStatus, viewRef: viewRef, enableRefreshToken: false, tokensCopy: TokensSchema(access_token: accessToken, refresh_token: refreshToken))
                                            
                                        }else{
                                            if(fetchedTokens.message != nil){
                                                let message = fetchedTokens.message!
            
                                                viewRef.handleError(message: message)
                                                
                                            }else{
                                                if(fetchedTokens.errorCode! == 401 || fetchedTokens.errorCode! == 403){
                                                    viewRef.handleCredentialsError()
                                                }else{
                                                    viewRef.handleError(message: "Internal problem occured")
                                                }
                                            }
                                            
                                        }
                                    case .failure(_):
                                        viewRef.handleError(message: "Internal problem occured")
                                    }
                                }
                            }else{
                                viewRef.handleCredentialsError()
                            }
                            
                        } else if (statusCode == 403){
                            viewRef.handleCredentialsError()
                        }else{
                            let detail = try JSONDecoder().decode(DetailSchema.self, from: data)
                            viewRef.handleError(message: detail.detail)
                
                        }
                        
                    } catch let jsonError {
                        viewRef.handleError(message: "Internal problem occured")
                    }
                        
                    return
                }
                
                viewRef.handleDeleteAccount()
                
            }.resume()
        return
    }
}
