//
//  MainTabBarViewModel.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/17/21.
//

import Foundation

final class MainTabBarViewModel {
    private let settingService: SettingsService = .shared
    
    var agreedConditionStatus: Bool {
        return settingService.agreedConditionStatus
    }
}
