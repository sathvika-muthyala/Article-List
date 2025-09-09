//
//  ArticleViewModel.swift
//  ArticleList
//
//  Created by sathvika muthyala on 9/8/25.
//

import UIKit

protocol ArticleViewModelProtocol {
    var articleList: [Article] { get }
    func getDataFromServer(closure: @escaping (() -> Void))
    func getCount() -> Int
    func getArticle(row: Int) -> Article?
    func getTitle(row: Int) -> String
    var heightOfRow: Int { get }
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
        guard row >= 0, row < articleList.count else { return "" }
        return articleList[row].title
    }
}

