//
//  String+HTML.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/6/21.
//

import UIKit

extension String {
    func convertToAttributedStringFromHTML() -> NSAttributedString? {
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [.documentType: NSAttributedString.DocumentType.html,
                                                                           .characterEncoding: String.Encoding.utf8.rawValue]
        
        guard let data = data(using: .utf8),
              let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return nil
        }
        
        return attributedString
    }
    
    func convertToAttributedStringFromHTMLWithClear() -> NSAttributedString? {
        guard let attributedString: NSMutableAttributedString = convertToAttributedStringFromHTML()?
                .mutableCopy() as? NSMutableAttributedString
        else {
            return nil
        }
        
        let totalRange: NSRange = NSMakeRange(0, attributedString.length)
        attributedString.removeAttribute(NSAttributedString.Key.foregroundColor, range: totalRange)
        attributedString.removeAttribute(NSAttributedString.Key.font, range: totalRange)
        attributedString.addAttributes([NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)], range: totalRange)
        
        return attributedString.copy() as? NSAttributedString
    }
}
