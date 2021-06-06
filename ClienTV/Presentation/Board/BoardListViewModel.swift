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
    
    private let dataSource: DataSource
    private let useCase: BoardListUseCase
    private var isBoardListEmpty: Bool {
        let snapshot: Snapshot = dataSource.snapshot()
        let isBoardListEmpty: Bool = snapshot.numberOfItems == 0
        return isBoardListEmpty
    }
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    init(dataSource: DataSource,
        useCase: BoardListUseCase = BoardListUseCaseImpl()) {
        self.dataSource = dataSource
        self.useCase = useCase
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
            guard let self = self else {
                return
            }
            
            let isTestMode: Bool = ProcessInfo.processInfo.isTestMode
            
            // Test Mode에서는 데이터를 불러오지 않는다.
            guard !isTestMode else {
                Logger.debug("isTestMode == true")
                return
            }
            
            guard self.isBoardListEmpty else {
                Logger.warning("이미 BoardList가 존재함!")
                return
            }
            
            self.useCase
                .getAllBoardList()
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        promise(.failure(error))
                    case .finished:
                        break
                    }
                } receiveValue: { [weak self] boardList in
                    self?.updateBoardList(boardList)
                    promise(.success(()))
                }
                .store(in: &self.cancellableBag)
        }
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
        
        dataSource.apply(snapshot)
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
