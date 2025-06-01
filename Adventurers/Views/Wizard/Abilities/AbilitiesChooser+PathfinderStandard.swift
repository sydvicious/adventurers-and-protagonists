//
//  AbilitiesChooser+Roll4d6Best3.swift
//  Adventurers
//
//  Created by Syd Polk on 6/22/24.
//

import SwiftUI

@MainActor
struct PathfinderStandard: View {
    @EnvironmentObject var viewModel: AbilitiesChooserViewModel
    
    @State var rolls: [RollData] = []
    @State var isDragging: Bool = false
    @State var draggingIndex: RollData? = nil
    @State var hoverItem: RollData? = nil
    @State var dragOffset: CGSize = .zero
    @State private var startLocation: CGPoint = .zero
    @State private var frames: [RollData: CGRect] = [:]
    
    init() {
        self.rolls = newRolls()
    }
    
    var body: some View {
        VStack {
            Text("Use the handles on the right to drag the scores to place the scores with the abilities you want.")
                .padding(10)
            ZStack {
                Grid {
                    ForEach(rolls, id: \.self) { roll in
                        GridDiceRollsRow(rollData: roll)
                            .background(GeometryReader { geo in
                                Color.clear.preference(
                                    key: FramePreferenceKey.self,
                                    value: [roll: geo.frame(in: .global)]
                                )
                            })
                            .opacity(draggingIndex == roll ? 0.3 : 1)
                            .overlay(
                                hoverItem == roll
                                ? RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.accentColor, lineWidth: 3) : nil)
                            .animation(.spring(), value: rolls)
                    }
                }
                .onPreferenceChange(FramePreferenceKey.self) { @MainActor value in
                    frames = value
                }
                
                if isDragging, let draggingIndex {
                    DiceView(rollData: draggingIndex)
                        .position(x: startLocation.x + dragOffset.width, y: startLocation.y + dragOffset.height)                        .zIndex(1)
                        .allowsHitTesting(false)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0), value: dragOffset)
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
        viewModel.abilities = RollData.abilities(from: rolls)
        viewModel.checkDoneDisabled()
    }
    
    func diceDragGesture(_ roll: RollData) -> some Gesture {
        DragGesture()
            .onChanged { value in
                if isDragging {
                    let toDrag = draggingIndex ?? roll
                    dragOffset = value.translation
                    
                    if let hovered = getItemAt(point: value.location), hovered != toDrag {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0)) {
                            swap(toDrag, hovered)
                        }
                    }
                    draggingIndex = nil
                }
            }
            .onEnded { value in
                if let draggingIndex = draggingIndex, let hoverItem = hoverItem {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0)) {
                        swap(draggingIndex, hoverItem)
                    }
                }
                // Reset state
                draggingIndex = nil
                hoverItem = nil
                isDragging = false
                dragOffset = .zero

            }
    }

    @ViewBuilder func GridDiceRollsRow(rollData: RollData) -> some View {
        GridRow {
            Text("\(rollData.label.rawValue)")
                .multilineTextAlignment(.leading)
                .gridColumnAlignment(.leading)
            Text("\(rollData.value)").fontWeight(.bold)
                .multilineTextAlignment(.trailing)
                .gridColumnAlignment(.trailing)
            DiceView(rollData: rollData)
                .padding(2)
            Button(action: {
                startDragging(rollData)
            }, label: {
                Image(systemName: "line.3.horizontal")
                    .foregroundColor(.gray)
            })
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.1)
                    .onEnded { _ in
                        startDragging(rollData)
                    }
            )
            .gesture(diceDragGesture(rollData))
        }
        .padding([.all], 2)
    }
    
    private func startDragging(_ roll: RollData) {
        draggingIndex = roll
        hoverItem = roll
        isDragging = true
        dragOffset = .zero
    }
    
    private func swap(_ from: RollData, _ to: RollData) {
        let fromIndex = rolls.firstIndex(of: from)
        let toIndex = rolls.firstIndex(of: to)
        if let fromIndex, let toIndex {
            let temp = rolls[fromIndex]
            rolls[fromIndex] = rolls[toIndex]
            rolls[toIndex] = temp
        }
    }
    
    private func findFrame(for roll: RollData) -> CGRect? {
        return frames[roll]
    }

    private func getItemAt(point: CGPoint) -> RollData? {
        return rolls.first(where: { frames[$0]?.contains(point) ?? false })
    }
}

public struct RollData: Equatable, Hashable {
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
    
    static func abilities(from rolls: [RollData]) -> [ProtoAbility] {
        var protoAbilites: [ProtoAbility] = []
        for item in rolls {
            let protoAbility = ProtoAbility(label: item.label.rawValue, score: item.value)
            protoAbilites.append(protoAbility)
        }
        return protoAbilites
    }
}

struct DiceView: View {
    @State var rollData: RollData
    
    var body: some View {
        HStack {
            ForEach(0..<rollData.rolls.count, id: \.self) { index in
                if let imageName = Dice.d6ImageName(rollData.rolls[index]) {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(1, contentMode: .fit) // Maintains a square aspect ratio
                        .frame(maxWidth: 35)
                        .opacity(index == rollData.minimumIndex ? 0.5 : 1.0)
                }
            }
        }
    }
}

@MainActor
struct FramePreferenceKey: @preconcurrency PreferenceKey {
    static var defaultValue: [RollData: CGRect] = [:]

    static func reduce(value: inout [RollData: CGRect], nextValue: () -> [RollData: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
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

#Preview("Dice View") {
    @Previewable @State var rollData: RollData = .init(label: .str)

    DiceView(rollData: rollData)
}
