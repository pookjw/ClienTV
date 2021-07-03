//
//  ImageArticleBaseListViewModel.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/10/21.
//

import UIKit
import Combine
import ClienTVAPI

final class ImageArticleBaseListViewModel {
    typealias DataSource = UICollectionViewDiffableDataSource<ImageArticleBaseListHeaderItem, ImageArticleBaseListCellItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<ImageArticleBaseListHeaderItem, ImageArticleBaseListCellItem>

    private let dataSource: DataSource
    private let imageArticleBaseListUseCase: ImageArticleBaseListUseCase = ImageArticleBaseListUseCaseImpl()
    private var currentBoardPage: Int = 0
    private let queue: OperationQueue = .init()
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    init(dataSource: DataSource) {
        self.dataSource = dataSource
        configureQueue()
    }
    
    func getCellItem(from indexPath: IndexPath) -> ImageArticleBaseListCellItem? {
        let snapshot: Snapshot = dataSource.snapshot()
        return snapshot.getCellItem(from: indexPath)
    }
    
    func requestFirstImageArticleBaseList() -> Future<Bool, Error> {
        currentBoardPage = 0
        return requestImageArticleBaseList(shouldResetSnapshot: true)
    }
    
    func requestNextImageArticleBaseList() -> Future<Bool, Error> {
        currentBoardPage += 1
        return requestImageArticleBaseList(shouldResetSnapshot: false)
    }
    
    private func requestImageArticleBaseList(shouldResetSnapshot: Bool) -> Future<Bool, Error> {
        return .init { [weak self] promise in
            self?.configurePromise(promise, shouldResetSnapshot: shouldResetSnapshot)
        }
    }
    
    private func configurePromise(_ promise: @escaping ((Result<Bool, Error>) -> Void),
                                  shouldResetSnapshot: Bool) {
        imageArticleBaseListUseCase
            .getImageArticleBaseList(page: currentBoardPage)
            .receive(on: queue)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    promise(.failure(error))
                case .finished:
                    break
                }
            } receiveValue: { [weak self] imageArticleBaseList in
                self?.updateImageArticleBaseList(imageArticleBaseList, reset: shouldResetSnapshot)
                promise(.success(shouldResetSnapshot))
            }
            .store(in: &cancellableBag)
    }
    
    private func updateImageArticleBaseList(_ imageArticleBaseList: [ImageArticleBase], reset: Bool) {
        var snapshot: Snapshot = dataSource.snapshot()
        
        if reset {
            snapshot.deleteAllItems()
        }
        
        let headerItem: ImageArticleBaseListHeaderItem = {
            if let headerItem: ImageArticleBaseListHeaderItem = snapshot
                .sectionIdentifiers
                .first(where: {$0.dataType == .imageArticleBaseList })
            {
                return headerItem
            } else {
                let headerItem: ImageArticleBaseListHeaderItem = .init(dataType: .imageArticleBaseList)
                snapshot.appendSections([headerItem])
                return headerItem
            }
        }()
        
        let oldCellItems: [ImageArticleBaseListCellItem] = snapshot.itemIdentifiers(inSection: headerItem)
        let newCellItems: [ImageArticleBaseListCellItem] = createCellItems(from: imageArticleBaseList, oldCellItems: oldCellItems)
        let loadMoreCellItem: ImageArticleBaseListCellItem = .init(dataType: .loadMore)
        
        snapshot.appendItems(newCellItems, toSection: headerItem)
        snapshot.deleteItems([loadMoreCellItem])
        snapshot.appendItems([loadMoreCellItem], toSection: headerItem)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func configureQueue() {
        queue.qualityOfService = .userInteractive
    }
    
    // MARK: - Helper
    private func createCellItems(from imageArticleBaseList: [ImageArticleBase], oldCellItems: [ImageArticleBaseListCellItem]) -> [ImageArticleBaseListCellItem] {
        let cellItems: [ImageArticleBaseListCellItem] = imageArticleBaseList
            .compactMap { imageArticleBase -> ImageArticleBaseListCellItem? in
                let imageArticleBaseData: ImageArticleBaseListCellItem.ImageArticleBaseData = .init(previewImageURL: imageArticleBase.previewImageURL,
                                                                                                    category: imageArticleBase.category,
                                                                                                    title: imageArticleBase.title,
                                                                                                    previewBody: imageArticleBase.previewBody,
                                                                                                    timestamp: imageArticleBase.timestamp,
                                                                                                    likeCount: imageArticleBase.likeCount,
                                                                                                    commentCount: imageArticleBase.commentCount,
                                                                                                    nickname: imageArticleBase.nickname,
                                                                                                    nicknameImageURL: imageArticleBase.nicknameImageURL,
                                                                                                    path: imageArticleBase.path)
                let cellItem: ImageArticleBaseListCellItem = .init(dataType: .imageArticleBase(data: imageArticleBaseData))
                
                // 중복 제거
                guard !oldCellItems.contains(cellItem) else {
                    return nil
                }
                
                return cellItem
            }
        
        return cellItems
    }
}
