//
//  GlobalDateFormatter.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/9/21.
//

import Foundation

public final class GlobalDateFormatter: DateFormatter {
    override public init() {
        super.init()
        setAttributes()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setAttributes() {
        timeZone = TimeZone(secondsFromGMT: 0)
        dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
}
