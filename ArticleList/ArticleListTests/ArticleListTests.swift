//
//  ArticleListTests.swift
//  ArticleListTests
//
//  Created by sathvika muthyala on 9/8/25.
//

import XCTest
import UIKit
@testable import ArticleList

final class ArticleViewModelTests: XCTestCase {

    var viewModel: ArticleViewModel!
    var mockNetwork: MockNetworkManager!

    override func setUp() {
        super.setUp()
        mockNetwork = MockNetworkManager()
        viewModel = ArticleViewModel(networkManager: mockNetwork)
    }

    override func tearDown() {
        viewModel = nil
        mockNetwork = nil
        super.tearDown()
    }

    func testGetDataFromServerLoadsArticles() {
        let article = Article(
            source: Source(id: "test-source", name: "Test Source"),
            author: "Test Author",
            title: "Test Title",
            description: "Test Description",
            url: "https://example.com/article",
            imageUrl: "https://example.com/image.png",
            dateOfPublication: "2025-09-09T15:47:40Z",
            content: "Full content here"
        )
        mockNetwork.mockArticles = [article]

        let expectation = self.expectation(description: "Data Loaded")
        viewModel.getDataFromServer {
            XCTAssertEqual(self.viewModel.getCount(), 1)
            XCTAssertEqual(self.viewModel.getTitle(row: 0), "Test Title")
            XCTAssertEqual(self.viewModel.getAuthor(row: 0), "Test Author")
            XCTAssertEqual(self.viewModel.getDescription(row: 0), "Test Description")
            XCTAssertEqual(self.viewModel.getFormattedDate(row: 0), "2025-09-09")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func test_getCount_whenEmpty_returnsZero() {
        XCTAssertEqual(viewModel.getCount(), 0)
    }

    func test_getTitle_withInvalidIndex_returnsEmptyString() {
        XCTAssertEqual(viewModel.getTitle(row: 5), "")
    }

    func test_getAuthor_withNilAuthor_returnsUnknown() {        let article = Article(
            source: Source(id: "test-source", name: "Test Source"),
            author: nil,
            title: "No Author",
            description: "desc",
            url: "https://example.com/article",
            imageUrl: nil,
            dateOfPublication: "2025-09-08T15:47:40Z",
            content: nil
        )
        mockNetwork.mockArticles = [article]

        let exp = expectation(description: "fetch")
        viewModel.getDataFromServer { exp.fulfill() }
        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(viewModel.getAuthor(row: 0), "Unknown")
    }



}
