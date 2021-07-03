//
//  FilterSettingListViewModel.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 7/2/21.
//

import UIKit
import Combine
import OSLog
import SortSnapshot
import ClienTVAPI

final class FilterSettingListViewModel {
    typealias DataSource = UICollectionViewDiffableDataSource<FilterSettingHeaderItem, FilterSettingCellItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<FilterSettingHeaderItem, FilterSettingCellItem>
    
    private let dataSource: DataSource
    private let filterSettingUseCase: FilterSettingListUseCase = FilterSettingListUseCaseImpl()
    private let queue: OperationQueue = .init()
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    init(dataSource: DataSource) {
        self.dataSource = dataSource
        
        configureQueue()
        bind()
        configureInitialDataSource()
    }
    
    func getCellItem(from indexPath: IndexPath) -> FilterSettingCellItem? {
        let snapshot: Snapshot = dataSource.snapshot()
        return snapshot.getCellItem(from: indexPath)
    }
    
    func createFilterSetting(text: String) {
        do {
            try filterSettingUseCase.createFilterSetting(text: text)
        } catch {
            Logger.error(error.localizedDescription)
        }
    }
    
    func removeFilterSetting(text: String) {
        do {
            try filterSettingUseCase.removeFilterSetting(toRemove: text)
        } catch {
            Logger.error(error.localizedDescription)
        }
    }
    
    private func configureQueue() {
        queue.qualityOfService = .userInteractive
    }
    
    private func configureInitialDataSource() {
        let filterSettings: [String: Date] = try! filterSettingUseCase.getFilterSettingList()
        updateFilterSetting(filterSettings)
    }
    
    private func bind() {
        filterSettingUseCase
            .observeFilterSettingList()
            .receive(on: queue)
            .sink { [weak self] filterSettings in
                self?.updateFilterSetting(filterSettings)
            }
            .store(in: &cancellableBag)
    }
    
    private func updateFilterSetting(_ filterSettings: [String: Date]) {
        var snapshot: Snapshot = dataSource.snapshot()
        
        snapshot.deleteAllItems()
        
        let filterSettingsHeaderItem: FilterSettingHeaderItem = .init(dataType: .filterSettings)
        snapshot.appendSections([filterSettingsHeaderItem])
        
        let filterSettingCellItems: [FilterSettingCellItem] = createCellItems(from: filterSettings)
        snapshot.appendItems(filterSettingCellItems, toSection: filterSettingsHeaderItem)
        
        snapshot.ssSortItems([filterSettingsHeaderItem], by: >)
        
        dataSource.apply(snapshot)
    }
    
    // MARK: - Helper
    private func createCellItems(from filterSettings: [String: Date]) -> [FilterSettingCellItem] {
        let cellItems: [FilterSettingCellItem] = filterSettings
            .map { (text, timestamp) in
                let data: FilterSettingCellItem.FilterSettingData = .init(text: text, timestamp: timestamp)
                return .init(dataType: .filterSetting(data: data))
            }
        
        return cellItems
    }
}
