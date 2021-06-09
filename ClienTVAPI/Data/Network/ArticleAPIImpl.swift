//
//  ArticleAPIImpl.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/6/21.
//

import Foundation
import Combine
import OSLog
import SwiftSoup

final class ArticleAPIImpl: ArticleAPI {
    private let dateFormatter: GlobalDateFormatter = .init()
    private var cancallableBag: Set<AnyCancellable> = .init()
    
    func getArticle(path: String) -> Future<Article, Error> {
        return .init { [weak self] promise in
            guard let self = self else {
                promise(.failure(ArticleAPIError.nilError))
                return
            }
            self.configurePromise(promise, path: path)
        }
    }
    
    private func configurePromise(_ promise: @escaping (Result<Article, Error>) -> Void, path: String) {
        let url: URL = ClienURLFactory.url(path: path)
        
        URLSession
            .shared
            .dataTaskPublisher(for: url)
            .tryMap { (data, response) throws -> (Data, HTTPURLResponse) in
                guard let response: HTTPURLResponse = response as? HTTPURLResponse else {
                    throw ArticleAPIError.nilError
                }
                return (data, response)
            }
            .tryFilter { (_, response) throws -> Bool in
                let statusCode: Int = response.statusCode
                guard 200..<300 ~= statusCode else {
                    throw ArticleAPIError.responseError(statusCode)
                }
                return true
            }
            .tryMap { [weak self] (data, response) throws -> Article in
                guard let self = self else {
                    throw ArticleAPIError.nilError
                }
                
                let article: Article = try self.convertArticle(from: data, path: path)
                return article
            }
            .sink { completion in
                switch completion {
                case .failure(let error):
                    promise(.failure(error))
                case .finished:
                    break
                }
            } receiveValue: { article in
                promise(.success(article))
            }
            .store(in: &cancallableBag)
    }
    
    private func convertArticle(from data: Data, path: String) throws -> Article {
        guard let html: String = String(data: data, encoding: .utf8) else {
            throw ArticleBaseListAPIError.parseError
        }
        
        let document: Document = try SwiftSoup.parse(html)
        guard let element: Element = try document
                .getElementsByClass("content_view")
                .first() else {
            throw ArticleBaseListAPIError.parseError
        }
        
        //
        
        let likeCount: Int = try element
            .getElementsByClass("post_symph view_symph")
            .select("span")
            .first()?
            .ownText()
            .toInt() ?? 0
        
        let category: String? = try element
            .getElementsByClass("post_category")
            .first()?
            .ownText()
        
        /*
         <h3 class="post_subject" data-role="cut-string">
            <span class="post_category">잡담</span>
            <span>현직 미래에셋페이 서포터즈 활동중입니다</span>
         </h3>
         */
        let title: String = try element
            .getElementsByClass("post_subject")
            .select("span")
            .filter { try $0.className() != "post_category" }
            .first?
            .ownText() ?? ""
        
        /*
         <a class="post_reply" href="#comment-head">
            <span>7</span>
            <span class="fa fa-angle-down"></span>
         </a>
         */
        let commentCount: Int = try element
            .getElementsByClass("post_reply")
            .select("span")
            .filter { try $0.className() != "fa fa-angle-down" }
            .first?
            .ownText()
            .toInt() ?? 0
        
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
        
        let hitCount: Int = try element
            .getElementsByClass("view_count")
            .first()?
            .select("strong")
            .first()?
            .ownText()
            .filter { $0 != "," } // 1,182 -> 1182
            .toInt() ?? 0
        
        let timestamp: Date
        
        if let timestampString: String = try element
            .getElementsByClass("fa fa-clock-o")
            .first()?
            .parent()?
            .ownText()
        {
            timestamp = dateFormatter.date(from: timestampString) ?? Date(timeIntervalSince1970: 0)
        } else {
            timestamp = Date(timeIntervalSince1970: 0)
        }
        
        let path: String = path
        
        let bodyHTML: String = try element
            .getElementsByClass("post_article")
            .first()?
            .html() ?? ""
        
        let articleBase: ArticleBase = .init(likeCount: likeCount,
                                             category: category,
                                             title: title,
                                             commentCount: commentCount,
                                             nickname: nickname,
                                             nicknameImageURL: nicknameImageURL,
                                             hitCount: hitCount,
                                             timestamp: timestamp,
                                             path: path)
        
        return .init(base: articleBase,
                     bodyHTML: bodyHTML)
    }
    
    private func configureDateFormatter() {
        // TimeZone offset 제거
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
}
