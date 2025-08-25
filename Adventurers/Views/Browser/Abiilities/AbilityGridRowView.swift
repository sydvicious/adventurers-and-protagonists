//
//  AbilityGridRow.swift
//  Adventurers
//
//  Created by Syd Polk on 1/28/24.
//  Copyright ©2024-2025 Syd Polk. All rights reserved.
//

import SwiftUI

struct AbilityGridRowView: View {
    private var name: String?
    private var baseScore: Int = 0
    private var modifierString: String = "-5"

    init(name: String, score: Int) {
        self.name = name
        self.baseScore = score
        self.modifierString = Ability.modifierString(value: baseScore)
    }

    var body: some View {
        GridRow {
            Text(name ?? "<no name>")
                .gridColumnAlignment(.leading)
                .bold()
                .frame(minWidth: 150, maxWidth: .infinity, alignment: .leading)
                .padding([.trailing], 5)
            Text("\(baseScore)")
                .gridColumnAlignment(.trailing)
                .frame(minWidth: 40)
                .padding([.trailing], 5)
                .font(.system(.body, design: .monospaced))
            Text("\(modifierString)")
                .gridColumnAlignment(.trailing)
                .font(.system(.body, design: .monospaced))
                .frame(minWidth: 40)
                .padding([.trailing], 5)
        }
        .padding([.all], 2)
    }
}

#Preview {
    Grid {
        AbilityGridRowView(name: "Strength", score: 18)
    }
}
