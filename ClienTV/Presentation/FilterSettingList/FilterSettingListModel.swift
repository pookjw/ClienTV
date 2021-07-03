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

struct FilterSettingCellItem: Comparable, Hashable {
    static func == (lhs: FilterSettingCellItem, rhs: FilterSettingCellItem) -> Bool {
        return lhs.dataType == rhs.dataType
    }
    
    static func < (lhs: FilterSettingCellItem, rhs: FilterSettingCellItem) -> Bool {
        return lhs.dataType < rhs.dataType
    }
    
    enum DataType: Comparable, Hashable {
        case filterSetting(data: FilterSettingData)
        
        static func == (lhs: DataType, rhs: DataType) -> Bool {
            switch (lhs, rhs) {
            case (.filterSetting(let lhsData), .filterSetting(let rhsData)):
                return lhsData == rhsData
            }
        }
        
        static func < (lhs: DataType, rhs: DataType) -> Bool {
            switch (lhs, rhs) {
            case (.filterSetting(let lhsData), .filterSetting(let rhsData)):
                return lhsData < rhsData
            }
        }
    }
    
    let dataType: DataType
}

extension FilterSettingCellItem {
    struct FilterSettingData: Comparable, Hashable {
        static func == (lhs: FilterSettingData, rhs: FilterSettingData) -> Bool {
            return lhs.text == rhs.text
        }
        
        static func < (lhs: FilterSettingData, rhs: FilterSettingData) -> Bool {
            return lhs.timestamp < rhs.timestamp
        }
     
        let text: String
        let timestamp: Date
    }
}
