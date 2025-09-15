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
    var stubArticlesJSON: String = "{ ... }"
    var mockImageData: Data?

    func getData(from serverUrl: String?, closure: @escaping (NetworkState) -> Void) {
        if shouldFail {
            closure(.errorFetchingData)
            return
        }

        guard let urlString = serverUrl, !urlString.isEmpty else {
            closure(.success(stubArticlesJSON.data(using: .utf8)!))
            return
        }

        let isImage = urlString.lowercased().contains("image")
        if isImage {
            if let img = mockImageData {
                closure(.success(img))
            } else {
                let pngBase64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAAB..."
                closure(.success(Data(base64Encoded: pngBase64)!))
            }
            return
        }

        closure(.success(stubArticlesJSON.data(using: .utf8)!))
    }

    func parse(data: Data?) -> [Article]? {
        guard let data = data else { return [] }
        return try? JSONDecoder().decode(ArticleList.self, from: data).articles
    }
}
