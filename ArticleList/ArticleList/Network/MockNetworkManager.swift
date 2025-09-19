//
//  MockNetworkManager.swift
//  ArticleList
//
//  Created by sathvika muthyala on 9/9/25.
//

import Foundation

final class MockNetworkManager: Network {
    static let shared = MockNetworkManager()
    private init() {}

    var shouldFail: Bool = false
    var stubArticlesJSON: String = """
    {
        "articles": [
            { "author": "Mock Author", "title": "Mock Title", "description": "Mock description", "url": "https://example.com", "urlToImage": null, "publishedAt": "2025-09-19T10:00:00Z", "content": "Mock content" }
        ]
    }
    """
    var stubCountriesJSON: String = """
    {
        "countries": [
            { "countryName": "Mockland", "code": "ML", "region": "Mock Region", "capital": "Mock City" }
        ]
    }
    """
    var mockImageData: Data?

    func getData(from serverUrl: String?, closure: @escaping (NetworkState) -> Void) {
        if shouldFail {
            closure(.errorFetchingData)
            return
        }

        guard let urlString = serverUrl, !urlString.isEmpty else {
            // Default stub is Article JSON
            closure(.success(stubArticlesJSON.data(using: .utf8)!))
            return
        }

        let isImage = urlString.lowercased().contains("image")
        if isImage {
            if let img = mockImageData {
                closure(.success(img))
            } else {
                let pngBase64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAAB..." // tiny placeholder PNG
                closure(.success(Data(base64Encoded: pngBase64)!))
            }
            return
        }

        // Return Articles or Countries depending on URL
        if urlString.lowercased().contains("country") {
            closure(.success(stubCountriesJSON.data(using: .utf8)!))
        } else {
            closure(.success(stubArticlesJSON.data(using: .utf8)!))
        }
    }

    func parse<T: Decodable>(data: Data?, type: T.Type) -> T? {
        guard let data = data else { return nil }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("Mock decoding error:", error)
            return nil
        }
    }
}
