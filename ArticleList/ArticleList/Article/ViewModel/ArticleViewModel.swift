//
//  ArticleViewModel.swift
//  ArticleList
//
//  Created by sathvika muthyala on 9/8/25.
//

import UIKit

protocol ArticleViewModelProtocol: AnyObject {
    var articleList: [Article] { get set}
    var filteredList: [Article] { get }
    var errorMessage: String? { get }
    var heightOfRow: Int {get}
    func getDataFromServer<T: Decodable>(
        type: T.Type,
        closure: @escaping (NetworkState?) -> Void
    )
    func getArticle(row: Int) -> Article?
    func getCount() -> Int
    func getTitle(row: Int) -> String
    func getAuthor(row: Int) -> String
    func getDescription(row: Int) -> String
    func getFormattedDate(row: Int) -> String
    func getImage(row: Int, completion: @escaping (UIImage?) -> Void)
}


class ArticleViewModel: ArticleViewModelProtocol {
  
    var errorState: NetworkState?
    var articleList: [Article] = []
    var networkManager = NetworkManager.shared
    var heightOfRow: Int = Height.rowHeight.rawValue
    private var filterQuery: String = ""
    var filteredList: [Article] {
            if filterQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return articleList
            } else {
                return articleList.filter {
                    $0.title.localizedCaseInsensitiveContains(filterQuery) ||
                    ($0.description?.localizedCaseInsensitiveContains(filterQuery) ?? false) ||
                    ($0.author?.localizedCaseInsensitiveContains(filterQuery) ?? false)
                }
            }
        }
    
    
    init(networkManager: Network = NetworkManager.shared) {
        self.networkManager = networkManager as! NetworkManager
    }
    
   
    
    func getDataFromServer<T: Decodable>(
            type: T.Type,
            closure: @escaping (NetworkState?) -> Void
        ) {
            networkManager.getData(from: Server.articleApi.rawValue) { [weak self] fetchedState in
                guard let self = self else { return }
                
                switch fetchedState {
                case .isLoading, .invalidURL, .errorFetchingData, .noDataFromServer:
                    self.errorState = fetchedState
                    
                case .success(let data):
                    switch self.networkManager.parse(data: data, type: type) {
                    case .success(let result):
                        if let articleList = (result as? ArticleList)?.articles {
                            self.articleList = articleList
                            self.filterArticles(query: self.filterQuery)
                        }
                        self.errorState = nil
                    case .failure(let parseError):
                        self.errorState = parseError
                    }
                case .decodingError:
                    self.errorState = fetchedState
                }
                
                DispatchQueue.main.async {
                    closure(self.errorState)
                }
            }
        }
    
    func filterArticles(query: String) {
        filterQuery = query
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
    
    func getImage(row: Int, completion: @escaping (UIImage?) -> Void) {
        guard let urlString = getArticle(row: row)?.imageUrl,
              !urlString.isEmpty else {
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

            case .isLoading, .invalidURL, .errorFetchingData, .noDataFromServer, .decodingError:
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }



}
