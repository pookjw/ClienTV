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
        contentView.update(for: self)
        return contentView
    }
    
    func updated(for state: UIConfigurationState) -> ArticleBaseContentConfiguration {
        contentView?.update(for: state)
        contentView?.update(for: self)
        return self
    }
}

