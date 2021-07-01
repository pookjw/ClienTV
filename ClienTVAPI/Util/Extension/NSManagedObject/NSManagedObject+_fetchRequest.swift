//
//  NSManagedObject+_fetchRequest.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 7/1/21.
//

import Foundation
import CoreData

extension NSManagedObject {
    static func _fetchRequest<T: NSManagedObject>() -> NSFetchRequest<T> {
        let fetchRequest: NSFetchRequest<T> = .init(entityName: className)
        return fetchRequest
    }
}
