//
//  ArticleBase.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/3/21.
//

import Foundation

public struct ArticleBase {
    public let likeCount: Int
    public let category: String?
    public let title: String
    public let commentCount: Int
    public let authorID: String
    public let nickname: String
    public let nicknameImageURL: URL?
    public let hitCount: Int
    public let timestamp: Date
}
