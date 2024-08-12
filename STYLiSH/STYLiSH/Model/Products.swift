import Foundation

struct Hots: Codable {
    let data: [Data]
}

struct Data: Codable {
    let title: String
    let products: [Products]
}

struct Product: Codable {
    let data: [Products]
}

struct Products: Codable {
    let id: Int
    let category, title, description: String
    let price: Int
    let texture, wash, place, note: String
    let story: String
    let main_image: String
    let images: [String]
    let variants: [Variant]
    let colors: [Color]
    let sizes: [String]
}

struct Color: Codable {
    var code, name: String
}

struct Variant: Codable {
    let color_code: String
    let size: String
    let stock: Int
}

struct List: Codable {
    var id: String
    var name: String
    var price: Int
    var color: [String]
    var size: String
    var qty: Int
}
