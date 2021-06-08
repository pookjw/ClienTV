//
//  CommentListViewController.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/6/21.
//

import UIKit
import Combine
import OSLog
import SnapKit

final class CommentListViewController: UIViewController {
    private weak var collectionView: UICollectionView!
    private var viewModel: CommentListViewModel!
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureViewModel()
    }

    func requestCommentList(boardPath: String, articlePath: String) {
        Logger.debug("CommentListViewController: \(boardPath)/\(articlePath)")
        let future: Future<Void, Error> = viewModel.requestCommentList(boardPath: boardPath, articlePath: articlePath)
        handleRequestCompletion(future)
    }
    
    private func configureCollectionView() {
        let collectionViewLayout: UICollectionViewCompositionalLayout = .init(sectionProvider: getSectionProvider())
        let collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: collectionViewLayout)
        self.collectionView = collectionView
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        collectionView.register(UICollectionViewListCell.self, forCellWithReuseIdentifier: UICollectionViewListCell.identifier)
        collectionView.register(UICollectionViewListCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: UICollectionViewListCell.identifier)
        collectionView.delegate = self
    }
    
    private func getSectionProvider() -> UICollectionViewCompositionalLayoutSectionProvider {
        return { (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            var configuration: UICollectionLayoutListConfiguration = .init(appearance: .grouped)
            
            configuration.headerMode = .supplementary
            
            return .list(using: configuration, layoutEnvironment: layoutEnvironment)
        }
    }
    
    private func makeDataSource() -> CommentListViewModel.DataSource {
        guard let collectionView: UICollectionView = collectionView else {
            fatalError("collectionView is not configured!")
        }
        
        let dataSource: CommentListViewModel.DataSource = .init(collectionView: collectionView) { (collectionView, indexPath, cellItem) -> UICollectionViewCell? in
//            guard let self = self else { return nil }
//            return collectionView.dequeueConfiguredReusableCell(using: self.getCellItemRegisteration(), for: indexPath, item: cellItem)
            
            guard let cell: UICollectionViewListCell = collectionView.dequeueReusableCell(withReuseIdentifier: UICollectionViewListCell.identifier, for: indexPath) as? UICollectionViewListCell else {
                return nil
            }
            
            switch cellItem.dataType {
            case .comment(let data):
                let configuration: CommentContentConfiguration = .init(commentData: data)
                
                if let contentView: CommentContentView = cell.contentView as? CommentContentView,
                   cell.contentConfiguration is CommentContentConfiguration {
                    
                    // Reuse
                    cell.contentConfiguration = configuration
                    contentView.update(configuration)
                    
                } else {
                    cell.contentConfiguration = configuration
                }
            }
            
            return cell
        }
        
        dataSource.supplementaryViewProvider = { [weak self] (collectionView, elementKind, indexPath) -> UICollectionReusableView? in
//            guard let self = self else {
//                return nil
//            }
//
//            switch elementKind {
//            case UICollectionView.elementKindSectionHeader:
//                return self.collectionView?.dequeueConfiguredReusableSupplementary(using: self.getHeaderCellRegisteration(), for: indexPath)
//            default:
//                return nil
//            }
            
            guard let headerView: UICollectionViewListCell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: UICollectionViewListCell.identifier, for: indexPath) as? UICollectionViewListCell else {
                return nil
            }
            
            guard let self = self,
                  let headerItem: CommentListHeaderItem = self.viewModel?.getHeaderItem(from: indexPath) else {
                return nil
            }
            
            switch headerItem.dataType {
            case .commentCount(let data):
                var configuration: UIListContentConfiguration = headerView.defaultContentConfiguration()
                configuration.text = data.title
                configuration.textProperties.font = .preferredFont(forTextStyle: .headline)
                headerView.contentConfiguration = configuration
            }
            
            return headerView
        }
        
        return dataSource
    }
    
//    private func getCellItemRegisteration() -> UICollectionView.CellRegistration<UICollectionViewListCell, CommentListCellItem> {
//        return .init { (cell, indexPath, cellItem) in
//            switch cellItem.dataType {
//            case .comment(let data):
//                let configuration: CommentConentConfiguration = .init(commentData: data)
//                cell.contentConfiguration = configuration
//            }
//        }
//    }
    
//    private func getHeaderCellRegisteration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
//        return .init(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] (headerView, elementKind, indexPath) in
//            
//            guard let self = self,
//                  let headerItem: CommentListHeaderItem = self.viewModel?.getHeaderItem(from: indexPath) else {
//                return
//            }
//            
//            switch headerItem.dataType {
//            case .commentCount(let data):
//                var configuration: UIListContentConfiguration = headerView.defaultContentConfiguration()
//                configuration.text = data.title
//                configuration.textProperties.font = .preferredFont(forTextStyle: .headline)
//                headerView.contentConfiguration = configuration
//            }
//        }
//    }
    
    private func configureViewModel() {
        let viewModel: CommentListViewModel = .init(dataSource: makeDataSource())
        self.viewModel = viewModel
    }
    
    private func handleRequestCompletion(_ future: Future<Void, Error>) {
        future
            .receive(on: OperationQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.showErrorAlert(error)
                case .finished:
                    break
                }
            } receiveValue: {}
            .store(in: &cancellableBag)
    }
}

// MARK: - UICollectionViewDelegate

extension CommentListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
}
