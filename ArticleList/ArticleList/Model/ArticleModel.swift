//  NewsModel.swift
//  News_IOS
//
//  Created by sathvika muthyala on 9/8/25.
//

import Foundation

struct ArticleList: Decodable {
    var articles: [Article]
}

struct Article: Decodable {
    let source: Source
    var author: String?
    var title: String
    let description: String?
    let url: String
    let imageUrl: String?
    let dateOfPublication: String?
    let content: String?
    
    enum CodingKeys: String, CodingKey {
        case source
        case author
        case title
        case description
        case url
        case imageUrl = "urlToImage"
        case dateOfPublication = "publishedAt"
        case content
    }
    var dateOfPublicationOnly: String {
        guard let dateOfPublication = dateOfPublication, dateOfPublication.count >= 10 else { return "" }
        return String(dateOfPublication.prefix(10))
    }
}

struct Source: Decodable {
    let id: String?
    let name: String
}
