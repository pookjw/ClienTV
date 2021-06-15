//
//  SettingsService.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/15/21.
//

import Foundation
import Combine

final class SettingsService {
    static let shared: SettingsService = .init()
    
    let changedEvent: PassthroughSubject<(key: SettingsServiceDataKey, value: Any), Never> = .init()
    
    private let userDefaults: UserDefaults = .standard
    
    func save(key: SettingsServiceDataKey, value: Any) {
        userDefaults.set(value, forKey: key.rawValue)
        changedEvent.send((key: key, value: value))
    }
    
    func load(forKey key: SettingsServiceDataKey) -> Any? {
        return userDefaults.object(forKey: key.rawValue)
    }
    
    // MARK: - Values
    var boardPathVisibilityStatus: Bool {
        guard let number: NSNumber = load(forKey: .toggleBoardPathVisibility) as? NSNumber else {
            return false
        }
        
        return number.boolValue
    }
    
    private init() {}
}
