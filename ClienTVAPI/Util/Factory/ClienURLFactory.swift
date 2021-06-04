//
//  ClienURLFactory.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/3/21.
//

import Foundation

final class ClienURLFactory {
    private struct API {
        static let scheme: String = "https"
        static let host: String = "www.clien.net"
    }
    
    static func url(path: String? = nil, queryItems: [URLQueryItem] = []) -> URL {
        var components: URLComponents = .init()
        components.scheme = API.scheme
        components.host = API.host
        if let path: String = path {
            components.path = path
        }
        components.queryItems = queryItems
        return components.url!
    }
}
