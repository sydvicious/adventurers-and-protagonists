//
//  Item.swift
//  Adventurers
//
//  Created by Syd Polk on 7/4/23.
//

import Foundation
import SwiftData

@Model
final class Adventurer  {
    var timestamp: Date
    var uid: UUID
    var name: String
    var abilities: [Ability]
    @Transient var abilitiesMap: [AbilityLabels:Ability] = [:]

    init(name: String, abilities: [Ability]) {
        self.timestamp = Date()
        self.uid = UUID()
        self.name = name
        self.abilities = abilities
    }

    func updateFromProto(_ proto: Proto) {
        updateName(proto)
        updateAbilities(proto)
    }

    private func updateName(_ proto: Proto) {
        if self.name != proto.name {
            self.name = proto.name
        }
    }

    private func updateAbilities (_ proto: Proto) {
        struct Scores {
            var stored: Int?
            var proto: Int?
        }
        var scores: [String: Scores] = [:]
        var newAbilities: [Ability] = []

        AbilityLabels.allCases.forEach {
            let score = Scores(stored: nil, proto: nil)
            scores[$0.rawValue] = score
        }

        proto.abilities.forEach {
            let label = $0.label
            let protoScore = $0.score
            var comparedScore = scores[label]
            comparedScore?.proto = protoScore
            scores[label] = comparedScore
        }

        self.abilities.forEach {
            let label = $0.label
            let storedScore = $0.score
            var comparedScore = scores[label]
            comparedScore?.stored = storedScore
            scores[label] = comparedScore
        }

        var writeAbilities = false
        scores.forEach { label, comparedScore in
            if let protoScore = comparedScore.proto {
                if let _ = comparedScore.stored {
                    writeAbilities = true
                }
                newAbilities.append(Ability(label: label, score: protoScore))
            }
        }

        if writeAbilities {
            self.abilities = newAbilities
        }
    }

    #if DEBUG
    static let preview: Adventurer = {
        var abilities = [Ability]()
        abilities.append(Ability(label: AbilityLabels.str.rawValue, score: 17))
        abilities.append(Ability(label: AbilityLabels.dex.rawValue, score: 15))
        abilities.append(Ability(label: AbilityLabels.con.rawValue, score: 12))
        abilities.append(Ability(label: AbilityLabels.int.rawValue, score: 9))
        abilities.append(Ability(label: AbilityLabels.wis.rawValue, score: 7))
        abilities.append(Ability(label: AbilityLabels.cha.rawValue, score: 21))
        return Adventurer(name: "Pendecar", abilities: abilities)
    }()
    #endif
}
