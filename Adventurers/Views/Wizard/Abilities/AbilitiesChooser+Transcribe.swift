//
//  AbilitiesChooser+Transcribe.swift
//  Adventurers
//
//  Created by Syd Polk on 6/22/24.
//

import SwiftUI

@MainActor
extension AbilitiesChooser {
    @ViewBuilder func Transcribe() -> some View {
        Grid {
            ForEach(0..<6) { index in
                AbilitiesChooserEditScoreRow(name: self.viewModel.abilities[index].label, score: $viewModel.abilities[index].score)
            }
        }
        .onAppear {
            self.viewModel.abilities = Proto.baseAbilities()
            self.checkDoneDisabled()
        }
    }
}

#Preview {
    @Previewable @State var wizardShowing = true
    @Previewable @State var isReady = false
    @Previewable @State var proto = Proto()

    proto.abilities = Proto.baseAbilities()

    return AbilitiesChooser(isShowing: $wizardShowing, 
                            isReady: $isReady, 
                            proto: $proto,
                            chooserType: .transcribe)
}
