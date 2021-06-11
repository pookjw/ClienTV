//
//  ImageTopShelfConstant.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/11/21.
//

import Foundation

struct ImageTopShelfConstant {
    static let suitName: String = "group.com.pookjw.ClienTV"
    static let timestampKey: String = "timestampKey"
    static let imageTopShelfDatasKey: String = "imageTopShelfDatasKey"
    
    #if DEBUG
    static let saveThrottleInterval: TimeInterval = 0
    #else
    static let saveThrottleInterval: TimeInterval = 60 * 60 * 1000
    #endif
}
