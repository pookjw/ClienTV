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
    
    init(dataSource: DataSource) {
        self.dataSource = dataSource
        configureQueue()
    }
    
    func getHeaderItem(from indexPath: IndexPath) -> SettingsHeaderItem? {
        let snapshot: Snapshot = dataSource.snapshot()
        return snapshot.getHeaderItem(from: indexPath)
    }
    
    func configureInitialDataSource() {
        queue.addOperation { [weak self] in
            guard let self = self else { return }
            
            var snapshot: Snapshot = self.dataSource.snapshot()
            
            snapshot.deleteAllItems()
            
            let developerInfoHeaderItem: SettingsHeaderItem = .init(dataType: .developerInfo)
            
            snapshot.appendSections([developerInfoHeaderItem])
            
            let developerEmailData: SettingsCellItem.DeveloperEmailData = .init(dataType: .jinwooKim)
            let developerGitHubData: SettingsCellItem.DeveloperGitHubData = .init(dataType: .jinwooKim)
            let developerEmailCellItem: SettingsCellItem = .init(dataType: .developerEmail(data: developerEmailData))
            let developerGitHubCellItem: SettingsCellItem = .init(dataType: .developerGitHub(data: developerGitHubData))
            
            snapshot.appendItems([developerEmailCellItem, developerGitHubCellItem], toSection: developerInfoHeaderItem)
            
            self.dataSource.apply(snapshot)
        }
    }
    
    private func configureQueue() {
        queue.qualityOfService = .userInteractive
    }
}
