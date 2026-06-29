//
//  ColumnGrid.swift
//  Adventurers
//
//  Created by Syd Polk on 6/28/26.
//  Copyright ©2026 Syd Polk. All rights reserved.
//

import SwiftUI

/// A grid whose column count snaps to one of `columnChoices` (largest-first) based on the
/// available width — rather than packing in whatever fits. For six items with
/// `[6, 3, 2, 1]` that yields 6×1, 3×2, 2×3, or 1×6, never an awkward 4 or 5 across.
struct ColumnGrid<Item: Identifiable, Content: View>: View {
    let items: [Item]
    var columnChoices: [Int] = [6, 3, 2, 1]
    var minCellWidth: CGFloat = 84
    var spacing: CGFloat = 8
    @ViewBuilder let content: (Item) -> Content

    @State private var width: CGFloat = 0

    private var columnCount: Int {
        guard width > 0 else { return columnChoices.first ?? 1 }
        return columnChoices.first { CGFloat($0) * minCellWidth <= width }
            ?? (columnChoices.last ?? 1)
    }

    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: columnCount),
            spacing: 12
        ) {
            ForEach(items) { content($0) }
        }
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width = $0 }
    }
}
