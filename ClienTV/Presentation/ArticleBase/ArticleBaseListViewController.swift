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
    private weak var gradientLayer: CAGradientLayer!
    private var viewModel: ArticleBaseListViewModel!
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureViewModel()
        configureGradientLayer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateGradientLayer()
    }
    
    func requestArticleBaseList(with boardPath: String) {
        Logger.debug("ArticleBaseListViewController: \(boardPath)")
        let future: Future<Bool, Error> = viewModel.requestFirstArticleBaseList(boardPath: boardPath)
        handleRequestCompletion(future)
    }
    
    private func configureCollectionView() {
        let collectionViewLayout: UICollectionViewCompositionalLayout = .init(sectionProvider: getSectionProvider())
        let collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: collectionViewLayout)
        self.collectionView = collectionView
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        collectionView.contentInset = .init(top: 20, left: 100, bottom: 0, right: 0)
        collectionView.register(UICollectionViewListCell.self, forCellWithReuseIdentifier: UICollectionViewListCell.identifier)
        collectionView.register(UICollectionViewListCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: UICollectionViewListCell.identifier)
        collectionView.delegate = self
    }
    
    private func getSectionProvider() -> UICollectionViewCompositionalLayoutSectionProvider {
        return { (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let configuration: UICollectionLayoutListConfiguration = .init(appearance: .grouped)
            
            return .list(using: configuration, layoutEnvironment: layoutEnvironment)
        }
    }
    
    private func getDataSource() -> ArticleBaseListViewModel.DataSource {
        guard let collectionView: UICollectionView = collectionView else {
            fatalError("collectionView is not configured!")
        }
        
        let dataSource: ArticleBaseListViewModel.DataSource = .init(collectionView: collectionView, cellProvider: getCellProvider())
        
        return dataSource
    }
    
    private func getCellProvider() -> ArticleBaseListViewModel.DataSource.CellProvider {
        return { (collectionView, indexPath, cellItem) -> UICollectionViewCell? in
            
            guard let cell: UICollectionViewListCell = collectionView.dequeueReusableCell(withReuseIdentifier: UICollectionViewListCell.identifier, for: indexPath) as? UICollectionViewListCell else {
                return nil
            }
            
            switch cellItem.dataType {
            case .articleBase(let data):
                
                if let contentView: ArticleBaseContentView = cell.contentView as? ArticleBaseContentView,
                   cell.contentConfiguration is ArticleBaseContentConfiguration {
                    
                    let configuration: ArticleBaseContentConfiguration = .init(articleBaseData: data, contentView: contentView)
                    // Reuse
                    cell.contentConfiguration = configuration
                } else {
                    let configuration: ArticleBaseContentConfiguration = .init(articleBaseData: data, contentView: .loadFromNib())
                    cell.contentConfiguration = configuration
                }
            case .loadMore:
                var configuration: UIListContentConfiguration = cell.defaultContentConfiguration()
                configuration.text = "더 불러오기..."
                configuration.textProperties.alignment = .center
                configuration.textProperties.font = .preferredFont(forTextStyle: .body)
                cell.contentConfiguration = configuration
            }
            
            return cell
        }
    }
    
    private func configureViewModel() {
        let viewModel: ArticleBaseListViewModel = .init(dataSource: getDataSource())
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
    
    private func presentArticleViewController(articlePath: String) {
        guard let boardPath: String = viewModel.boardPath else {
            Logger.error("viewModel.boardPath이 존재하지 않음!")
            return
        }
        
        let articleViewController: ArticleViewController = .loadFromNib()
        articleViewController.loadViewIfNeeded()
        articleViewController.requestArticle(boardPath: boardPath, articlePath: articlePath)
        present(articleViewController, animated: true, completion: nil)
    }
    
    private func requestNextArticleBaseList(from indexPath: IndexPath) {
        viewModel.cacheIndexPath = indexPath
        let future: Future<Bool, Error> = viewModel.requestNextArticleBaseList()
        handleRequestCompletion(future)
    }
    
    private func handleRequestCompletion(_ future: Future<Bool, Error>) {
        future
            .receive(on: OperationQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.showErrorAlert(error)
                case .finished:
                    break
                }
            } receiveValue: { [weak self] reset in
                guard let self = self else { return }
                
                if reset {
                    self.collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                } else {
                    if let cacheIndexPath: IndexPath = self.viewModel.cacheIndexPath {
                        self.collectionView?.scrollToItem(at: cacheIndexPath, at: .top, animated: false)
                    }
                }
                
                self.collectionView?.collectionViewLayout.invalidateLayout()
            }
            .store(in: &cancellableBag)
    }
}

// MARK: - UICollectionViewDelegate

extension ArticleBaseListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let cellItem: ArticleBaseListCellItem = viewModel?.getCellItem(from: indexPath) else {
            Logger.error("cellItem is nil")
            return
        }
        
        switch cellItem.dataType {
        case let .articleBase(data):
            Logger.info(data.path)
            presentArticleViewController(articlePath: data.path)
        case .loadMore:
            requestNextArticleBaseList(from: indexPath)
        }
    }
}
