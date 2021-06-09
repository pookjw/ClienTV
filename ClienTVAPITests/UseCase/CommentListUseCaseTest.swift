//
//  CommentListUseCaseTest.swift
//  ClienTVAPITests
//
//  Created by Jinwoo Kim on 6/10/21.
//

import XCTest
import Combine
import OSLog
@testable import ClienTVAPI

final class CommentListUseCaseTest: XCTestCase {
    private var cancallableBag: Set<AnyCancellable> = .init()
    
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
