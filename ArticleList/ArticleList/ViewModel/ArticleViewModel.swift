//
//  ArticleViewModel.swift
//  ArticleList
//
//  Created by sathvika muthyala on 9/8/25.
//

import UIKit

protocol ArticleViewModelProtocol {
    var articleList: [Article] { get }
    var heightOfRow: Int {get}
    func getDataFromServer(closure: @escaping () -> Void)
    func getArticle(row: Int) -> Article?
    func getCount() -> Int
    func getTitle(row: Int) -> String
    func getAuthor(row: Int) -> String
    func getDescription(row: Int) -> String
    func getFormattedDate(row: Int) -> String
    func getImage(row: Int, completion: @escaping (UIImage?) -> Void)
}


class ArticleViewModel: ArticleViewModelProtocol {
    var articleList: [Article] = []
    var filteredList: [Article] = []
    var networkManager = NetworkManager.shared
    var heightOfRow: Int = Height.rowHeight.rawValue
    
    init(networkManager: Network = NetworkManager.shared) {
        self.networkManager = networkManager as! NetworkManager
    }
    
    func getDataFromServer(closure: @escaping () -> Void) {
        networkManager.getData(from: Server.articleApi.rawValue) { [weak self] data in
            guard let self = self else { return }
            self.articleList = self.networkManager.parse(data: data) ?? []
            self.filteredList = self.articleList  // start with full list
            DispatchQueue.main.async { closure() }
        }
    }
    
    func getCount() -> Int {
        return filteredList.count
    }
    
    func getArticle(row: Int) -> Article? {
        guard row >= 0, row < filteredList.count else { return nil }
        return filteredList[row]
    }
    
    func getTitle(row: Int) -> String {
        return getArticle(row: row)?.title ?? ""
    }
    
    func getAuthor(row: Int) -> String {
        return getArticle(row: row)?.author ?? "Unknown"
    }
    
    func getDescription(row: Int) -> String {
        return getArticle(row: row)?.description ?? ""
    }
    
    func getFormattedDate(row: Int) -> String {
        return getArticle(row: row)?.dateOfPublicationOnly ?? ""
    }
    
    func filterArticles(query: String) {
        if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            filteredList = articleList
        } else {
            filteredList = articleList.filter {
                $0.title.localizedCaseInsensitiveContains(query) ||
                ($0.description?.localizedCaseInsensitiveContains(query) ?? false) ||
                ($0.author?.localizedCaseInsensitiveContains(query) ?? false)
            }
        }
    }


    func getImage(row: Int, completion: @escaping (UIImage?) -> Void) {
        guard let urlString = getArticle(row: row)?.imageUrl, !urlString.isEmpty else {
            DispatchQueue.main.async { completion(nil) }
            return
        }
        networkManager.getData(from: urlString) { data in
            let image = data.flatMap(UIImage.init(data:))
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }

}
