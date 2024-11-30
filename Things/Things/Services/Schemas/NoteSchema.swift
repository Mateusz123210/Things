import SwiftUI

struct NoteSchema: Codable, Hashable{
    
    var name: String
    var text: String
    
    init(name: String, text: String){
        self.name = name
        self.text = text
    }

    init(from decoder: Decoder) throws {
            var container = try decoder.unkeyedContainer()
            name = try container.decode(String.self)
            text = try container.decode(String.self)
    }
    
    mutating func clear(){
        self.name = ""
        self.text = ""
    }
}

struct NoteAddSchema: Codable, Hashable{
    
    var name: String
    var text: String

}

struct NoteEditSchema: Codable, Hashable{
    
    var old_name: String
    var name: String
    var text: String

}

struct NoteDeleteSchema: Codable, Hashable{
    
    let name: String
    
}

struct NoteNameSchema: Codable, Hashable{
    
    var name: String
    
    init(name: String){
        self.name = name
    }

}
