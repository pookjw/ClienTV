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
    private weak var collectionView: UICollectionView!
    private var viewModel: ImageArticleBaseListViewModel!
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureViewModel()
    }
    
    func requestImageArticleBaseList() {
        let future: Future<Bool, Error> = viewModel.requestFirstImageArticleBaseList()
        handleRequestCompletion(future)
    }
    
    private func configureCollectionView() {
        let collectionViewLayout: TVCollectionViewFullScreenLayout = .init()
        let collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: collectionViewLayout)
        self.collectionView = collectionView
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        let imageArticleBaseCellNib: UINib = .init(nibName: ImageArticleBaseTVCollectionViewFullScreenCell.identifier, bundle: nil)
        collectionView.register(imageArticleBaseCellNib, forCellWithReuseIdentifier: ImageArticleBaseTVCollectionViewFullScreenCell.identifier)
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
                guard let cell: ImageArticleBaseTVCollectionViewFullScreenCell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageArticleBaseTVCollectionViewFullScreenCell.identifier, for: indexPath) as? ImageArticleBaseTVCollectionViewFullScreenCell else {
                    return nil
                }
                
                cell.titleLabel.text = data.title
                
                return cell
            case .loadMore:
                return nil
            }
        }
    }
    
    private func configureViewModel() {
        let viewModel: ImageArticleBaseListViewModel = .init(dataSource: makeDataSource())
        self.viewModel = viewModel
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

// MARK: - TVCollectionViewDelegateFullScreenLayout

extension ImageArticleBaseListViewController: TVCollectionViewDelegateFullScreenLayout {
    
}
