//
//  AbilitiesChooser+Intro.swift
//  Adventurers
//
//  Created by Syd Polk on 6/22/24.
//

import SwiftUI

@MainActor
extension AbilitiesChooser {
    @ViewBuilder func Intro() -> some View {
        VStack {
            Button(action: {
                viewModel.abilities = Proto.baseAbilities()
                viewModel.chooserType = .transcribe
            }, label: {
                Text("Transcribe existing character")
            })
            .padding()

            Button(action: {
                viewModel.chooserType = .roll4d6Best3
            }, label: {
                Text("Roll 4d6; take best three")
            })
            .padding()

            Button(action: {
                viewModel.chooserType = .points
            }, label: {
                Text("Use the point-based system")
            })
            .padding()
        }
    }
}

#Preview {
    @State var wizardShowing = true
    @State var isReady = false
    @State var proto = Proto()

    proto.name = "Pendecar"

    return AbilitiesChooser(isShowing: $wizardShowing, 
                            isReady: $isReady,
                            proto: $proto,
                            chooserType: .intro)
}
