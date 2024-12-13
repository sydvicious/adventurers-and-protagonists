//
//  ViewHeightModifier.swift
//  Adventurers
//
//  Created by Syd Polk on 11/23/23.
//

import SwiftUI

@MainActor
struct HeightPreferenceKey: @preconcurrency PreferenceKey {
    @MainActor static var defaultValue: CGFloat?

    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        guard let nextValue = nextValue() else { return }
        value = nextValue
    }
}

@MainActor
private struct ReadHeightModifier: ViewModifier {
    private var sizeView: some View {
        GeometryReader { geometry in
            Color.clear.preference(key: HeightPreferenceKey.self, value: geometry.size.height)
        }
    }

    func body(content: Content) -> some View {
        content.background(sizeView)
    }
}

@MainActor
extension View {
    func readHeight() -> some View {
        self
            .modifier(ReadHeightModifier())
    }
}

