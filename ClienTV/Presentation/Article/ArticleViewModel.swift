//
//  ArticleViewModel.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/6/21.
//

import Foundation
import Combine
import OSLog
import ClienTVAPI

final class ArticleViewModel {
    private(set) var boardPath: String?
    private(set) var articlePath: String?
    private let useCase: ArticleUseCase
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    init(useCase: ArticleUseCase = ArticleUseCaseImpl()) {
        self.useCase = useCase
    }
    
    func requestArticle(boardPath: String, articlePath: String) -> Future<Article, Error> {
        self.boardPath = boardPath
        self.articlePath = articlePath
        
        return .init { [weak self] promise in
            guard let self = self else {
                return
            }
            
            let path: String = "\(boardPath)/\(articlePath)"
            
            self.useCase
                .getArticle(path: path)
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        promise(.failure(error))
                    case .finished:
                        break
                    }
                } receiveValue: { article in
                    promise(.success(article))
                }
                .store(in: &self.cancellableBag)
        }
    }
}
