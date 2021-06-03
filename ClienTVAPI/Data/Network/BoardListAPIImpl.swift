//
//  BoardListAPIImpl.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/2/21.
//

import Foundation
import Combine
import SwiftSoup
import OSLog

final class BoardListAPIImpl: BoardListAPI {
    private var cancallableBag: Set<AnyCancellable> = .init()
    
    func getBoardList() -> Future<[Board], Error> {
        return .init { [weak self] promise in
            guard let self: BoardListAPIImpl = self else {
                promise(.failure(BoardListAPIError.nilError))
                return
            }
            self.configureBoardListPromise(promise)
        }
    }
    
    private func configureBoardListPromise(_ promise: @escaping (Result<[Board], Error>) -> Void) {
        guard let url: URL = ClienURLFactory.url() else {
            promise(.failure(BoardListAPIError.nilError))
            return
        }
        
        URLSession
            .shared
            .dataTaskPublisher(for: url)
            .tryMap { (data, response) throws -> (Data, HTTPURLResponse) in
                guard let response: HTTPURLResponse = response as? HTTPURLResponse else {
                    throw BoardListAPIError.nilError
                }
                return (data, response)
            }
            .tryFilter { (_, response) throws -> Bool in
                let statusCode: Int = response.statusCode
                guard 200..<300 ~= statusCode else {
                    throw BoardListAPIError.responseError(statusCode)
                }
                return true
            }
            .tryMap { [weak self] (data, response) throws -> [Board] in
                guard let self: BoardListAPIImpl = self else {
                    throw BoardListAPIError.nilError
                }
                
                let allMenuList: [Board] = try self.convertAllMenuList(from: data)
                return allMenuList
            }
            .sink { completion in
                switch completion {
                case .failure(let error):
                    promise(.failure(error))
                case .finished:
                    break
                }
            } receiveValue: { boardList in
                Logger.debug(boardList)
                promise(.success(boardList))
            }
            .store(in: &cancallableBag)
    }
    
    private func convertAllMenuList(from data: Data) throws -> [Board] {
        var result: [Board] = []
        
        try Board.Category.allCases.forEach { [weak self] category in
            guard let self: BoardListAPIImpl = self else {
                throw BoardListAPIError.nilError
            }
            result += try self.convertMenuList(from: data, category: category)
        }
        
        return result
    }
    
    private func convertMenuList(from data: Data, category: Board.Category) throws -> [Board] {
        guard let html: String = String(data: data, encoding: .utf8) else {
            throw BoardListAPIError.parseError
        }
        
        let document: Document = try SwiftSoup.parse(html)
        
        let elements: Elements = try document
            .getElementsByClass(category.rawValue)
        
        let menuList: [Board] = try elements
            .compactMap { element -> Board? in
                let name: String? = try element
                    .getElementsByClass("menu_over")
                    .first?
                    .ownText()
                let path: String = try element.attr("href")
                
                guard let name: String = name else {
                    return nil
                }
                
                return .init(name: name, path: path, category: category)
            }
        
        return menuList
    }
}
