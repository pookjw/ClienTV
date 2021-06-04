//
//  ArticleBaseListRepositoryImpl.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/4/21.
//

import Foundation
import Combine

final class ArticleBaseListRepositoryImpl: ArticleBaseListRepository {
    private let api: ArticleBaseListAPI
    
    init(api: ArticleBaseListAPI = ArticleBaseListAPIImpl()) {
        self.api = api
    }
    
    func getArticleBaseList(path: String, page: Int) -> Future<[ArticleBase], Error> {
        return api.getArticleBaseList(path: path, page: page)
    }
}
