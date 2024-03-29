//
//  CoreDataStackImpl.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 7/2/21.
//

import Foundation
import Combine
import OSLog
import CoreData

private var kStoreContainers: [String: NSPersistentContainer] = [:]

class CoreDataStackImpl<T: NSPersistentContainer>: CoreDataStack {
    private let modelName: String
    
    private(set) lazy var mainContext: NSManagedObjectContext = {
        return storeContainer.viewContext
    }()
    
    private(set) lazy var storeContainer: NSPersistentContainer = {
        if let storeContainer: NSPersistentContainer = kStoreContainers[modelName] {
            guard type(of: storeContainer) == T.self else {
                fatalError("NSPersistentContainer의 Type이 일치하지 않음!")
            }
            return storeContainer
        } else {
            let bundle: Bundle = .init(identifier: "com.pookjw.ClienTVAPI")!
            let modelURL: URL = bundle.url(forResource: modelName, withExtension: "momd")!
            let model: NSManagedObjectModel = .init(contentsOf: modelURL)!
            let container: T = .init(name: modelName, managedObjectModel: model)
            
            container.loadPersistentStores { _, error in
                if let error: Error = error {
                    Logger.error(error.localizedDescription)
                }
            }
            
            kStoreContainers[modelName] = container
            
            return container
        }
    }()
    
    private(set) lazy var changesPublisher: AnyPublisher<Notification, Never> = {
        let contextEvent: AnyPublisher<Notification, Never> = NotificationCenter
            .default
            .publisher(for: .NSManagedObjectContextDidSave, object: mainContext)
            .eraseToAnyPublisher()
        let cloudKitEvent: AnyPublisher<Notification, Never> = NotificationCenter
            .default
            .publisher(for: NSPersistentCloudKitContainer.eventChangedNotification, object: storeContainer)
            .eraseToAnyPublisher()
        
        return contextEvent
            .merge(with: cloudKitEvent)
            .share()
            .eraseToAnyPublisher()
    }()
    
    required init(modelName: String) {
        self.modelName = modelName
    }
    
    func saveChanges() throws {
        guard mainContext.hasChanges else {
            throw CoreDataStackError.noChangesToSave
        }
        try mainContext.save()
    }
}
