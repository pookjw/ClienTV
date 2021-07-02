//
//  FilterSetting.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 7/2/21.
//

import Foundation
import CoreData

@objc(FilterSetting)
final class FilterSetting: NSManagedObject {
    @NSManaged var text: String?
    @NSManaged var timestamp: Date?
}
