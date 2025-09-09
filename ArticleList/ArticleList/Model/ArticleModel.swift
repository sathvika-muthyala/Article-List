//  NewsModel.swift
//  News_IOS
//
//  Created by sathvika muthyala on 9/8/25.
//

import Foundation

struct ArticleList: Decodable {
    var articles: [Article]?
}

struct Article: Decodable {
    let source: Source
    let author: String?
    let title: String
    let description: String?
    let url: String
    let imageUrl: String?
    let dateOfPublication: String
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
}

struct Source: Codable {
    let id: String?
    let name: String
}
