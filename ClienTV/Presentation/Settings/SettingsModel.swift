//
//  SettingsModel.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/13/21.
//

import UIKit

// MARK: - SettingsHeaderItem

struct SettingsHeaderItem: Comparable, Hashable {
    static func == (lhs: SettingsHeaderItem, rhs: SettingsHeaderItem) -> Bool {
        return lhs.dataType == rhs.dataType
    }
    
    static func < (lhs: SettingsHeaderItem, rhs: SettingsHeaderItem) -> Bool {
        return lhs.dataType.index < rhs.dataType.index
    }
    
    enum DataType {
        case boardList
        case misc
        case developerInfo
        
        var index: Int {
            switch self {
            case .boardList:
                return 0
            case .misc:
                return 1
            case .developerInfo:
                return 2
            }
        }
    }
    
    let dataType: DataType
    
    var title: String {
        switch dataType {
        case .boardList:
            return "게시판 목록 설정"
        case .misc:
            return "MISC"
        case .developerInfo:
            return "개발자 정보"
        }
    }
}

extension SettingsHeaderItem {
}

// MARK: - SettingsCellItem

struct SettingsCellItem: Equatable, Hashable {
    static func == (lhs: SettingsCellItem, rhs: SettingsCellItem) -> Bool {
        return lhs.dataType == rhs.dataType
    }
    
    enum DataType: Equatable, Hashable {
        case toggleBoardPathVisibility(data: ToggleBoardPathVisibilityData)
        case developerEmail(data: DeveloperEmailData)
        case developerGitHub(data: DeveloperGitHubData)
        case presentCondition(data: PresentConditionData)
        case presentFilterSetting(data: PresentFilterSetting)
        
        static func == (lhs: DataType, rhs: DataType) -> Bool {
            switch (lhs, rhs) {
            case (.toggleBoardPathVisibility(let lhsData), .toggleBoardPathVisibility(let rhsData)):
                return lhsData == rhsData
            case (.developerEmail(let lhsData), .developerEmail(let rhsData)):
                return lhsData == rhsData
            case (.developerGitHub(let lhsData), .developerGitHub(let rhsData)):
                return lhsData == rhsData
            case (.presentCondition(let lhsData), .presentCondition(let rhsData)):
                return lhsData == rhsData
            case (.presentFilterSetting(let lhsData), .presentFilterSetting(let rhsData)):
                return lhsData == rhsData
            default:
                return false
            }
        }
    }
    
    let dataType: DataType
}

extension SettingsCellItem {
    struct ToggleBoardPathVisibilityData: Equatable, Hashable {
        static func == (lhs: ToggleBoardPathVisibilityData, rhs: ToggleBoardPathVisibilityData) -> Bool {
            return lhs.status == rhs.status
        }
        
        let status: Bool
        
        var title: String {
            return "게시판 목록에서 URL Path 표시"
        }
        
        var image: UIImage? {
            return .init(systemName: "point.topleft.down.curvedto.point.bottomright.up")
        }
        
        var accessoryText: String {
            return status ? "켜짐" : "꺼짐"
        }
    }
}

extension SettingsCellItem {
    struct DeveloperEmailData: Equatable, Hashable {
        static func == (lhs: DeveloperEmailData, rhs: DeveloperEmailData) -> Bool {
            return lhs.dataType == rhs.dataType
        }
        
        enum DataType: Equatable, Hashable {
            case jinwooKim
        }
        
        let dataType: DataType
        
        var image: UIImage? {
            return .init(systemName: "envelope.fill")
        }
        
        var title: String {
            return "이메일 주소"
        }
        
        var subTitle: String {
            switch dataType {
            case .jinwooKim:
                return "kidjinwoo@me.com"
            }
        }
    }
}

extension SettingsCellItem {
    struct DeveloperGitHubData: Equatable, Hashable {
        static func == (lhs: DeveloperGitHubData, rhs: DeveloperGitHubData) -> Bool {
            return lhs.dataType == rhs.dataType
        }
        
        enum DataType: Equatable, Hashable {
            case jinwooKim
        }
        
        let dataType: DataType
        
        var image: UIImage? {
            return .init(systemName: "chevron.left.slash.chevron.right")
        }
        
        var title: String {
            return "GitHub"
        }
        
        var subTitle: String {
            switch dataType {
            case .jinwooKim:
                return "github.com/pookjw"
            }
        }
    }
}

extension SettingsCellItem {
    struct PresentConditionData: Equatable, Hashable {
        static func == (lhs: PresentConditionData, rhs: PresentConditionData) -> Bool {
            return lhs.id == rhs.id
        }
        
        var title: String {
            return "클리앙 이용약관 보기"
        }
        
        var image: UIImage? {
            return .init(systemName: "doc.plaintext")
        }
        
        private let id: UUID = .init()
    }
}

extension SettingsCellItem {
    struct PresentFilterSetting: Equatable, Hashable {
        static func == (lhs: PresentFilterSetting, rhs: PresentFilterSetting) -> Bool {
            return lhs.id == rhs.id
        }
        
        var title: String {
            return "차단단어 설정"
        }
        
        var image: UIImage? {
            return .init(systemName: "line.horizontal.3")
        }
        
        private let id: UUID = .init()
    }
}
