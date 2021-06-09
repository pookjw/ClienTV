//
//  ImageArticleBase.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/9/21.
//

import Foundation

public struct ImageArticleBase {
    public let previewImageURL: URL?
    public let category: String
    public let title: String
    public let previewBody: String
    public let timestamp: Date
    public let commentCount: Int
    public let hitCount: Int
    public let nickname: String
    public let nicknameImageURL: URL?
}
