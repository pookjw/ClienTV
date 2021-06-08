//
//  CommentContentConfiguration.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/7/21.
//

import UIKit

struct CommentContentConfiguration: UIContentConfiguration {
    let commentData: CommentListCellItem.CommentData
    
    func makeContentView() -> UIView & UIContentView {
        let contentView: CommentContentView = .loadFromNib()
        contentView.update(self)
        return contentView
    }
    
    func updated(for state: UIConfigurationState) -> CommentContentConfiguration {
        return self
    }
}
