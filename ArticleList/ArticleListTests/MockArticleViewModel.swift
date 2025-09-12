//
//  MockArticleViewModel.swift
//  ArticleListTests
//
//  Created by Sathvika Muthyala on 9/9/25.
//

import UIKit
@testable import ArticleList

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

class MockArticleViewModel: ArticleViewModelProtocol {

    var articleList: [Article] = []
    var heightOfRow: Int = 100

    init() {
        let source = Source(id: "mock-source", name: "Mock Source")
        
        let article1 = Article(
            source: source,
            author: "Alice",
            title: "Mock Article 1",
            description: "This is a mock description 1.",
            url: "https://example.com/article1",
            imageUrl: nil,
            dateOfPublication: "2025-09-09T10:00:00Z",
            content: "Full content of mock article 1"
        )
        
        let article2 = Article(
            source: source,
            author: nil,
            title: "Mock Article 2",
            description: "This is a mock description 2.",
            url: "https://example.com/article2",
            imageUrl: "https://example.com/image.png",
            dateOfPublication: "2025-09-08T12:30:00Z",
            content: "Full content of mock article 2"
        )
        
        self.articleList = [article1, article2]
    }

    func getDataFromServer(closure: @escaping (() -> Void)) {
        closure()
    }

    func getCount() -> Int {
        return articleList.count
    }

    func getTitle(row: Int) -> String {
        return articleList[safe: row]?.title ?? ""
    }

    func getAuthor(row: Int) -> String {
        return articleList[safe: row]?.author ?? "Unknown"
    }

    func getDescription(row: Int) -> String {
        return articleList[safe: row]?.description ?? ""
    }

    func getFormattedDate(row: Int) -> String {
        guard let isoString = articleList[safe: row]?.dateOfPublication else { return "" }
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]
        if let date = isoFormatter.date(from: isoString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "yyyy-MM-dd"
            return displayFormatter.string(from: date)
        }
        return isoString
    }

    func getImage(row: Int, completion: @escaping (UIImage?) -> Void) {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1))
        let img = renderer.image { _ in
            UIColor.white.setFill()
            UIBezierPath(rect: CGRect(x:0, y:0, width:1, height:1)).fill()
        }
        completion(img)
    }
}
