//
//  ImageArticleBaseListUseCaseTest.swift
//  ClienTVAPITests
//
//  Created by Jinwoo Kim on 6/10/21.
//

import XCTest
import Combine
import OSLog
@testable import ClienTVAPI

final class ImageArticleBaseListUseCaseTest: XCTestCase {
    private var cancallableBag: Set<AnyCancellable> = .init()
    
    func testImageArticleBaseListUseCase() {
        let semaphore: DispatchSemaphore = .init(value: 0)
        let useCase: ImageArticleBaseListUseCase = ImageArticleBaseListUseCaseImpl()
        
        useCase.getImageArticleBaseList(page: 0)
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
