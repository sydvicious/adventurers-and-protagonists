//
//  AbilityEditScore.swift
//  Adventurers
//
//  Created by Syd Polk on 7/4/24.
//  Copyright ©2024 Syd Polk. All rights reserved.
//

import SwiftUI

struct AbilitiesChooserEditScoreRow: View {
    private var name: String?
    @Binding var baseScore: Int

    private var modifierString: String = ""

    @ScaledMetric(relativeTo: .body) var width: CGFloat = 40

    static let monospaced = Font.system(.body, design: .monospaced)
    static let formatter: Formatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.minimumIntegerDigits = 1
        formatter.maximumIntegerDigits = 2
        return formatter
    }()

    init(name: String, score: Binding<Int>) {
        self.name = name
        self._baseScore = score
        self.modifierString = Ability.modifierString(value: score.wrappedValue)
    }

    var body: some View {
        GridRow {
            Text(name ?? "<no name>")
                .gridColumnAlignment(.leading)
                .bold()
                .padding([.trailing], 5)
            TextField("10", 
                      value: $baseScore,
                      formatter: Self.formatter)
                .frame(width: width, alignment: .trailing)
                .gridColumnAlignment(.trailing)
                .font(Self.monospaced)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.trailing)
                .padding([.trailing], 5)
            Text("\(modifierString)")
                .gridColumnAlignment(.trailing)
                .padding([.trailing], 5)
                .font(Self.monospaced)
        }.padding([.leading, .trailing], 2)
    }
}

#Preview {
    @Previewable @State var score: Int = 18
    Grid {
        AbilitiesChooserEditScoreRow(name: "Strength", score: $score)
    }
}
