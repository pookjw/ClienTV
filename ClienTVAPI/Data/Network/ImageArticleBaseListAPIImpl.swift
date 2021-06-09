//
//  ImageArticleBaseListAPIImpl.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/9/21.
//

import Foundation
import Combine
import OSLog
import SwiftSoup

final class ImageArticleBaseListAPIImpl: ImageArticleBaseListAPI {
    private let dateFormatter: DateFormatter = .init()
    private var cancallableBag: Set<AnyCancellable> = .init()

    func getImageArticleBaseList(page: Int) -> Future<[ImageArticleBase], Error> {
        return .init { [weak self] promise in
            guard let self = self else {
                promise(.failure(ImageArticleBaseListAPIError.nilError))
                return
            }
            self.configurePromise(promise, page: page)
        }
    }
    
    private func configurePromise(_ promise: @escaping (Result<[ImageArticleBase], Error>) -> Void, page: Int) {
        let url: URL = ClienURLFactory.url(path: "/service/board/image",
                                           queryItems: [.init(name: "po", value: String(page))])
        
        URLSession
            .shared
            .dataTaskPublisher(for: url)
            .tryMap { (data, response) throws -> (Data, HTTPURLResponse) in
                guard let response: HTTPURLResponse = response as? HTTPURLResponse else {
                    throw ImageArticleBaseListAPIError.nilError
                }
                return (data, response)
            }
            .tryFilter { (_, response) throws -> Bool in
                let statusCode: Int = response.statusCode
                guard 200..<300 ~= statusCode else {
                    throw ImageArticleBaseListAPIError.responseError(statusCode)
                }
                return true
            }
            .tryMap { [weak self] (data, response) throws -> [ImageArticleBase] in
                guard let self = self else {
                    throw ImageArticleBaseListAPIError.nilError
                }
                
                let imageArticleBaseList: [ImageArticleBase] = try self.convertImageArticleBaseList(from: data)
                
                return imageArticleBaseList
            }
            .sink { completion in
                switch completion {
                case .failure(let error):
                    promise(.failure(error))
                case .finished:
                    break
                }
            } receiveValue: { imageArticleBaseList in
                promise(.success(imageArticleBaseList))
            }
            .store(in: &cancallableBag)
    }
    
    private func convertImageArticleBaseList(from data: Data) throws -> [ImageArticleBase] {
        guard let html: String = String(data: data, encoding: .utf8) else{
            throw ImageArticleBaseListAPIError.parseError
        }
        
        let document: Document = try SwiftSoup.parse(html)
        
        guard let elements: [Element] = try document
                .getElementsByClass("list_content")
                .first()?
                .getElementsByClass("card")
                .first()?
                .getElementsByTag("div")
                .filter({ try $0.className() == "card_item" })
        else {
            throw ImageArticleBaseListAPIError.parseError
        }
        
        let result: [ImageArticleBase] = try elements
            .map { [weak self] element -> ImageArticleBase in
                guard let self = self else {
                    throw ImageArticleBaseListAPIError.nilError
                }
                let imageArticleBase: ImageArticleBase = try self.convertImageArticleBase(from: element)
                return imageArticleBase
            }
        
        return result
    }
    
    private func convertImageArticleBase(from element: Element) throws -> ImageArticleBase {
        let previewImageURL: URL?
        
        if let previewImageString: String = try element
            .getElementsByClass("card_image")
            .first()?
            .getElementsByTag("img")
            .first()?
            .attr("src")
        {
            previewImageURL = URL(string: previewImageString)
        } else {
            previewImageURL = nil
        }
        
        //
        
        let category: String = try element
            .getElementsByClass("subject_category")
            .first()?
            .ownText() ?? ""
        
        //
        
        let title: String = try element
            .getElementsByClass("card_subject")
            .first()?
            .getElementsByTag("span")
            .filter { $0.hasAttr("title") }
            .first?
            .attr("title") ?? ""
    }
}
