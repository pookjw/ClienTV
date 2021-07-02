//
//  BoardSettingUseCase.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 7/1/21.
//

import Foundation
import Combine

public protocol BoardSettingUseCase {
    func toggleIsEnabled() throws
    func getIsEnabled() throws -> Bool
    func observeIsEnabled() -> AnyPublisher<Bool, Never>
}

public final class BoardSettingUseCaseImpl: BoardSettingUseCase {
    private let boardSettingRepository: BoardSettingRepository
    
    public init() {
        self.boardSettingRepository = BoardSettingRepositoryImpl()
    }
    
    public func toggleIsEnabled() throws {
        let boardSetting: BoardSetting = try boardSettingRepository.getBoardSetting()
        boardSetting.isEnabled.toggle()
        try boardSettingRepository.saveChanges()
    }
    
    public func getIsEnabled() throws -> Bool {
        let boardSetting: BoardSetting = try boardSettingRepository.getBoardSetting()
        return boardSetting.isEnabled
    }
    
    public func observeIsEnabled() -> AnyPublisher<Bool, Never> {
        return boardSettingRepository
            .observeBoardSetting()
            .map { $0.isEnabled }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
