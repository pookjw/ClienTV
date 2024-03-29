//
//  FilterSettingListRepositoryImpl.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 7/2/21.
//

import Foundation
import CoreData
import Combine

final class FilterSettingListRepositoryImpl: FilterSettingListRepository {
    private let coreDataStack: CoreDataStack = CloudDataStackImpl(modelName: "FilterSetting")
    
    func saveChanges() throws {
        try coreDataStack.saveChanges()
    }
    
    func getFilterSettingList() throws -> [FilterSetting] {
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
    
    func getCountOfFilterSetting(text: String) throws -> Int {
        let mainContext: NSManagedObjectContext = coreDataStack.mainContext
        let fetchRequest: NSFetchRequest<FilterSetting> = FilterSetting._fetchRequest()
        let predicate: NSPredicate = .init(format: "%K = %@", #keyPath(FilterSetting.text), text)
        fetchRequest.predicate = predicate
        let count: Int = try mainContext.count(for: fetchRequest)
        return count
    }
    
    func observeFilterSetting() -> AnyPublisher<[FilterSetting], Never> {
        return coreDataStack
            .changesPublisher
            .tryMap { [weak self] _ -> [FilterSetting]? in
                guard let self = self else {
                    return nil
                }
                
                return try self.getFilterSettingList()
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
