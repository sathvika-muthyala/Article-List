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

    func loadImage() async -> UIImage? {
        guard let urlString = article.imageUrl, !urlString.isEmpty else {
            return nil
        }

        do {
            let data = try await networkManager.getData(from: urlString)
            return UIImage(data: data)
        } catch {
            return nil
        }
    }


}
