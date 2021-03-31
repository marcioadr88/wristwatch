//
//  LatestNewsViewModel.swift
//  WristWatch
//
//  Created by Marcio Duarte on 2021-03-30.
//

import Foundation
import RxSwift
import RxCocoa

class LatestNewsViewModel {
    private let newsRepository: NewsRepository
    
    let articles = BehaviorRelay<[Article]>(value: [])
    let loading = BehaviorRelay<Bool>(value: false)
    let error = BehaviorRelay<AppError?>(value: nil)
    
    var page: Int
    let pageSize: Int = 50
    
    init(newsRepository: NewsRepository) {
        self.newsRepository = newsRepository
        self.page = 1
    }
    
    func loadArticles(keyword: String, fromScratch: Bool) {
        guard !loading.value && error.value == nil  else {
            return
        }
        
        print("load moar")
        loading.accept(true)
        
        if fromScratch {
            self.page = 1
        }
        
        DispatchQueue.global(qos: .background).async { [unowned self] in
            newsRepository.read(keyword: keyword, page: self.page, pageSize: self.pageSize) { [unowned self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let news):
                        var current = fromScratch ? [] : self.articles.value
                        current.append(contentsOf: news.articles)
                        
                        self.page += 1
                        self.articles.accept(current)

                    case .failure(let cause):
                        error.accept(cause)
                    }
                    
                    loading.accept(false)
                }
            }
        }
    }
    
    func clearError() {
        error.accept(nil)
    }
}
