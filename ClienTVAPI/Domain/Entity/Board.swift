//
//  Board.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/2/21.
//

import Foundation

public struct Board {
    public enum Category: String, CaseIterable {
        case community = "menu-list"
        case somoim = "menu-list somoim"
        case somoimEtc = "menu-group somoim etc"
    }
    
    public let name: String
    public let path: String
    public let category: Category
}
