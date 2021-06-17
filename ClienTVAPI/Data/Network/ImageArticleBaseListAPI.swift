//
//  ImageArticleBaseListAPI.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/9/21.
//

import Foundation
import Combine

protocol ImageArticleBaseListAPI {
    func getImageArticleBaseList(page: Int) -> Future<[ImageArticleBase], Error>
}
