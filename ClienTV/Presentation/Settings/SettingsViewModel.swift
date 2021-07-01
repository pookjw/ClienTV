//
//  SettingsViewModel.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/13/21.
//

import UIKit
import Combine
import OSLog
import SortSnapshot
import ClienTVAPI

final class SettingsViewModel {
    typealias DataSource = UICollectionViewDiffableDataSource<SettingsHeaderItem, SettingsCellItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<SettingsHeaderItem, SettingsCellItem>
    
    private let dataSource: DataSource
    private let queue: OperationQueue = .init()
    private let boardSettingUseCase: BoardSettingUseCase
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    init(dataSource: DataSource) {
        self.dataSource = dataSource
        self.boardSettingUseCase = BoardSettingUseCaseImpl()
        configureQueue()
        configureInitialDataSource()
        bind()
    }
    
    func getHeaderItem(from indexPath: IndexPath) -> SettingsHeaderItem? {
        let snapshot: Snapshot = dataSource.snapshot()
        return snapshot.getHeaderItem(from: indexPath)
    }
    
    func getCellItem(from indexPath: IndexPath) -> SettingsCellItem? {
        let snapshot: Snapshot = dataSource.snapshot()
        return snapshot.getCellItem(from: indexPath)
    }
    
    func toggleBoardPathVisibility() {
        try! boardSettingUseCase
            .toggleBoardSetting()
    }
    
    private func configureInitialDataSource() {
        queue.addOperation { [weak self] in
            guard let self = self else { return }
            
            var snapshot: Snapshot = self.dataSource.snapshot()
            
            snapshot.deleteAllItems()
            
            //
            
            let boardListHeaderItem: SettingsHeaderItem = .init(dataType: .boardList)
            
            snapshot.appendSections([boardListHeaderItem])
            
            let boardSetting: BoardSetting = try! self.boardSettingUseCase.getBoardSetting()
            let boardPathVisibilityStatus: Bool = boardSetting.isEnabled
            let toggleBoardPathVisibilityData: SettingsCellItem.ToggleBoardPathVisibilityData = .init(status: boardPathVisibilityStatus)
            let toggleBoardPathVisibilityCellItem: SettingsCellItem = .init(dataType: .toggleBoardPathVisibility(data: toggleBoardPathVisibilityData))
            
            snapshot.appendItems([toggleBoardPathVisibilityCellItem], toSection: boardListHeaderItem)
            
            //
            
            let miscHeaderItem: SettingsHeaderItem = .init(dataType: .misc)
            
            snapshot.appendSections([miscHeaderItem])
            
            let presentConditionData: SettingsCellItem.PresentConditionData = . init()
            let presentConditionCellItem: SettingsCellItem = .init(dataType: .presentCondition(data: presentConditionData))
            
            snapshot.appendItems([presentConditionCellItem], toSection: miscHeaderItem)
            
            //
            
            let developerInfoHeaderItem: SettingsHeaderItem = .init(dataType: .developerInfo)
            
            snapshot.appendSections([developerInfoHeaderItem])
            
            let developerEmailData: SettingsCellItem.DeveloperEmailData = .init(dataType: .jinwooKim)
            let developerGitHubData: SettingsCellItem.DeveloperGitHubData = .init(dataType: .jinwooKim)
            let developerEmailCellItem: SettingsCellItem = .init(dataType: .developerEmail(data: developerEmailData))
            let developerGitHubCellItem: SettingsCellItem = .init(dataType: .developerGitHub(data: developerGitHubData))
            
            snapshot.appendItems([developerEmailCellItem, developerGitHubCellItem], toSection: developerInfoHeaderItem)
            
            //
            
            self.dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
    
    private func configureQueue() {
        queue.qualityOfService = .userInteractive
    }
    
    private func bind() {
        boardSettingUseCase
            .observeBoardSetting()
            .receive(on: queue)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    Logger.error(error)
                case .finished:
                    break
                }
            } receiveValue: { [weak self] boardSetting in
                self?.updateToggleBoardPathVisibility(boardSetting: boardSetting)
            }
            .store(in: &cancellableBag)
    }
    
    private func updateToggleBoardPathVisibility(boardSetting: BoardSetting) {
        var snapshot: Snapshot = dataSource.snapshot()
        
        let boardListHeaderItem: SettingsHeaderItem = {
            if let boardListHeaderItem: SettingsHeaderItem = snapshot
                .sectionIdentifiers
                .first(where: { $0.dataType == .boardList })
            {
                return boardListHeaderItem
            } else {
                let boardListHeaderItem: SettingsHeaderItem = .init(dataType: .boardList)
                snapshot.appendSections([boardListHeaderItem])
                return boardListHeaderItem
            }
        }()
        
        snapshot.deleteSections([boardListHeaderItem])
        snapshot.appendSections([boardListHeaderItem])
        
        let boardPathVisibilityStatus: Bool = boardSetting.isEnabled
        let toggleBoardPathVisibilityData: SettingsCellItem.ToggleBoardPathVisibilityData = .init(status: boardPathVisibilityStatus)
        let toggleBoardPathVisibilityItem: SettingsCellItem = .init(dataType: .toggleBoardPathVisibility(data: toggleBoardPathVisibilityData))

        snapshot.appendItems([toggleBoardPathVisibilityItem], toSection: boardListHeaderItem)
        
        snapshot.ssSortSections()
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}
