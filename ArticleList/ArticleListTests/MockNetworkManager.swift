//
//  MockNetworkManager.swift
//  ArticleList
//
//  Created by sathvika muthyala on 9/9/25.
//

import Foundation
@testable import ArticleList

class MockNetworkManager: NetworkManagerProtocol {
    var mockArticles: [Article] = []
    var mockImageData: Data? = nil

    func fetchData(from url: String, completion: @escaping (ArticleList?) -> Void) {
        completion(ArticleList(articles: mockArticles))
    }

    func fetchImage(from url: URL, completion: @escaping (Data?) -> Void) {
        completion(mockImageData)
    }
}

