//
//  ArticleBaseListAPI.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/3/21.
//

import Foundation
import Combine

protocol ArticleBaseListAPI {
    func getArticleBaseList(path: String, page: Int) -> Future<[ArticleBase], Error>
}

enum ArticleBaseListAPIError: Error {
    case nilError
    case parseError
    case responseError(Int)
}
