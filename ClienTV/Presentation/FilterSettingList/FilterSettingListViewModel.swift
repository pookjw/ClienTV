//
//  FilterSettingListViewModel.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 7/2/21.
//

import UIKit
import Combine
import ClienTVAPI

final class FilterSettingListViewModel {
    typealias DataSource = UICollectionViewDiffableDataSource<FilterSettingHeaderItem, FilterSettingCellItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<FilterSettingHeaderItem, FilterSettingCellItem>
    
    private let dataSource: DataSource
    private let useCase: FilterSettingListUseCase
    private let queue: OperationQueue = .init()
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    init(dataSource: DataSource,
         useCase: FilterSettingListUseCase = FilterSettingListUseCaseImpl()) {
        self.dataSource = dataSource
        self.useCase = useCase
        
        configureQueue()
        bind()
        configureInitialDataSource()
    }
    
    private func configureQueue() {
        queue.qualityOfService = .userInteractive
    }
    
    private func configureInitialDataSource() {
        let filterSettings: [String: Date] = try! useCase.getFilterSettingList()
        updateFilterSetting(filterSettings)
    }
    
    private func bind() {
        useCase
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
