//
//  CommentListModel.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/7/21.
//

import Foundation

// MARK: - CommentListHeaderItem

struct CommentListHeaderItem: Equatable, Hashable {
    static func ==(lhs: CommentListHeaderItem, rhs: CommentListHeaderItem) -> Bool {
        return lhs.dataType == rhs.dataType
    }
    
    enum DataType: Equatable, Hashable {
        case commentCount(data: CommentCountData)
        
        static func ==(lhs: DataType, rhs: DataType) -> Bool {
            switch (lhs, rhs) {
            case (.commentCount(let lhsData), .commentCount(let rhsData)):
                return lhsData == rhsData
            }
        }
    }
    
    let dataType: DataType
}

extension CommentListHeaderItem {
    struct CommentCountData: Equatable, Hashable {
        static func ==(lhs: CommentCountData, rhs: CommentCountData) -> Bool {
            return lhs.count == rhs.count
        }
        
        let count: Int
        
        var title: String {
            return "\(count)개의 댓글"
        }
    }
}

// MARK: - CommentListCellItem

struct CommentListCellItem: Equatable, Hashable {
    static func ==(lhs: CommentListCellItem, rhs: CommentListCellItem) -> Bool {
        return lhs.dataType == rhs.dataType
    }
    
    enum DataType: Equatable, Hashable {
        case comment(data: CommentData)
        
        static func ==(lhs: DataType, rhs: DataType) -> Bool {
            switch (lhs, rhs) {
            case (.comment(let lhsData), .comment(let rhsData)):
                return lhsData == rhsData
            }
        }
    }
    
    let dataType: DataType
}

extension CommentListCellItem {
    struct CommentData: Equatable, Hashable {
        static func ==(lhs: CommentData, rhs: CommentData) -> Bool {
            return lhs.isAuthor == rhs.isAuthor &&
            lhs.isReply == rhs.isReply &&
            lhs.nickname == rhs.nickname &&
            lhs.nicknameImageURL == rhs.nicknameImageURL &&
            lhs.timestamp == rhs.timestamp &&
            lhs.likeCount == rhs.likeCount &&
            lhs.bodyImageURL == rhs.bodyImageURL &&
            lhs.bodyHTML == rhs.bodyHTML
        }
        
        let isAuthor: Bool
        let isReply: Bool
        let nickname: String
        let nicknameImageURL: URL?
        let timestamp: Date
        let likeCount: Int
        let bodyImageURL: URL?
        let bodyHTML: String
    }
}
