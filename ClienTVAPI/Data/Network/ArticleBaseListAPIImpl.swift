//
//  ArticleBaseListAPIImpl.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/3/21.
//

import Foundation
import Combine

final class ArticleBaseListAPIImpl: ArticleBaseListAPI {
    private var cancallableBag: Set<AnyCancellable> = .init()
    
    func getArticleBaseList(path: String, page: Int) -> URLSession.DataTaskPublisher {
        let url: URL = ClienURLFactory.url(path: path,
                                           queryItems: [.init(name: "po", value: String(page))])
        
        return URLSession
            .shared
            .dataTaskPublisher(for: url)
    }
}
