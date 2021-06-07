//
//  CommentListRepositoryImpl.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/7/21.
//

import Foundation
import Combine

final class CommentListRepositoryImpl: CommentListRepository {
    private let api: CommentListAPI
    
    init(api: CommentListAPI = CommentListAPIImpl()) {
        self.api = api
    }
    
    func getCommentList(path: String) -> Future<[Comment], Error> {
        return api.getCommentList(path: path)
    }
}
