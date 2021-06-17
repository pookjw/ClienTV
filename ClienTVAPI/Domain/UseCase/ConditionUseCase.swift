//
//  ConditionUseCase.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/17/21.
//

import Foundation
import Combine

public protocol ConditionUseCase {
    func getCondition() -> Future<Condition, Error>
}

public final class ConditionUseCaseImpl: ConditionUseCase {
    private let conditionRepository: ConditionRepository
    
    public init() {
        self.conditionRepository = ConditionRepositoryImpl()
    }
    
    public func getCondition() -> Future<Condition, Error> {
        return conditionRepository.getCondition()
    }
}
