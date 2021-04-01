//
//  Repository.swift
//  WristWatch
//
//  Created by Marcio Duarte on 2021-03-30.
//

import Foundation

protocol NewsRepository {
    func read(keyword: String, page: Int,
              pageSize: Int, completionHandler: @escaping ((Result<[Article], AppError>) -> Void))
    func delete(article: Article) throws
    func createOrUpdate(article: Article) throws
}

class NetworkRepository: NewsRepository {
    func createOrUpdate(article: Article) throws {
        // no-op
    }
    
    func delete(article: Article) throws {
        // no-op
    }
    
    private let newsApiClient: NewsAPIClient
    
    init(newsApiClient: NewsAPIClient) {
        self.newsApiClient = newsApiClient
    }
    
    func read(keyword: String, page: Int, pageSize: Int,
              completionHandler: @escaping ((Result<[Article], AppError>) -> Void)) {
        newsApiClient.everything(keyword: keyword, page: page,
                                 pageSize: pageSize, handler: completionHandler)
    }
}

class LocalRepository: NewsRepository {
    private let database: Database
    
    init(database: Database) {
        self.database = database
    }
    
    func read(keyword: String, page: Int, pageSize: Int,
              completionHandler: @escaping ((Result<[Article], AppError>) -> Void)) {
        do {
            let articles = try database.query(keyword: keyword, page: page, pageSize: pageSize)
            
            completionHandler(.success(articles))
        } catch {
            completionHandler(.failure(.databaseError(cause: error)))
        }
    }
    
    func delete(article: Article) throws {
        try database.delete(article: article)
    }
    
    func createOrUpdate(article: Article) throws {
        try database.createOrUpdate(article: article)
    }
}
