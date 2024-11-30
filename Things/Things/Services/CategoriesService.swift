import SwiftUI


struct CategoriesService{
    private let refreshTokenService = RefreshTokenService()
        
    func getAllCategories(loginStatus: LoginStatus, viewRef: CategoriesView, enableRefreshToken: Bool = true, tokensCopy: TokensSchema? = nil){
        
        let url = "https://things2024.azurewebsites.net/category/all"
        
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

        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
            URLSession.shared.dataTask(with: request) {data, response, error in
                if let error = error {
                    
                        viewRef.handleFetchError(message: "Connection problem occured")
                    
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
                                                viewRef.handleFetchError(message: "Internal problem occured")
                                                return
                                            }
                                            DispatchQueue.main.async{
                                                loginStatus.accessToken = accessToken
                                                loginStatus.refreshToken = refreshToken
                                            }
                                            return getAllCategories(loginStatus: loginStatus, viewRef: viewRef, enableRefreshToken: false, tokensCopy: TokensSchema(access_token: accessToken, refresh_token: refreshToken))
                                            
                                        }else{
                                            if(fetchedTokens.message != nil){
                                                let message = fetchedTokens.message!
            
                                                viewRef.handleFetchError(message: message)
                                                
                                            }else{
                                                if(fetchedTokens.errorCode! == 401 || fetchedTokens.errorCode! == 403){
                                                    viewRef.handleCredentialsError()
                                                }else{
                                                    viewRef.handleFetchError(message: "Internal problem occured")
                                                }
                                            }
                                            
                                        }
                                    case .failure(_):
                                        viewRef.handleFetchError(message: "Internal problem occured")
                                    }
                                }
                            }else{
                                viewRef.handleCredentialsError()
                            }
                            
                        } else if (statusCode == 403){
                            viewRef.handleCredentialsError()
                        }else{
                            let detail = try JSONDecoder().decode(DetailSchema.self, from: data)
                            viewRef.handleFetchError(message: detail.detail)
                
                        }
                        
                    } catch let jsonError {
                        viewRef.handleFetchError(message: "Internal problem occured")
                    }
                        
                    return
                }
                
                do{
                    let resp = String(bytes: data, encoding: .utf8)
                    
                    if (resp!.count == 2){
                        viewRef.handleNoCategories()
                    }
                    else{
                                 
                        let categories = try JSONDecoder().decode([CategorySchema].self, from: data)
                        viewRef.categoriesFetched(categories: categories)
                    }
                    
                } catch let jsonError {
                    viewRef.handleFetchError(message: "Internal problem occured")
                }
                
            }.resume()
        return
    }
    
    func addCategory(paramsData: CategoryAddSchema, loginStatus: LoginStatus, viewRef: CategoriesView, enableRefreshToken: Bool = true, tokensCopy: TokensSchema? = nil){
        
        let url = "https://things2024.azurewebsites.net/category"
        
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
        
        do {
            let jsonData = try JSONEncoder().encode(paramsData)
            request.httpBody = jsonData
            URLSession.shared.dataTask(with: request) {data, response, error in
                
                if let error = error {
                    
                    viewRef.handleFetchError(message: "Connection problem occured")
                    
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
                                                viewRef.handleFetchError(message: "Internal problem occured")
                                                return
                                            }
                                            DispatchQueue.main.async{
                                                loginStatus.accessToken = accessToken
                                                loginStatus.refreshToken = refreshToken
                                            }
                                            return addCategory(paramsData: paramsData, loginStatus: loginStatus, viewRef: viewRef, enableRefreshToken: false, tokensCopy: TokensSchema(access_token: accessToken, refresh_token: refreshToken))
                                            
                                        }else{
                                            if(fetchedTokens.message != nil){
                                                let message = fetchedTokens.message!
                                                
                                                viewRef.handleFetchError(message: message)
                                                
                                            }else{
                                                if(fetchedTokens.errorCode! == 401 || fetchedTokens.errorCode! == 403){
                                                    viewRef.handleCredentialsError()
                                                }else{
                                                    viewRef.handleFetchError(message: "Internal problem occured")
                                                }
                                            }
                                            
                                        }
                                    case .failure(_):
                                        viewRef.handleFetchError(message: "Internal problem occured")
                                    }
                                }
                            }else{
                                viewRef.handleCredentialsError()
                            }
                            
                        } else if (statusCode == 403){
                            viewRef.handleCredentialsError()
                        }else{
                            let detail = try JSONDecoder().decode(DetailSchema.self, from: data)
                            viewRef.handleFetchError(message: detail.detail)
                            
                        }
                        
                    } catch let jsonError {
                        viewRef.handleFetchError(message: "Internal problem occured")
                    }
                    
                    return
                }
                viewRef.backToBrowse()
                viewRef.fetchCategories()
            }.resume()
        }catch {
            DispatchQueue.main.async {
                viewRef.showAlert(message: "Internal problem occured")
            }
        }
        return
    }
    
    func editCategory(paramsData: CategoryEditSchema, loginStatus: LoginStatus, viewRef: CategoriesView, enableRefreshToken: Bool = true, tokensCopy: TokensSchema? = nil){
        
        let url = "https://things2024.azurewebsites.net/category"
        
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

        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(paramsData)
            request.httpBody = jsonData
            URLSession.shared.dataTask(with: request) {data, response, error in
                
                if let error = error {
                    
                    viewRef.handleFetchError(message: "Connection problem occured")
                    
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
                                                viewRef.handleFetchError(message: "Internal problem occured")
                                                return
                                            }
                                            DispatchQueue.main.async{
                                                loginStatus.accessToken = accessToken
                                                loginStatus.refreshToken = refreshToken
                                            }
                                            return editCategory(paramsData: paramsData, loginStatus: loginStatus, viewRef: viewRef, enableRefreshToken: false, tokensCopy: TokensSchema(access_token: accessToken, refresh_token: refreshToken))
                                            
                                        }else{
                                            if(fetchedTokens.message != nil){
                                                let message = fetchedTokens.message!
                                                
                                                viewRef.handleFetchError(message: message)
                                                
                                            }else{
                                                if(fetchedTokens.errorCode! == 401 || fetchedTokens.errorCode! == 403){
                                                    viewRef.handleCredentialsError()
                                                }else{
                                                    viewRef.handleFetchError(message: "Internal problem occured")
                                                }
                                            }
                                            
                                        }
                                    case .failure(_):
                                        viewRef.handleFetchError(message: "Internal problem occured")
                                    }
                                }
                            }else{
                                viewRef.handleCredentialsError()
                            }
                            
                        } else if (statusCode == 403){
                            viewRef.handleCredentialsError()
                        }else{
                            let detail = try JSONDecoder().decode(DetailSchema.self, from: data)
                            viewRef.handleFetchError(message: detail.detail)
                            
                        }
                        
                    } catch let jsonError {
                        viewRef.handleFetchError(message: "Internal problem occured")
                    }
                    
                    return
                }
                viewRef.backToBrowse2()
                viewRef.fetchCategories()
            }.resume()
        }catch {
            DispatchQueue.main.async {
                viewRef.showAlert(message: "Internal problem occured")
            }
        }
        return
    }
    
    
    func deleteCategory(paramsData: CategoryDeleteSchema, loginStatus: LoginStatus, viewRef: CategoriesView, enableRefreshToken: Bool = true, tokensCopy: TokensSchema? = nil){
        
        let url = "https://things2024.azurewebsites.net/category"
        
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
        
        do {
            let jsonData = try JSONEncoder().encode(paramsData)
            request.httpBody = jsonData
            
            URLSession.shared.dataTask(with: request) {data, response, error in
                
                if let error = error {
                    
                    viewRef.handleFetchError(message: "Connection problem occured")
                    
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
                                                viewRef.handleFetchError(message: "Internal problem occured")
                                                return
                                            }
                                            DispatchQueue.main.async{
                                                loginStatus.accessToken = accessToken
                                                loginStatus.refreshToken = refreshToken
                                            }
                                            return deleteCategory(paramsData: paramsData, loginStatus: loginStatus, viewRef: viewRef, enableRefreshToken: false, tokensCopy: TokensSchema(access_token: accessToken, refresh_token: refreshToken))
                                            
                                        }else{
                                            if(fetchedTokens.message != nil){
                                                let message = fetchedTokens.message!
                                                
                                                viewRef.handleFetchError(message: message)
                                                
                                            }else{
                                                if(fetchedTokens.errorCode! == 401 || fetchedTokens.errorCode! == 403){
                                                    viewRef.handleCredentialsError()
                                                }else{
                                                    viewRef.handleFetchError(message: "Internal problem occured")
                                                }
                                            }
                                            
                                        }
                                    case .failure(_):
                                        viewRef.handleFetchError(message: "Internal problem occured")
                                    }
                                }
                            }else{
                                viewRef.handleCredentialsError()
                            }
                            
                        } else if (statusCode == 403){
                            viewRef.handleCredentialsError()
                        }else{
                            let detail = try JSONDecoder().decode(DetailSchema.self, from: data)
                            viewRef.handleFetchError(message: detail.detail)
                            
                        }
                        
                    } catch let jsonError {
                        viewRef.handleFetchError(message: "Internal problem occured")
                    }
                    
                    return
                }

                viewRef.fetchCategories()
                
            }.resume()
        }catch {
            DispatchQueue.main.async {
                viewRef.showAlert(message: "Internal problem occured")
            }
        }
        return
    }
    
