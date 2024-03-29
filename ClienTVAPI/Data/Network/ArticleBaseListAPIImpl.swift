//
//  ArticleBaseListAPIImpl.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/3/21.
//

import Foundation
import Combine
import OSLog
import SwiftSoup

final class ArticleBaseListAPIImpl: ArticleBaseListAPI {
    private let dateFormatter: ClienDateFormatter = .init()
    private var cancallableBag: Set<AnyCancellable> = .init()
    
    func getArticleBaseList(path: String, page: Int) -> Future<[ArticleBase], Error> {
        return .init { [weak self] promise in
            self?.configurePromise(promise, path: path, page: page)
        }
    }
    
    private func configurePromise(_ promise: @escaping (Result<[ArticleBase], Error>) -> Void, path: String, page: Int) {
        let url: URL = ClienURLFactory.url(path: path,
                                           queryItems: [.init(name: "po", value: String(page))])
        
        URLSession
            .shared
            .dataTaskPublisher(for: url)
            .tryMap { (data, response) throws -> (Data, HTTPURLResponse) in
                guard let response: HTTPURLResponse = response as? HTTPURLResponse else {
                    throw APIError.nilError
                }
                return (data, response)
            }
            .tryFilter { (_, response) throws -> Bool in
                let statusCode: Int = response.statusCode
                guard 200..<300 ~= statusCode else {
                    throw APIError.responseError(statusCode)
                }
                return true
            }
            .tryMap { [weak self] (data, response) throws -> [ArticleBase] in
                guard let self = self else {
                    throw APIError.nilError
                }
                
                let articleBaseList: [ArticleBase] = try self.convertArticleBaseList(from: data)
                return articleBaseList
            }
            .sink { completion in
                switch completion {
                case .failure(let error):
                    promise(.failure(error))
                case .finished:
                    break
                }
            } receiveValue: { articleBaseList in
                promise(.success(articleBaseList))
            }
            .store(in: &cancallableBag)
    }
    
    private func convertArticleBaseList(from data: Data) throws -> [ArticleBase] {
        guard let html: String = String(data: data, encoding: .utf8) else {
            throw APIError.parseError
        }
        
        let document: Document = try SwiftSoup.parse(html)
        
        guard let elements: [Element] = try document
                .getElementsByClass("list_content")
                .first()?
                .getElementsByTag("div")
                .filter({ try $0.attr("class").contains("list_item symph_row") }) else {
            throw APIError.parseError
        }
        
        let result: [ArticleBase] = try elements
            .map { [weak self] element -> ArticleBase in
                guard let self = self else {
                    throw APIError.nilError
                }
                let articleBase: ArticleBase = try self.convertArticleBase(from: element)
                return articleBase
            }
        
        return result
    }
    
    private func convertArticleBase(from element: Element) throws -> ArticleBase {
        let likeCount: Int = try element
            .getElementsByClass("list_symph view_symph")
            .first(where: { try $0.attr("data-role") == "list-like-count" })?
            .select("span")
            .first()?
            .ownText()
            .toInt() ?? 0
        
        let category: String? = try element
            .getElementsByClass("category fixed")
            .first(where: { $0.hasAttr("title") })?
            .ownText()
        
        let title: String = try {
            let normalTitle: String? = try element
                .getElementsByClass("subject_fixed")
                .filter { try $0.attr("data-role") == "list-title-text" }
                .first(where: { $0.hasAttr("title") })?
                .ownText()
            
            // 알뜰구매 게시판
            let jirumTitle: String? = try element
                .getElementsByClass("list_subject")
                .filter { try $0.attr("data-role") == "cut-string" }
                .filter { $0.hasAttr("title") }
                .first?
                .attr("title")
            
            return normalTitle ?? jirumTitle ?? "(no title)"
        }()
        
        let commentCount: Int = try element
            .getElementsByClass("list_reply reply_symph")
            .first()?
            .select("span")
            .first(where: { try $0.attr("class") == "rSymph05" })?
            .ownText()
            .toInt() ?? 0 // 댓글이 없는 글은 이 값이 없을 수 있음
        
        //
        
        let nickname: String
        let nicknameImageURL: URL?
        
        if let nicknameElement: Element = try element
            .getElementsByClass("nickname")
            .first()
        {
            
            if let imgElement: Element = nicknameElement
                .children()
                .first(where: { $0.tagName() == "img" })
            {
                nickname = try imgElement.attr("alt")
                let nicknameImageString: String = try imgElement.attr("src")
                nicknameImageURL = URL(string: nicknameImageString)
            } else if let srcElement: Element = nicknameElement
                        .children()
                        .first(where: { $0.tagName() == "span" })
            {
                nickname = srcElement.ownText()
                nicknameImageURL = nil
            } else {
                Logger.warning("no nickname (1)")
                nickname = "(no nickname)"
                nicknameImageURL = nil
            }
            
        } else {
            Logger.warning("no nickname (2)")
            nickname = "(no nickname)"
            nicknameImageURL = nil
        }
        
        //
        
        let hitCount: Int = try {
            let normalHitCount: Int? = try element
                .getElementsByClass("hit")
                .first()?
                .ownText()
                .toInt()
            
            let literalHitCount: Float = (try element
                .getElementsByClass("hit")
                .first()?
                .ownText()
                .components(separatedBy: " ")
                .first?
                .toFloat() ?? 0) * 1000
            
            return normalHitCount ?? Int(literalHitCount)
        }()
        
        //
        
        let timestamp: Date
        
        if let timestampString: String = try element
            .getElementsByClass("timestamp")
            .first()?
            .ownText()
        {
            timestamp = dateFormatter.date(from: timestampString) ?? Date(timeIntervalSince1970: 0)
        } else {
            timestamp = Date(timeIntervalSince1970: 0)
        }
        
        //
        
        let path: String = try element
            .attr("data-board-sn")
        
        return .init(likeCount: likeCount,
                     category: category,
                     title: title,
                     commentCount: commentCount,
                     nickname: nickname,
                     nicknameImageURL: nicknameImageURL,
                     hitCount: hitCount,
                     timestamp: timestamp,
                     path: path)
    }
}
