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
    private weak var gradientLayer: CAGradientLayer!
    private var viewModel: BoardListViewModel!
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureViewModel()
        configureGradientLayer()
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestBoardListIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateGradientLayer()
    }
    
    private func configureCollectionView() {
        let collectionViewLayout: UICollectionViewCompositionalLayout = .init(sectionProvider: getSectionProvider())
        let collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: collectionViewLayout)
        self.collectionView = collectionView
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        collectionView.contentInset = .init(top: 20, left: 0, bottom: 0, right: 100)
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
    
    private func getDataSource() -> BoardListViewModel.DataSource {
        guard let collectionView: UICollectionView = collectionView else {
            fatalError("collectionView is not configured!")
        }
        
        let dataSource: BoardListViewModel.DataSource = .init(collectionView: collectionView, cellProvider: getCellProvider())
        
        dataSource.supplementaryViewProvider = getSupplementaryViewProvider()
        
        return dataSource
    }
    
    private func getCellProvider() -> BoardListViewModel.DataSource.CellProvider {
        return { [weak self] (collectionView, indexPath, cellItem) -> UICollectionViewCell? in
            guard let self = self else { return nil }
            
            guard let cell: UICollectionViewListCell = collectionView.dequeueReusableCell(withReuseIdentifier: UICollectionViewListCell.identifier, for: indexPath) as? UICollectionViewListCell else {
                return nil
            }
            
            var configuration: UIListContentConfiguration = cell.defaultContentConfiguration()
            
            switch cellItem.dataType {
            case .board(let data):
                configuration.text = data.name
                configuration.secondaryText = self.viewModel.boardPathVisibilityStatus ? data.path : nil
            }
            
            cell.contentConfiguration = configuration
            
            return cell
        }
    }
    
    private func getSupplementaryViewProvider() -> BoardListViewModel.DataSource.SupplementaryViewProvider {
        return { [weak self] (collectionView, elementKind, indexPath) -> UICollectionReusableView? in
            guard let self = self else { return nil }
            
            guard let headerView: UICollectionViewListCell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: UICollectionViewListCell.identifier, for: indexPath) as? UICollectionViewListCell else {
                return nil
            }
            
            guard let headerItem: BoardListHeaderItem = self.viewModel?.getHeaderItem(from: indexPath) else {
                return nil
            }
            
            switch headerItem.dataType {
            case .category(let data):
                var configuration: UIListContentConfiguration = headerView.defaultContentConfiguration()
                configuration.text = data.title
                headerView.contentConfiguration = configuration
            }
            
            return headerView
        }
    }
    
    private func configureViewModel() {
        let viewModel: BoardListViewModel = .init(dataSource: getDataSource())
        self.viewModel = viewModel
    }
    
    private func configureGradientLayer() {
        let gradientLayer: CAGradientLayer = .init()
        self.gradientLayer = gradientLayer
        gradientLayer.colors = [
            UIColor.white.withAlphaComponent(0).cgColor,
            UIColor.white.cgColor
        ]
        gradientLayer.startPoint = .init(x: 0.0, y: 0.0)
        gradientLayer.endPoint = .init(x: 0.0, y: 0.015)
        view.layer.mask = gradientLayer
    }
    
    private func updateGradientLayer() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer?.frame = view.bounds
        CATransaction.commit()
    }
    
    private func requestBoardListIfNeeded() {
        viewModel?.requestBoardListIfNeeded()
            .receive(on: OperationQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    Logger.error(error.localizedDescription)
                    self?.showErrorAlert(error) { _ in
                        self?.requestBoardListIfNeeded()
                    }
                case .finished:
                    break
                }
            }, receiveValue: {})
            .store(in: &cancellableBag)
    }
    
    private func bind() {
        viewModel
            .shouldReloadCollectionViewData
            .receive(on: OperationQueue.main)
            .sink { [weak self] _ in
                self?.collectionView?.reloadData()
            }
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
