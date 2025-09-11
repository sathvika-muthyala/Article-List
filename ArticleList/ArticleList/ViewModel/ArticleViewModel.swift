//
//  ArticleViewModel.swift
//  ArticleList
//
//  Created by sathvika muthyala on 9/8/25.
//

import UIKit

protocol ArticleViewModelProtocol {
    var articleList: [Article] { get }
    var heightOfRow: Int { get }
    func getDataFromServer(closure: @escaping (() -> Void))
    func getCount() -> Int
    func getTitle(row: Int) -> String
    func getAuthor(row: Int) -> String
    func getDescription(row: Int) -> String
    func getFormattedDate(row: Int) -> String
    func getImage(row: Int, completion: @escaping (UIImage?) -> Void)
}


class ArticleViewModel: ArticleViewModelProtocol {
    
    var articleList: [Article] = []
    var networkManager = NetworkManager.shared
    var heightOfRow: Int = Height.rowHeight.rawValue
    
    init(networkManager: Network = NetworkManager.shared) {
        self.networkManager = networkManager as! NetworkManager
        }
    
    func getDataFromServer(closure: @escaping () -> Void) {
        networkManager.getData(from: Server.articleApi.rawValue) { [weak self] data in
            guard let self = self else { return }

            // Decode JSON bytes into [Article]
            self.articleList = self.networkManager.parse(data: data) ?? []

            // If you also keep a filtered/visible list, mirror it here:
            // self.visibleList = self.articleList

            DispatchQueue.main.async {
                closure() // tell the VC to reload UI etc.
            }
        }
    }
    
    func getCount() -> Int {
        return articleList.count
    }
    
    func getArticle(row: Int) -> Article? {
        guard row >= 0, row < articleList.count else { return nil }
        return articleList[row]
    }
    
    func getTitle(row: Int) -> String {
        guard let article = getArticle(row: row) else { return "" }
        return article.title
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
