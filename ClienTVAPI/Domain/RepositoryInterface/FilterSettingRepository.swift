//
//  FilterSettingRepository.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 7/2/21.
//

import Foundation
import Combine

protocol FilterSettingRepository {
    func saveChanges() throws
    func getFilterSettings() throws -> [FilterSetting]
    func getFilterSetting(text: String) throws -> FilterSetting?
    func observeFilterSetting() -> AnyPublisher<[FilterSetting], Never>
    func removeFilterSetting(toRemove filterSetting: FilterSetting) throws
    func createFilterSetting() throws -> FilterSetting
}
