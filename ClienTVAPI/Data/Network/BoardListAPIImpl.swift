//
//  BoardListAPIImpl.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/2/21.
//

import Foundation
import Combine
import SwiftSoup

final class BoardListAPIImpl: BoardListAPI {
    private var cancallableBag: Set<AnyCancellable> = .init()
    
    func getBoardList(categories: [Board.Category]) -> Future<[Board], Error> {
        return .init { [weak self] promise in
            guard let self = self else {
                promise(.failure(BoardListAPIError.nilError))
                return
            }
            self.configurePromise(promise, categories: categories)
        }
    }
    
    func getBoardList() -> URLSession.DataTaskPublisher {
        let url: URL = ClienURLFactory.url()
        return URLSession
            .shared
            .dataTaskPublisher(for: url)
    }
    
    private func configurePromise(_ promise: @escaping ((Result<[Board], Error>) -> Void), categories: [Board.Category]) {
        
        let url: URL = ClienURLFactory.url()
        return URLSession
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
                guard let self = self else {
                    throw BoardListAPIError.nilError
                }
                
                let boardList: [Board] = try self.convertMenuList(from: data, categories: categories)
                return boardList
            }
            .sink { completion in
                switch completion {
                case .failure(let error):
                    promise(.failure(error))
                case .finished:
                    break
                }
            } receiveValue: { boardList in
                promise(.success(boardList))
            }
            .store(in: &cancallableBag)
    }
    
    private func convertMenuList(from data: Data, categories: [Board.Category]) throws -> [Board] {
        guard let html: String = String(data: data, encoding: .utf8) else {
            throw BoardListAPIError.parseError
        }
        
        var result: [Board] = []
        let document: Document = try SwiftSoup.parse(html)
        
        try categories.forEach { category in
            let elements: [Element] = try document
                .select("a")
                .filter { try $0.attr("class") == category.rawValue }
            
            let boardList: [Board] = try elements
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
            
            result += boardList
        }
        
        return result
    }
}
