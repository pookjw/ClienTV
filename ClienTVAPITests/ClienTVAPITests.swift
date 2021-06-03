//
//  ClienTVAPITests.swift
//  ClienTVAPITests
//
//  Created by Jinwoo Kim on 6/2/21.
//

import XCTest
import Combine
@testable import ClienTVAPI

class ClienTVAPITests: XCTestCase {
    private var cancallableBag: Set<AnyCancellable> = .init()
    
    func testMenuListAPI() {
        let semaphore: DispatchSemaphore = .init(value: 0)
        let api: MenuListAPIImpl = .init()
        api.getBoardList()
            .sink { _ in
                semaphore.signal()
            } receiveValue: { _ in
                semaphore.signal()
            }
            .store(in: &self.cancallableBag)
        semaphore.wait()
    }
}
