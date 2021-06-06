//
//  NSDiffableDataSourceSnapshot+Item.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/4/21.
//

import UIKit

extension NSDiffableDataSourceSnapshot {
    func getHeaderItem(from indexPath: IndexPath) -> SectionIdentifierType? {
        guard sectionIdentifiers.count > indexPath.section else {
            return nil
        }
        return sectionIdentifiers[indexPath.section]
    }
    
    func getCellItem(from indexPath: IndexPath) -> ItemIdentifierType? {
        guard let headerItem: SectionIdentifierType = getHeaderItem(from: indexPath) else {
            return nil
        }
        
        let itemIdentifiers: [ItemIdentifierType] = itemIdentifiers(inSection: headerItem)
        
        guard itemIdentifiers.count > indexPath.row else {
            return nil
        }
        
        return itemIdentifiers[indexPath.row]
    }
}
