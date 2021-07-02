//
//  ConditionSetting.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 7/2/21.
//

import Foundation
import CoreData

@objc(ConditionSetting)
final class ConditionSetting: NSManagedObject {
    @NSManaged var didRead: Bool
}
