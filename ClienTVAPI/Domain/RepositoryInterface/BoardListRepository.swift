//
//  BoardListRepository.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/3/21.
//

import Foundation
import Combine

protocol BoardListRepository {
    func getBoardList(categories: [Board.Category]) -> Future<[Board], Error>
}
