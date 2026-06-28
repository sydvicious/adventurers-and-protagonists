//
//  IntFieldRow.swift
//  Adventurers
//
//  Created by Syd Polk on 6/28/26.
//  Copyright ©2026 Syd Polk. All rights reserved.
//

import SwiftUI

/// A labeled integer field with a stepper, used throughout the transcribe editor.
/// Reflows for Dynamic Type: the label, the typed value, and the stepper sit in
/// a single row that the system lays out, and the field uses a system text style.
struct IntFieldRow: View {
    let label: String
    @Binding var value: Int
    var range: ClosedRange<Int> = -99...99

    var body: some View {
        LabeledContent(label) {
            HStack(spacing: 8) {
                TextField(label, value: $value, format: .number)
                    .multilineTextAlignment(.trailing)
                    .monospacedDigit()
                    .frame(minWidth: 56)
                    .labelsHidden()
                    #if os(iOS)
                    .keyboardType(.numbersAndPunctuation)
                    #endif
                Stepper(label, value: $value, in: range)
                    .labelsHidden()
            }
        }
    }
}
