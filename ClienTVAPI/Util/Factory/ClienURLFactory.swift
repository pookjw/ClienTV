//
//  ClienURLFactory.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/3/21.
//

import Foundation

internal final class ClienURLFactory {
    private struct API {
        internal static let scheme: String = "https"
        internal static let host: String = "www.clien.net"
    }
    
    internal static func url(path: String? = nil) -> URL? {
        var components: URLComponents = .init()
        components.scheme = API.scheme
        components.host = API.host
        if let path: String = path {
            components.path = path
        }
        return components.url
    }
}
