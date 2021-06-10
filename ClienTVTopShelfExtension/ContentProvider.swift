//
//  ContentProvider.swift
//  ClienTVTopShelfExtension
//
//  Created by Jinwoo Kim on 6/11/21.
//

import TVServices

class ContentProvider: TVTopShelfContentProvider {

    override func loadTopShelfContent(completionHandler: @escaping (TVTopShelfContent?) -> Void) {
        // Fetch content and call completionHandler
        completionHandler(nil);
    }

}

