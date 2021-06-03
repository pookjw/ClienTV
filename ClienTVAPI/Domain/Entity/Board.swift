//
//  Board.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/2/21.
//

import Foundation

struct Board {
    enum Category: String, CaseIterable {
        case community = "menu-list"
        case somoim = "menu-list somoim"
        case somoimEtc = "menu-group somoim etc"
    }
    
    let name: String
    let path: String
    let category: Category
}
