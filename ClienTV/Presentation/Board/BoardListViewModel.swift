//
//  BoardListViewModel.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/4/21.
//

import UIKit
import Combine
import OSLog
import ClienTVAPI

final class BoardListViewModel {
    typealias DataSource = UICollectionViewDiffableDataSource<BoardListHeaderItem, BoardListCellItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<BoardListHeaderItem, BoardListCellItem>
    
    var boardPathVisibilityStatus: Bool {
        return settingService.boardPathVisibilityStatus
    }
    
    private let dataSource: DataSource
    private let useCase: BoardListUseCase
    private let queue: OperationQueue = .init()
    private let settingService: SettingsService = .shared
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    init(dataSource: DataSource,
        useCase: BoardListUseCase = BoardListUseCaseImpl()) {
        self.dataSource = dataSource
        self.useCase = useCase
        configureQueue()
    }
    
    func getHeaderItem(from indexPath: IndexPath) -> BoardListHeaderItem? {
        let snapshot: Snapshot = dataSource.snapshot()
        return snapshot.getHeaderItem(from: indexPath)
    }
    
    func getCellItem(from indexPath: IndexPath) -> BoardListCellItem? {
        let snapshot: Snapshot = dataSource.snapshot()
        return snapshot.getCellItem(from: indexPath)
    }
    
    func requestBoardListIfNeeded() -> Future<Void, Error> {
        return .init { [weak self] promise in
            self?.configurePromise(promise)
        }
    }
    
    private func configurePromise(_ promise: @escaping ((Result<Void, Error>) -> Void)) {
        let isTestMode: Bool = ProcessInfo.processInfo.isTestMode
        
        // Test Mode에서는 데이터를 불러오지 않는다.
        guard !isTestMode else {
            Logger.debug("isTestMode == true")
            return
        }
        
        useCase
            .getAllBoardList()
            .receive(on: queue)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    promise(.failure(error))
                case .finished:
                    break
                }
            } receiveValue: { [weak self] boardList in
                guard !(boardList.isEmpty) else {
                    Logger.warning("불러오기 실패! 재시도 중...")
                    self?.configurePromise(promise)
                    return
                }
                
                self?.updateBoardList(boardList)
                promise(.success(()))
            }
            .store(in: &cancellableBag)
    }
    
    private func updateBoardList(_ boardList: [Board]) {
        var snapshot: Snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        
        let communityHeaderItem: BoardListHeaderItem = .init(dataType: .category(data: .init(category: .community)))
        let somoimHeaderItem: BoardListHeaderItem = .init(dataType: .category(data: .init(category: .somoim)))
        let somoimEtcHeaderItem: BoardListHeaderItem = .init(dataType: .category(data: .init(category: .somoimEtc)))
        
        let communityCellItems: [BoardListCellItem] = createCellItems(from: boardList, category: .community)
        let somoimCellItems: [BoardListCellItem] = createCellItems(from: boardList, category: .somoim)
        let somoimEtcCellItems: [BoardListCellItem] = createCellItems(from: boardList, category: .somoimEtc)
        
        snapshot.appendSections([communityHeaderItem, somoimHeaderItem, somoimEtcHeaderItem])
        snapshot.appendItems(communityCellItems, toSection: communityHeaderItem)
        snapshot.appendItems(somoimCellItems, toSection: somoimHeaderItem)
        snapshot.appendItems(somoimEtcCellItems, toSection: somoimEtcHeaderItem)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func configureQueue() {
        queue.qualityOfService = .userInteractive
    }
    
    // MARK: - Helper
    private func createCellItems(from boardList: [Board], category: BoardListHeaderItem.CategoryData.Category) -> [BoardListCellItem] {
        
        let cellItems: [BoardListCellItem] = boardList
            .filter { board -> Bool in
                switch (board.category, category) {
                case (.community, .community):
                    return true
                case (.somoim, .somoim):
                    return true
                case (.somoimEtc, .somoimEtc):
                    return true
                default:
                    return false
                }
            }
            .map { board -> BoardListCellItem in
                let boardData: BoardListCellItem.BoardData = .init(name: board.name,
                                                                   path: board.path)
                return .init(dataType: .board(data: boardData))
            }
        
        return cellItems
    }
}
