import SwiftUI

struct NoteSchema: Codable, Hashable{
    
    let name: String
    let text: String

    init(from decoder: Decoder) throws {
            var container = try decoder.unkeyedContainer()
            name = try container.decode(String.self)
            text = try container.decode(String.self)
    }
}

struct NoteAddSchema: Codable, Hashable{
    
    var name: String
    var text: String

}

struct NoteEditSchema: Codable, Hashable{
    
    var old_name: String
    var name: String
    var text: String?

}

struct NoteDeleteSchema: Codable, Hashable{
    
    let name: String
    
}