//    func getCategory(categoryName: String, loginStatus: LoginStatus, viewRef: CategoryView, enableRefreshToken: Bool = true, tokensCopy: TokensSchema? = nil){
//        
//        let url = "https://things2024.azurewebsites.net/category"
//        
//        var parameters: [String: String] = [:]
//        
//        if(tokensCopy == nil){
//            parameters = ["access_token": loginStatus.accessToken!,
//                          "email": loginStatus.email!,
//                          "name": categoryName]
//        }else{
//            parameters = ["access_token": tokensCopy!.access_token,
//                          "email": loginStatus.email!,
//                          "name": categoryName]
//        }
//        
//        let paramString = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
//        let fullURL = URL(string: "\(url)?\(paramString)")!
//
//        var request = URLRequest(url: fullURL)
//
//        request.httpMethod = "GET"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//            URLSession.shared.dataTask(with: request) {data, response, error in
//                if let error = error {
//                    
//                        viewRef.handleFetchError(message: "Connection problem occured")
//                    
//                    return
//                    
//                }
//                
//                guard let data = data else {
//                    return
//                }
//                
//                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
//                    
//                    do{
//                        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
//                        if (statusCode == 401){
//                            if(enableRefreshToken == true){
//                                refreshTokenService.refreshToken(loginStatus: loginStatus){ result in
//                                    switch result {
//                                    case .success(let fetchedTokens):
//                                        if(fetchedTokens.fetched == true){
//                                            
//                                            let accessToken = fetchedTokens.tokens!.access_token
//                                            let refreshToken = fetchedTokens.tokens!.refresh_token
//                                            
//                                            
//                                            if(accessToken.count != 151 || refreshToken.count != 151){
//                                                viewRef.handleFetchError(message: "Internal problem occured")
//                                                return
//                                            }
//                                            DispatchQueue.main.async{
//                                                loginStatus.accessToken = accessToken
//                                                loginStatus.refreshToken = refreshToken
//                                            }
//                                            return getCategory(categoryName: categoryName, loginStatus: loginStatus, viewRef: viewRef, enableRefreshToken: false, tokensCopy: TokensSchema(access_token: accessToken, refresh_token: refreshToken))
//                                            
//                                        }else{
//                                            if(fetchedTokens.message != nil){
//                                                let message = fetchedTokens.message!
//            
//                                                viewRef.handleFetchError(message: message)
//                                                
//                                            }else{
//                                                if(fetchedTokens.errorCode! == 401 || fetchedTokens.errorCode! == 403){
//                                                    viewRef.handleCredentialsError()
//                                                }else{
//                                                    viewRef.handleFetchError(message: "Internal problem occured")
//                                                }
//                                            }
//                                            
//                                        }
//                                    case .failure(_):
//                                        viewRef.handleFetchError(message: "Internal problem occured")
//                                    }
//                                }
//                            }else{
//                                viewRef.handleCredentialsError()
//                            }
//                            
//                        } else if (statusCode == 403){
//                            viewRef.handleCredentialsError()
//                        }else{
//                            let detail = try JSONDecoder().decode(DetailSchema.self, from: data)
//                            viewRef.handleFetchError(message: detail.detail)
//                
//                        }
//                        
//                    } catch let jsonError {
//                        viewRef.handleFetchError(message: "Internal problem occured")
//                    }
//                        
//                    return
//                }
//                
//                do{
//                    let resp = String(bytes: data, encoding: .utf8)
//                    
//                    if (resp!.count == 2){
//                        viewRef.handleNoCategory()
//                    }
//                    else{
//    
//                        let category = try JSONDecoder().decode(CategorySchema.self, from: data)
//                        viewRef.categoryFetched(category: category)
//                    }
//                    
//                } catch let jsonError {
//                    viewRef.handleFetchError(message: "Internal problem occured")
//                }
//                
//            }.resume()
//        return
//    }
    
}
