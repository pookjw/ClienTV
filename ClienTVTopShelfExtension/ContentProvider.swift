//
//  ContentProvider.swift
//  ClienTVTopShelfExtension
//
//  Created by Jinwoo Kim on 6/11/21.
//

import TVServices
import OSLog

final class ContentProvider: TVTopShelfContentProvider {
    private let queue: OperationQueue = .init()
    
    override init() {
        super.init()
        configureQueue()
    }

    override func loadTopShelfContent(completionHandler: @escaping (TVTopShelfContent?) -> Void) {
        queue.addOperation {
            do {
                let objects: [ImageTopShelfData] = try ImageTopShelfLoader.shared.load()
                let items: [TVTopShelfCarouselItem] = objects.map { $0.makeCarouselItem() }
                let content: TVTopShelfCarouselContent = .init(style: .details, items: items)
                completionHandler(content)
                Logger.info("Loaded!")
            } catch {
                Logger.error(error.localizedDescription)
                completionHandler(nil)
            }
        }
    }

    private func configureQueue() {
        queue.qualityOfService = .background
    }
}

