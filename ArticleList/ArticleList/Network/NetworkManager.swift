//
//  Untitled.swift
//  ArticleList
//
//  Created by sathvika muthyala on 9/8/25.
//

import Foundation

protocol Network {
    
    func getData(from serverUrl: String?, closure: @escaping (NetworkState) -> Void)
    func parse(data: Data?) -> [Article]?
    
}

class NetworkManager: Network {
    
    static let shared = NetworkManager()
    var state: NetworkState = .isLoading
    
    func getData(from serverUrl: String?, closure: @escaping (NetworkState) -> Void) {
        guard let apiUrl = serverUrl, let serverURL = URL(string: apiUrl) else {
            state = .invalidURL
            closure(state)
            return
        }
        
        URLSession.shared.dataTask(with: serverURL) { [self] data, response, error in
            if let _ = error {
                self.state = .errorFetchingData
                closure(self.state)
                return
            }
            
            guard let data = data else {
                self.state = .noDataFromServer
                closure(state)
                return
            }
            self.state = .success(data)
            closure(self.state)
        }.resume()
    }
    
    func parse(data: Data?) -> [Article]? {
        guard let data = data else {
            print("No data to parse")
            return []
        }
        do {
            let decoder = JSONDecoder()
            let fetchedResult = try decoder.decode(ArticleList.self, from: data)
            return fetchedResult.articles
        } catch {
            print(error)
        }
        return []
    }
}
