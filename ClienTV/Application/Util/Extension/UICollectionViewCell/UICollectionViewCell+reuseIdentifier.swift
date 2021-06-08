//
//  UICollectionViewCell+reuseIdentifier.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/8/21.
//

import UIKit

extension UICollectionViewCell {
    static var identifier: String {
        return String(describing: self)
    }
}
