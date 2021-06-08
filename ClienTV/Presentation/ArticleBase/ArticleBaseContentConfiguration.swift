//
//  ArticleBaseContentConfiguration.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/4/21.
//

import UIKit

struct ArticleBaseContentConfiguration: UIContentConfiguration {
    let articleBaseData: ArticleBaseListCellItem.ArticleBaseData
    
    func makeContentView() -> UIView & UIContentView {
        let contentView: ArticleBaseContentView = .loadFromNib()
        contentView.update(self)
        return contentView
    }
    
    func updated(for state: UIConfigurationState) -> ArticleBaseContentConfiguration {
        return self
    }
}

