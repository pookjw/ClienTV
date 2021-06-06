//
//  String+HTML.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/6/21.
//

import Foundation

extension String {
    func convertToAttributedStringFromHTML() -> NSAttributedString? {
        var attributedText: NSAttributedString?
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [.documentType: NSAttributedString.DocumentType.html,
                                                                           .characterEncoding: String.Encoding.utf8.rawValue]
        if let data = data(using: .unicode, allowLossyConversion: true),
           let attrStr = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            attributedText = attrStr
            
        }
        
        return attributedText
    }
}
