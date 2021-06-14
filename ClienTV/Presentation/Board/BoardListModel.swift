//
//  BoardListModel.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/4/21.
//

import Foundation

// MARK: - BoardListHeaderItem

struct BoardListHeaderItem: Equatable, Hashable {
    static func == (lhs: BoardListHeaderItem, rhs: BoardListHeaderItem) -> Bool {
        return lhs.dataType == rhs.dataType
    }
    
    enum DataType: Equatable, Hashable {
        case category(data: CategoryData)
        
        static func == (lhs: DataType, rhs: DataType) -> Bool {
            switch (lhs, rhs) {
            case (.category(let lhsData), .category(let rhsData)):
                return lhsData == rhsData
            }
        }
    }
    
    let dataType: DataType
}

extension BoardListHeaderItem {
    struct CategoryData: Equatable, Hashable {
        static func == (lhs: CategoryData, rhs: CategoryData) -> Bool {
            return lhs.category == rhs.category
        }
        
        enum Category {
            case community
            case somoim
            case somoimEtc
        }
        
        let category: Category
        
        var title: String {
            switch category {
            case .community:
                return "커뮤니티"
            case .somoim:
                return "소모임"
            case .somoimEtc:
                return "기타"
            }
        }
    }
}

// MARK: - BoardListCellItem

struct BoardListCellItem: Equatable, Hashable {
    static func == (lhs: BoardListCellItem, rhs: BoardListCellItem) -> Bool {
        return lhs.dataType == rhs.dataType
    }
    
    enum DataType: Equatable, Hashable {
        case board(data: BoardData)
        
        static func == (lhs: DataType, rhs: DataType) -> Bool {
            switch (lhs, rhs) {
            case let (.board(lhsData), .board(rhsData)):
                return lhsData == rhsData
            }
        }
    }
    
    let dataType: DataType
}

extension BoardListCellItem {
    struct BoardData: Equatable, Hashable {
        static func == (lhs: BoardData, rhs: BoardData) -> Bool {
            return lhs.name == rhs.name &&
                lhs.path == rhs.path
        }
        
        let name: String
        let path: String
    }
}
