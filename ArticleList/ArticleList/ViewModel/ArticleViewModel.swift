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
    
    func getDataFromServer(closure: @escaping (() -> Void)) {
        networkManager.fetchData(from: Server.articleApi.rawValue) { [weak self] fetchedList in
            self?.articleList = fetchedList?.articles ?? []
            closure()
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
        guard let isoString = getArticle(row: row)?.dateOfPublication else { return "" }
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]
        
        if let date = isoFormatter.date(from: isoString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "yyyy-MM-dd"
            return displayFormatter.string(from: date)
        }
        return isoString
    }
    
    func getImage(row: Int, completion: @escaping (UIImage?) -> Void) {
        guard let urlString = getArticle(row: row)?.imageUrl,
              let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let img = UIImage(data: data) else {
                completion(nil)
                return
            }
            completion(img)
        }.resume()
    }
}
