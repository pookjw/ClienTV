//
//  ContentProvider.swift
//  ClienTVTopShelfExtension
//
//  Created by Jinwoo Kim on 6/11/21.
//

import TVServices

final class ContentProvider: TVTopShelfContentProvider {
    private let queue: OperationQueue = .init()
    
    override init() {
        super.init()
        configureQueue()
    }

    override func loadTopShelfContent(completionHandler: @escaping (TVTopShelfContent?) -> Void) {
        // Fetch content and call completionHandler
        completionHandler(nil);
    }

    private func configureQueue() {
        queue.qualityOfService = .background
    }
}

