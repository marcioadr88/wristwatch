// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let news = try? newJSONDecoder().decode(News.self, from: jsonData)

import Foundation
import RealmSwift

// MARK: - News
struct News: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

// MARK: - Article
class Article: Object, Codable {
    @objc dynamic var id: String?
    @objc dynamic var title: String?
    @objc dynamic var content: String?
    
    var author: String?

    var publishedAt: Date?
    var urlToImage: String?

    var source: Source?
    var articleDescription: String?
    var url: String?
    
    enum CodingKeys: String, CodingKey {
        case source, author, title
        case articleDescription = "description"
        case url, urlToImage, content, publishedAt 
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

// MARK: - Source
class Source: Codable {
    let id: String?
    let name: String?
}

// MARK: - News
struct NewsError: Codable {
    let status, code, message: String
}
