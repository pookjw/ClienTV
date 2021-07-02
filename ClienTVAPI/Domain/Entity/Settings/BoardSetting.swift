//
//  BoardSetting.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 7/1/21.
//

import Foundation
import CoreData

@objc(BoardSetting)
final class BoardSetting: NSManagedObject {
    @NSManaged public var isEnabled: Bool
}
