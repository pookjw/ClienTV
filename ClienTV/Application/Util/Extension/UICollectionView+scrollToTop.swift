//
//  UICollectionView+scrollToTop.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/4/21.
//

import UIKit

extension UICollectionView {
    func scrollToTop(animated: Bool) {
        scrollRectToVisible(.zero, animated: animated)
    }
}
