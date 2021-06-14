//
//  ImageArticleBaseListModel.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/10/21.
//

import Foundation

struct ImageArticleBaseListHeaderItem: Equatable, Hashable {
    static func == (lhs: ImageArticleBaseListHeaderItem, rhs: ImageArticleBaseListHeaderItem) -> Bool {
        return lhs.dataType == rhs.dataType
    }
    
    enum DataType: Equatable, Hashable {
        case imageArticleBaseList
        
        static func == (lhs: DataType, rhs: DataType) -> Bool {
            switch (lhs, rhs) {
            case (.imageArticleBaseList, .imageArticleBaseList):
                return true
            }
        }
    }
    
    let dataType: DataType
}

extension ImageArticleBaseListHeaderItem {
}

// MARK: - ArticleBaseListCellItem

struct ImageArticleBaseListCellItem: Equatable, Hashable {
    static func == (lhs: ImageArticleBaseListCellItem, rhs: ImageArticleBaseListCellItem) -> Bool {
        return lhs.dataType == rhs.dataType
    }
    
    enum DataType: Equatable, Hashable {
        case imageArticleBase(data: ImageArticleBaseData)
        case loadMore
        
        static func == (lhs: DataType, rhs: DataType) -> Bool {
            switch (lhs, rhs) {
            case let (.imageArticleBase(lhsData), .imageArticleBase(rhsData)):
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

extension ImageArticleBaseListCellItem {
    struct ImageArticleBaseData: Equatable, Hashable {
        static func == (lhs: ImageArticleBaseData, rhs: ImageArticleBaseData) -> Bool {
            return lhs.previewImageURL == rhs.previewImageURL &&
                lhs.category == rhs.category &&
                lhs.title == rhs.title &&
                lhs.previewBody == rhs.previewBody &&
                lhs.timestamp == rhs.timestamp &&
                lhs.likeCount == rhs.likeCount &&
                lhs.commentCount == rhs.commentCount &&
                lhs.nickname == rhs.nickname &&
                lhs.nicknameImageURL == rhs.nicknameImageURL &&
                lhs.path == rhs.path
        }
        
        let previewImageURL: URL?
        let category: String
        let title: String
        let previewBody: String
        let timestamp: Date
        let likeCount: Int
        let commentCount: Int
        let nickname: String
        let nicknameImageURL: URL?
        let path: String
    }
}
