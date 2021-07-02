//
//  CloudDataStack.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 7/1/21.
//

import Foundation
import Combine
import OSLog
import CoreData

final class CloudDataStackImpl: CoreDataStack {
    private let modelName: String
    private static var storeContainers: [String: NSPersistentContainer] = [:]
    
    private(set) lazy var mainContext: NSManagedObjectContext = {
        return storeContainer.viewContext
    }()
    
    private(set) lazy var storeContainer: NSPersistentContainer = {
        if let storeContainer: NSPersistentContainer = Self.storeContainers[modelName] {
            return storeContainer
        } else {
            let bundle: Bundle = .init(identifier: "com.pookjw.ClienTVAPI")!
            let modelURL: URL = bundle.url(forResource: modelName, withExtension: "momd")!
            let model: NSManagedObjectModel = .init(contentsOf: modelURL)!
            let container: NSPersistentCloudKitContainer = .init(name: modelName, managedObjectModel: model)
            
            container.loadPersistentStores { _, error in
                if let error: Error = error {
                    Logger.error(error.localizedDescription)
                }
            }
            
            Self.storeContainers[modelName] = container
            
            return container
        }
    }()
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
    func saveChanges() throws {
        guard mainContext.hasChanges else {
            throw CoreDataStackError.noChangesToSave
        }
        try mainContext.save()
    }
}
