//
//  StringUtils.swift
//  Adventurers
//
//  Created by Syd Polk on 11/23/23.
//  Copyright ©2023 Syd Polk. All rights reserved.
//

import Foundation

extension StringProtocol {
    public func isTrimmedStringEmpty() -> Bool {
        let trimmedName = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return trimmedName.isEmpty
    }
}
