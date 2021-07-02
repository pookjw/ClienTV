//
//  MainTabBarViewModel.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/17/21.
//

import Foundation
import ClienTVAPI

final class MainTabBarViewModel {
    private let conditionSettingUseCase: ConditionSettingUseCase = ConditionSettingUseCaseImpl()
    
    var agreedConditionStatus: Bool {
        return try! conditionSettingUseCase.getReadStatus()
    }
}
