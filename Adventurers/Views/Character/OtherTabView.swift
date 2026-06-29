//
//  OtherTabView.swift
//  Adventurers
//
//  Created by Syd Polk on 6/28/26.
//  Copyright ©2026 Syd Polk. All rights reserved.
//

import SwiftUI

/// Placeholder for the character surfaces still to come (Biography, Equipment, Skills,
/// Spells, Journal — vision §5c "More").
struct OtherTabView: View {
    var body: some View {
        ContentUnavailableView(
            "More Coming Soon",
            systemImage: "ellipsis.circle",
            description: Text("Biography, equipment, skills, spells, and journal will live here."))
        .navigationTitle("Other")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}
