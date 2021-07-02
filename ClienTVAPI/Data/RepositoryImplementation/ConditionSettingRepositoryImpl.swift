//
//  ConditionSettingRepositoryImpl.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 7/2/21.
//

import Foundation
import CoreData

final class ConditionSettingRepositoryImpl: ConditionSettingRepository {
    private let coreDataStack: CoreDataStack = LocalDataStackImpl(modelName: "ConditionSetting")
    
    func saveChanges() throws {
        try coreDataStack.saveChanges()
    }
    
    func getConditionSetting() throws -> ConditionSetting {
        let mainContext: NSManagedObjectContext = coreDataStack.mainContext
        let fetchRequest: NSFetchRequest<ConditionSetting> = ConditionSetting._fetchRequest()
        let results: [ConditionSetting] = try mainContext.fetch(fetchRequest)
        
        if let result: ConditionSetting = results.first {
            return result
        } else {
            let new: ConditionSetting = .init(context: mainContext)
            try coreDataStack.saveChanges()
            return new
        }
    }
}
