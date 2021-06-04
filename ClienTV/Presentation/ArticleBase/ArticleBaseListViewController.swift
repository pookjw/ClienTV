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
        collectionView?.scrollToTop(animated: true)
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
            var configuration: UICollectionLayoutListConfiguration = .init(appearance: .grouped)
            
            configuration.headerMode = .supplementary
            
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
        
        dataSource.supplementaryViewProvider = { [weak self] (collectionView, elementKind, indexPath) -> UICollectionReusableView? in
            guard let self = self else {
                return nil
            }
            
            switch elementKind {
            case UICollectionView.elementKindSectionHeader:
                return self.collectionView?.dequeueConfiguredReusableSupplementary(using: self.getHeaderCellRegisteration(), for: indexPath)
            default:
                return nil
            }
        }
        
        return dataSource
    }
    
    private func getCellItemRegisteration() -> UICollectionView.CellRegistration<UICollectionViewListCell, ArticleBaseListCellItem> {
        return .init { (cell, indexPath, cellItem) in
            switch cellItem.dataType {
            case let .articleBase(data):
                let configuration: ArticleBaseContentConfiguration = .init(articleBaseData: data)
                cell.contentConfiguration = configuration
            case .loadMore:
                var configuration: UIListContentConfiguration = cell.defaultContentConfiguration()
                configuration.text = "더 불러오기..."
                configuration.textProperties.alignment = .center
                configuration.textProperties.font = .preferredFont(forTextStyle: .body)
                cell.contentConfiguration = configuration
            }
        }
    }
    
    private func getHeaderCellRegisteration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return .init(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] (headerView, elementKind, indexPath) in
            
            guard let self = self,
                let headerItem: ArticleBaseListHeaderItem = self.viewModel?.getHeaderItem(from: indexPath) else {
                return
            }
            
            switch headerItem.dataType {
            case .articleBaseList:
                headerView.frame = .zero
                return
            }
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
        
        viewModel
            .updateCompletionEvent
            .receive(on: OperationQueue.main)
            .sink(receiveValue: { [weak self] reset in
                guard let self = self else { return }
                guard !self.viewModel.isItemEmpty else { return }
                
                if reset {
                    self.collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                } else {
                    if let cacheIndexPath: IndexPath = self.viewModel.cacheIndexPath {
                        self.collectionView?.scrollToItem(at: cacheIndexPath, at: .top, animated: false)
                    }
                }
        
                self.collectionView?.reloadData()
            })
            .store(in: &cancellableBag)
    }
    
    private func requestNextArticleBaseList(from indexPath: IndexPath) {
        viewModel.cacheIndexPath = indexPath
        viewModel.requestNextArticleBaseList()
    }
}

// MARK: - UICollectionViewDelegate

extension ArticleBaseListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cellItem: ArticleBaseListCellItem = viewModel?.getCellItem(from: indexPath) else {
            Logger.error("cellItem is nil")
            return
        }
        
        switch cellItem.dataType {
        case let .articleBase(data):
            break
        case .loadMore:
            requestNextArticleBaseList(from: indexPath)
        }
    }
}
