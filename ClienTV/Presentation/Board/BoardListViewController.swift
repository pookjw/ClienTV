//
//  BoardListViewController.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/3/21.
//

import UIKit
import Combine
import OSLog
import SnapKit

protocol BoardListViewControllerDelegate: AnyObject {
    func boardListViewControllerDidTapCell(_ viewController: BoardListViewController, boardPath: String)
}

final class BoardListViewController: UIViewController {
    weak var delegate: BoardListViewControllerDelegate? = nil
    private weak var collectionView: UICollectionView!
    private var viewModel: BoardListViewModel!
    private var cancellableBag: Set<AnyCancellable> = .init()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureViewModel()
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestBoardListIfNeeded()
    }
    
    private func configureCollectionView() {
        let collectionViewLayout: UICollectionViewCompositionalLayout = .init(sectionProvider: getSectionProvider())
        let collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: collectionViewLayout)
        self.collectionView = collectionView
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        collectionView.contentInset = .init(top: 0, left: 0, bottom: 0, right: 100)
        collectionView.delegate = self
    }
    
    private func getSectionProvider() -> UICollectionViewCompositionalLayoutSectionProvider {
        return { (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            var configuration: UICollectionLayoutListConfiguration = .init(appearance: .grouped)
            configuration.headerMode = .supplementary
            return .list(using: configuration, layoutEnvironment: layoutEnvironment)
        }
    }
    
    private func makeDataSource() -> BoardListViewModel.DataSource {
        guard let collectionView: UICollectionView = collectionView else {
            fatalError("collectionView is not configured!")
        }
        
        let dataSource: BoardListViewModel.DataSource = .init(collectionView: collectionView) { [weak self] (collectionView, indexPath, cellItem) -> UICollectionViewCell? in
            guard let self = self else { return nil }
            return collectionView.dequeueConfiguredReusableCell(using: self.getCellItemRegisteration(), for: indexPath, item: cellItem)
        }
        
        dataSource.supplementaryViewProvider = { [weak self] (collectionView, elementKind, indexPath) -> UICollectionReusableView? in
            guard let self = self else { return nil }
            
            switch elementKind {
            case UICollectionView.elementKindSectionHeader:
                return self.collectionView?.dequeueConfiguredReusableSupplementary(using: self.getHeaderItemRegisteration(), for: indexPath)
            default:
                return nil
            }
        }
        
        return dataSource
    }
    
    private func getCellItemRegisteration() -> UICollectionView.CellRegistration<UICollectionViewListCell, BoardListCellItem> {
        return .init { (cell, indexPath, cellItem) in
            var configuration: UIListContentConfiguration = cell.defaultContentConfiguration()
            
            switch cellItem.dataType {
            case .board(let data):
                configuration.text = data.name
//                configuration.secondaryText = data.path
            }
            
            cell.contentConfiguration = configuration
        }
    }
    
    private func getHeaderItemRegisteration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return .init(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] (headerView, elementKind, indexPath) in
            
            guard let headerItem: BoardListHeaderItem = self?.viewModel?.getHeaderItem(from: indexPath) else {
                return
            }
            
            var configuration: UIListContentConfiguration = headerView.defaultContentConfiguration()
            
            switch headerItem.dataType {
            case .category(let data):
                configuration.text = data.title
            }
            
            headerView.contentConfiguration = configuration
        }
    }
    
    private func configureViewModel() {
        let viewModel: BoardListViewModel = .init(dataSource: makeDataSource())
        self.viewModel = viewModel
    }
    
    private func bind() {
        
    }
    
    private func requestBoardListIfNeeded() {
        viewModel?.requestBoardListIfNeeded()
            .receive(on: OperationQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.showErrorAlert(error)
                case .finished:
                    break
                }
            }, receiveValue: {})
            .store(in: &cancellableBag)
    }
}

// MARK: - UICollectionViewDelegate

extension BoardListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cellItem: BoardListCellItem = viewModel.getCellItem(from: indexPath) else {
            Logger.error("cellItem is nil")
            return
        }
        
        switch cellItem.dataType {
        case .board(let data):
            let boardPath: String = data.path
            delegate?.boardListViewControllerDidTapCell(self, boardPath: boardPath)
        }
    }
}
