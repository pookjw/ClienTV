//
//  ImageTopShelfData.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/11/21.
//

import Foundation

struct ImageTopShelfData: Codable {
    public let previewImageURL: URL?
    public let title: String
    public let previewBody: String
    public let timestamp: Date
    public let nickname: String
    public let path: String
}
