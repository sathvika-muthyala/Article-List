//
//  DetailsViewModel.swift
//  ArticleList
//
//  Created by sathvika muthyala on 9/10/25.
//

import UIKit

final class DetailsViewModel: AnyObject {
    var article: Article

    init(article: Article) {
        self.article = article
    }
    var networkManager = NetworkManager.shared
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
        guard let urlString = article.imageUrl, !urlString.isEmpty else {
            DispatchQueue.main.async { completion(nil) }
            return
        }

        networkManager.getData(from: urlString) { state in
            switch state {
            case .success(let data):
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    completion(image)
                }
            case .isLoading, .invalidURL, .errorFetchingData, .noDataFromServer:
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }

}
