//
//  Repository.swift
//  WristWatch
//
//  Created by Marcio Duarte on 2021-03-30.
//

import Foundation

//enum RepositoryOperation {
//    case create
//    case read
//    case update
//    case delete
//}

protocol NewsRepository {
    func read(keyword: String, page: Int,
              pageSize: Int, completionHandler: @escaping ((Result<News, AppError>) -> Void))
}

class NetworkRepository: NewsRepository {
    private let newsApiClient: NewsAPIClient
    
    init(newsApiClient: NewsAPIClient) {
        self.newsApiClient = newsApiClient
    }
    
    func read(keyword: String, page: Int,
              pageSize: Int, completionHandler: @escaping ((Result<News, AppError>) -> Void)) {
        newsApiClient.everything(keyword: keyword, page: page,
                                 pageSize: pageSize, handler: completionHandler)
    }
}

//
// class LocalRepository: Repository {
//
// }
