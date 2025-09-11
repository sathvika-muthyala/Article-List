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
    var mockImageData: Data?

    var shouldFail: Bool = false

    var stubArticlesJSON: String = """
    {
      "status": "ok",
      "totalResults": 1,
      "articles": [
        {
          "source": { "id": null, "name": "MockNews" },
          "author": "Jane Doe",
          "title": "Mock Title",
          "description": "Mock description from mock network.",
          "url": "https://example.com/mock-article",
          "urlToImage": "https://example.com/mock-image.jpg",
          "publishedAt": "2025-09-10T12:34:56Z",
          "content": "Mock content…"
        }
      ]
    }
    """

    // MARK: - Network

    func getData(from serverUrl: String?, closure: @escaping (Data?) -> Void) {
        guard !shouldFail else {
            closure(nil)
            return
        }

        // No URL or non-image URL → return the stub JSON bytes
        guard let urlString = serverUrl, !urlString.isEmpty else {
            closure(stubArticlesJSON.data(using: .utf8))
            return
        }

        // If it looks like an image request, return image bytes
        let lower = urlString.lowercased()
        let isImage = lower.hasSuffix(".png") || lower.hasSuffix(".jpg") || lower.hasSuffix(".jpeg") || lower.contains("image")
        if isImage {
            if let img = mockImageData {
                closure(img)
            } else {
                // 1x1 transparent PNG
                let pngBase64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII="
                closure(Data(base64Encoded: pngBase64))
            }
            return
        }

        // Default to JSON for everything else
        closure(stubArticlesJSON.data(using: .utf8))
    }

    func parse(data: Data?) -> [Article]? {
        guard let data = data else {
            print("No data to parse")
            return []
        }
        do {
            let decoded = try JSONDecoder().decode(ArticleList.self, from: data)
            return decoded.articles ?? []
        } catch {
            print("Mock decode error:", error)
            return []
        }
    }
}
