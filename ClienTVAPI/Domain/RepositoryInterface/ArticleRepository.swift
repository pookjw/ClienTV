//
//  ArticleRepository.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/6/21.
//

import Foundation
import Combine

protocol ArticleRepository {
    func getArticle(path: String) -> Future<Article, Error>
}
