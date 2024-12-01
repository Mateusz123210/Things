import SwiftUI

struct FetchTokensSchema : Codable {
    
    var tokens: TokensSchema?
    var fetched: Bool
    var message: String?
    var errorCode: Int?
    
}
