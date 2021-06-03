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

class ClienTVAPITests: XCTestCase {
    private var cancallableBag: Set<AnyCancellable> = .init()
    
    func testBoardListAPI() {
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
    
    func testArticleBastListAPI() {
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
}
