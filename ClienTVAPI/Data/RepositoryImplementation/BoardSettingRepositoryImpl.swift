//
//  BoardSettingRepositoryImpl.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 7/1/21.
//

import Foundation
import Combine
import CoreData

final class BoardSettingRepositoryImpl: BoardSettingRepository {
    private let coreDataStack: CoreDataStack = CloudDataStackImpl(modelName: "BoardSetting")
    
    func saveChanges() throws {
        return try coreDataStack.saveChanges()
    }
    
    func getBoardSetting() throws -> BoardSetting {
        let mainContext: NSManagedObjectContext = coreDataStack.mainContext
        let fetchRequest: NSFetchRequest<BoardSetting> = BoardSetting._fetchRequest()
        let results: [BoardSetting] = try mainContext.fetch(fetchRequest)
        
        if let result: BoardSetting = results.first {
            return result
        } else {
            let new: BoardSetting = .init(context: mainContext)
            try coreDataStack.saveChanges()
            return new
        }
    }
    
    func observeBoardSetting() -> AnyPublisher<BoardSetting, Never> {
        return NotificationCenter
            .default
            .publisher(for: .NSManagedObjectContextDidSave, object: coreDataStack.mainContext)
            .compactMap { notification -> BoardSetting? in
                guard let userInfo: [AnyHashable: Any] = notification.userInfo else {
                    return nil
                }
                
                if let boardSetting: BoardSetting = (userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>)?.first as? BoardSetting {
                    return boardSetting
                } else if let boardSetting: BoardSetting = (userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>)?.first as? BoardSetting {
                    return boardSetting
                } else {
                    return nil
                }
            }
            .eraseToAnyPublisher()
    }
}
