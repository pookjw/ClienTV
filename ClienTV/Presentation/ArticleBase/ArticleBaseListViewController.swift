//
//  ArticleBaseListViewController.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/3/21.
//

import UIKit
import Combine
import OSLog
import SnapKit

final class ArticleBaseListViewController: UIViewController {
    private weak var collectionView: UICollectionView!
    private var viewModel: ArticleBaseListViewModel!
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureViewModel()
        bind()
    }
    
    func requestArticleBaseList(with boardPath: String) {
        Logger.debug("ArticleBaseListViewController: \(boardPath)")
        viewModel?.requestFirstArticleBaseList(boardPath: boardPath)
    }
    
    private func configureCollectionView() {
        let collectionViewLayout: UICollectionViewCompositionalLayout = .init(sectionProvider: getSectionProvider())
        let collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: collectionViewLayout)
        self.collectionView = collectionView
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        collectionView.delegate = self
    }
    
    private func getSectionProvider() -> UICollectionViewCompositionalLayoutSectionProvider {
        return { (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let configuration: UICollectionLayoutListConfiguration = .init(appearance: .grouped)
            return .list(using: configuration, layoutEnvironment: layoutEnvironment)
        }
    }
    
    private func makeDataSource() -> ArticleBaseListViewModel.DataSource {
        guard let collectionView: UICollectionView = collectionView else {
            fatalError("collectionView is not configured!")
        }
        
        let dataSource: ArticleBaseListViewModel.DataSource = .init(collectionView: collectionView) { [weak self] (collectionView, indexPath, cellItem) -> UICollectionViewCell? in
            guard let self = self else { return nil }
            return collectionView.dequeueConfiguredReusableCell(using: self.getCellItemRegisteration(), for: indexPath, item: cellItem)
        }
        
        return dataSource
    }
    
    private func getCellItemRegisteration() -> UICollectionView.CellRegistration<UICollectionViewListCell, ArticleBaseListCellItem> {
        return .init { (cell, indexPath, cellItem) in
            var configuration: UIListContentConfiguration = cell.defaultContentConfiguration()
            
            switch cellItem.dataType {
            case let .articleBase(data):
                configuration.text = data.title
            }
            
            cell.contentConfiguration = configuration
        }
    }
    
    private func configureViewModel() {
        let viewModel: ArticleBaseListViewModel = .init(dataSource: makeDataSource())
        self.viewModel = viewModel
    }
    
    private func bind() {
        viewModel
            .errorEvent
            .receive(on: OperationQueue.main)
            .sink { [weak self] error in
                self?.showErrorAlert(error)
            }
            .store(in: &cancellableBag)
    }
}

// MARK: - UICollectionViewDelegate

extension ArticleBaseListViewController: UICollectionViewDelegate {
    
}
