//
//  BoardListUseCase.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/4/21.
//

import Foundation
import Combine

public protocol BoardListUseCase {
    func getAllBoardList() -> Future<[Board], Error>
}

public final class BoardListUseCaseImpl: BoardListUseCase {
    private let boardListRepository: BoardListRepository
    
    public init() {
        self.boardListRepository = BoardListRepositoryImpl()
    }
    
    public func getAllBoardList() -> Future<[Board], Error> {
        return boardListRepository.getBoardList(categories: Board.Category.allCases)
    }
}
