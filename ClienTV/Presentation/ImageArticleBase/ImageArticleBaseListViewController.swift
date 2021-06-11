//
//  ImageArticleBaseListViewController.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/10/21.
//

import TVUIKit
import Combine
import OSLog
import SnapKit

final class ImageArticleBaseListViewController: UIViewController {
    private struct Const {
        static let imageBoardPath: String = "/service/board/image"
    }
    
    private weak var collectionView: UICollectionView!
    private weak var gradientLayer: CAGradientLayer!
    private var viewModel: ImageArticleBaseListViewModel!
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        updateGradientLayer()
    }
    
    func requestImageArticleBaseList() {
        let future: Future<Bool, Error> = viewModel.requestFirstImageArticleBaseList()
        handleRequestCompletion(future)
    }
    
    private func configureCollectionView() {
        let collectionViewLayout: TVCollectionViewFullScreenLayout = .init()
        let collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: collectionViewLayout)
        self.collectionView = collectionView
        
        collectionViewLayout.interitemSpacing = 50
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        collectionView.register(ImageArticleBaseCollectoinViewCell.self, forCellWithReuseIdentifier: ImageArticleBaseCollectoinViewCell.identifier)
        collectionView.register(ImageArticleBaseLoadMoreCollectoinViewCell.self, forCellWithReuseIdentifier: ImageArticleBaseLoadMoreCollectoinViewCell.identifier)
        collectionView.delegate = self
    }
    
    private func makeDataSource() -> ImageArticleBaseListViewModel.DataSource {
        guard let collectionView: UICollectionView = collectionView else {
            fatalError("collectionView is not configured!")
        }
        
        let dataSource: ImageArticleBaseListViewModel.DataSource = .init(collectionView: collectionView, cellProvider: getCellProvider())
        
        return dataSource
    }
    
    private func getCellProvider() -> ImageArticleBaseListViewModel.DataSource.CellProvider {
        return { (collectionView, indexPath, cellItem) -> UICollectionViewCell? in
            
            switch cellItem.dataType {
            case .imageArticleBase(let data):
                guard let cell: ImageArticleBaseCollectoinViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageArticleBaseCollectoinViewCell.identifier, for: indexPath) as? ImageArticleBaseCollectoinViewCell else {
                    return nil
                }
                
                cell.configure(data)
                
                return cell
            case .loadMore:
                guard let cell: ImageArticleBaseLoadMoreCollectoinViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageArticleBaseLoadMoreCollectoinViewCell.identifier, for: indexPath) as? ImageArticleBaseLoadMoreCollectoinViewCell else {
                    return nil
                }
                
                return cell
            }
        }
    }
    
    private func configureViewModel() {
        let viewModel: ImageArticleBaseListViewModel = .init(dataSource: makeDataSource())
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
        gradientLayer.endPoint = .init(x: 0.015, y: 0.0)
        view.layer.mask = gradientLayer
    }
    
    private func updateGradientLayer() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer?.frame = view.bounds
        CATransaction.commit()
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
                    self.collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: false)
                }
            }
            .store(in: &cancellableBag)
    }
    
    private func presentArticleViewController(articlePath: String) {
        let articleViewController: ArticleViewController = .loadFromNib()
        articleViewController.loadViewIfNeeded()
        articleViewController.requestArticle(boardPath: Const.imageBoardPath, articlePath: articlePath)
        present(articleViewController, animated: true, completion: nil)
    }
    
    private func requestNextImageArticleBaseList() {
        let future: Future<Bool, Error> = viewModel.requestNextImageArticleBaseList()
        handleRequestCompletion(future)
    }
}

// MARK: - TVCollectionViewDelegateFullScreenLayout

extension ImageArticleBaseListViewController: TVCollectionViewDelegateFullScreenLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let cellItem: ImageArticleBaseListCellItem = viewModel?.getCellItem(from: indexPath) else {
            Logger.error("cellItem is nil")
            return
        }
        
        switch cellItem.dataType {
        case let .imageArticleBase(data):
            Logger.info(data.path)
            presentArticleViewController(articlePath: data.path)
        case .loadMore:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let cellItem: ImageArticleBaseListCellItem = viewModel?.getCellItem(from: indexPath) else {
            Logger.error("cellItem is nil")
            return
        }
        
        switch cellItem.dataType {
        case .loadMore:
            requestNextImageArticleBaseList()
        default:
            break
        }
    }
}
