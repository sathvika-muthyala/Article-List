//
//  extensions.swift
//  ArticleList
//
//  Created by sathvika muthyala on 9/9/25.
//

import Foundation

extension NetworkManager: NetworkManagerProtocol {
    func fetchData(from url: String, completion: @escaping (ArticleList?) -> Void) {
        self.fetchData(from: url, closure: completion)
    }

    func fetchImage(from url: URL, completion: @escaping (Data?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            completion(data)
        }.resume()
    }
}
