//
//  BoardListRepositoryImpl.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/4/21.
//

import Foundation
import Combine

final class BoardListRepositoryImpl: BoardListRepository {
    private let api: BoardListAPI
    
    init(api: BoardListAPI = BoardListAPIImpl()) {
        self.api = api
    }
    
    func getBoardList(categories: [Board.Category]) -> Future<[Board], Error> {
        return api.getBoardList(categories: categories)
    }
}
