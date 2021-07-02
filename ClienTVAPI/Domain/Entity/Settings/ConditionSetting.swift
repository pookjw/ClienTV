//
//  ConditionSetting.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 7/2/21.
//

import Foundation
import CoreData

@objc(ConditionSetting)
public final class ConditionSetting: NSManagedObject {
    @NSManaged public var didRead: Bool
}
