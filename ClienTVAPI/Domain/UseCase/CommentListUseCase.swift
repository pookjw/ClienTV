//
//  CommentListUseCase.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/7/21.
//

import Foundation
import Combine

public protocol CommentListUseCase {
    func getCommentList(path: String) -> Future<[Comment], Error>
}

public final class CommentListUseCaseImpl: CommentListUseCase {
    private let commentListRepository: CommentListRepository
    
    public init() {
        self.commentListRepository = CommentListRepositoryImpl()
    }
    
    public func getCommentList(path: String) -> Future<[Comment], Error> {
        return commentListRepository.getCommentList(path: path)
    }
}
