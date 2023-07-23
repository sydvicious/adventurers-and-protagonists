//
//  CaseInsensitiveComparitor.swift
//  Adventurers
//
//  Created by Syd Polk on 7/23/23.
//

import Foundation

struct CaseInsensitiveComparitor: SortComparator {
    typealias Compared = String
    
    var order: SortOrder = .forward

    func compare(_ lhs: Compared, _ rhs: Compared) -> ComparisonResult {
        return lhs.caseInsensitiveCompare(rhs)
    }
}
