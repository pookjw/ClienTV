//
//  ArticleBaseListModel.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/4/21.
//

import Foundation

struct ArticleBaseListHeaderItem: Equatable, Hashable {
    static func ==(lhs: ArticleBaseListHeaderItem, rhs: ArticleBaseListHeaderItem) -> Bool {
        return lhs.dataType == rhs.dataType
    }
    
    enum DataType: Equatable, Hashable {
        case articleBaseList
        
        static func ==(lhs: DataType, rhs: DataType) -> Bool {
            switch (lhs, rhs) {
            case (.articleBaseList, .articleBaseList):
                return true
            }
        }
    }
    
    let dataType: DataType
}

extension ArticleBaseListHeaderItem {
}

// MARK: - ArticleBaseListCellItem

struct ArticleBaseListCellItem: Equatable, Hashable {
    static func ==(lhs: ArticleBaseListCellItem, rhs: ArticleBaseListCellItem) -> Bool {
        return lhs.dataType == rhs.dataType
    }
    
    enum DataType: Equatable, Hashable {
        case articleBase(data: ArticleBaseData)
        case loadMore
        
        static func ==(lhs: DataType, rhs: DataType) -> Bool {
            switch (lhs, rhs) {
            case let (.articleBase(lhsData), .articleBase(rhsData)):
                return lhsData == rhsData
            case (.loadMore, .loadMore):
                return true
            default:
                return false
            }
        }
    }
    
    let dataType: DataType
}

extension ArticleBaseListCellItem {
    struct ArticleBaseData: Equatable, Hashable {
        static func ==(lhs: ArticleBaseData, rhs: ArticleBaseData) -> Bool {
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
}
