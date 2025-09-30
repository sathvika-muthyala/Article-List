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
        type: T.Type
    ) async -> NetworkState?
    func getArticle(row: Int) -> Article?
    func getCount() -> Int
    func getTitle(row: Int) -> String
    func getAuthor(row: Int) -> String
    func getDescription(row: Int) -> String
    func getFormattedDate(row: Int) -> String
    func getImage(row: Int) async -> UIImage? 
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
        type: T.Type
    ) async -> NetworkState? {
        do {
            let data = try await networkManager.getData(from: Server.articleApi.rawValue)
            let result = try networkManager.parse(data: data, type: type)
            if let articleList = (result as? ArticleList)?.articles {
                self.articleList = articleList
                self.filterArticles(query: self.filterQuery)
            }
            
            self.errorState = nil
            return nil 
        } catch let error as NetworkState {
            self.errorState = error
            return error
        } catch {
            self.errorState = .errorFetchingData
            return self.errorState
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
    
    func getImage(row: Int) async -> UIImage? {
        guard let urlString = getArticle(row: row)?.imageUrl,
              !urlString.isEmpty else {
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

extension ArticleViewModel {
    var errorMessage: String? {
        guard let errorState = errorState else { return nil }
        
        switch errorState {
        case .isLoading:
            return "Data Loading"
        case .invalidURL:
            return "Invalid URL"
        case .errorFetchingData:
            return "Error fetching data"
        case .noDataFromServer:
            return "No data from server"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .success:
            return nil
        }
    }
}

