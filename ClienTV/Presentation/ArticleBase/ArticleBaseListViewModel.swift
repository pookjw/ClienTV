//
//  ArticleBaseListViewModel.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/4/21.
//

import UIKit
import Combine
import ClienTVAPI

final class ArticleBaseListViewModel {
    typealias DataSource = UICollectionViewDiffableDataSource<ArticleBaseListHeaderItem, ArticleBaseListCellItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<ArticleBaseListHeaderItem, ArticleBaseListCellItem>
    
    private let dataSource: DataSource
    private let useCase: ArticleBaseListUseCase
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    init(dataSource: DataSource,
        useCase: ArticleBaseListUseCase = ArticleBaseListUseCaseImpl()) {
        self.dataSource = dataSource
        self.useCase = useCase
    }
    
    func requestArticleBaseList() {
        
    }
}
