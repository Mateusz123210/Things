import SwiftUI

struct ProductFetchSchema: Codable, Hashable{
    
    let name: String
    let categoryName: String
    let quantity: String
    let photo: String?
    let audio: String?
    let video: String?
    var marked: Bool = false
    
    init(name: String, categoryName: String, quantity: String, photo: String?, audio: String?, video: String?){

        self.name = name
        self.categoryName = categoryName
        self.quantity = quantity
        self.photo = photo
        self.audio = audio
        self.video = video
    }
    
    init(from decoder: Decoder) throws {
            var container = try decoder.unkeyedContainer()
            name = try container.decode(String.self)
            categoryName = try container.decode(String.self)
            quantity = try container.decode(String.self)
            photo = try container.decodeIfPresent(String.self)
            audio = try container.decodeIfPresent(String.self)
            video = try container.decodeIfPresent(String.self)
    }
}

struct ProductAddSchema: Codable, Hashable{
    
    var name: String
    var category_name: String
    var quantity: String
    var photo: String?
    var audio: String?
    var video: String?

}

struct ProductEditSchema: Codable, Hashable{
    
    var name: String
    var category_name: String
    var quantity: String
    var photo: String?
    var audio: String?
    var video: String?
    var old_name: String

}

struct ProductDeleteSchema: Codable, Hashable{
    
    var name: String
    var category_name: String
    
}
