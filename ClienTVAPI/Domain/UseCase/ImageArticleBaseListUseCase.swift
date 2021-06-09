//
//  ImageArticleBaseListUseCase.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/10/21.
//

import Foundation
import Combine

public protocol ImageArticleBaseListUseCase {
    func getImageArticleBaseList(page: Int) -> Future<[ImageArticleBase], Error>
}

public final class ImageArticleBaseListUseCaseImpl: ImageArticleBaseListUseCase {
    private let imageArticleBaseListRepository: ImageArticleBaseListRepository
    
    public init() {
        self.imageArticleBaseListRepository = ImageArticleBaseListRepositoryImpl()
    }
    
    public func getImageArticleBaseList(page: Int) -> Future<[ImageArticleBase], Error> {
        return imageArticleBaseListRepository.getImageArticleBaseList(page: page)
    }
}
