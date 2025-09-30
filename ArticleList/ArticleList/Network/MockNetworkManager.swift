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

    // MARK: - Mock getData (async/await)
    func getData(from serverUrl: String?) async throws -> Data {
        if shouldFail {
            throw NetworkState.errorFetchingData
        }

        guard let urlString = serverUrl, !urlString.isEmpty else {
            return Data(stubArticlesJSON.utf8)
        }

        if urlString.lowercased().contains("image") {
            if let img = mockImageData {
                return img
            } else {
                let pngBase64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAAB..."
                if let data = Data(base64Encoded: pngBase64) {
                    return data
                } else {
                    throw NetworkState.noDataFromServer
                }
            }
        }

        if urlString.lowercased().contains("country") {
            return Data(stubCountriesJSON.utf8)
        } else {
            return Data(stubArticlesJSON.utf8)
        }
    }

    func parse<T: Decodable>(data: Data?, type: T.Type) throws -> T {
        guard let data = data else {
            throw NetworkState.noDataFromServer
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkState.decodingError(error)
        }
    }
}
