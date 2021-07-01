//
//  NSObject+className.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 7/1/21.
//

import Foundation

extension NSObject {
    static var className: String {
        return .init(describing: self)
    }
    
    var className: String {
        return Self.className
    }
}
