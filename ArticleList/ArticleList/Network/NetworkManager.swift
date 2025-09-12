//
//  Untitled.swift
//  ArticleList
//
//  Created by sathvika muthyala on 9/8/25.
//

import Foundation

protocol Network {
    
    func getData(from serverUrl: String?, closure: @escaping (Data?) -> Void)
    func parse(data: Data?) -> [Article]?
    
}

class NetworkManager: Network {
    
    static let shared = NetworkManager()
    
    func getData(from serverUrl: String?, closure: @escaping (Data?) -> Void) {
        guard let apiUrl = serverUrl, let serverURL = URL(string: apiUrl) else {
            print("Server URL is invalid")
            closure(nil)
            return
        }
        
        URLSession.shared.dataTask(with: serverURL) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error)")
                closure(nil)
                return
            }
            
            guard let data = data else {
                print("No data returned from the server")
                closure(nil)
                return
            }
            
            closure(data)
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
