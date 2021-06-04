//
//  ProcessInfo+isTestMode.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/5/21.
//

import Foundation

extension ProcessInfo {
    var isTestMode: Bool {
        return arguments.contains("enable-testing")
    }
}
