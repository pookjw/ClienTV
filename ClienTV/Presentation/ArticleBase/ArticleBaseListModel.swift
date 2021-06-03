//
//  ArticleBaseListModel.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/4/21.
//

import Foundation

struct ArticleBaseListHeaderItem: Hashable, Equatable {
}

struct ArticleBaseListCellItem: Hashable, Equatable {
    static func ==(lhs: ArticleBaseListCellItem, rhs: ArticleBaseListCellItem) -> Bool {
        return lhs.likeCount == rhs.likeCount &&
            lhs.category == rhs.category &&
            lhs.likeCount == rhs.likeCount &&
            lhs.title == rhs.title &&
            lhs.commentCount == rhs.commentCount &&
            lhs.nickname == rhs.nickname &&
            lhs.nicknameImageURL == rhs.nicknameImageURL &&
            lhs.hitCount == rhs.hitCount &&
            lhs.timestamp == rhs.timestamp
    }
    
    let likeCount: Int
    let category: String?
    let title: String
    let commentCount: Int
    let nickname: String
    let nicknameImageURL: URL?
    let hitCount: Int
    let timestamp: Date
}
