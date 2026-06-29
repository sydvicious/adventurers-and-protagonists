//
//  HitPointsPanel.swift
//  Adventurers
//
//  Created by Syd Polk on 6/28/26.
//  Copyright ©2026 Syd Polk. All rights reserved.
//

import SwiftUI

/// The hit-point control, shared by the Overview and Combat tabs so they're identical:
/// a single "[−] damage / max [+]" line (damage editable, same size as max), a current-HP
/// readout that turns red at 0 or below, a bar, and a temp-HP stepper.
struct HitPointsPanel: View {
    @Bindable var adventurer: Adventurer

    var body: some View {
        CollapsiblePanel("Hit Points") {
            VStack(spacing: 10) {
                HStack(spacing: 12) {
                    stepButton(systemImage: "minus", label: "Heal") {
                        adventurer.damageTaken -= 1
                    }
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        TextField("0", value: $adventurer.damageTaken, format: .number)
                            .multilineTextAlignment(.trailing)
                            .fixedSize()
                            #if os(iOS)
                            .keyboardType(.numberPad)
                            #endif
                        Text("/").foregroundStyle(.secondary)
                        Text("\(adventurer.maxHP)")
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .frame(maxWidth: .infinity)
                    stepButton(systemImage: "plus", label: "Damage") {
                        adventurer.damageTaken += 1
                    }
                }
                Text("Damage / Max HP   ·   HP \(adventurer.currentHP)")
                    .font(.caption)
                    .monospacedDigit()
                    .foregroundStyle(adventurer.currentHP <= 0 ? Color.red : Color.secondary)
                ProgressView(value: hpFraction)
                    .tint(.green)
                Stepper("Temp HP: \(adventurer.tempHP)", value: $adventurer.tempHP, in: 0...999)
                    .font(.footnote)
            }
        }
    }

    private var hpFraction: Double {
        guard adventurer.maxHP > 0 else { return 0 }
        return min(1, max(0, Double(adventurer.currentHP) / Double(adventurer.maxHP)))
    }

    private func stepButton(systemImage: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.title2)
                .frame(width: 48, height: 48)
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.circle)
        .accessibilityLabel(label)
    }
}
