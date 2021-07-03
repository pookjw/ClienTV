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
    private let articleUseCase: ArticleUseCase = ArticleUseCaseImpl()
    private let queue: OperationQueue = .init()
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    init() {
        configureQueue()
    }
    
    func requestArticle(boardPath: String, articlePath: String) -> Future<Article, Error> {
        self.boardPath = boardPath
        self.articlePath = articlePath
        
        return .init { [weak self] promise in
            self?.configurePromise(promise, boardPath: boardPath, articlePath: articlePath)
        }
    }
    
    private func configurePromise(_ promise: @escaping ((Result<Article, Error>) -> Void),
                                  boardPath: String,
                                  articlePath: String) {
        let path: String = "\(boardPath)/\(articlePath)"
        
        articleUseCase
            .getArticle(path: path)
            .receive(on: queue)
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
            .store(in: &cancellableBag)
    }
    
    private func configureQueue() {
        queue.qualityOfService = .userInteractive
    }
}
