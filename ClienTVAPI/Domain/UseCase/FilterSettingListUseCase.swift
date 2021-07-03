//
//  FilterSettingListUseCase.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 7/2/21.
//

import Foundation
import Combine
import OSLog

public protocol FilterSettingListUseCase {
    func getFilterSettingList() throws -> [String: Date]
    func observeFilterSettingList() -> AnyPublisher<[String: Date], Never>
    func removeFilterSetting(toRemove filterText: String) throws
    func createFilterSetting(text: String) throws
}

enum FilterSettingListUseCaseError: Error {
    case alreadyExists
}

public final class FilterSettingListUseCaseImpl: FilterSettingListUseCase {
    private let filterSettingRepository: FilterSettingListRepository
    
    public init() {
        self.filterSettingRepository = FilterSettingListRepositoryImpl()
    }
    
    public func getFilterSettingList() throws -> [String: Date] {
        let filterSettings: [FilterSetting] = try filterSettingRepository
            .getFilterSettingList()
        
        return convert(filterSettings: filterSettings)
    }
    
    public func observeFilterSettingList() -> AnyPublisher<[String: Date], Never> {
        return filterSettingRepository
            .observeFilterSetting()
            .compactMap { [weak self] filterSettings in
                guard let self = self else {
                    return nil
                }
                return self.convert(filterSettings: filterSettings)
            }
            .eraseToAnyPublisher()
    }
    
    public func removeFilterSetting(toRemove filterText: String) throws {
        guard let filterSetting: FilterSetting = try filterSettingRepository
                .getFilterSetting(text: filterText) else {
                    Logger.warning("filterText에 해당되는 FilterSetting가 존재하지 않음!")
                    return
                }
        
        try filterSettingRepository.removeFilterSetting(toRemove: filterSetting)
        try filterSettingRepository.saveChanges()
    }
    
    public func createFilterSetting(text: String) throws {
        guard (try filterSettingRepository.getCountOfFilterSetting(text: text)) == 0 else {
            throw FilterSettingListUseCaseError.alreadyExists
        }
        
        let filterSetting: FilterSetting = try filterSettingRepository.createFilterSetting()
        filterSetting.text = text
        filterSetting.timestamp = .init()
        try filterSettingRepository.saveChanges()
    }
    
    private func convert(filterSettings: [FilterSetting]) -> [String: Date] {
        var result: [String: Date] = [:]
        
        filterSettings
            .forEach { filterSetting in
                guard let text: String = filterSetting.text,
                      let timestamp: Date = filterSetting.timestamp else {
                          return
                      }
                result[text] = timestamp
            }
        
        return result
    }
}
