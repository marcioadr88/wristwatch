//
//  WristWatchTests.swift
//  WristWatchTests
//
//  Created by Marcio Duarte on 2021-03-29.
//

import XCTest
@testable import WristWatch

class WristWatchTests: XCTestCase {
    var database: Database!
    var repository: NewsRepository!
    
    override class func setUp() {
        
    }
    
    override func setUpWithError() throws {
        database = InMemoryDatabase()
        repository = LocalRepository(database: database)
    }

    override func tearDownWithError() throws {
        database = nil
        repository = nil
    }

    func testRepositoryAddElement() {
        let newElement = Article()
        newElement.id = UUID().uuidString
        newElement.title = "Test title"
        newElement.content = "Test content"
        
        try? repository.createOrUpdate(article: newElement)
        
        let expectation = XCTestExpectation(description: "query")
        var countAfter = -1
        
        repository.read(keyword: "", page: 1, pageSize: 100) { result in
            switch result {
            case .success(let articles):
                countAfter = articles.count
            case .failure:
                XCTFail("Cannot read database")
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssert(countAfter == 1)
    }
    
    func testRepositoryDeleteElement() {
        let newElement = Article()
        newElement.id = UUID().uuidString
        newElement.title = "Test title"
        newElement.content = "Test content"
        
        try? repository.createOrUpdate(article: newElement)
        try? repository.delete(article: newElement)
        
        let expectation = XCTestExpectation(description: "query")
        var countAfter = -1
        
        repository.read(keyword: "", page: 1, pageSize: 100) { result in
            switch result {
            case .success(let articles):
                countAfter = articles.count
            case .failure:
                XCTFail("Cannot read database")
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssert(countAfter == 0)
    }
}
