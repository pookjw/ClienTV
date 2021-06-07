//
//  CommentConentConfiguration.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/7/21.
//

import UIKit
import SnapKit

struct CommentConentConfiguration: UIContentConfiguration {
    let commentData: CommentListCellItem.CommentData
    
    func makeContentView() -> UIView & UIContentView {
        let contentView: CommentContentView = .initFromConfiguration(self)
        return contentView
    }
    
    func updated(for state: UIConfigurationState) -> CommentConentConfiguration {
        return self
    }
}
