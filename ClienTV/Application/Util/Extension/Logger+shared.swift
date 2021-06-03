//
//  Logger+shared.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/3/21.
//

import Foundation
import OSLog

extension Logger {
    private static let shared: Logger = .init()
    
    static func debug(_ message: Any) {
        shared.debug("\(String(describing: message))")
    }
    
    static func trace(_ message: Any) {
        shared.trace("\(String(describing: message))")
    }
    
    static func info(_ message: Any) {
        shared.info("\(String(describing: message))")
    }
    
    static func log(_ message: Any) {
        shared.log("\(String(describing: message))")
    }
    
    static func notice(_ message: Any) {
        shared.notice("\(String(describing: message))")
    }
    
    static func error(_ message: Any) {
        shared.error("\(String(describing: message))")
    }
    
    static func warning(_ message: Any) {
        shared.warning("\(String(describing: message))")
    }
    
    static func critical(_ message: Any) {
        shared.critical("\(String(describing: message))")
    }
    
    static func fault(_ message: Any) {
        shared.fault("\(String(describing: message))")
    }
}
