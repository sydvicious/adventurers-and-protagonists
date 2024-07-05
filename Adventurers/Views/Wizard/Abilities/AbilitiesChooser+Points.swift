//
//  AbilitiesChooser+Points.swift
//  Adventurers
//
//  Created by Syd Polk on 6/22/24.
//

import SwiftUI

@MainActor
extension AbilitiesChooser {
    @ViewBuilder func Points() -> some View {
        Text("Use points to build your character")
    }
}

#Preview {
    @State var wizardShowing = true
    @State var isReady = false
    @State var proto = Proto.dummyProtoData()

    return AbilitiesChooser(isShowing: $wizardShowing, 
                            isReady: $isReady,
                            proto: $proto,
                            chooserType: .points)
}
