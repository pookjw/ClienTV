//
//  ArticleBaseListViewModel.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/4/21.
//

import UIKit
import Combine
import OSLog
import ClienTVAPI

final class ArticleBaseListViewModel {
    typealias DataSource = UICollectionViewDiffableDataSource<ArticleBaseListHeaderItem, ArticleBaseListCellItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<ArticleBaseListHeaderItem, ArticleBaseListCellItem>
    
    let errorEvent: PassthroughSubject<Error, Never> = .init()
    let updateCompletionEvent: PassthroughSubject<Bool, Never> = .init()
    var cacheIndexPath: IndexPath? = nil
    var isItemEmpty: Bool {
        let snapshot: Snapshot = dataSource.snapshot()
        let isItemEmpty: Bool = snapshot.numberOfItems == 0
        return isItemEmpty
    }
    private let dataSource: DataSource
    private let useCase: ArticleBaseListUseCase
    private var boardPath: String?
    private var currentBoardPage: Int = 0
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    init(dataSource: DataSource,
        useCase: ArticleBaseListUseCase = ArticleBaseListUseCaseImpl()) {
        self.dataSource = dataSource
        self.useCase = useCase
    }
    
    func getHeaderItem(from indexPath: IndexPath) -> ArticleBaseListHeaderItem? {
        let snapshot: Snapshot = dataSource.snapshot()
        return snapshot.getHeaderItem(from: indexPath)
    }
    
    func getCellItem(from indexPath: IndexPath) -> ArticleBaseListCellItem? {
        let snapshot: Snapshot = dataSource.snapshot()
        return snapshot.getCellItem(from: indexPath)
    }
    
    func requestFirstArticleBaseList(boardPath: String) {
        self.boardPath = boardPath
        currentBoardPage = 0
        requestArticleBaseList(shouldResetSnapshot: true)
    }
    
    func requestNextArticleBaseList() {
        currentBoardPage += 1
        requestArticleBaseList(shouldResetSnapshot: false)
    }
    
    private func requestArticleBaseList(shouldResetSnapshot: Bool) {
        guard let boardPath: String = boardPath else {
            Logger.error("boardPath is nil!")
            return
        }
        
        useCase
            .getArticleBaseList(path: boardPath, page: currentBoardPage)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.errorEvent.send(error)
                case .finished:
                    break
                }
            } receiveValue: { [weak self] articleBaseList in
                self?.updateArticleBaseList(articleBaseList, reset: shouldResetSnapshot)
            }
            .store(in: &cancellableBag)
    }
    
    private func updateArticleBaseList(_ articleBaseList: [ArticleBase], reset: Bool) {
        var snapshot: Snapshot = dataSource.snapshot()
        
        if reset {
            snapshot.deleteAllItems()
        }
        
        let articleBaseListHeaderItem: ArticleBaseListHeaderItem = {
            if let articleBaseListHeaderItem: ArticleBaseListHeaderItem = snapshot
                .sectionIdentifiers
                .first(where: { $0.dataType == .articleBaseList })
            {
                return articleBaseListHeaderItem
            } else {
                let articleBaseListHeaderItem: ArticleBaseListHeaderItem = .init(dataType: .articleBaseList)
                snapshot.appendSections([articleBaseListHeaderItem])
                return articleBaseListHeaderItem
            }
        }()
        
        let oldArticleBaseListCellItems: [ArticleBaseListCellItem] = snapshot.itemIdentifiers(inSection: articleBaseListHeaderItem)
        let articleBaseListCellItems: [ArticleBaseListCellItem] = createCellItems(from: articleBaseList, oldCellItems: oldArticleBaseListCellItems)
        let loadMoreCellItem: ArticleBaseListCellItem = .init(dataType: .loadMore)
        
        snapshot.appendItems(articleBaseListCellItems, toSection: articleBaseListHeaderItem)
        snapshot.deleteItems([loadMoreCellItem])
        snapshot.appendItems([loadMoreCellItem], toSection: articleBaseListHeaderItem)
        
        dataSource.apply(snapshot, animatingDifferences: false) { [weak self] in
            self?.updateCompletionEvent.send(reset)
        }
    }
    
    // MARK: - Helper
    private func createCellItems(from articleBaseList: [ArticleBase], oldCellItems: [ArticleBaseListCellItem]) -> [ArticleBaseListCellItem] {
        let cellItems: [ArticleBaseListCellItem] = articleBaseList
            .compactMap { articleBase -> ArticleBaseListCellItem?  in
                let articleBaseData: ArticleBaseListCellItem.ArticleBaseData = .init(likeCount: articleBase.likeCount,
                                                                                     category: articleBase.category,
                                                                                     title: articleBase.title,
                                                                                     commentCount: articleBase.commentCount,
                                                                                     nickname: articleBase.nickname,
                                                                                     nicknameImageURL: articleBase.nicknameImageURL,
                                                                                     hitCount: articleBase.hitCount,
                                                                                     timestamp: articleBase.timestamp,
                                                                                     path: articleBase.path)
                let cellItem: ArticleBaseListCellItem = .init(dataType: .articleBase(data: articleBaseData))
                
                // 중복 제거
                guard !oldCellItems.contains(cellItem) else {
                    return nil
                }
                
                return cellItem
            }
        
        return cellItems
    }
}
