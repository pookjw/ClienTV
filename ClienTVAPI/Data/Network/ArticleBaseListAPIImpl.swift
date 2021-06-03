//
//  ArticleBaseListAPIImpl.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/3/21.
//

import Foundation
import Combine
import SwiftSoup
import OSLog

final class ArticleBaseListAPIImpl: ArticleBaseListAPI {
    private let dateFormatter: DateFormatter = .init()
    private var cancallableBag: Set<AnyCancellable> = .init()
    
    init() {
        configureDateFormatter()
    }
    
    func getArticleBaseList(path: String) -> Future<[ArticleBase], Error> {
        return .init { [weak self] promise in
            guard let self: ArticleBaseListAPIImpl = self else {
                promise(.failure(ArticleBaseListError.nilError))
                return
            }
            self.configureArticleBaseListPromise(promise, path: path)
        }
    }
    
    private func configureDateFormatter() {
        // TimeZone offset 제거
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
    private func configureArticleBaseListPromise(_ promise: @escaping (Result<[ArticleBase], Error>) -> Void, path: String) {
        guard let url: URL = ClienURLFactory.url(path: path) else {
            promise(.failure(ArticleBaseListError.nilError))
            return
        }
        
        URLSession
            .shared
            .dataTaskPublisher(for: url)
            .tryMap { (data, response) throws -> (Data, HTTPURLResponse) in
                guard let response: HTTPURLResponse = response as? HTTPURLResponse else {
                    throw ArticleBaseListError.nilError
                }
                return (data, response)
            }
            .tryFilter { (_, response) throws -> Bool in
                let statusCode: Int = response.statusCode
                guard 200..<300 ~= statusCode else {
                    throw ArticleBaseListError.responseError(statusCode)
                }
                return true
            }
            .tryMap { [weak self] (data, response) throws -> [ArticleBase] in
                guard let self: ArticleBaseListAPIImpl = self else {
                    throw MenuListAPIError.nilError
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
            throw ArticleBaseListError.parseError
        }
        
        let document: Document = try SwiftSoup.parse(html)
        guard let elements: [Element] = try document
                .getElementsByClass("list_content")
                .first?
                .getElementsByTag("div")
                .filter({ try $0.attr("class").contains("list_item symph_row") }) else {
            throw ArticleBaseListError.parseError
        }
        
        let result: [ArticleBase] = try elements
            .map { [weak self] element -> ArticleBase in
                guard let self: ArticleBaseListAPIImpl = self else {
                    throw ArticleBaseListError.nilError
                }
                let articleBase: ArticleBase = try self.convertArticleBase(from: element)
                return articleBase
            }
        
        return result
    }
    
    private func convertArticleBase(from element: Element) throws -> ArticleBase {
        let likeCount: Int = try element
            .getElementsByClass("list_symph view_symph")
            .filter { try $0.attr("data-role") == "list-like-count" }
            .first?
            .select("span")
            .first()?
            .ownText()
            .toInt() ?? 0
        
        let category: String? = try element
            .getElementsByClass("category fixed")
            .filter { $0.hasAttr("title") }
            .first?
            .ownText()
        
        let title: String = try element
            .getElementsByClass("subject_fixed")
            .filter { try $0.attr("data-role") == "list-title-text" }
            .filter { $0.hasAttr("title") }
            .first?
            .ownText() ?? "(no title)"
        
        let commentCount: Int = try element
            .getElementsByClass("list_reply reply_symph")
            .first?
            .select("span")
            .filter { try $0.attr("class") == "rSymph05" }
            .first?
            .ownText()
            .toInt() ?? 0 // 댓글이 없는 글은 이 값이 없을 수 있음
        
        let authorID: String = try element
            .attr("data-author-id")
        
        //
        
        let nickname: String
        let nicknameImageURL: URL?
        
        if let nicknameElement: Element = try element
            .getElementsByClass("nickname")
            .first()
        {
            
            if let imgElement: Element = nicknameElement
                .children()
                .filter({ $0.tagName() == "img" })
                .first
            {
                nickname = try imgElement.attr("alt")
                let nicknameImageString: String = try imgElement.attr("src")
                nicknameImageURL = URL(string: nicknameImageString)
            } else if let srcElement: Element = nicknameElement
                        .children()
                        .filter({ $0.tagName() == "span" })
                        .first
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
        
        let hitCount: Int = try element
            .getElementsByClass("hit")
            .first?
            .ownText()
            .toInt() ?? 0
        
        
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
        
        return .init(likeCount: likeCount,
                     category: category,
                     title: title,
                     commentCount: commentCount,
                     authorID: authorID,
                     nickname: nickname,
                     nicknameImageURL: nicknameImageURL,
                     hitCount: hitCount,
                     timestamp: timestamp)
    }
}
