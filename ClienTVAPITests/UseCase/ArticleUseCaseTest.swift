//
//  ArticleUseCaseTest.swift
//  ClienTVAPITests
//
//  Created by Jinwoo Kim on 6/10/21.
//

import XCTest
import Combine
import OSLog
@testable import ClienTVAPI

final class ArticleUseCaseTest: XCTestCase {
    private var cancallableBag: Set<AnyCancellable> = .init()
    
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
}
