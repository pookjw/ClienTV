//
//  ConditionUseCaseTest.swift
//  ClienTVAPITests
//
//  Created by Jinwoo Kim on 6/17/21.
//

import XCTest
import Combine
import OSLog
@testable import ClienTVAPI

final class ConditionUseCaseTest: XCTestCase {
    private var cancallableBag: Set<AnyCancellable> = .init()
    
    func testImageArticleBaseListUseCase() {
        let semaphore: DispatchSemaphore = .init(value: 0)
        let useCase: ConditionUseCase = ConditionUseCaseImpl()
        
        useCase.getCondition()
            .sink { completion in
                switch completion {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .finished:
                    break
                }
                semaphore.signal()
            } receiveValue: { ImageArticleBase in
                Logger.info(ImageArticleBase)
                semaphore.signal()
            }
            .store(in: &self.cancallableBag)
        
        semaphore.wait()
    }
}
