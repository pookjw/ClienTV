//
//  BoardListAPI.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/2/21.
//

import Foundation
import Combine

protocol BoardListAPI {
    func getBoardList(categories: [Board.Category]) -> Future<[Board], Error>
}
