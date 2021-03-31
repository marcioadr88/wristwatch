//
//  WristWatchTests.swift
//  WristWatchTests
//
//  Created by Marcio Duarte on 2021-03-29.
//

import XCTest
@testable import WristWatch

class WristWatchTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testApi() throws {
        let expectation = XCTestExpectation(description: "test api")

        let apiClient = NewsAPIClientImpl(baseURL: "https://newsapi.org",
                                          apiKey: "e2c0bd1a7ce94d39beb67a8e0a086897",
                                          version: "v2")

        apiClient.everything(keyword: "watches price") { result in
            
            switch result {
            case .failure(let error):
                print(error)
                XCTFail()
                
            case .success(let news):
                print(news)
                
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10)
    }

}
