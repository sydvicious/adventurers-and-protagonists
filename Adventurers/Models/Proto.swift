//
//  Proto.swift
//  Adventurers
//
//  Created by Syd Polk on 7/23/23.
//

import Foundation

@Observable class Proto : Identifiable, Equatable {
    static func == (lhs: Proto, rhs: Proto) -> Bool {
        return lhs.name == rhs.name
    }

    var name : String
    var abilities : [ProtoAbility]
    let campaignType: CampaignTypes

    public init(from adventurer: Adventurer? = nil, campaignType: CampaignTypes = .standardFantasy) {
        self.campaignType = campaignType
        if let adventurer {
            self.name = adventurer.name
            self.abilities = Proto.protoAbilities(from: adventurer)
        } else {
            self.name = ""
            self.abilities = []
        }
    }

    public static func baseAbilities() -> [ProtoAbility] {
        var abilities = [ProtoAbility]()
        abilities.append(ProtoAbility(label: AbilityLabels.str.rawValue, score: 10))
        abilities.append(ProtoAbility(label: AbilityLabels.con.rawValue, score: 10))
        abilities.append(ProtoAbility(label: AbilityLabels.dex.rawValue, score: 10))
        abilities.append(ProtoAbility(label: AbilityLabels.int.rawValue, score: 10))
        abilities.append(ProtoAbility(label: AbilityLabels.wis.rawValue, score: 10))
        abilities.append(ProtoAbility(label: AbilityLabels.cha.rawValue, score: 10))
        return abilities
    }


    public func isReady(usePoints: Bool) -> Bool {

        // check the name
        if name.isTrimmedStringEmpty() {
            return false
        }

        if !Self.abilitiesReady(abilities: self.abilities, usePoints: usePoints, campaignType: self.campaignType) {
            return false
        }
        return true
    }

    public func adventurerFrom(usePoints: Bool) -> Adventurer? {
        guard isReady(usePoints: usePoints) else {
            return nil
        }
        let abilites: [Ability] = self.abilities.map { Ability(label: $0.label, score: $0.score) }
        return Adventurer(name: self.name, abilities: abilites)
    }

    static func protoFromProto(oldProto: Proto) -> Proto {
        let proto = Proto(campaignType: oldProto.campaignType)
        proto.name = oldProto.name
        proto.abilities = oldProto.abilities
        return proto
    }

    static func dummyProtoData() -> Proto {
        let protoData = Proto(campaignType: .epicFantasy)
        protoData.name = ""
        protoData.abilities = Self.baseAbilities()
        return protoData
    }

    static func protoAbilities(from adventurer: Adventurer) -> [ProtoAbility] {
        let protoAbilities: [ProtoAbility] = adventurer.abilities.map { ProtoAbility(label: $0.label, score: $0.score)}
        return protoAbilities
    }

    static public func abilitiesReady(abilities: [ProtoAbility], 
                                      usePoints: Bool = false,
                                      campaignType: CampaignTypes = .epicFantasy) -> Bool {
        guard abilities.count == 6  else {
            return false
        }
        if usePoints {
            var points = 0
            for ability in abilities {
                let score = ability.score
                points += score
            }
            if points > campaignType.rawValue {
                return false
            }
        }
        return true
    }

    static public func abilities(from protoAbilities: [ProtoAbility]) -> [Ability] {
        let abilities: [Ability] = protoAbilities.map { Ability(label: $0.label, score: $0.score) }
        return abilities
    }
}

struct ProtoAbility: Identifiable {
    var id: String

    var label: String;
    var score: Int;

    init(label: String, score: Int) {
        self.label = label
        self.score = score
        self.id = label
    }

    func ability() -> Ability {
        let ability = Ability(label: self.label, score: self.score)
        return ability
    }
}


extension ProtoAbility {
    func abiityCost() -> Int? {
        switch(self.score) {
        case 7:
            return -4
        case 8:
            return -2
        case 9:
            return -1
        case 10:
            return 0
        case 11:
            return 1
        case 12:
            return 2
        case 13:
            return 3
        case 14:
            return 5
        case 15:
            return 7
        case 16:
            return 10
        case 17:
            return 13
        case 18:
            return 17
        default:
            return nil
        }
    }
}

enum CampaignTypes: Int {
    case lowFantasy = 10
    case standardFantasy = 15
    case highFantasy = 20
    case epicFantasy = 25
}
