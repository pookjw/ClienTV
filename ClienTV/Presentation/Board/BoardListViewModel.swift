//
//  BoardListViewModel.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/4/21.
//

import UIKit
import Combine
import ClienTVAPI

final class BoardListViewModel {
    typealias DataSource = UICollectionViewDiffableDataSource<BoardListHeaderItem, BoardListCellItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<BoardListHeaderItem, BoardListCellItem>
    
    let errorEvent: PassthroughSubject<Error, Never> = .init()
    private let dataSource: DataSource
    private let useCase: BoardListUseCase
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    init(dataSource: DataSource,
        useCase: BoardListUseCase = BoardListUseCaseImpl()) {
        self.dataSource = dataSource
        self.useCase = useCase
    }
    
    func requestBoardList() {
        useCase
            .getAllBoardList()
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.errorEvent.send(error)
                case .finished:
                    break
                }
            } receiveValue: { [weak self] boardList in
                self?.updateBoardList(boardList)
            }
            .store(in: &cancellableBag)
    }
    
    private func updateBoardList(_ boardList: [Board]) {
        var snapshot: Snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        
        let communityHeaderItem: BoardListHeaderItem = .init(category: .community)
        let somoimHeaderItem: BoardListHeaderItem = .init(category: .somoim)
        let somoimEtcHeaderItem: BoardListHeaderItem = .init(category: .somoimEtc)
        
        let communityCellItem: [BoardListCellItem] = createCellItems(from: boardList, category: .community)
        let somoimCellItem: [BoardListCellItem] = createCellItems(from: boardList, category: .somoim)
        let somoimEtcCellItem: [BoardListCellItem] = createCellItems(from: boardList, category: .somoimEtc)
        
        snapshot.appendSections([communityHeaderItem, somoimHeaderItem, somoimEtcHeaderItem])
        snapshot.appendItems(communityCellItem, toSection: communityHeaderItem)
        snapshot.appendItems(somoimCellItem, toSection: somoimHeaderItem)
        snapshot.appendItems(somoimEtcCellItem, toSection: somoimEtcHeaderItem)
        
        dataSource.apply(snapshot)
    }
    
    // MARK: - Helper
    private func createCellItems(from boardList: [Board], category: BoardListHeaderItem.Category) -> [BoardListCellItem] {
        
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
                return .init(name: board.name,
                             path: board.path)
            }
        
        return cellItems
    }
}
