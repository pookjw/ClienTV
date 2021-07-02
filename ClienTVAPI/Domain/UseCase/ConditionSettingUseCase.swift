//
//  ConditionSettingUseCase.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 7/2/21.
//

import Foundation

public protocol ConditionSettingUseCase {
    func setRead() throws
    func getReadStatus() throws -> Bool
}

public final class ConditionSettingUseCaseImpl: ConditionSettingUseCase {
    private let conditionSettingRepository: ConditionSettingRepository
    
    public init() {
        self.conditionSettingRepository = ConditionSettingRepositoryImpl()
    }
    
    public func setRead() throws {
        let conditionSetting: ConditionSetting = try conditionSettingRepository.getConditionSetting()
        
        if !conditionSetting.didRead {
            conditionSetting.didRead = true
            try conditionSettingRepository.saveChanges()
        }
    }
    
    public func getReadStatus() throws -> Bool {
        let conditionSetting: ConditionSetting = try conditionSettingRepository.getConditionSetting()
        return conditionSetting.didRead
    }
}
