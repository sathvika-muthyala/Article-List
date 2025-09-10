//
//  MockNetworkManager.swift
//  ArticleList
//
//  Created by sathvika muthyala on 9/9/25.
//

import Foundation

class MockNetworkManager: Network {
    static let shared = MockNetworkManager()
    func fetchData(from serverUrl: String, closure: @escaping (ArticleList?) -> Void) {
        func getData(from serverUrl: String?, closure: @escaping (Data?) -> Void) {
            guard let imageUrl = serverUrl, let serverURL = URL(string: imageUrl) else {
                print("Server URL is invalid")
                closure(nil)
                return
            }
            var articleJsonString: String? =  """
            {
            "status": "ok",
            "totalResults": 3457,
            "articles": [
            {
             "source": {
               "id": null,
               "name": "Seekingalpha.com"
             },
             "author": "Victor Dergunov",
             "title": "Tesla: The Top Is Here",
             "description": "To say that Tesla has been on fire lately is an understatement. The stock has gone parabolic, Bitcoin like, vertical in recent weeks.The company's market cap is now around $160 billion, and its projected 2020 P/E multiple is roughly 113.Stocks cannot continuo…",
             "url": "https://seekingalpha.com/article/4321590-tesla-top-is",
             "urlToImage": "https://static.seekingalpha.com/uploads/2020/2/5/48200183-15809104384836764_origin.jpg",
             "publishedAt": "2020-02-05T15:47:40Z",
             "content": "Image Source\r\nTesla's Top Is Here\r\nTeslas (TSLA) stock has entered full throttle ludicrous mode, as shares have literally turned vertical in recent sessions. Due to what I referred to as the short squeeze of the century in a previous article, as well as vario… [+5303 chars]"
            }
            ]
            }
            """
            
            let data = articleJsonString?.data(using: .utf8)
            guard let data = data else {
                print("No data returned from the server")
                closure(nil)
                return
            }
            
            closure(data)
        }
        
        func parse(data: Data?) -> [ArticleList] {
            guard let data = data else {
                print("No data to parse")
                return []
            }
            
            do {
                let articleList = try JSONDecoder().decode(ArticleList.self, from: data)
                closure(articleList)
            } catch {
                print("Error parsing JSON: \(error)")
            }
            
            return []
        }
    }
}
