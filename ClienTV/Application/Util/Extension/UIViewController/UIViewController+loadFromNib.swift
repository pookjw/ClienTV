//
//  UIViewController+loadFromNib.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/6/21.
//

import UIKit

extension UIViewController {
    static func loadFromNib() -> Self {
        return Self.init(nibName: String(describing: Self.self), bundle: nil)
    }
}
