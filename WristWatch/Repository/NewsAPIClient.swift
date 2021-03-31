//
//  NewsAPIClient.swift
//  WristWatch
//
//  Created by Marcio Duarte on 2021-03-30.
//

import Foundation

protocol NewsAPIClient {
    func everything(keyword: String?, page: Int, pageSize: Int, handler: @escaping ((Result<News, AppError>) -> Void))
}

class NewsAPIClientImpl: NewsAPIClient {
    private var baseURL: String
    private var apiKey: String
    private var version: String
    
    required init(baseURL: String, apiKey: String, version: String) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.version = version
    }
    
    func everything(keyword: String?,
                    page: Int = 1,
                    pageSize: Int = 100,
                    handler: @escaping ((Result<News, AppError>) -> Void)) {
        guard var endpoint = URLComponents(string: baseURL) else {
            handler(.failure(.invalidBaseURL))
            return
        }
        
        // build the endpoint URL
        endpoint.path = "/\(version)/everything"
        endpoint.queryItems = [
            URLQueryItem(name: "q", value: keyword),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "pageSize", value: String(pageSize))
        ]
        
        guard let url = endpoint.url else {
            handler(.failure(.invalidEndpoindURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-Api-Key")
        
        // perform the request
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            guard let data = data else {
                // according to apple's documentation if data == nil then error != nil
                handler(.failure(.networkError(cause: error!)))
                return
            }
            
            // parse the response
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            do {
                // decode the json response
                let newsResponse = try decoder.decode(News.self, from: data)
                handler(.success(newsResponse))
            } catch let error {
                if let newsError = try? decoder.decode(NewsError.self, from: data) {
                    handler(.failure(.apiError(message: newsError.message)))
                } else {
                    handler(.failure(.decodingError(cause: error)))
                }
            }
        }.resume()
    }
}
