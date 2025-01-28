//
//  NewsViewModelTests.swift
//  NewsAppTests
//
//  Created by Anup Ghosh on 25/01/25.
//

import Foundation
import Combine

import XCTest
@testable import NewsApp
import CoreData

class NewsViewModelTests: XCTestCase {
    
    var viewModel: NewsViewModel!
    var mockNetworkService: MockNetworkService!
    var mockCoreDataManager : MockCoreNewsDataManager!
    var cancellables = Set<AnyCancellable>()

    let mockArticles = [
        Article(
            author: "John Doe",
            title: "Breaking News Title",
            description: "Breaking News Description",
            url: "https://example.com/article1",
            urlToImage: "https://example.com/image1.jpg"
        ),
        Article(
            author: "Jane Smith",
            title: "Advancements in iOS Development",
            description: "Learn about the latest advancements in iOS development with SwiftUI.",
            url: "https://example.com/article2",
            urlToImage: "https://example.com/image2.jpg"
        )
    ]
    
    lazy var mockNewsData = NewsData(
        status: "ok",
        totalResults: 2,
        articles: mockArticles
    )
    
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        viewModel = NewsViewModel(networkService: mockNetworkService,coreDataManager: MockCoreNewsDataManager())
    }
    
    override func tearDown() {
        viewModel = nil
        mockNetworkService = nil
        super.tearDown()
    }
    
    func testFetchNewsData_Success() {
        // Encode mock data
        let encodedData: Data
        do {
            encodedData = try JSONEncoder().encode(mockNewsData)
        } catch {
            XCTFail("Failed to encode mock data: \(error.localizedDescription)")
            return
        }
        
        mockNetworkService.mockData = encodedData
        
        let expectation = XCTestExpectation(description: "Fetch News Data Success")
        
        //  Observe the `newsData` property
        viewModel.$newsData
            .dropFirst() // Skip the initial nil value emitted by @Published
            .sink { newsData in
                guard let newsData = newsData else {
                    XCTFail("NewsData should not be nil")
                    return
                }
                XCTAssertEqual(newsData.status, "ok", "Status should match")
                XCTAssertEqual(newsData.totalResults, 2, "Total results should match")
                XCTAssertEqual(newsData.articles?.count, 2, "Number of articles should match")
                
                let firstArticle = newsData.articles?.first
                XCTAssertEqual(firstArticle?.author, "John Doe", "Author of the first article should match")
                XCTAssertEqual(firstArticle?.title, "Breaking News Title", "Title of the first article should match")
                XCTAssertEqual(firstArticle?.description, "Breaking News Description", "Description of the first article should match")
                XCTAssertEqual(firstArticle?.url, "https://example.com/article1", "URL of the first article should match")
                XCTAssertEqual(firstArticle?.urlToImage, "https://example.com/image1.jpg", "URL to Image of the first article should match")
                
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Call the method to fetch news data
        viewModel.fetchNewsData()
        
        // 4. Wait for expectations
        wait(for: [expectation], timeout: 1.0)
    }

    
    
    


    
}
