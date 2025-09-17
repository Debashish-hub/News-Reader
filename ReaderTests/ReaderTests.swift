//
//  ReaderTests.swift
//  ReaderTests
//
//  Created by Debashish on 15/09/25.
//

import XCTest
@testable import Reader
import CoreData

final class ReaderTests: XCTestCase {
    
    var apiService: NewsAPIService!
    var coreDataManager: CoreDataManager!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        apiService = NewsAPIService()
        coreDataManager = CoreDataManager.shared
    }

    override func tearDownWithError() throws {
        apiService = nil
        coreDataManager = nil
        try super.tearDownWithError()
    }

    // MARK: - API Tests
    func testFetchArticlesFromAPI() throws {
        let expectation = self.expectation(description: "Fetch Articles")
        
        apiService.fetchTopHeadlines { result in
            switch result {
            case .success(let articles):
                XCTAssertFalse(articles.isEmpty, "Articles should not be empty from API")
            case .failure(let error):
                XCTFail("API fetch failed: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10)
    }
    
    // MARK: - Core Data Tests
    func testSaveAndFetchArticlesFromCoreData() throws {
        // Create dummy Article
        let article = Article(title: "title", author: "author", urlToImage: "", url: "", isBookmarked: true)
        
        // Save
        coreDataManager.context.reset()
        let entity = ArticleEntity(context: coreDataManager.context)
        entity.title = article.title
        entity.author = article.author
        entity.isBookmarked = true
        coreDataManager.saveContext()
        
        // Fetch
        let request: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        let results = try coreDataManager.context.fetch(request)
        
        XCTAssertTrue(results.contains { $0.title == "title" && $0.isBookmarked },
                      "Saved article should be fetched with bookmark flag")
    }
    
    // MARK: - Bookmark Tests
    func testBookmarkToggle() throws {
        let entity = ArticleEntity(context: coreDataManager.context)
        entity.title = "Bookmark Test"
        entity.isBookmarked = false
        
        // Toggle
        entity.isBookmarked.toggle()
        XCTAssertTrue(entity.isBookmarked, "Bookmark should toggle to true")
        
        entity.isBookmarked.toggle()
        XCTAssertFalse(entity.isBookmarked, "Bookmark should toggle back to false")
    }
    
    // MARK: - Search Tests
    func testSearchArticles() throws {
        let articles = [
            Article(title: "swift1", author: "author1", urlToImage: "", url: "", isBookmarked: false),
            Article(title: "swift2", author: "author2", urlToImage: "", url: "", isBookmarked: false)
        ]
        
        let query = "swift"
        let filtered = articles.filter {
            ($0.title?.lowercased().contains(query) ?? false) ||
            ($0.author?.lowercased().contains(query) ?? false)
        }
        
        XCTAssertEqual(filtered.count, 2, "Both articles should match 'swift'")
    }
}

final class BookmarkVCTests: XCTestCase {
    
    var sut: BookmarkVC!   // system under test
    var window: UIWindow!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        window = UIWindow()
        sut = BookmarkVC(nibName: nil, bundle: nil)
        window.addSubview(sut.view)  // load view hierarchy
    }

    override func tearDownWithError() throws {
        sut = nil
        window = nil
        try super.tearDownWithError()
    }
    
    func testTableViewIsConnected() throws {
        sut.loadViewIfNeeded()
        XCTAssertNotNil(sut.bookmarkTable, "TableView should be connected")
        XCTAssertTrue(sut.bookmarkTable?.delegate === sut, "TableView delegate should be set")
        XCTAssertTrue(sut.bookmarkTable?.dataSource === sut, "TableView datasource should be set")
    }
    
    func testNumberOfRowsInSection_MatchesArticlesCount() throws {
        sut.loadViewIfNeeded()
        let context = CoreDataManager.shared.context
        
        sut.viewModel.articles = [
            ArticleEntity(context: context),
            ArticleEntity(context: context)
        ]
        let rows = sut.tableView(sut.bookmarkTable!, numberOfRowsInSection: 0)
        XCTAssertEqual(rows, 2, "Row count should equal number of articles")
    }

    
    func testCellForRow_ConfiguresCellCorrectly() throws {
        sut.loadViewIfNeeded()
        let context = CoreDataManager.shared.context
        let article = ArticleEntity(context: context)
        article.title = "Sample Title"
        article.author = "John Doe"
        article.urlToImage = nil
        article.isBookmarked = true
        
        sut.viewModel.articles = [article]
        sut.bookmarkTable?.reloadData()
        
        let cell = sut.tableView(sut.bookmarkTable!, cellForRowAt: IndexPath(row: 0, section: 0)) as! ArticleCell
        
        XCTAssertEqual(cell.titleLabel.text, "Sample Title")
        XCTAssertEqual(cell.authorLabel.text, "John Doe")
        XCTAssertEqual(cell.bookmarkIcon.image, UIImage(systemName: "bookmark.fill"))
    }
    
    func testHandleBookmarkTap_TogglesBookmark() throws {
        sut.loadViewIfNeeded()
        let context = CoreDataManager.shared.context
        let article = ArticleEntity(context: context)
        article.title = "Bookmark Test"
        article.isBookmarked = false
        
        sut.viewModel.articles = [article]
        sut.bookmarkTable?.reloadData()
        
        let cell = sut.tableView(sut.bookmarkTable!, cellForRowAt: IndexPath(row: 0, section: 0)) as! ArticleCell
        let tap = UITapGestureRecognizer()
        
        sut.handleBookmarkTap(tap)
        
        XCTAssertFalse(sut.viewModel.articles[0].isBookmarked, "Bookmark should toggle to true")
    }
}
