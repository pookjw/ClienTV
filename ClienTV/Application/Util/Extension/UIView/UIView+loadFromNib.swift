//
//  UIView+loadFromNib.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/4/21.
//

import UIKit

extension UIView {
    static func loadFromNib() -> Self {
        let loadedView: Self = Bundle.main.loadNibNamed(String(describing: Self.self), owner: nil, options: nil)?.first as! Self
        return loadedView
    }
}
