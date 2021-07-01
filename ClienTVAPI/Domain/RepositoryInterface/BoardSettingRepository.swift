//
//  BoardSettingRepository.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 7/1/21.
//

import Foundation
import Combine

protocol BoardSettingRepository {
    func saveChanges() throws
    func getBoardSetting() throws -> BoardSetting
    func observeBoardSetting() -> AnyPublisher<BoardSetting, Never>
}
