//
//  ConditionAPIImpl.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/17/21.
//

import Foundation
import Combine
import SwiftSoup

final class ConditionAPIImpl: ConditionAPI {
    private var cancallableBag: Set<AnyCancellable> = .init()
    
    func getCondition() -> Future<Condition, Error> {
        return .init { [weak self] promise in
            self?.configurePromise(promise)
        }
    }
    
    private func configurePromise(_ promise: @escaping ((Result<Condition, Error>) -> ())) {
        let url: URL = ClienURLFactory.url(path: "/service/cs/conditions",
                                           queryItems: [])
        
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
            .tryMap { [weak self] (data, response) -> Condition in
                guard let self = self else {
                    throw APIError.nilError
                }
                
                let condition: Condition = try self.convertCondition(from: data)
                
                return condition
            }
            .sink { completion in
                switch completion {
                case .failure(let error):
                    promise(.failure(error))
                case .finished:
                    break
                }
            } receiveValue: { condition in
                promise(.success(condition))
            }
            .store(in: &cancallableBag)
    }
    
    private func convertCondition(from data: Data) throws -> Condition {
        guard let html: String = String(data: data, encoding: .utf8) else{
            throw APIError.parseError
        }
        
        let document: Document = try SwiftSoup.parse(html)
        
        let bodyHTML: String = try document
            .getElementsByClass("content_terms terms_style")
            .first()?
            .children()
            .toString() ?? ""
        
        let result: Condition = .init(bodyHTML: bodyHTML)
        
        return result
    }
}
