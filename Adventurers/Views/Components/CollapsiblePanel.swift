//
//  CollapsiblePanel.swift
//  Adventurers
//
//  Created by Syd Polk on 6/28/26.
//  Copyright ©2026 Syd Polk. All rights reserved.
//

import SwiftUI

/// A titled, collapsible panel shared by the character sheet and the combat HUD so both
/// read the same way: the title sits at the top of the panel with a disclosure triangle,
/// and the content expands/collapses beneath it.
struct CollapsiblePanel<Content: View>: View {
    private let title: String
    @State private var isExpanded: Bool
    private let content: Content

    init(_ title: String,
         initiallyExpanded: Bool = true,
         @ViewBuilder content: () -> Content) {
        self.title = title
        _isExpanded = State(initialValue: initiallyExpanded)
        self.content = content()
    }

    var body: some View {
        GroupBox {
            DisclosureGroup(isExpanded: $isExpanded) {
                content
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
            } label: {
                Text(title)
                    .font(.headline)
            }
        }
    }
}
