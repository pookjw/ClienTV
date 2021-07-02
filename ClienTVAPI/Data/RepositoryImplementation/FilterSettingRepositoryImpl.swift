//
//  FilterSettingRepositoryImpl.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 7/2/21.
//

import Foundation
import CoreData
import Combine

final class FilterSettingRepositoryImpl: FilterSettingRepository {
    private let coreDataStack: CoreDataStack = CloudDataStackImpl(modelName: "FilterSetting")
    
    func saveChanges() throws {
        try coreDataStack.saveChanges()
    }
    
    func getFilterSettings() throws -> [FilterSetting] {
        let mainContext: NSManagedObjectContext = coreDataStack.mainContext
        let fetchRequest: NSFetchRequest<FilterSetting> = FilterSetting._fetchRequest()
        let sortDescriptor: NSSortDescriptor = .init(key: #keyPath(FilterSetting.timestamp), ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let results: [FilterSetting] = try mainContext.fetch(fetchRequest)
        return results
    }
    
    func getFilterSetting(text: String) throws -> FilterSetting? {
        let mainContext: NSManagedObjectContext = coreDataStack.mainContext
        let fetchRequest: NSFetchRequest<FilterSetting> = FilterSetting._fetchRequest()
        let predicate: NSPredicate = .init(format: "%K = %@", #keyPath(FilterSetting.text), text)
        fetchRequest.predicate = predicate
        let results: [FilterSetting] = try mainContext.fetch(fetchRequest)
        
        return results.first
    }
    
    func observeFilterSetting() -> AnyPublisher<[FilterSetting], Never> {
        return NotificationCenter
            .default
            .publisher(for: .NSManagedObjectContextDidSave, object: coreDataStack.mainContext)
            .tryMap { [weak self] _ -> [FilterSetting]? in
                guard let self = self else {
                    return nil
                }
                
                return try self.getFilterSettings()
            }
            .replaceError(with: nil)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    func removeFilterSetting(toRemove filterSetting: FilterSetting) throws {
        coreDataStack.mainContext.delete(filterSetting)
    }
    
    func createFilterSetting() throws -> FilterSetting {
        let filterSetting: FilterSetting = .init(context: coreDataStack.mainContext)
        return filterSetting
    }
}
