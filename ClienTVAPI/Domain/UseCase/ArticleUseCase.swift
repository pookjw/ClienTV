//
//  ArticleUseCase.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/6/21.
//

import Foundation
import Combine

public protocol ArticleUseCase {
    func getArticle(path: String) -> Future<Article, Error>
}

public final class ArticleUseCaseImpl: ArticleUseCase {
    private let articleRepository: ArticleRepository
    
    public init() {
        self.articleRepository = ArticleRepositoryImpl()
    }
    
    public func getArticle(path: String) -> Future<Article, Error> {
        return articleRepository.getArticle(path: path)
    }
}
