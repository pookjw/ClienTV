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
    
    public static func debug(_ message: Any) {
        shared.debug("\(String(describing: message))")
    }
    
    public static func trace(_ message: Any) {
        shared.trace("\(String(describing: message))")
    }
    
    public static func info(_ message: Any) {
        shared.info("\(String(describing: message))")
    }
    
    public static func log(_ message: Any) {
        shared.log("\(String(describing: message))")
    }
    
    public static func notice(_ message: Any) {
        shared.notice("\(String(describing: message))")
    }
    
    public static func error(_ message: Any) {
        shared.error("\(String(describing: message))")
    }
    
    public static func warning(_ message: Any) {
        shared.warning("\(String(describing: message))")
    }
    
    public static func critical(_ message: Any) {
        shared.critical("\(String(describing: message))")
    }
    
    public static func fault(_ message: Any) {
        shared.fault("\(String(describing: message))")
    }
}
