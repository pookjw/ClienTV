//
//  FilterSettingUseCase.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 7/2/21.
//

import Foundation
import Combine
import OSLog

public protocol FilterSettingUseCase {
    func getFilterTexts() throws -> [String: Date]
    func observeFilterTexts() -> AnyPublisher<[String: Date], Never>
    func removeFilterTexts(toRemove filterText: String) throws
    func createFilterText(_ text: String) throws
}

public final class FilterSettingUseCaseImpl: FilterSettingUseCase {
    private let filterSettingRepository: FilterSettingRepository
    
    public init() {
        self.filterSettingRepository = FilterSettingRepositoryImpl()
    }
    
    public func getFilterTexts() throws -> [String: Date] {
        let filterSettings: [FilterSetting] = try filterSettingRepository
            .getFilterSettings()
        
        return convert(filterSettings: filterSettings)
    }
    
    public func observeFilterTexts() -> AnyPublisher<[String: Date], Never> {
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
    
    public func removeFilterTexts(toRemove filterText: String) throws {
        guard let filterSetting: FilterSetting = try filterSettingRepository
                .getFilterSetting(text: filterText) else {
                    Logger.warning("filterText에 해당되는 FilterSetting가 존재하지 않음!")
                    return
                }
        
        try filterSettingRepository.removeFilterSetting(toRemove: filterSetting)
        try filterSettingRepository.saveChanges()
    }
    
    public func createFilterText(_ text: String) throws {
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
