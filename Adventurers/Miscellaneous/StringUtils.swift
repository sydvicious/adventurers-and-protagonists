//
//  StringUtils.swift
//  Adventurers
//
//  Created by Syd Polk on 11/23/23.
//

import Foundation

extension StringProtocol {
    public func isTrimmedStringEmpty() -> Bool {
        let trimmedName = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return !trimmedName.isEmpty
    }
}
