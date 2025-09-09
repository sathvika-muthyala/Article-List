//
//  Untitled.swift
//  ArticleList
//
//  Created by sathvika muthyala on 9/8/25.
//

import Foundation

protocol Network {
    func fetchData(from serverUrl: String, closure: @escaping (ArticleList?) -> Void)
}

class NetworkManager: Network {
    static let shared = NetworkManager()

    func fetchData(from serverUrl: String, closure: @escaping (ArticleList?) -> Void) {

        guard let serverURL = URL(string: serverUrl) else {
            print("Server URL is invalid")
            return
        }
        
        let urlSession = URLSession.shared
        urlSession.dataTask(with: URLRequest(url: serverURL)) { data, response, error in
            
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data returned from the server")
                return
            }
            
            do {
                let articleList = try JSONDecoder().decode(ArticleList.self, from: data)
                closure(articleList)
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }.resume()
    }
}
