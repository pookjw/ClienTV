//
//  ArticleBaseListUseCaseTest.swift
//  ClienTVAPITests
//
//  Created by Jinwoo Kim on 6/10/21.
//

import XCTest
import Combine
import OSLog
@testable import ClienTVAPI

final class ArticleBaseListUseCaseTest: XCTestCase {
    private var cancallableBag: Set<AnyCancellable> = .init()
    
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
}
