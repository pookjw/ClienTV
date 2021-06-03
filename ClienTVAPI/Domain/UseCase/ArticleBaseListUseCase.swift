//
//  ArticleBaseListUseCase.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/4/21.
//

import Foundation
import Combine

public protocol ArticleBaseListUseCase {
    func getArticleBaseList(path: String, page: Int) -> Future<[ArticleBase], Error>
}

public final class ArticleBaseListUseCaseImpl: ArticleBaseListUseCase {
    private let articleBaseListRepository: ArticleBaseListRepository
    
    public init() {
        self.articleBaseListRepository = ArticleBaseListRepositoryImpl()
    }
    
    public func getArticleBaseList(path: String, page: Int) -> Future<[ArticleBase], Error> {
        return articleBaseListRepository.getArticleBaseList(path: path, page: page)
    }
}
