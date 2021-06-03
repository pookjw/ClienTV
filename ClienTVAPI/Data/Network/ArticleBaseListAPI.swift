//
//  ArticleBaseListAPI.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/3/21.
//

import Foundation
import Combine

protocol ArticleBaseListAPI {
    func getArticleBaseList(path: String) -> Future<[ArticleBase], Error>
}

enum ArticleBaseListError: Error {
    case nilError
    case parseError
    case responseError(Int)
}
