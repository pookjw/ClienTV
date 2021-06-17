//
//  CommentListAPIImpl.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/7/21.
//

import Foundation
import Combine
import OSLog
import SwiftSoup

final class CommentListAPIImpl: CommentListAPI {
    private let dateFormatter: ClienDateFormatter = .init()
    private var cancallableBag: Set<AnyCancellable> = .init()
    
    func getCommentList(path: String) -> Future<[Comment], Error> {
        return .init { [weak self] promise in
            self?.configurePromise(promise, path: path)
        }
    }
    
    private func configurePromise(_ promise: @escaping (Result<[Comment], Error>) -> Void, path: String) {
        let url: URL = ClienURLFactory.url(path: path)
        
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
            .tryMap { [weak self] (data, response) throws -> [Comment] in
                guard let self = self else {
                    throw APIError.nilError
                }
                
                let commentList: [Comment] = try self.convertCommentList(from: data)
                return commentList
            }
            .sink { completion in
                switch completion {
                case .failure(let error):
                    promise(.failure(error))
                case .finished:
                    break
                }
            } receiveValue: { commentList in
                promise(.success(commentList))
            }
            .store(in: &cancallableBag)
    }
    
    private func convertCommentList(from data: Data) throws -> [Comment] {
        guard let html: String = String(data: data, encoding: .utf8) else {
            throw APIError.parseError
        }
        
        let document: Document = try SwiftSoup.parse(html)
        
        guard let elements: Elements = try document
                .getElementsByClass("comment")
                .first()?
                .children() else {
            throw APIError.parseError
        }
        
        let result: [Comment] = try elements
            .compactMap { [weak self] element in
                guard let self = self else {
                    throw APIError.nilError
                }
                let comment: Comment? = try self.convertComment(from: element)
                return comment
            }
        
        return result
    }
    
    private func convertComment(from element: Element) throws -> Comment? {
        let commentType: String = try element.className()
        
        let isAuthor: Bool
        let isReply: Bool
        let isMe: Bool
        let isBlocked: Bool
        
        switch commentType {
        case "comment_row":
            isAuthor = false
            isReply = false
            isMe = false
            isBlocked = false
        case "comment_row  re":
            isAuthor = false
            isReply = true
            isMe = false
            isBlocked = false
        case "comment_row by-author ":
            isAuthor = true
            isReply = false
            isMe = false
            isBlocked = false
        case "comment_row by-author re":
            isAuthor = true
            isReply = true
            isMe = false
            isBlocked = false
        case "comment_row by-me ":
            isAuthor = false
            isReply = false
            isMe = true
            isBlocked = false
        case "comment_row by-me re":
            isAuthor = false
            isReply = true
            isMe = true
            isBlocked = false
        case "comment_row blocked":
            isAuthor = false
            isReply = false
            isMe = false
            isBlocked = true
        case "comment_row blocked re":
            isAuthor = false
            isReply = true
            isMe = false
            isBlocked = true
        default:
            Logger.warning("unspecified comment type: \(commentType)")
            isAuthor = false
            isReply = false
            isMe = false
            isBlocked = false
        }
        
        //
        
        let nickname: String?
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
                nickname = nil
                nicknameImageURL = nil
            }
            
        } else {
            Logger.warning("no nickname (2)")
            nickname = nil
            nicknameImageURL = nil
        }
        
        //
        
        let timestamp: Date?
        
        if let timestampString: String = try element
            .getElementsByClass("timestamp")
            .first()?
            .ownText()
            .components(separatedBy: " / 수정일:")
            .first
        {
            timestamp = dateFormatter.date(from: timestampString) ?? nil
        } else {
            timestamp = nil
        }
        
        //
        
        let likeCount: Int? = try element
            .getElementsByClass("comment_symph")
            .first()?
            .select("strong")
            .filter { try $0.attr("id").contains("setLikeCount") }
            .first?
            .ownText()
            .toInt()
        
        //
        
        let imageURL: URL?
        
        if let imageURLString: String = try element
            .getElementsByClass("comment-img")
            .first()?
            .children()
            .first(where: { $0.tagName() == "img" })?
            .attr("src") {
            imageURL = URL(string: imageURLString)
        } else {
            imageURL = nil
        }
        
        let bodyHTML: String = try {
            if isBlocked {
                return try element
                    .getElementsByTag("span")
                    .first()?
                    .ownText() ?? ""
            } else {
                return try element
                    .getElementsByClass("comment_view")
                    .first()?
                    .html() ?? ""
            }
        }()
        
        let comment: Comment = .init(isAuthor: isAuthor,
                                     isReply: isReply,
                                     isMe: isMe,
                                     isBlocked: isBlocked,
                                     nickname: nickname,
                                     nicknameImageURL: nicknameImageURL,
                                     timestamp: timestamp,
                                     likeCount: likeCount,
                                     bodyImageURL: imageURL,
                                     bodyHTML: bodyHTML)
        
        return comment
    }
}
