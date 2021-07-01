//
//  BoardSettingUseCase.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 7/1/21.
//

import Foundation
import Combine

public protocol BoardSettingUseCase {
    func toggleBoardSetting() throws
    func getBoardSetting() throws -> BoardSetting
    func observeBoardSetting() -> AnyPublisher<BoardSetting, Never>
}

public final class BoardSettingUseCaseImpl: BoardSettingUseCase {
    private let boardSettingRepository: BoardSettingRepository
    
    public init() {
        self.boardSettingRepository = BoardSettingRepositoryImpl()
    }
    
    public func toggleBoardSetting() throws {
        let boardSetting: BoardSetting = try boardSettingRepository.getBoardSetting()
        boardSetting.isEnabled.toggle()
        try boardSettingRepository.saveChanges()
    }
    
    public func getBoardSetting() throws -> BoardSetting {
        return try boardSettingRepository.getBoardSetting()
    }
    
    public func observeBoardSetting() -> AnyPublisher<BoardSetting, Never> {
        return boardSettingRepository.observeBoardSetting()
    }
}
