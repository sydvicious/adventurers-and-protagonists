//
//  RollResultView.swift
//  Adventurers
//
//  Created by Syd Polk on 6/28/26.
//  Copyright ©2026 Syd Polk. All rights reserved.
//

import SwiftUI

/// Presents a roll result as a sheet: each line's total in bold (red when it's a critical
/// threat) with the composition beneath it.
struct RollResultView: View {
    let result: RollResult
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(Array(result.lines.enumerated()), id: \.offset) { _, line in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(alignment: .firstTextBaseline) {
                                if !line.label.isEmpty {
                                    Text(line.label)
                                        .font(.headline)
                                }
                                Spacer()
                                Text(line.total)
                                    .font(.system(.title, design: .rounded).weight(.bold))
                                    .monospacedDigit()
                                    .foregroundStyle(line.highlighted ? Color.red : Color.primary)
                            }
                            Text(line.breakdown)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle(result.title)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
