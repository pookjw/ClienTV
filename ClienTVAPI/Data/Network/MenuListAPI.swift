//
//  MenuListAPI.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/2/21.
//

import Foundation
import Combine

protocol MenuListAPI {
    func getBoardList() -> Future<[Menu], Error>
}

enum MenuListAPIError: Error {
    case nilError
    case parseError
}
