//
//  FilterSettingListRepository.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 7/2/21.
//

import Foundation
import Combine

protocol FilterSettingListRepository {
    func saveChanges() throws
    func getFilterSettingList() throws -> [FilterSetting]
    func getFilterSetting(text: String) throws -> FilterSetting?
    func getCountOfFilterSetting(text: String) throws -> Int
    func observeFilterSetting() -> AnyPublisher<[FilterSetting], Never>
    func removeFilterSetting(toRemove filterSetting: FilterSetting) throws
    func createFilterSetting() throws -> FilterSetting
}
