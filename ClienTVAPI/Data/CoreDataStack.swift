//
//  CoreDataStack.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 7/1/21.
//

import Foundation
import Combine
import CoreData

protocol CoreDataStack {
    var mainContext: NSManagedObjectContext { get }
    var storeContainer: NSPersistentContainer { get }
    init(modelName: String)
    func saveChanges() throws
}

enum CoreDataStackError: Error {
    case noChangesToSave
}
