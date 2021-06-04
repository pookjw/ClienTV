//
//  ArticleBaseContentConfiguration.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/4/21.
//

import UIKit
import SnapKit
import Kingfisher

struct ArticleBaseContentConfiguration: UIContentConfiguration {
    let articleBaseData: ArticleBaseListCellItem.ArticleBaseData
    
    func makeContentView() -> UIView & UIContentView {
        return _ArticleBaseContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> ArticleBaseContentConfiguration {
        return self
    }
}

fileprivate final class _ArticleBaseContentView: UIView, UIContentView {
    var configuration: UIContentConfiguration
    
    init(configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
