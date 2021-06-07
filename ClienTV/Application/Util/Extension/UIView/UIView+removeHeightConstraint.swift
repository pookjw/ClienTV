//
//  UIView+removeHeightConstraint.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/8/21.
//

import UIKit

extension UIView {
    func removeHeightConstraint() {
        constraints.forEach { constraint in
            if (constraint.firstAttribute == .height) || (constraint.secondAttribute == .height) {
                constraint.isActive = false
            }
        }
    }
}
