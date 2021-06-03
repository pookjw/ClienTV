//
//  BoardListRepositoryImpl.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/4/21.
//

import Foundation
import Combine
import SwiftSoup

final class BoardListRepositoryImpl: BoardListRepository {
    private let api: BoardListAPI
    private var cancallableBag: Set<AnyCancellable> = .init()
    
    init(api: BoardListAPI = BoardListAPIImpl()) {
        self.api = api
    }
    
    func getBoardList(categories: [Board.Category]) -> Future<[Board], Error> {
        return .init { [weak self] promise in
            guard let self: BoardListRepositoryImpl = self else {
                promise(.failure(BoardListRepositoryError.nilError))
                return
            }
            self.configurePromise(promise, categories: categories)
        }
    }
    
    private func configurePromise(_ promise: @escaping ((Result<[Board], Error>) -> Void), categories: [Board.Category]) {
        
        api.getBoardList()
            .tryMap { (data, response) throws -> (Data, HTTPURLResponse) in
                guard let response: HTTPURLResponse = response as? HTTPURLResponse else {
                    throw BoardListRepositoryError.nilError
                }
                return (data, response)
            }
            .tryFilter { (_, response) throws -> Bool in
                let statusCode: Int = response.statusCode
                guard 200..<300 ~= statusCode else {
                    throw BoardListRepositoryError.responseError(statusCode)
                }
                return true
            }
            .tryMap { [weak self] (data, response) throws -> [Board] in
                guard let self: BoardListRepositoryImpl = self else {
                    throw BoardListRepositoryError.nilError
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
            throw BoardListRepositoryError.parseError
        }
        
        var result: [Board] = []
        let document: Document = try SwiftSoup.parse(html)
        
        try categories.forEach { category in
            let elements: Elements = try document
                .getElementsByClass(category.rawValue)
            
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
