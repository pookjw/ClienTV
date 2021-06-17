//
//  ConditionAPIImpl.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/17/21.
//

import Foundation
import Combine
import SwiftSoup

final class ConditionAPIImpl: ConditionAPI {
    func get() -> Future<Condition, Error> {
        return .init { [weak self] promise in
            
        }
    }
}
