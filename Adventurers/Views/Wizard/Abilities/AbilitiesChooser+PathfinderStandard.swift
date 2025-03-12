//
//  AbilitiesChooser+Roll4d6Best3.swift
//  Adventurers
//
//  Created by Syd Polk on 6/22/24.
//

import SwiftUI

@MainActor
extension AbilitiesChooser {
    
    @ViewBuilder func PathfinderStandard() -> some View {
        var rolls: [RollData] = newRolls()

        VStack {
            Text("Use the handles on the right to drag the scores to place the scores with the abilities you want.")
                .padding(.bottom, 10)

            let columns = [
                GridItem(.fixed(50), alignment: .leading),
                GridItem(.flexible(), alignment: .trailing),
                GridItem(.flexible(), spacing: 20, alignment: .leading),
                GridItem(.flexible(), alignment: .leading)
            ]
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(rolls, id: \.self) { roll in
                    Text("\(roll.label.rawValue)")
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(minWidth: 100, maxWidth: .infinity, alignment: .leading)
                        .border(Color.black, width: 2)
                    Text("\(roll.value)").fontWeight(.bold)
                    HStack {
                        ForEach(0..<roll.rolls.count, id: \.self) { index in
                            if let imageName = Dice.d6ImageName(roll.rolls[index]) {
                                Image(imageName)
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fit)
                                    .frame(minWidth: 20, minHeight: 10)
                                    .opacity(index == roll.minimumIndex ? 0.5 : 1.0)
                            }
                        }
                    }
                    Image(systemName: "line.3.horizontal")
                        .foregroundColor(.gray)
                }
            }
            Button(action: {
                rolls = newRolls()
                setRolls(rolls)
            }, label: {
                Text("Reroll")
            })
            .padding(20)
            Spacer()
        }
        .padding(20)
        .onAppear {
            rolls = newRolls()
            setRolls(rolls)
        }
    }
                   
    func newRolls() -> [RollData] {
        var newRolls: [RollData] = []
        
        for label in AbilityLabels.allCases {
            newRolls.append(RollData(label: label))
        }
        return newRolls
    }
    
    func setRolls(_ rolls: [RollData]) {
        viewModel.abilities = Proto.abilities(from: rolls)
        self.checkDoneDisabled()
    }
}

struct RollData: Equatable, Hashable {
    let label: AbilityLabels
    let rolls: [Int]
    let value: Int
    let minimumIndex: Int
    
    init(label: AbilityLabels) {
        self.label = label
        self.rolls = Dice.rolls(number: 4, dieType: 6)
        self.value = Dice.value(from: rolls, best: 3)
        self.minimumIndex = Dice.miminumIndex(from: rolls)
    }
}

extension Proto {
    static public func abilities(from rolls: [RollData]) -> [ProtoAbility] {
        var protoAbilites: [ProtoAbility] = []
        for item in rolls {
            let protoAbility = ProtoAbility(label: item.label.rawValue, score: item.value)
            protoAbilites.append(protoAbility)
        }
        return protoAbilites
    }
}

#Preview {
    @Previewable @State var wizardShowing = true
    @Previewable @State var isReady = false
    @Previewable @State var proto = Proto.dummyProtoData()

    return AbilitiesChooser(isShowing: $wizardShowing, 
                            isReady: $isReady,
                            proto: $proto,
                            chooserType: .roll4d6Best3)
}

