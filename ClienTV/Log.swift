//
//  Log.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/2/21.
//

import Foundation
import SwiftyBeaver

final class Log: SwiftyBeaver {
    private static let console: ConsoleDestination = .init()
    
    static func configureIfNeeded() {
        guard !destinations.contains(console) else {
            return
        }
        
        console.levelString.verbose = "💜 VERBOSE"
        console.levelString.debug = "💚 DEBUG"
        console.levelString.info = "💙 INFO"
        console.levelString.warning = "💛 WARNING"
        console.levelString.error = "❤️ ERROR"
        
        addDestination(console)
    }
}
