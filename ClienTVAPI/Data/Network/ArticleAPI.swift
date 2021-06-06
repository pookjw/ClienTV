//
//  ArticleAPI.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/5/21.
//

import Foundation
import Combine

protocol ArticleAPI {
    func getArticle(path: String) -> Future<Article, Error>
}

enum ArticleAPIError: Error {
    case nilError
    case parseError
    case responseError(Int)
}
