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
    
    /// 다음 페이지 불러올 때, 현재 위치를 잡아주기 위함
    var cacheIndexPath: IndexPath? = nil
    private(set) var boardPath: String?
    private let dataSource: DataSource
    private let articleBaseListUseCase: ArticleBaseListUseCase = ArticleBaseListUseCaseImpl()
    private let filterSettingListUseCase: FilterSettingListUseCase = FilterSettingListUseCaseImpl()
    private var currentBoardPage: Int = 0
    private let queue: OperationQueue = .init()
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    init(dataSource: DataSource) {
        self.dataSource = dataSource
        configureQueue()
    }
    
    func getCellItem(from indexPath: IndexPath) -> ArticleBaseListCellItem? {
        let snapshot: Snapshot = dataSource.snapshot()
        return snapshot.getCellItem(from: indexPath)
    }
    
    func requestFirstArticleBaseList(boardPath: String) -> Future<Bool, Error> {
        self.boardPath = boardPath
        currentBoardPage = 0
        return requestArticleBaseList(shouldResetSnapshot: true)
    }
    
    func requestNextArticleBaseList() -> Future<Bool, Error> {
        currentBoardPage += 1
        return requestArticleBaseList(shouldResetSnapshot: false)
    }
    
    private func requestArticleBaseList(shouldResetSnapshot: Bool) -> Future<Bool, Error> {
        return .init { [weak self] promise in
            self?.configurePromise(promise, shouldResetSnapshot: shouldResetSnapshot)
        }
    }
    
    private func configurePromise(_ promise: @escaping ((Result<Bool, Error>) -> Void),
                                  shouldResetSnapshot: Bool) {
        guard let boardPath: String = boardPath else {
            Logger.error("boardPath is nil!")
            return
        }
        
        articleBaseListUseCase
            .getArticleBaseList(path: boardPath, page: currentBoardPage)
            .receive(on: queue)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    promise(.failure(error))
                case .finished:
                    break
                }
            } receiveValue: { [weak self] articleBaseList in
                self?.updateArticleBaseList(articleBaseList, reset: shouldResetSnapshot)
                promise(.success(shouldResetSnapshot))
            }
            .store(in: &self.cancellableBag)
    }
    
    private func updateArticleBaseList(_ articleBaseList: [ArticleBase], reset: Bool) {
        var snapshot: Snapshot = dataSource.snapshot()
        
        if reset {
            snapshot.deleteAllItems()
        }
        
        let headerItem: ArticleBaseListHeaderItem = {
            if let headerItem: ArticleBaseListHeaderItem = snapshot
                .sectionIdentifiers
                .first(where: { $0.dataType == .articleBaseList })
            {
                return headerItem
            } else {
                let headerItem: ArticleBaseListHeaderItem = .init(dataType: .articleBaseList)
                snapshot.appendSections([headerItem])
                return headerItem
            }
        }()
        
        let oldCellItems: [ArticleBaseListCellItem] = snapshot.itemIdentifiers(inSection: headerItem)
        let newCellItems: [ArticleBaseListCellItem] = createCellItems(from: articleBaseList, oldCellItems: oldCellItems)
        let loadMoreCellItem: ArticleBaseListCellItem = .init(dataType: .loadMore)
        
        snapshot.appendItems(newCellItems, toSection: headerItem)
        snapshot.deleteItems([loadMoreCellItem])
        snapshot.appendItems([loadMoreCellItem], toSection: headerItem)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func configureQueue() {
        queue.qualityOfService = .userInteractive
    }
    
    // MARK: - Helper
    private func createCellItems(from articleBaseList: [ArticleBase], oldCellItems: [ArticleBaseListCellItem]) -> [ArticleBaseListCellItem] {
        let filterTexts: [String] = (try? filterSettingListUseCase
            .getFilterSettingList()
            .keys
            .map { $0 }) ?? []
        
        let cellItems: [ArticleBaseListCellItem] = articleBaseList
            .compactMap { articleBase -> ArticleBaseListCellItem? in
                
                // 필터링
                for filterText in filterTexts {
                    guard !((articleBase.title.localizedCaseInsensitiveContains(filterText)) ||
                        (articleBase.nickname.localizedCaseInsensitiveContains(filterText))) else {
                        return nil
                    }
                }
                
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
