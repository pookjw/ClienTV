//
//  ImageArticleBaseListRepository.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/10/21.
//

import Foundation
import Combine

protocol ImageArticleBaseListRepository {
    func getImageArticleBaseList(page: Int) -> Future<[ImageArticleBase], Error>
}
