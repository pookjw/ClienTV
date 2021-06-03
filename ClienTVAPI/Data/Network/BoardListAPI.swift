//
//  BoardListAPI.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/2/21.
//

import Foundation
import Combine

protocol BoardListAPI {
    func getBoardList() -> Future<[Board], Error>
}

enum BoardListAPIError: Error {
    case nilError
    case parseError
    case responseError(Int)
}
