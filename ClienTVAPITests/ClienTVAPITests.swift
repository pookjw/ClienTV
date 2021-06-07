//
//  ClienTVAPITests.swift
//  ClienTVAPITests
//
//  Created by Jinwoo Kim on 6/2/21.
//

import XCTest
import Combine
import OSLog
@testable import ClienTVAPI

final class ClienTVAPITests: XCTestCase {
    private var cancallableBag: Set<AnyCancellable> = .init()
    
    func testBoardListUseCase() {
        let semaphore: DispatchSemaphore = .init(value: 0)
        let useCase: BoardListUseCase = BoardListUseCaseImpl()
        
        useCase.getAllBoardList()
            .sink { completion in
                switch completion {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .finished:
                    break
                }
                semaphore.signal()
            } receiveValue: { boardList in
                Logger.info(boardList)
                semaphore.signal()
            }
            .store(in: &self.cancallableBag)
        
        semaphore.wait()
    }
    
    func testArticleBastListUseCase() {
        let semaphore: DispatchSemaphore = .init(value: 0)
        let useCase: ArticleBaseListUseCase = ArticleBaseListUseCaseImpl()
        
        useCase.getArticleBaseList(path: "/service/board/cm_iphonien", page: 0)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .finished:
                    break
                }
                semaphore.signal()
            } receiveValue: { articleBaseList in
                Logger.info(articleBaseList)
                semaphore.signal()
            }
            .store(in: &self.cancallableBag)
        
        semaphore.wait()
    }
    
    func testArticleBastListUseCaseJirum() {
        let semaphore: DispatchSemaphore = .init(value: 0)
        let useCase: ArticleBaseListUseCase = ArticleBaseListUseCaseImpl()
        
        useCase.getArticleBaseList(path: "/service/board/jirum", page: 0)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .finished:
                    break
                }
                semaphore.signal()
            } receiveValue: { articleBaseList in
                Logger.info(articleBaseList)
                semaphore.signal()
            }
            .store(in: &self.cancallableBag)
        
        semaphore.wait()
    }
    
    func testArticleUseCase() {
        let semaphore: DispatchSemaphore = .init(value: 0)
        let useCase: ArticleUseCase = ArticleUseCaseImpl()
        
        useCase.getArticle(path: "/service/board/cm_iphonien/16203705")
            .sink { completion in
                switch completion {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .finished:
                    break
                }
                semaphore.signal()
            } receiveValue: { article in
                Logger.info(article)
                semaphore.signal()
            }
            .store(in: &self.cancallableBag)
        
        semaphore.wait()
    }
    
    func testCommentListUseCase() {
        let semaphore: DispatchSemaphore = .init(value: 0)
        let useCase: CommentListUseCase = CommentListUseCaseImpl()
        
        useCase.getCommentList(path: "/service/board/news/16200750")
            .sink { completion in
                switch completion {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .finished:
                    break
                }
                semaphore.signal()
            } receiveValue: { article in
                Logger.info(article)
                semaphore.signal()
            }
            .store(in: &self.cancallableBag)
        
        semaphore.wait()
    }
}
