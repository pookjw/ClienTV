//
//  ConditionSettingRepository.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 7/2/21.
//

import Foundation

protocol ConditionSettingRepository {
    func saveChanges() throws
    func getConditionSetting() throws -> ConditionSetting
}
