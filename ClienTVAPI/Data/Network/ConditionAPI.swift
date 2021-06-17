//
//  ConditionAPI.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/17/21.
//

import Foundation
import Combine

protocol ConditionAPI {
    func get() -> Future<Condition, Error>
}
