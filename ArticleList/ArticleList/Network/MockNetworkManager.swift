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
    
    // MARK: - Stub JSON
    var stubArticlesJSON: String = """
    {
        "articles": [
            {
                "author": "Mock Author",
                "title": "Mock Title",
                "description": "Mock description",
                "url": "https://example.com",
                "urlToImage": null,
                "publishedAt": "2025-09-19T10:00:00Z",
                "content": "Mock content"
            }
        ]
    }
    """
    
    var stubCountriesJSON: String = """
    {
        "countries": [
            {
                "countryName": "Mockland",
                "code": "ML",
                "region": "Mock Region",
                "capital": "Mock City"
            }
        ]
    }
    """
    
    var mockImageData: Data?

    // MARK: - Mock getData
    func getData(from serverUrl: String?, closure: @escaping (NetworkState) -> Void) {
        if shouldFail {
            closure(.errorFetchingData)
            return
        }

        guard let urlString = serverUrl, !urlString.isEmpty else {
            closure(.success(stubArticlesJSON.data(using: .utf8)!))
            return
        }

        // Decide if it's an image
        let isImage = urlString.lowercased().contains("image")
        if isImage {
            if let img = mockImageData {
                closure(.success(img))
            } else {
                let pngBase64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAAB..." // placeholder PNG
                if let data = Data(base64Encoded: pngBase64) {
                    closure(.success(data))
                } else {
                    closure(.noDataFromServer)
                }
            }
            return
        }

        // Return stubbed JSON depending on URL
        if urlString.lowercased().contains("country") {
            closure(.success(stubCountriesJSON.data(using: .utf8)!))
        } else {
            closure(.success(stubArticlesJSON.data(using: .utf8)!))
        }
    }

    // MARK: - Mock parse
    func parse<T: Decodable>(data: Data?, type: T.Type) -> Result<T, NetworkState> {
        guard let data = data else {
            return .failure(.noDataFromServer)
        }
        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return .success(decoded)
        } catch {
            print("Mock decoding error:", error)
            return .failure(.decodingError(error))
        }
    }
}
