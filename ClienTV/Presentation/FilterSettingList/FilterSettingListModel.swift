//
//  FilterSettingModel.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 7/2/21.
//

import Foundation

// MARK: - FilterSettingHeaderItem

struct FilterSettingHeaderItem: Equatable, Hashable {
    static func == (lhs: FilterSettingHeaderItem, rhs: FilterSettingHeaderItem) -> Bool {
        return lhs.dataType == rhs.dataType
    }
    
    enum DataType: Equatable, Hashable {
        case filterSettings
        
        static func == (lhs: DataType, rhs: DataType) -> Bool {
            switch (lhs, rhs) {
            case (.filterSettings, .filterSettings):
                return true
            }
        }
    }
    
    let dataType: DataType
}

extension FilterSettingHeaderItem {
}

// MARK: - FilterSettingCellItem

struct FilterSettingCellItem: Equatable, Hashable {
    static func == (lhs: FilterSettingCellItem, rhs: FilterSettingCellItem) -> Bool {
        return lhs.dataType == rhs.dataType
    }
    
    enum DataType: Equatable, Hashable {
        case filterSetting(data: FilterSettingData)
        
        static func == (lhs: DataType, rhs: DataType) -> Bool {
            switch (lhs, rhs) {
            case (.filterSetting(let lhsData), .filterSetting(let rhsData)):
                return lhsData == rhsData
            }
        }
    }
    
    let dataType: DataType
}

extension FilterSettingCellItem {
    struct FilterSettingData: Equatable, Hashable {
        static func == (lhs: FilterSettingData, rhs: FilterSettingData) -> Bool {
            return lhs.text == rhs.text
        }
     
        let text: String
        let timestamp: Date
    }
}
