//
//  ConditionRepository.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/17/21.
//

import Foundation
import Combine

protocol ConditionRepository {
    func getCondition() -> Future<Condition, Error>
}
