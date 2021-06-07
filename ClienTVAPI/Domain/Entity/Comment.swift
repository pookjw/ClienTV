//
//  Comment.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/6/21.
//

import Foundation

public struct Comment {
    public let isAuthor: Bool
    public let isReply: Bool
    public let isMe: Bool
    public let nickname: String
    public let nicknameImageURL: URL?
    public let timestamp: Date
    public let imageURL: URL?
    public let bodyHTML: String
}
