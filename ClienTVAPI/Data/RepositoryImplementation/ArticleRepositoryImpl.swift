//
//  ArticleRepositoryImpl.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/6/21.
//

import Foundation
import Combine

final class ArticleRepositoryImpl: ArticleRepository {
    private let api: ArticleAPI
    
    init(api: ArticleAPI = ArticleAPIImpl()) {
        self.api = api
    }
    
    func getArticle(path: String) -> Future<Article, Error> {
        return api.getArticle(path: path)
    }
}
