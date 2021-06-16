//
//  CommentContentConfiguration.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/7/21.
//

import UIKit

struct CommentContentConfiguration: UIContentConfiguration {
    let commentData: CommentListCellItem.CommentData
    private weak var contentView: CommentContentView!
    
    init(commentData: CommentListCellItem.CommentData,
         contentView: CommentContentView?) {
        self.commentData = commentData
        self.contentView = contentView
    }
    
    func makeContentView() -> UIView & UIContentView {
        contentView.update(for: self)
        return contentView
    }
    
    func updated(for state: UIConfigurationState) -> CommentContentConfiguration {
        contentView?.update(for: state)
        contentView?.update(for: self)
        return self
    }
}
