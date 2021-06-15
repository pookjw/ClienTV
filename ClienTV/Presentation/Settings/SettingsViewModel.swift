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

final class SettingsViewModel {
    typealias DataSource = UICollectionViewDiffableDataSource<SettingsHeaderItem, SettingsCellItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<SettingsHeaderItem, SettingsCellItem>
    
    private let dataSource: DataSource
    private let queue: OperationQueue = .init()
    private let settingService: SettingsService = .shared
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    init(dataSource: DataSource) {
        self.dataSource = dataSource
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
        let oldStatus: Bool = settingService.boardPathVisibilityStatus
        let newStatus: Bool = !oldStatus
        let newNumber: NSNumber = .init(booleanLiteral: newStatus)
        
        settingService.save(key: .toggleBoardPathVisibility, value: newNumber)
    }
    
    private func configureInitialDataSource() {
        queue.addOperation { [weak self] in
            guard let self = self else { return }
            
            var snapshot: Snapshot = self.dataSource.snapshot()
            
            snapshot.deleteAllItems()
            
            //
            
            let boardListHeaderItem: SettingsHeaderItem = .init(dataType: .boardList)
            
            snapshot.appendSections([boardListHeaderItem])
            
            let boardPathVisibilityStatus: Bool = self.settingService.boardPathVisibilityStatus
            let toggleBoardPathVisibilityData: SettingsCellItem.ToggleBoardPathVisibilityData = .init(status: boardPathVisibilityStatus)
            let toggleBoardPathVisibilityItem: SettingsCellItem = .init(dataType: .toggleBoardPathVisibility(data: toggleBoardPathVisibilityData))
            
            snapshot.appendItems([toggleBoardPathVisibilityItem], toSection: boardListHeaderItem)
            
            //
            
            let developerInfoHeaderItem: SettingsHeaderItem = .init(dataType: .developerInfo)
            
            snapshot.appendSections([developerInfoHeaderItem])
            
            let developerEmailData: SettingsCellItem.DeveloperEmailData = .init(dataType: .jinwooKim)
            let developerGitHubData: SettingsCellItem.DeveloperGitHubData = .init(dataType: .jinwooKim)
            let developerEmailCellItem: SettingsCellItem = .init(dataType: .developerEmail(data: developerEmailData))
            let developerGitHubCellItem: SettingsCellItem = .init(dataType: .developerGitHub(data: developerGitHubData))
            
            snapshot.appendItems([developerEmailCellItem, developerGitHubCellItem], toSection: developerInfoHeaderItem)
            
            //
            
            self.dataSource.apply(snapshot)
        }
    }
    
    private func configureQueue() {
        queue.qualityOfService = .userInteractive
    }
    
    private func bind() {
        settingService
            .changedEvent
            .receive(on: queue)
            .sink(receiveValue: { [weak self] newValue in
                self?.updateSettingsDataSource(newValue: newValue)
            })
            .store(in: &cancellableBag)
    }
    
    private func updateSettingsDataSource(newValue: (key: SettingsServiceDataKey, value: Any)) {
        switch newValue.key {
        case .toggleBoardPathVisibility:
            guard let number: NSNumber = newValue.value as? NSNumber else {
                return
            }
            updateToggleBoardPathVisibility(status: number.boolValue)
        }
    }
    
    private func updateToggleBoardPathVisibility(status: Bool) {
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
        
        let boardPathVisibilityStatus: Bool = settingService.boardPathVisibilityStatus
        let toggleBoardPathVisibilityData: SettingsCellItem.ToggleBoardPathVisibilityData = .init(status: boardPathVisibilityStatus)
        let toggleBoardPathVisibilityItem: SettingsCellItem = .init(dataType: .toggleBoardPathVisibility(data: toggleBoardPathVisibilityData))
        
        snapshot.appendItems([toggleBoardPathVisibilityItem], toSection: boardListHeaderItem)
        
        snapshot.ssSortSections()
        
        dataSource.apply(snapshot)
    }
}
