//
//  ArticleBaseContentConfiguration.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/4/21.
//

import UIKit

struct ArticleBaseContentConfiguration: UIContentConfiguration {
    let articleBaseData: ArticleBaseListCellItem.ArticleBaseData
    private weak var contentView: ArticleBaseContentView!
    
    init(articleBaseData: ArticleBaseListCellItem.ArticleBaseData,
         contentView: ArticleBaseContentView) {
        self.articleBaseData = articleBaseData
        self.contentView = contentView
    }
    
    func makeContentView() -> UIView & UIContentView {
        contentView.update(articleBaseContentConfiguration: self)
        return contentView
    }
    
    func updated(for state: UIConfigurationState) -> ArticleBaseContentConfiguration {
        if let state: UICellConfigurationState = state as? UICellConfigurationState {
            contentView?.update(isFocused: state.isFocused)
        }
        contentView?.update(articleBaseContentConfiguration: self)
        return self
    }
}

