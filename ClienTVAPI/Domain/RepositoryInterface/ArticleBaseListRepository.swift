//
//  ArticleBaseListRepository.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/4/21.
//

import Foundation
import Combine

protocol ArticleBaseListRepository {
    func getArticleBaseList(path: String, page: Int) -> Future<[ArticleBase], Error>
}
