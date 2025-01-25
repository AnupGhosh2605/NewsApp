//
//  NewsViewModelTests.swift
//  NewsAppTests
//
//  Created by Anup Ghosh on 25/01/25.
//

import Foundation

import XCTest
@testable import NewsApp

class NewsViewModelTests: XCTestCase {
    
    var viewModel: NewsViewModel!
    var mockNetworkService: MockNetworkService!
    
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        viewModel = NewsViewModel(networkService: mockNetworkService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockNetworkService = nil
        super.tearDown()
    }
    
    func testFetchNewsData_Success() {
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
        let mockNewsData = NewsData(
            status: "ok",
            totalResults: 2,
            articles: mockArticles
        )
        let encodedData = try! JSONEncoder().encode(mockNewsData)
        mockNetworkService.mockData = encodedData

        let expectation = XCTestExpectation(description: "Fetch News Data")
        viewModel.onFetchData = { newsData in
            XCTAssertNotNil(newsData, "NewsData should not be nil")
            XCTAssertEqual(newsData?.status, "ok", "Status should match")
            XCTAssertEqual(newsData?.totalResults, 2, "Total results should match")
            XCTAssertEqual(newsData?.articles?.count, 2, "Number of articles should match")
            XCTAssertEqual(newsData?.articles?.first?.author, "John Doe", "Author of the first article should match")
            XCTAssertEqual(newsData?.articles?.first?.title, "Breaking News Title", "Title of the first article should match")
            XCTAssertEqual(newsData?.articles?.first?.description, "Breaking News Description", "Description of the first article should match")
            XCTAssertEqual(newsData?.articles?.first?.url, "https://example.com/article1", "URL of the first article should match")
            XCTAssertEqual(newsData?.articles?.first?.urlToImage, "https://example.com/image1.jpg", "URL to Image of the first article should match")
            expectation.fulfill()
        }

        // Call
        viewModel.fetchNewsData()

        // Assert
        wait(for: [expectation], timeout: 1.0)
    }

    
    func testFetchNewsData_Failure() {
        mockNetworkService.mockError = .dataError

        let expectation = XCTestExpectation(description: "Fetch News Data Failure")
        viewModel.onFetchData = { newsData in
            XCTAssertNil(newsData, "NewsData should be nil on failure")
            expectation.fulfill()
        }

        // call
        viewModel.fetchNewsData()

        // Assert
        wait(for: [expectation], timeout: 1.0)
    }

}
