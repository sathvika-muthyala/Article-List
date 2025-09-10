//
//  DetailsViewModel.swift
//  ArticleList
//
//  Created by sathvika muthyala on 9/10/25.
//

import UIKit

final class DetailsViewModel {
    private(set) var article: Article

    init(article: Article) {
        self.article = article
    }
    
    var authorText: String { article.author ?? "" }
    var titleText: String { article.title }
    var bodyText: String { article.description ?? article.content ?? "" }

    func setAuthor(_ newAuthor: String?) {
        let trimmed = (newAuthor ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            article.author = trimmed
        }
    }

    func loadImage(_ completion: @escaping (UIImage?) -> Void) {
        guard let path = article.imageUrl, !path.isEmpty else {
            completion(nil); return
        }

        if let img = UIImage(named: path) {
            completion(img); return
        }

        guard let url = URL(string: path) else {
            completion(nil); return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let img = UIImage(data: data) else {
                completion(nil); return
            }
            completion(img)
        }.resume()
    }
}
