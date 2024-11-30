import SwiftUI

struct NotesService{
    private let refreshTokenService = RefreshTokenService()
        
    func getAllNotes(loginStatus: LoginStatus, viewRef: NotesView, enableRefreshToken: Bool = true, tokensCopy: TokensSchema? = nil){
        
        let url = "https://things2024.azurewebsites.net/note/all"
        
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
                                            return getAllNotes(loginStatus: loginStatus, viewRef: viewRef, enableRefreshToken: false, tokensCopy: TokensSchema(access_token: accessToken, refresh_token: refreshToken))
                                            
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
                        viewRef.handleNoNotes()
                    }
                    else{
                                 
                        let notes = try JSONDecoder().decode([NoteSchema].self, from: data)
                        viewRef.notesFetched(notes: notes)
                    }
                    
                } catch let jsonError {
                    viewRef.handleFetchError(message: "Internal problem occured")
                }
                
            }.resume()
        return
    }
    
    func addNote(paramsData: NoteAddSchema, loginStatus: LoginStatus, viewRef: NotesView, enableRefreshToken: Bool = true, tokensCopy: TokensSchema? = nil){
        
        let url = "https://things2024.azurewebsites.net/note"
        
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
                                            return addNote(paramsData: paramsData, loginStatus: loginStatus, viewRef: viewRef, enableRefreshToken: false, tokensCopy: TokensSchema(access_token: accessToken, refresh_token: refreshToken))
                                            
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
                viewRef.fetchNotes()
            }.resume()
        }catch {
            DispatchQueue.main.async {
                viewRef.showAlert(message: "Internal problem occured")
            }
        }
        return
    }
    
    func editNote(paramsData: NoteEditSchema, loginStatus: LoginStatus, viewRef: NoteView, enableRefreshToken: Bool = true, tokensCopy: TokensSchema? = nil){
        
        let url = "https://things2024.azurewebsites.net/note"
        
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
                        print(statusCode)
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
                                            return editNote(paramsData: paramsData, loginStatus: loginStatus, viewRef: viewRef, enableRefreshToken: false, tokensCopy: TokensSchema(access_token: accessToken, refresh_token: refreshToken))
                                            
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
                        print("1")
                        viewRef.handleFetchError(message: "Internal problem occured")
                    }
                    
                    return
                }
                viewRef.backToBrowse()

            }.resume()
        }catch {
            DispatchQueue.main.async {
                viewRef.showAlert(message: "Internal problem occured")
            }
        }
        return
    }
    
    
    func deleteNote(paramsData: NoteDeleteSchema, loginStatus: LoginStatus, viewRef: NoteView, enableRefreshToken: Bool = true, tokensCopy: TokensSchema? = nil){
        
        let url = "https://things2024.azurewebsites.net/note"
        
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
                                            return deleteNote(paramsData: paramsData, loginStatus: loginStatus, viewRef: viewRef, enableRefreshToken: false, tokensCopy: TokensSchema(access_token: accessToken, refresh_token: refreshToken))
                                            
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
                
            }.resume()
        }catch {
            DispatchQueue.main.async {
                viewRef.showAlert(message: "Internal problem occured")
            }
        }
        return
    }
    
    func getNote(paramsData: NoteNameSchema, loginStatus: LoginStatus, viewRef: NoteView, enableRefreshToken: Bool = true, tokensCopy: TokensSchema? = nil){
        
        let url = "https://things2024.azurewebsites.net/note"
        
        var parameters: [String: String] = [:]
        
        if(tokensCopy == nil){
            parameters = ["access_token": loginStatus.accessToken!,
                          "email": loginStatus.email!,
                          "name": paramsData.name]
        }else{
            parameters = ["access_token": tokensCopy!.access_token,
                          "email": loginStatus.email!,
                          "name": paramsData.name]
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
                                        return getNote(paramsData: paramsData, loginStatus: loginStatus, viewRef: viewRef, enableRefreshToken: false, tokensCopy: TokensSchema(access_token: accessToken, refresh_token: refreshToken))
                                        
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
                    viewRef.handleNoNote()
                }
                else{
                             
                    let note = try JSONDecoder().decode(NoteSchema.self, from: data)
                    viewRef.noteFetched(note: note)
                }
                
            } catch let jsonError {
                viewRef.handleFetchError(message: "Internal problem occured")
            }
            
        }.resume()

        return
    }
    
    
}
