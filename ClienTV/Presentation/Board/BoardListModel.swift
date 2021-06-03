//
//  BoardListModel.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/4/21.
//

import Foundation

struct BoardListHeaderItem: Hashable, Equatable {
    static func ==(lhs: BoardListHeaderItem, rhs: BoardListHeaderItem) -> Bool {
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

struct BoardListCellItem: Hashable, Equatable {
    static func ==(lhs: BoardListCellItem, rhs: BoardListCellItem) -> Bool {
        return lhs.name == rhs.name &&
            lhs.path == rhs.path
    }
    
    let name: String
    let path: String
}
