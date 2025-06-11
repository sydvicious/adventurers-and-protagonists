//
//  AbilitiesChooser.swift
//  Adventurers
//
//  Created by Syd Polk on 6/21/24.
//

import SwiftUI

struct AbilitiesChooser: View {
    @Binding var isShowing: Bool
    @Binding var isReady: Bool
    @Binding var proto: Proto

    @ObservedObject var viewModel: AbilitiesChooserViewModel

    @State var doneDisabled: Bool

        init(isShowing: Binding<Bool>,
             isReady: Binding<Bool>,
             proto: Binding<Proto>,
             chooserType: AbilityChooserTypes = .intro) {
        self._isShowing = isShowing
        self._isReady = isReady
        self._proto = proto
        self.viewModel = AbilitiesChooserViewModel(chooserType: chooserType, abilities: proto.wrappedValue.abilities)
        self.doneDisabled = true
    }


    var body: some View {
        VStack {
            switch viewModel.chooserType {
            case .intro:
                Intro()
            case .transcribe:
                Transcribe()
            case .roll4d6Best3:
                PathfinderStandard()
                    .frame(maxHeight: .infinity)
            case .points:
                Points().disabled(true)
            }
        }
        .frame(maxHeight: .infinity)
        .navigationTitle("Set your adventurer's abilities")
        HStack {
            Button("Cancel", action: cancel)
            Button("Done", action: done)
                .disabled(doneDisabled)
        }
    }

    func checkDoneDisabled() {
        self.doneDisabled = !Proto.abilitiesReady(abilities: viewModel.abilities)
    }

    func cancel() {
        self.isShowing = false
    }

    func done() {
        self.proto.abilities = self.viewModel.abilities
        self.isReady = true
        self.isShowing = false
    }
}

#Preview {
    @Previewable @State var wizardShowing = true
    @Previewable @State var isReady = false
    @Previewable @State var proto = Proto()

    return AbilitiesChooser(isShowing: $wizardShowing,
                            isReady: $isReady,
                            proto: $proto,
                            chooserType: .intro)
}
