//
//  CommentListRepository.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/7/21.
//

import Foundation
import Combine

protocol CommentListRepository {
    func getCommentList(path: String) -> Future<[Comment], Error>
}
