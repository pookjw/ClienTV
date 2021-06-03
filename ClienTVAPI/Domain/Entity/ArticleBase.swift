//
//  ArticleBase.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/3/21.
//

import Foundation

struct ArticleBase {
    let likeCount: Int
    let category: String?
    let title: String
    let commentCount: Int
    let authorID: String
    let nickname: String
    let nicknameImageURL: URL?
    let hitCount: Int
    let timestamp: Date
}
