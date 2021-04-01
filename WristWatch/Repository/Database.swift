//
//  Database.swift
//  WristWatch
//
//  Created by Marcio Duarte on 2021-03-31.
//

import Foundation
import RealmSwift

protocol Database {
    func createOrUpdate(article: Article) throws
    func query(keyword: String?, page: Int, pageSize: Int) throws -> [Article]
    func delete(article: Article) throws
}

class RealmDatabase: Database {
    func query(keyword: String?, page: Int, pageSize: Int) throws -> [Article] {
        do {
            let realm = try Realm()
            let articles = realm.objects(Article.self).freeze().asList()
            
            let firstIndex = (page - 1) * pageSize
            let lastIndex = firstIndex + pageSize - 1
            
            // suboptimal paging, but keeping it as simple as possible
            var slice = [Article].SubSequence()
            if articles.indices.contains(firstIndex) {
                if articles.indices.contains(lastIndex) {
                    slice = articles[firstIndex...lastIndex]
                } else {
                    slice = articles[firstIndex...articles.count - 1]
                }
            }
            
            return Array(slice)
        } catch {
            throw AppError.databaseError(cause: error)
        }
    }
    
    func createOrUpdate(article: Article) throws {
        do {
            let realm = try Realm()
            
            try realm.write {
                realm.create(Article.self, value: article, update: .all)
            }
        } catch {
            throw AppError.databaseError(cause: error)
        }
    }
    
    func delete(article: Article) throws {
        do {
            let realm = try Realm()
            
            if let object = realm.object(ofType: Article.self, forPrimaryKey: article.id) {
                try realm.write {
                    realm.delete(object)
                }
            }            
        } catch {
            throw AppError.databaseError(cause: error)
        }
    }
}

class InMemoryDatabase: Database {
    var articles: [Article]
    
    init() {
        articles = []
    }
    
    func createOrUpdate(article: Article) throws {
        articles.append(article) // not updating
    }
    
    func query(keyword: String?, page: Int, pageSize: Int) throws -> [Article] {
        return articles
    }
    
    func delete(article: Article) throws {
        articles.removeAll { $0.id == article.id }
    }
}
