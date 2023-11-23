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
    var abilities = [ProtoAbility]()
    let campaignType: CampaignTypes

    public init(from adventurer: Adventurer? = nil, campaignType: CampaignTypes = .standardFantasy) {
        self.name = adventurer?.name ?? ""
        self.campaignType = campaignType
    }

    private static func baseAbilities() -> [ProtoAbility] {
        var abilities = [ProtoAbility]()
        abilities.append(ProtoAbility(label: AbilityLabels.str.rawValue))
        abilities.append(ProtoAbility(label: AbilityLabels.con.rawValue))
        abilities.append(ProtoAbility(label: AbilityLabels.dex.rawValue))
        abilities.append(ProtoAbility(label: AbilityLabels.int.rawValue))
        abilities.append(ProtoAbility(label: AbilityLabels.wis.rawValue))
        abilities.append(ProtoAbility(label: AbilityLabels.cha.rawValue))
        return abilities
    }

    public func abilitiesReady(usePoints: Bool) -> Bool {
        var points = 0
        for ability in abilities {
            guard let score = ability.score else {
                return false
            }
            points += score
        }
        if usePoints && points > self.campaignType.rawValue {
            return false
        }
        return true
    }

    public func isReady(usePoints: Bool) -> Bool {

        // check the name
        if name.isTrimmedStringEmpty() {
            return false
        }

        if !abilitiesReady(usePoints: usePoints) {
            return false
        }
        return true
    }

    public func adventurerFrom(usePoints: Bool) -> Adventurer? {
        guard isReady(usePoints: usePoints) else {
            return nil
        }
        let abilites: [Ability] = self.abilities.map { Ability(label: $0.label, score: $0.score!) }
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
        return protoData
    }

}

class ProtoAbility {
    var label: String;
    var score: Int? = nil

    init(label: String) {
        self.label = label
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
