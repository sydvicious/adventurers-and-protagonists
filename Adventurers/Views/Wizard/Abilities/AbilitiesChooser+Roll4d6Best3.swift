//
//  AbilitiesChooser+Roll4d6Best3.swift
//  Adventurers
//
//  Created by Syd Polk on 6/22/24.
//

import SwiftUI

@MainActor
extension AbilitiesChooser {
    @ViewBuilder func Roll4d6Best3() -> some View {
        Text("For each ability roll 4d6 and choose best 3")
    }
}

#Preview {
    @State var wizardShowing = true
    @State var isReady = false
    @State var proto = Proto.dummyProtoData()

    return AbilitiesChooser(isShowing: $wizardShowing, 
                            isReady: $isReady,
                            proto: $proto,
                            chooserType: .roll4d6Best3)
}
