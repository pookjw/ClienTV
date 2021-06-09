//
//  BoardListUseCaseTest.swift
//  ClienTVAPITests
//
//  Created by Jinwoo Kim on 6/10/21.
//

import XCTest
import Combine
import OSLog
@testable import ClienTVAPI

final class BoardListUseCaseTest: XCTestCase {
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
}
