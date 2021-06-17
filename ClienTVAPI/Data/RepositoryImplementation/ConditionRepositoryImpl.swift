//
//  ConditionRepositoryImpl.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/17/21.
//

import Foundation
import Combine

final class ConditionRepositoryImpl: ConditionRepository {
    private let api: ConditionAPI
    
    init(api: ConditionAPI = ConditionAPIImpl()) {
        self.api = api
    }
    
    func getCondition() -> Future<Condition, Error> {
        return api.getCondition()
    }
}
