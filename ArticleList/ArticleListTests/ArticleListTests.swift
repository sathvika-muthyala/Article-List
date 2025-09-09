import XCTest
@testable import ArticleList
import UIKit

final class ArticleViewModelTests: XCTestCase {

    var viewModel: MockArticleViewModel!

    override func setUp() {
        super.setUp()
        viewModel = MockArticleViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func test_getCount_returnsCorrectNumberOfArticles() {
        XCTAssertEqual(viewModel.getCount(), 2)
    }

    func test_getTitle_returnsCorrectTitle() {
        XCTAssertEqual(viewModel.getTitle(row: 0), "Mock Article 1")
        XCTAssertEqual(viewModel.getTitle(row: 1), "Mock Article 2")
        XCTAssertEqual(viewModel.getTitle(row: 5), "")     }

    func test_getAuthor_returnsAuthorOrUnknown() {
        XCTAssertEqual(viewModel.getAuthor(row: 0), "Alice")
        XCTAssertEqual(viewModel.getAuthor(row: 1), "Unknown") 
    }

    func test_getDescription_returnsCorrectDescription() {
        XCTAssertEqual(viewModel.getDescription(row: 0), "This is a mock description 1.")
        XCTAssertEqual(viewModel.getDescription(row: 1), "This is a mock description 2.")
    }

    func test_getFormattedDate_returnsCorrectDate() {
        XCTAssertEqual(viewModel.getFormattedDate(row: 0), "2025-09-09")
        XCTAssertEqual(viewModel.getFormattedDate(row: 1), "2025-09-08")
    }

    func test_getImage_returnsNonNilImage() {
        let expectation = self.expectation(description: "image fetch")
        viewModel.getImage(row: 0) { image in
            XCTAssertNotNil(image)
            XCTAssertEqual(image?.size.width, 1)
            XCTAssertEqual(image?.size.height, 1)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
}
