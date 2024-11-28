import SwiftUI

struct CategorySchema: Codable, Hashable{
    
    let name: String
    let photo: String?
    var marked: Bool = false
    
    init(from decoder: Decoder) throws {
            var container = try decoder.unkeyedContainer()
            name = try container.decode(String.self)
            photo = try container.decodeIfPresent(String.self)
    }
}
