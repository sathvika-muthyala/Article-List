//
//  ArticleListTests.swift
//  ArticleListTests
//
//  Created by sathvika muthyala on 9/8/25.
//
import XCTest
import Testing
@testable import ArticleList

struct ArticleListTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

}

class ArticleViewModelTests: XCTestCase {
    var viewModel: ArticleViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = ArticleViewModel()
    }
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
        
}
