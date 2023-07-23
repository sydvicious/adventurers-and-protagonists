//
//  Proto.swift
//  Adventurers
//
//  Created by Syd Polk on 7/23/23.
//

import Foundation

class Proto {
    var name = ""
    
    static func dummyProtoData() -> Proto {
        let protoData = Proto()
        protoData.name = ""
        return protoData
    }
    
    func isReady() -> Bool {
        let proposedName = name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if "" == proposedName {
            return false
        }
        return true
    }

    func adventurerFrom() -> Adventurer? {
        guard isReady() else {
            return nil
        }
        return Adventurer(name: self.name)
    }
}
