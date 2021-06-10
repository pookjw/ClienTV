//
//  ImageTopShelfObject.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/11/21.
//

import Foundation

final class ImageTopShelfObject: NSObject, NSCoding {
    let previewImageURL: URL
    let category: String
    let title: String
    let previewBody: String
    let timestamp: Date
    let nickname: String
    let path: String
    
    init(previewImageURL: URL,
                     category: String,
                     title: String,
                     previewBody: String,
                     timestamp: Date,
                     nickname: String,
                     path: String) {
        
        self.previewImageURL = previewImageURL
        self.category = category
        self.title = title
        self.previewBody = previewBody
        self.timestamp = timestamp
        self.nickname = nickname
        self.path = path
    }
    
    required init?(coder: NSCoder) {
        self.previewImageURL = coder.decodeObject(forKey: "previewImageURL") as! URL
        self.category = coder.decodeObject(forKey: "category") as! String
        self.title = coder.decodeObject(forKey: "title") as! String
        self.previewBody = coder.decodeObject(forKey: "previewBody") as! String
        self.timestamp = coder.decodeObject(forKey: "timestamp") as! Date
        self.nickname = coder.decodeObject(forKey: "nickname") as! String
        self.path = coder.decodeObject(forKey: "path") as! String
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(previewImageURL, forKey: "previewImageURL")
        coder.encode(category, forKey: "category")
        coder.encode(title, forKey: "title")
        coder.encode(previewBody, forKey: "previewBody")
        coder.encode(timestamp, forKey: "timestamp")
        coder.encode(nickname, forKey: "nickname")
        coder.encode(path, forKey: "path")
    }
}
