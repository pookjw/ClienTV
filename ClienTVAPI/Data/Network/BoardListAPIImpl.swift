//
//  BoardListAPIImpl.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/2/21.
//

import Foundation
import Combine

final class BoardListAPIImpl: BoardListAPI {
    func getBoardList() -> URLSession.DataTaskPublisher {
        let url: URL = ClienURLFactory.url()
        return URLSession
            .shared
            .dataTaskPublisher(for: url)
    }
}
