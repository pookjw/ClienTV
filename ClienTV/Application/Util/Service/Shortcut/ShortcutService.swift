//
//  ShortcutService.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/11/21.
//

import Foundation
import Combine
import OSLog

final class ShortcutService {
    enum Category {
        case article(boardPath: String, articlePath: String)
    }
    
    static let shared: ShortcutService = .init()
    let categoryEvent: PassthroughSubject<Category, Never> = .init()
    
    func handle(for url: URL) {
        guard let components: URLComponents = .init(url: url, resolvingAgainstBaseURL: false),
              let host: String = components.host else {
            Logger.warning("invalid url!")
            return
        }
        
        let queryItems: [URLQueryItem] = components.queryItems ?? []
        
        switch host {
        case "article":
            handleArticleEvent(queryItems: queryItems)
        default:
            Logger.warning("unknown host for URL Scheme: \(host)")
        }
    }
    
    private init() {}
    
    private func handleArticleEvent(queryItems: [URLQueryItem]) {
        var boardPath: String? = nil
        var articlePath: String? = nil
        
        queryItems.forEach { queryItem in
            let name: String = queryItem.name
            switch name {
            case "boardPath":
                boardPath = queryItem.value
            case "articlePath":
                articlePath = queryItem.value
            default:
                break
            }
        }
        
        guard let boardPath: String = boardPath,
              let articlePath: String = articlePath else {
            Logger.error("invalid queryItems for article!")
            return
        }
        
        let event: Category = .article(boardPath: boardPath, articlePath: articlePath)
        categoryEvent.send(event)
    }
}
