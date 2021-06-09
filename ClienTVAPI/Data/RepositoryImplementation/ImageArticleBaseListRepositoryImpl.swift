//
//  ImageArticleBaseListRepositoryImpl.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/10/21.
//

import Foundation
import Combine

final class ImageArticleBaseListRepositoryImpl: ImageArticleBaseListRepository {
    private let api: ImageArticleBaseListAPI
    
    init(api: ImageArticleBaseListAPI = ImageArticleBaseListAPIImpl()) {
        self.api = api
    }
    
    func getImageArticleBaseList(page: Int) -> Future<[ImageArticleBase], Error> {
        return api.getImageArticleBaseList(page: page)
    }
}
